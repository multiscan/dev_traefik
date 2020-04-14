DEV_DOMAIN ?= dev.jkldsa.com
CRTDIR ?= /keybase/private/multiscan/certbot/etc/live/$(DEV_DOMAIN)
CERTS = certs/fullchain.pem certs/privkey.pem

.PHONY: up
up: $(CERTS) network
	DEV_DOMAIN=$(DEV_DOMAIN) docker-compose up -d

.PHONY: down
down:
	docker-compose down
	rm -f $(CERTS)

.PHONY: logs
logs:
	docker-compose logs -f

.PHONY: ps
ps:
	docker-compose ps

.PHONY: network
network:
	docker network ls --format "{{.ID}} {{.Name}}" --filter "name=traefik"  | grep -q ' traefik$$' || docker network create --subnet=192.168.129.0/24 traefik

.PHONY: clean
clean: down
	docker network inspect traefik --format='{{ range $$key, $$value := .Containers}}{{ $$key }} {{ end }}' | xargs docker stop | xargs docker rm
	docker network rm traefik

$(CERTS):
	cp $(CRTDIR)/$(notdir $@) certs/

certs:
	mkdir -p $@
