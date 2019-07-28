#!/bin/bash

docker rm runtime-container
rm -f bootstrap

docker build . --tag runtime-image
docker create -it --name runtime-container runtime-image
docker cp runtime-container:/runtime bootstrap

