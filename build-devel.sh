#!/bin/bash

lilypond_version="${1:-"2.23.0"}"

export DOCKER_BUILDKIT=1

docker build \
    -t "jeandeaual/lilypond:latest" \
    -t "jeandeaual/lilypond:devel" \
    -t "jeandeaual/lilypond:${lilypond_version}" \
    --build-arg LILYPOND_VERSION="${lilypond_version}" \
    .

for image_suffix in "-fonts" "-ly2video" "-fonts-ly2video"; do
    docker build \
        -t "jeandeaual/lilypond:devel${image_suffix}" \
        -t "jeandeaual/lilypond:${lilypond_version}${image_suffix}" \
        --build-arg LILYPOND_VERSION="${lilypond_version}" \
        --build-arg SUFFIX="${image_suffix}" \
        .
done
