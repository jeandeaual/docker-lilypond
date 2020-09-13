#!/bin/sh

docker build \
    -t jeandeaual/lilypond-stable \
    .
docker build \
    -t jeandeaual/lilypond-ly2video-stable \
    --build-arg ly2video="true" \
    .
