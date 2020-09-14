#!/bin/sh

docker build \
    -t jeandeaual/lilypond-stable \
    .
docker build \
    -t jeandeaual/lilypond-ly2video-stable \
    --build-arg install_ly2video="true" \
    .
