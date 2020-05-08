DEV_DOMAIN ?= dev.jkldsa.com
KEYBASE_USER ?= $(shell /usr/local/bin/keybase whoami)
CRTDIR ?= /keybase/private/$(KEYBASE_USER)/certbot/etc/live/$(DEV_DOMAIN)
CERTS = certs/fullchain.pem certs/privkey.pem

.PHONY: up down logs ps network clean

up: $(CERTS) network
	DEV_DOMAIN=$(DEV_DOMAIN) docker-compose up -d

down:
	docker-compose down
	rm -f $(CERTS)

logs:
	docker-compose logs -f

ps:
	docker-compose ps

network:
	docker network ls --format "{{.ID}} {{.Name}}" --filter "name=traefik"  | grep -q ' traefik$$' || docker network create --subnet=192.168.129.0/24 traefik

clean: down
	docker network inspect traefik --format='{{ range $$key, $$value := .Containers}}{{ $$key }} {{ end }}' | xargs docker stop | xargs docker rm
	docker network rm traefik

$(CERTS):
	cp $(CRTDIR)/$(notdir $@) certs/

certs:
	mkdir -p $@

