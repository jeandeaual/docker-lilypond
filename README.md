# LilyPond Docker Image

[![LilyPond logo](https://lilypond.org/pictures/double-lily-modified3.png)](https://lilypond.org)

Docker image for the music engraving program, [LilyPond](https://lilypond.org/), with variants including [ly2video](https://github.com/aspiers/ly2video) and [open-source fonts](https://github.com/OpenLilyPondFonts).

## Prerequisities

In order to run this container you'll need [Docker](https://docs.docker.com/get-started/#set-up-your-docker-environment).

## Supported Tags

* `stable` (latest [stable version](https://lilypond.org/download.html))
    * `2.20.0`
    * `2.18.2`
    * `2.18.1`
    * `2.18.0`
* `devel` (latest [development version](https://lilypond.org/development.html))
    * `2.21.6`
    * `2.21.5`
    * `2.21.4`
    * `2.21.3`
    * `2.21.2`
    * `2.21.1`
    * `2.21.0`

All tags are available with the following variants:

* `-ly2video`

    Includes [ly2video](https://github.com/aspiers/ly2video).

    This requires Python and makes the image quite larger, so I made it a separate tag.

* `-fonts`

    Includes various open-sources fonts (mainly from [OpenLilyFonts](https://github.com/OpenLilyPondFonts])).

    For usage, see <https://lilypond.org/doc/stable/Documentation/notation/replacing-the-notation-font> and <https://lilypond.org/doc/stable/Documentation/notation/fonts.html>

    * LilyPond fonts:

        * Gonville
        * LilyJAZZ
        * Profondo
        * Haydn
        * Beethoven
        * Paganini
        * Improviso
        * Bravura
        * Lily Boulez
        * Scorlatti
        * LV GoldenAge
        * Gutenberg1939
        * Ross
        * Sebastiano
        * Cadence

    * System fonts:
        * [Libertinus](https://github.com/alerque/libertinus)

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
