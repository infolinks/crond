#!/usr/bin/env bash

set -e

docker build -t infolinks/crond:${TRAVIS_COMMIT} .

if [[ ${TRAVIS_TAG} =~ ^v[0-9]+$ ]]; then
    docker tag infolinks/crond:${TRAVIS_COMMIT} infolinks/crond:${TRAVIS_TAG}
    docker push infolinks/crond:${TRAVIS_TAG}
    docker tag infolinks/crond:${TRAVIS_COMMIT} infolinks/crond:latest
    docker push infolinks/crond:latest
fi
