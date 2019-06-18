#!/usr/bin/env bash
# id_rsa (private key) is going to be added to the docker image.
docker build -t maven-git:3-alpine -f Dockerfile .