#!/bin/sh

lilypond_version="2.21.5"

docker build \
    -t jeandeaual/lilypond-devel \
    --build-arg lilypond_version="${lilypond_version}" \
    .
docker build \
    -t jeandeaual/lilypond-ly2video-devel \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg ly2video="true" \
    .
