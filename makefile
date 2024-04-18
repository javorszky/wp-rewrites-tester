.PHONY: run-wp-ms-subfolder

run-wp-ms-subfolder:
	newman run postman/wp-ms-subfolder/wp\ subfolder\ multisite\ testing.postman_collection.json
