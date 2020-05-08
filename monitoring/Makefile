TRAEFIK_DIR ?= $(dir $(CURDIR))
DEV_DOMAIN ?= dev.jkldsa.com

.PHONY: up down grafana ps logs traefik

up: grafana traefik
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


# ---------------------------------------------------------------------- Grafana
GPLUPATH = data/grafana/plugins
GPLUGINS = grafana-piechart-panel

grafana: $(addprefix $(GPLUPATH)/, $(GPLUGINS)) 
	@echo "Grafana config is ok"

$(GPLUPATH)/grafana-piechart-panel:
	mkdir -p $$(dirname $@)
	git clone https://github.com/grafana/piechart-panel.git --branch release-1.3.8 $@
