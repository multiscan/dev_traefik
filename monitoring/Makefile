TRAEFIK_DIR ?= $(dir $(CURDIR))
DEV_DOMAIN ?= dev.jkldsa.com

up: traefik
	DEV_DOMAIN=$(DEV_DOMAIN) docker-compose up -d

down:
	docker-compose down

ps:
	docker-compose ps

logs:
	docker-compose logs -f

tlogs:
	cd $(TRAEFIK_DIR) && make logs

traefik: $(TRAEFIK_DIR)
	@echo "Launching traefik  from $(TRAEFIK_DIR)"
	cd $(TRAEFIK_DIR) && make up

.PHONY: up down ps logs traefik