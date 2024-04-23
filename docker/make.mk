.PHONY: build-unit build-wp build

# this is needed until we have an official release with the request URI changes in it.
# PR 1162 needs to be merged, and Unit 1.33 needs to be tagged (assuming 1.33 has the
# changes in it).
build-unit:
	docker build -f unit-requesturi.dockerfile --no-cache -t unit:local-php .

build-wp:
	docker build -f unit-wp.dockerfile --no-cache -t unit:wp-ms .

build: build-unit build-wp
	