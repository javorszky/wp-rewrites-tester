# wp-rewrites-tester

A tool to test whether the server configurations for your WordPress site function as intended.

It uses WordPress running behind your choice of server, whether that be Apache, NGINX, NGINX Unit, Caddy, or something else with known static content in the database using docker. Postman's CLI runner tool, [newman](https://github.com/postmanlabs/newman) is then used to test each endpoint and see whether the response is expected or not.

This can surface issues with server configuration issues or `$_SERVER['REQUEST_URI']` weirdness.

The tests are not complete, and there are a lot of caveats. I'm hoping the community would be able to provide more help with this.

## How to use this

First make sure you have all the prerequisites installed and available.

Then after cloning this repository you'll need two terminal windows.

In the first one you'll start one of the environments using one of the make targets.

In the other you'll start the tests against the running WordPress instance.

### Make targets

1. `up-ms-subfolder-unit`: Starts WordPress running behind Unit in multisite subfolder mode. For this to be successful you need to build the images first. See the [docker/unit/](docker/unit/) folder for the makefiles.

## Prerequisites

### Locally

You'll need [docker](https://docker.com), [newman](https://github.com/postmanlabs/newman) (and for that [nodejs](https://nodejs.org)), and optionally [Postman itself](https://www.postman.com/).

I also added a [makefile](makefile) to make life easier and abstract away the individual calls that go into testing.

### Via CI/CD

Newman is the way to go. More documentation will come later.

## FAQ

### Can I use something else besides Postman / newman?

Possibly. [Bruno](https://www.usebruno.com/) is a similar application to help edit http requests. [Insomnia](https://insomnia.rest/) is another. These are the ones I'm sure can also send a request and receive a response where you can attach tests to them.

For command line usage I've not seen anything similar to newman.

### Why is there a directory with Unit source code in `docker/`?

Code changes in the Unit codebase are currently in a pull request. The easiest way to build a Unit-based image with those changes present is to have a snapshot of the codebase and copy that into the dockerfile. In the future once 1.33 is released and the request URI changes are included in that release the source code directory will go away as we won't need to build a local unit image.

## Note

This project was made to test a work project in NGINX. It's expected that this repository gets transferred to their Github organization in the future.
