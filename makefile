.PHONY: test-ms-subfolder up-ms-subfolder-unit up-ms-subfolder-apache

include ./docker/make.mk

build-unit-ms-subfolder:
	${MAKE} -C docker -f make.mk build

test-ms-subfolder:
	newman run cases/ms-subfolder/wp\ subfolder\ multisite\ testing.postman_collection.json

up-ms-subfolder-unit: build-unit-ms-subfolder
	docker compose -f cases/ms-subfolder/docker-compose.yaml up -d unit --build

up-ms-subfolder-apache:
	docker compose -f cases/ms-subfolder/docker-compose.yaml up -d apache --build

up-ms-subfolder-nginx:
	docker compose -f cases/ms-subfolder/docker-compose.yaml up -d nginx --build