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

# LilyJAZZ
# See https://github.com/OpenLilyPondFonts/lilyjazz/blob/master/LilyPond-Fonts-Installation-And-Usage.txt
readonly lilyjazz_repo="https://github.com/OpenLilyPondFonts/lilyjazz"

for size in 11 13 14 16 18 20 23 26 brace; do
    wget "${lilyjazz_repo}/raw/master/otf/lilyjazz-${size}.otf" -P "${otf_folder}/"
    wget "${lilyjazz_repo}/raw/master/svg/lilyjazz-${size}.svg" -P "${svg_folder}/"
    wget "${lilyjazz_repo}/raw/master/svg/lilyjazz-${size}.woff" -P "${svg_folder}/"
done

wget "${lilyjazz_repo}/raw/master/supplementary-files/lilyjazz-chord/lilyjazz-chord.otf" -P "${otf_folder}/"
wget "${lilyjazz_repo}/raw/master/supplementary-files/lilyjazz-text/lilyjazz-text.otf" -P "${otf_folder}/"

for stylesheet in jazzchords jazzextras lilyjazz; do
    wget "${lilyjazz_repo}/raw/master/stylesheet/${stylesheet}.ily" -P "${ly_folder}/"
done

# Gonville
# See https://lilypond.org/doc/stable/Documentation/notation/replacing-the-notation-font
readonly tmp_folder=$(mktemp -d)
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
