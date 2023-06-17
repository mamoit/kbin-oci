#!/usr/bin/env bash

set -e

OCI_REGISTRY="docker.io/mamoit/"

# Clone repo
if [ ! -d "kbin-core" ]; then
    git clone https://codeberg.org/Kbin/kbin-core.git
fi

cd kbin-core

git pull
SHORT_SHA=$(git rev-parse --short HEAD)

# FIXME: Use example env otherwise build won't finish
cp .env.example .env

# Uncomment this if you're using podman or your docker version is old (stable)
#shopt -s expand_aliases
#alias docker=podman
## Podman does not support --link
#sed -i "s/\-\-link//g" Dockerfile

docker build \
    --target app_php \
    -t ${OCI_REGISTRY}kbin:php \
    -t ${OCI_REGISTRY}kbin:php-${SHORT_SHA} \
    .

docker build \
    --target app_caddy \
    -t ${OCI_REGISTRY}kbin:caddy \
    -t ${OCI_REGISTRY}kbin:caddy-${SHORT_SHA} \
    .

docker build \
    --target symfony_messenger \
    -t ${OCI_REGISTRY}kbin:messenger \
    -t ${OCI_REGISTRY}kbin:messenger-${SHORT_SHA} \
    .

docker push ${OCI_REGISTRY}kbin:php
docker push ${OCI_REGISTRY}kbin:caddy
docker push ${OCI_REGISTRY}kbin:messenger

docker push ${OCI_REGISTRY}kbin:php-${SHORT_SHA}
docker push ${OCI_REGISTRY}kbin:caddy-${SHORT_SHA}
docker push ${OCI_REGISTRY}kbin:messenger-${SHORT_SHA}
