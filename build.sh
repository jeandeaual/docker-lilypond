#!/bin/bash

lilypond_version="${1:-"2.20.0"}"

docker build \
    -t "jeandeaual/lilypond:stable" \
    -t "jeandeaual/lilypond:${lilypond_version}" \
    --build-arg lilypond_version="${lilypond_version}" \
    .
docker build \
    -t "jeandeaual/lilypond:stable-fonts" \
    -t "jeandeaual/lilypond:${lilypond_version}-fonts" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_fonts="true" \
    .
docker build \
    -t "jeandeaual/lilypond:stable-ly2video" \
    -t "jeandeaual/lilypond:${lilypond_version}-ly2video" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_ly2video="true" \
    .
docker build \
    -t "jeandeaual/lilypond:stable-fonts-ly2video" \
    -t "jeandeaual/lilypond:${lilypond_version}-fonts-ly2video" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_fonts="true" \
    --build-arg install_ly2video="true" \
    .
