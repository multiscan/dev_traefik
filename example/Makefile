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
	@echo "TCP:"
	echo "ciao" | ncat --ssl tr.$(DEV_DOMAIN) 9090 # This shoudl print "CIAO"
	@echo "Standard https:"
	@curl -s 'https://whoami1.$(DEV_DOMAIN)/'   | awk '/^Hostname:/{printf("  whoami1: %s\n", $$2);}'
	@curl -s 'https://whoami2.$(DEV_DOMAIN)/'   | awk '/^Hostname:/{printf("  whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami2a.$(DEV_DOMAIN)/'  | awk '/^Hostname:/{printf("  whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami2b.$(DEV_DOMAIN)/'  | awk '/^Hostname:/{printf("  whoami2: %s\n", $$2);}'
	@curl -s 'https://whoami3.$(DEV_DOMAIN)/'   | awk '/^Hostname:/{printf("  whoami3: %s\n", $$2);}'
	@curl -s 'https://whoami3.$(DEV_DOMAIN)/a/' | awk '/^Hostname:/{printf("  whoami4: %s\n", $$2);}'
	@curl -s 'https://whoami3.$(DEV_DOMAIN)/b/' | awk '/^Hostname:/{printf("  whoami5: %s\n", $$2);}'
	@echo "WSS - this is interactive: type something and then Ctrl-D to exit"
	wscat -c wss://wssecho.dev.jkldsa.com/	


traefik: $(TRAEFIK_DIR)
	@echo "Launching traefik  from $(TRAEFIK_DIR)"
	cd $(TRAEFIK_DIR) && make up

.PHONY: up down ps logs test traefik

