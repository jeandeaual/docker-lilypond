#!/bin/sh

docker run --rm -v $(pwd):/app -w /app -u 1000:1000 jeandeaual/lilypond:devel lilypond -dno-point-and-click "$*"
