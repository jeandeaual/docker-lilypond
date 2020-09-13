#!/bin/sh
docker run --rm -v $(pwd):/app -w /app jeandeaual/lilypond-stable lilypond -dno-point-and-click "$*"
