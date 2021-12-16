#!/bin/bash

set -euo pipefail

command -v wget &>/dev/null || {
    echo "wget needs to be installed" 2>&1
    exit 1
}

usage () {
    echo "Usage: $(basename "$0") UID GUID"
}

if [[ $# -ge 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
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
    cd "${tmp_folder}"

    # Spontini installation
    wget https://github.com/paopre/Spontini/archive/refs/tags/1.2.tar.gz -O Spontini.tar.gz

    tar -xzf Spontini.tar.gz
    rm Spontini.tar.gz

    mv Spontini-* /opt/Spontini

    # Workaround to access Spontini from outside the container
    sed -i 's/127\.0\.0\.1/0.0.0.0/' /opt/Spontini/lib/python/uvicorn_cli.py

    cat <<'EOF' > /usr/local/bin/spontini
#!/bin/sh

python /opt/Spontini/SpontiniServer.py nogui "$@"
EOF

    chmod +x /usr/local/bin/spontini
)
