.PHONY: test-ms-subfolder

test-ms-subfolder:
	newman run cases/ms-subfolder/wp\ subfolder\ multisite\ testing.postman_collection.json
