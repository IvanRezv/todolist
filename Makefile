#!/usr/bin/make
include .env
export
SHELL:=/bin/sh
docker_bin:=$(shell command -v docker 2> /dev/null)
docker_compose_bin := $(shell command -v docker-compose 2> /dev/null)

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL:=help

deploy: pull up

build: ## rebuild all containers
	$(docker_compose_bin) build
up: ## up all containers
	$(docker_compose_bin) up -d
down: ## stop all containers
	$(docker_compose_bin) stop
pull: # pull containers
	$(docker_compose_bin) pull
migrate: #migration container
	$(docker_bin) pull registry.arealidea.ru/lrv/backend_db_handler/backend_db_handler_migrations:latest \
	&& $(docker_bin) run -d --name migrations registry.arealidea.ru/lrv/backend_db_handler/backend_db_handler_migrations:latest \
	&& $(docker_bin) container wait migrations \
	&& $(docker_bin) rm migrations
full-clean: #clean all
	$(docker_bin) ps -a -q -f status=exited | xargs --no-run-if-empty $(docker_bin) rm -v \
	&& $(docker_bin) images -f "dangling=true" -q | xargs --no-run-if-empty $(docker_bin) rmi \
	&& $(docker_bin) volume ls -qf dangling=true | xargs --no-run-if-empty $(docker_bin) volume rm
