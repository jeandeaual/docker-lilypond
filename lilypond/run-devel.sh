#!/bin/sh
docker run --rm -v $(pwd):/app -w /app jeandeaual/lilypond-devel lilypond -dno-point-and-click "$*"
