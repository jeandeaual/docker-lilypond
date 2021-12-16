#!/bin/bash

lilypond_version="${1:-"2.22.0"}"

export DOCKER_BUILDKIT=1

for image_suffix in "" "-fonts" "-tools" "-fonts-tools"; do
    docker build \
        -t "jeandeaual/lilypond:stable${image_suffix}" \
        -t "jeandeaual/lilypond:${lilypond_version}${image_suffix}" \
        --build-arg LILYPOND_VERSION="${lilypond_version}" \
        --build-arg SUFFIX="${image_suffix}" \
        .
done
