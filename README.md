# LilyPond Docker

Docker image for [LilyPond](https://lilypond.org/), including [ly2video](https://github.com/aspiers/ly2video) and [open-source fonts](https://github.com/OpenLilyPondFonts).

## Prerequisities

In order to run this container you'll need [Docker](https://docs.docker.com/get-started/#set-up-your-docker-environment).

## Usage

### Command-line Examples

Build a file using LilyPond 2.20.0:

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:2.20.0 lilypond -dno-point-and-click main.ly
```

Run ly2video on your LilyPond file (with the latest stable LilyPond version):

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:stable-ly2video ly2video main.ly
```

Run [convert-ly](https://lilypond.org/doc/stable/Documentation/usage/invoking-convert_002dly) from the latest development version on all the LilyPond files in the current directory:

```shell
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:devel convert-ly -e *.ly
```

### GitHub Actions

```yml
name: build
on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the code
        uses: actions/checkout@v2
      - name: Build PDF
        uses: docker://jeandeaual/lilypond:2.20.0
        with:
          args: lilypond -dno-point-and-click -dembed-source-code -dpaper-size=\"a4\" -o build main.ly
      - name: Get short SHA
        id: slug
        run: echo "::set-output name=sha7::$(echo ${GITHUB_SHA} | cut -c1-7)"
      - name: Upload artifact
        uses: actions/upload-artifact@v1.0.0
        with:
          name: pdf-${{ steps.slug.outputs.sha7 }}
          path: build
```

### GitLab CI

```yml
image: jeandeaual/lilypond

stages:
  - build

lilypond:
  stage: build
  script:
    - lilypond -dno-point-and-click main.ly
  artifacts:
    paths:
    - *.pdf
```
