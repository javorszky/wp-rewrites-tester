.PHONY: test-ms-subfolder up-ms-subfolder-unit up-ms-subfolder-apache

test-ms-subfolder:
	newman run cases/ms-subfolder/wp\ subfolder\ multisite\ testing.postman_collection.json

up-ms-subfolder-unit:
	docker compose -f cases/ms-subfolder/docker-compose.yaml up db unit --build

up-ms-subfolder-apache:
	docker compose -f cases/ms-subfolder/docker-compose.yaml up db apache --build