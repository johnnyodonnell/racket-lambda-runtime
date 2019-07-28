#!/bin/bash

docker rm runtime-container
rm -f bootstrap

docker build . --tag runtime-image
docker create -it --name runtime-container runtime-image
docker cp runtime-container:/runtime bootstrap

zip -r lambda.zip bootstrap
aws lambda publish-layer-version --layer-name racket-runtime \
    --description "Racket custom runtime" \
    --zip-file fileb://lambda.zip

