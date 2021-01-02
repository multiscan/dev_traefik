DEV_DOMAIN ?= dev.jkldsa.com
DOMAINS ?= $(DEV_DOMAIN)
KEYBASE_USER ?= $(shell /usr/local/bin/keybase whoami)
CRTDIR ?= /keybase/private/$(KEYBASE_USER)/certbot/etc/live/
CERTS = $(addprefix certs/,$(DOMAINS))
DYNCONFIGS = $(addprefix config/,$(addsuffix .yml,$(DOMAINS)))

all:
	@echo $(DYNCONFIGS)

.PHONY: up down logs ps network clean

up: $(CERTS) $(DYNCONFIGS) network
	DEV_DOMAIN=$(DEV_DOMAIN) docker-compose up -d

down:
	docker-compose down
	rm -rf $(CERTS)

logs:
	docker-compose logs -f

ps:
	docker-compose ps

network:
	docker network ls --format "{{.ID}} {{.Name}}" --filter "name=traefik"  | grep -q ' traefik$$' || docker network create --subnet=192.168.129.0/24 traefik

clean: down
	docker network inspect traefik --format='{{ range $$key, $$value := .Containers}}{{ $$key }} {{ end }}' | xargs docker stop | xargs docker rm
	docker network rm traefik

$(CERTS): certs
	cp -RL $(CRTDIR)/$(notdir $@) certs/

$(DYNCONFIGS): config
	@echo "tls:" > $@
	@echo "  certificates:" >> $@
	@echo "    - certFile: /certs/$$(basename $@ .yml)/fullchain.pem" >> $@
	@echo "      keyFile: /certs/$$(basename $@ .yml)/privkey.pem" >> $@

certs:
	mkdir -p $@

config:
	mkdir -p $@