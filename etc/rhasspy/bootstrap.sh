#!/bin/bash

set -e

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Ensure we're running in our current directory
pushd $SCRIPT_DIR
trap "popd; exit" INT TERM EXIT

# Set up environment configured in our env file
# https://unix.stackexchange.com/a/79077/358706
set -o allexport
. ./bootstrap.conf
set +o allexport

# Parse options using getopt
# https://www.codebyamir.com/blog/parse-command-line-arguments-using-getopt
opts=$(getopt \
    --longoptions "start,stop" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)
eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --start)
            # Run (in lexical sort-order) all executable scripts within init.d for startup
            run-parts --exit-on-error init.d
            shift
            ;;

        --stop)
            # Run (in lexical sort-order) all executable scripts within shutdown.d for shutdown
            run-parts --exit-on-error shutdown.d
            shift
            ;;

        *)
            break
            ;;
    esac
done
