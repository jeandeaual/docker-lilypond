#!/bin/bash

set -euo pipefail

for cmd in git pip3; do
    command -v "${cmd}" &>/dev/null || {
        echo "${cmd} needs to be installed" 2>&1
        exit 1
    }
done

usage () {
    echo "Usage: $(basename "$0")"
}

if [[ $# -gt 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
    usage
    exit 0
fi

tmp_folder=$(mktemp -d)
readonly tmp_folder
function cleanup {
    rm -rf "${tmp_folder}"
}
trap cleanup EXIT

(
    # ly2video installation
    git clone https://github.com/aspiers/ly2video.git "${tmp_folder}/ly2video"

    cd "${tmp_folder}/ly2video"

    # Fix "The unauthenticated git protocol on port 9418 is no longer supported."
    sed -i 's/^git+git/git+https/' requirements.txt

    pip3 install -r requirements.txt
    pip3 install .
)
