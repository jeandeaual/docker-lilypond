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

# ly2video installation
git clone https://github.com/aspiers/ly2video.git

cd ly2video

pip3 install -r requirements.txt
pip3 install .
