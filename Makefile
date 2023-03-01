-include .env
export
DEV_DOMAIN ?= dev.jkldsa.com
DOMAINS ?= epfl.cz dev.jkldsa.com
MKCERT_DOMAINS ?= local
# KEYBASE_USER ?= $(shell /usr/local/bin/keybase whoami)
# CRTDIR ?= /keybase/private/$(KEYBASE_USER)/certbot/etc/live/
CRTDIR ?= /keybase/team/epfl_idevfsd/certs
CERTS = $(addprefix certs/,$(DOMAINS)) $(addprefix certs/,$(MKCERT_DOMAINS))
DYNCONFIGS = $(addprefix config/,$(addsuffix .yml,$(DOMAINS)))

DOP ?= $(shell if which -s podman ; then echo "podman" ; else echo "docker" ; fi)

all:
	@echo "DOP: $(DOP)"	
	@echo "DOMAINS: $(DOMAINS)"
	@echo "MKCERT_DOMAINS: $(MKCERT_DOMAINS)"
	@echo "CRTDIR: $(CRTDIR)"
	@echo "DYNCONFIGS: $(DYNCONFIGS)"

.PHONY: up down logs ps network clean

up: $(CERTS) $(DYNCONFIGS) config/traefik.yml podman.yml docker-compose.yml network
ifeq ($(DOP),podman)
	podman play kube podman.yml
else
	docker-compose up -d
endif

down: podman.yml
ifeq ($(DOP),podman)
	podman play kube podman.yml --down
else
	docker-compose down
endif
	rm -rf $(CERTS)

logs:
ifeq ($(DOP),docker)
	docker-compose logs -f
endif

ps:
ifeq ($(DOP),podman)
	podman ps
else
	docker-compose ps
endif

console:
	docker-compose exec proxy /bin/sh

network:
ifeq ($(DOP),docker)
	docker network ls --format "{{.ID}} {{.Name}}" --filter "name=traefik"  | grep -q ' traefik$$' || docker network create --subnet=192.168.129.0/24 traefik
endif

clean: down
ifeq ($(DOP),docker)
	docker network inspect traefik --format='{{ range $$key, $$value := .Containers}}{{ $$key }} {{ end }}' | xargs docker stop | xargs docker rm
	docker network rm traefik
endif

$(CERTS): certs
	src=$(CRTDIR)/$(notdir $@);\
	if [ -d $$src ] ; then\
		echo "CERT: $@   $$src   -> certs/";\
		cp -RL $$src certs/;\
	else\
		mkdir $@;\
		mkcert --cert-file $@/fullchain.pem --key-file $@/privkey.pem "*.$(notdir $@)";\
	fi



$(DYNCONFIGS): config
	@echo "tls:" > $@
	@echo "  certificates:" >> $@
	@echo "    - certFile: /certs/$$(basename $@ .yml)/fullchain.pem" >> $@
	@echo "      keyFile: /certs/$$(basename $@ .yml)/privkey.pem" >> $@

certs:
	mkdir -p $@

config:
	mkdir -p $@

podman.yml: podman.yml.erb
	erb -T 2 $< >$@

docker-compose.yml: docker-compose.yml.erb
	erb -T 2 $< >$@

config/traefik.yml: service.yml.erb
	erb -T 2 $< >$@
