# LilyPond Docker Image

[![LilyPond logo](https://lilypond.org/pictures/double-lily-modified3.png)](https://lilypond.org)

Docker image for the music engraving program, [LilyPond](https://lilypond.org/), with variants including [ly2video](https://github.com/aspiers/ly2video) and [open-source fonts](https://github.com/OpenLilyPondFonts).

## Prerequisities

In order to run this container you'll need [Docker](https://docs.docker.com/get-started/#set-up-your-docker-environment).

## Supported Tags

* `stable` (latest [stable version](https://lilypond.org/download.html))
    * `2.24.1`
    * `2.24.0`
    * `2.22.2`
    * `2.22.1`
    * `2.22.0`
* `devel` (latest [development version](https://lilypond.org/development.html))
    * `2.25.2`
    * `2.25.1`
    * `2.25.0`
    * `2.23.82`
    * `2.23.81`
    * `2.23.80`
    * `2.23.14`
    * `2.23.13`
    * `2.23.12`
    * `2.23.11`
    * `2.23.10`
    * `2.23.9`
    * `2.23.8`
    * `2.23.7`
    * `2.23.6`
    * `2.23.5`
    * `2.23.4`
    * `2.23.3`
    * `2.23.2`
    * `2.23.1`
    * `2.23.0`
    * `2.21.82`
    * `2.21.81`
    * `2.21.80`
    * `2.21.7`
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

    This requires Python and makes the image quite larger.

* `-fonts`

    Includes various open-sources fonts (mainly from [OpenLilyFonts](https://github.com/OpenLilyPondFonts)).

    For usage, see <https://lilypond.org/doc/stable/Documentation/notation/replacing-the-notation-font> and <https://lilypond.org/doc/stable/Documentation/notation/fonts.html>.

    * LilyPond fonts:

        * [Gonville](https://www.chiark.greenend.org.uk/~sgtatham/gonville/)
        * [LilyJAZZ](https://github.com/OpenLilyPondFonts/lilyjazz)
        * [Profondo](https://github.com/OpenLilyPondFonts/profondo)
        * [Haydn](https://github.com/OpenLilyPondFonts/haydn)
        * [Beethoven](https://github.com/OpenLilyPondFonts/beethoven)
        * [Paganini](https://github.com/OpenLilyPondFonts/paganini)
        * [Improviso](https://github.com/OpenLilyPondFonts/improviso)
        * [Bravura](https://github.com/OpenLilyPondFonts/bravura)
        * [Lily Boulez](https://github.com/OpenLilyPondFonts/lilyboulez)
        * [Scorlatti](https://github.com/OpenLilyPondFonts/scorlatti)
        * [LV GoldenAge](https://github.com/OpenLilyPondFonts/lv-goldenage)
        * [Gutenberg1939](https://github.com/OpenLilyPondFonts/gutenberg1939)
        * [Ross](https://github.com/OpenLilyPondFonts/ross)
        * [Sebastiano](https://github.com/OpenLilyPondFonts/sebastiano)
        * [Cadence](https://github.com/OpenLilyPondFonts/cadence)

    * System fonts:

        * [Libertinus](https://github.com/alerque/libertinus)

## Usage

### Command-line Examples

Build a file using LilyPond 2.23.0:

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:2.23.0 lilypond -dno-point-and-click main.ly
```

Run ly2video on your LilyPond file (with the latest stable LilyPond version):

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:stable-ly2video ly2video -i main.ly
```

Run [convert-ly](https://lilypond.org/doc/stable/Documentation/usage/invoking-convert_002dly) from the latest development version on all the LilyPond files in the current directory:

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:devel convert-ly -e *.ly
```

Run [extractpdfmark](https://github.com/trueroad/extractpdfmark) to reduce the PDF file size:

```sh
docker run -v $(pwd):/app -w /app jeandeaual/lilypond:devel extractpdfmark main.pdf > /tmp/tmp.ps && gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dPDFDontUseFontObjectNum -dPrinted=false -sOutputFile=main-extracted.pdf main.pdf /tmp/tmp.ps
```

### GitHub Actions

```yaml
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
        uses: docker://jeandeaual/lilypond:stable
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

```yaml
image: jeandeaual/lilypond:stable

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
