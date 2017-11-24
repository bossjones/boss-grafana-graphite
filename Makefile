# docker-grafana-graphite makefile

.PHONY: up

SHELL := $(shell which bash)

# export DOCKER_IP = $(shell which docker-machine > /dev/null 2>&1 && docker-machine ip $(DOCKER_MACHINE_NAME))

export PATH := ./bin:./venv/bin:$(PATH)

YOUR_HOSTNAME := $(shell hostname | cut -d "." -f1 | awk '{print $1}')

export HOST_IP=$(shell curl ipv4.icanhazip.com 2>/dev/null)

username := bossjones
container_name := boss-grafana-graphite

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION  = latest

LOCAL_REPOSITORY = $(HOST_IP):5000

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

build: prep
	docker build --tag $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-force:
	docker build --rm --force-rm --pull --no-cache -t $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-local:
	docker build --tag $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(username)/$(container_name):latest

tag-local:
	docker tag $(username)/$(container_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(username)/$(container_name):$(TAG)
	docker tag $(username)/$(container_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(username)/$(container_name):latest

push-local:
	docker push $(LOCAL_REPOSITORY)/$(username)/$(container_name):$(TAG)
	docker push $(LOCAL_REPOSITORY)/$(username)/$(container_name):latest

build-push-local: build-local tag-local push-local

tag:
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG)

build-push: build tag
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

push:
	docker push $(username)/$(container_name):latest
	docker push $(username)/$(container_name):$(GIT_SHA)
	docker push $(username)/$(container_name):$(TAG)

push-force: build-force push

dc-up: prep
	docker-compose -f docker-compose.yml create && \
	docker-compose -f docker-compose.yml start

dc-down:
	docker-compose -f docker-compose.yml stop && \
	docker-compose -f docker-compose.yml down

dc-restart: dc-down dc-up

dc-build:
	docker-compose -f docker-compose.yml --force-rm --pull build

grafana-graphite-restart: grafana-graphite-down grafana-graphite-up

grafana-graphite-up: prep
	docker-compose -f docker-compose.yml up -d grafana-graphite

grafana-graphite-down:
	docker-compose -f docker-compose.yml stop grafana-graphite && \
	docker-compose -f docker-compose.yml rm -f grafana-graphite

prep:
	mkdir -p \
		data/whisper \
		data/elasticsearch \
		data/grafana \
		log/graphite \
		log/graphite/webapp \
		log/elasticsearch

nuke:
	rm -rfv data/whisper && \
	rm -rfv data/elasticsearch && \
	rm -rfv data/grafana && \
	rm -rfv log/graphite && \
	rm -rfv log/graphite/webapp && \
	rm -rfv log/elasticsearch

pull:
	docker-compose pull

up: prep pull
	docker-compose up

dev-up: up

dev-down: down

up-d: prep pull
	docker-compose up -d

down:
	docker-compose down && \
	docker-compose rm -f

restart: down up

shell:
	docker exec -ti $(username)/$(container_name):latest /bin/bash

tail:
	docker logs -f $(username)/$(container_name):latest

# FIX for: WARNING: Dependency conflict: an older version of the 'docker-py' package may be polluting the namespace. If you're experiencing crashes, run the following command to remedy the issue:
rm-docker-py:
	sudo pip uninstall -y docker-py; sudo pip uninstall -y docker; sudo pip install docker

firewalld:
	sudo firewall-cmd --add-port=1-65535/udp --permanent && sudo firewall-cmd --add-port=1-65535/tcp --permanent
