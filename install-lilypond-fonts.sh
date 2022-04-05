#!/bin/bash

set -euo pipefail

command -v wget &>/dev/null || {
    echo "wget needs to be installed" 2>&1
    exit 1
}

usage () {
    echo "Usage: $(basename "$0") LILYPOND_FOLDER (e.g. /usr/share/lilypond/X.Y.Z)"
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

readonly lilypond_folder="$1"
readonly otf_folder="${lilypond_folder}/fonts/otf"
readonly svg_folder="${lilypond_folder}/fonts/svg"
readonly ly_folder="${lilypond_folder}/ly"

if [[ ! -d "${otf_folder}" || ! -d "${svg_folder}" || ! -d "${ly_folder}" ]]; then
    echo "Invalid LilyPond folder: ${lilypond_folder}" 1>&2
    exit 1
fi

if [[ ! -w "${otf_folder}" || ! -w "${svg_folder}" || ! -w "${ly_folder}" ]]; then
    echo "No write permission on LilyPond folder: ${lilypond_folder}" 1>&2
    exit 1
fi

# OpenLilyPondFonts
# See https://github.com/OpenLilyPondFonts/lilyjazz/blob/master/LilyPond-Fonts-Installation-And-Usage.txt
readonly font_names=(
    "lilyjazz"
    "profondo"
    "haydn"
    "beethoven"
    "paganini"
    "improviso"
    # See https://github.com/lyp-packages/bravura/blob/master/package.ly
    # and http://lilypondblog.org/2020/08/google-summer-of-code-2020-smufl/
    "bravura"
    "lilyboulez"
    "scorlatti"
    "lv-goldenage"
    "gutenberg1939"
    "ross"
    "sebastiano"
    "cadence"
)

for font_name in "${font_names[@]}"; do
    repo="https://github.com/OpenLilyPondFonts/${font_name}"
    sizes=(11 13 14 16 18 20 23 26)

    case "${font_name}" in
        "paganini"|"lilyboulez"|"lv-goldenage"|"cadence")
            # These fonts don't have a brace font file
            ;;
        "bravura")
            # Bravura is a SMuFL font, so no font file for individual sizes
            sizes=()
            ;;
        *)
            sizes+=("brace")
            ;;
    esac

    for size in "${sizes[@]}"; do
        wget "${repo}/raw/master/otf/${font_name}-${size}.otf" -P "${otf_folder}/"
        wget "${repo}/raw/master/svg/${font_name}-${size}.svg" -P "${svg_folder}/"
        wget "${repo}/raw/master/svg/${font_name}-${size}.woff" -P "${svg_folder}/"
    done

    # Supplementary files
    case "${font_name}" in
        "lilyjazz")
            wget "${repo}/raw/master/supplementary-files/lilyjazz-chord/lilyjazz-chord.otf" -P "${otf_folder}/"
            wget "${repo}/raw/master/supplementary-files/lilyjazz-text/lilyjazz-text.otf" -P "${otf_folder}/"

            for stylesheet in jazzchords jazzextras lilyjazz; do
                wget "${repo}/raw/master/stylesheet/${stylesheet}.ily" -P "${ly_folder}/"
            done
            ;;
        "profondo")
            wget "${repo}/raw/master/supplementary-fonts/ProfondoTupletNumbers.otf" -P "${otf_folder}/"
            ;;
        "improviso")
            wget "${repo}/raw/master/supplementary-fonts/PeaMissywithaMarker.otf" -P "${otf_folder}/"
            wget "${repo}/raw/master/supplementary-fonts/PermanentMarker.ttf" -P "${otf_folder}/"
            wget "${repo}/raw/master/supplementary-fonts/Thickmarker.otf" -P "${otf_folder}/"
            ;;
        "lv-goldenage")
            wget "${repo}/raw/master/supplementary-fonts/GoldenAgeText.otf" -P "${otf_folder}/"
            wget "${repo}/raw/master/supplementary-fonts/GoldenAgeTitle.otf" -P "${otf_folder}/"
            ;;
        "bravura")
            # Special handling for Bravura which is a SMuFL font
            wget "${repo}/raw/master/otf/Bravura.otf" -P "${otf_folder}/"
            wget "${repo}/raw/master/otf/BravuraText.otf" -P "${otf_folder}/"
            wget "${repo}/raw/master/svg/Bravura.svg" -P "${svg_folder}/"
            wget "${repo}/raw/master/svg/BravuraText.svg" -P "${svg_folder}/"
            wget "${repo}/raw/master/woff/Bravura.woff" -P "${svg_folder}/"
            wget "${repo}/raw/master/woff/BravuraText.woff" -P "${svg_folder}/"
            # See http://lilypondblog.org/2020/08/google-summer-of-code-2020-smufl/
            wget "${repo}/raw/master/bravura_metadata.json" -O "${otf_folder}/bravura.json"
            ;;
    esac

    sleep 1
done

# Gonville
# See https://lilypond.org/doc/stable/Documentation/notation/replacing-the-notation-font
tmp_folder=$(mktemp -d)
readonly tmp_folder
function cleanup {
    rm -rf "${tmp_folder}"
}
trap cleanup EXIT

(
    readonly archive="gonville-20200703.bedc4d7.tar.gz"

    cd "${tmp_folder}"

    wget "https://www.chiark.greenend.org.uk/~sgtatham/gonville/${archive}" -P "${tmp_folder}/"
    tar -xvzf "${archive}"

    cd "${archive%.tar.*}"

    mv ./*.otf "${otf_folder}/"
    mv ./*.svg "${svg_folder}/"
    mv ./*.woff "${svg_folder}/"
    mv ./*.ily "${ly_folder}/"
)
