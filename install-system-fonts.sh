#!/bin/bash

set -euo pipefail

for cmd in wget xz; do
    command -v "${cmd}" &>/dev/null || {
        echo "${cmd} needs to be installed" 2>&1
        exit 1
    }
done

usage () {
    echo "Usage: $(basename "$0") [FONT_FOLDER]"
}

if [[ $# -gt 1 ]]; then
    usage
    exit 1
fi

if [[ $# -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
    usage
    exit 0
fi

readonly font_folder="${1:-"/usr/share/fonts"}"

if [[ ! -d "${font_folder}" ]]; then
    # Create the folder
    mkdir -pv "${font_folder}"
fi

if [[ ! -w "${font_folder}" ]]; then
    echo "No write permission on font folder: ${font_folder}" 1>&2
    exit 1
fi

tmp_folder=$(mktemp -d)
readonly tmp_folder
function cleanup {
    rm -rf "${tmp_folder}"
}
trap cleanup EXIT

# Libertinus
readonly libertinus_version="7.040"
readonly libertinus_archive="Libertinus-${libertinus_version}.tar.xz"

wget "https://github.com/alerque/libertinus/releases/download/v${libertinus_version}/${libertinus_archive}" \
    -O "${tmp_folder}/${libertinus_archive}"
tar -xvJf "${tmp_folder}/${libertinus_archive}" -C "${tmp_folder}/"
mv -v "${tmp_folder}/${libertinus_archive%.tar.xz}"/static/OTF/*.otf "${font_folder}/"

# 原ノ味フォント / Harano Aji fonts
readonly haranoaji_version="20220220"
readonly haranoaji_archive="HaranoAjiFonts-${haranoaji_version}.tar.gz"

wget "https://github.com/trueroad/HaranoAjiFonts/archive/refs/tags/${haranoaji_version}.tar.gz" \
    -O "${tmp_folder}/${haranoaji_archive}"
tar -xvzf "${tmp_folder}/${haranoaji_archive}" -C "${tmp_folder}/"
mv -v "${tmp_folder}/${haranoaji_archive%.tar.gz}"/*.otf "${font_folder}/"
