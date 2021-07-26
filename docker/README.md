# Docker Instructions

These are instructions to get the docker image running for pg-unit tests. 
The environment variable `${PG_ROOT}` may not be set in your system or differ from the instance of `pg` that you are using.
In this case, replate all occurences of `${PG_ROOT}` by your working copy of `pg`.

1. `cd ${PG_ROOT}/docker` 
2. `docker build -t pg-unit-test -f pg-text-docker.Dockerfile .` \
note: you may need sudo privileges.  The first time, this may take a couple of minutes.
3. `docker run -it --rm --name pg-unit-test -v ${PG_ROOT}:/opt/webwork/pg -w /opt/webwork/pg pg-unit-test prove -r .`

This will run all of the tests.

## Using the Image on Docker Hub

You can also pull and run a suitable image from dockerhub via
```bash
docker run -it --rm --name pg-unit-test -v ${PG_ROOT}:/opt/webwork/pg -w /opt/webwork/pg eltenedor/pg-unit-testing:latest prove -r .
```