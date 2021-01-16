#!/bin/bash

lilypond_version="${1:-"2.21.6"}"

docker build \
    -t "jeandeaual/lilypond:latest" \
    -t "jeandeaual/lilypond:devel" \
    -t "jeandeaual/lilypond:${lilypond_version}" \
    --build-arg lilypond_version="${lilypond_version}" \
    .
docker build \
    -t "jeandeaual/lilypond:devel-fonts" \
    -t "jeandeaual/lilypond:${lilypond_version}-fonts" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_fonts="true" \
    .
docker build \
    -t "jeandeaual/lilypond:devel-ly2video" \
    -t "jeandeaual/lilypond:${lilypond_version}-ly2video" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_ly2video="true" \
    .
docker build \
    -t "jeandeaual/lilypond:devel-fonts-ly2video" \
    -t "jeandeaual/lilypond:${lilypond_version}-fonts-ly2video" \
    --build-arg lilypond_version="${lilypond_version}" \
    --build-arg install_fonts="true" \
    --build-arg install_ly2video="true" \
    .
