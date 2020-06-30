TRAEFIK_DIR ?= $(dir $(CURDIR))
DEV_DOMAIN ?= dev.jkldsa.com

up: traefik
	DEV_DOMAIN=$(DEV_DOMAIN) docker-compose up -d --scale whoami1=2

down:
	docker-compose down

alldown:
	docker-compose down
	cd $(TRAEFIK_DIR) && make down

ps:
	docker-compose ps

logs:
	docker-compose logs -f

tlogs:
	cd $(TRAEFIK_DIR) && make logs

test:
	@curl -s 'https://whoami1.dev.jkldsa.com/'   | awk '/^Hostname:/{printf("whoami1: %s\n", $$2);}'
	@curl -s 'https://whoami2.dev.jkldsa.com/'   | awk '/^Hostname:/{printf("whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami2a.dev.jkldsa.com/'  | awk '/^Hostname:/{printf("whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami2b.dev.jkldsa.com/'  | awk '/^Hostname:/{printf("whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami3.dev.jkldsa.com/'   | awk '/^Hostname:/{printf("whoami3: %s\n", $$2);}'
	@curl -s 'https://whoami3.dev.jkldsa.com/a/' | awk '/^Hostname:/{printf("whoami4: %s\n", $$2);}'
	@curl -s 'https://whoami3.dev.jkldsa.com/b/' | awk '/^Hostname:/{printf("whoami5: %s\n", $$2);}'

traefik: $(TRAEFIK_DIR)
	@echo "Launching traefik  from $(TRAEFIK_DIR)"
	cd $(TRAEFIK_DIR) && make up

.PHONY: up down ps logs test traefik

