#!/bin/sh
docker run --rm -v $(pwd):/app -w /app jeandeaual/lilypond-ly2video-devel lilypond -dno-point-and-click "$*"
