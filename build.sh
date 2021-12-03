#!/bin/zsh

set -x

ScriptDir="$(cd "$(dirname "$0")"; pwd)"
declare -r ScriptDir

source "${ScriptDir}/shared.sh"

main() {
    docker build --no-cache \
                 --tag "$Tag" \
                 "$ScriptDir"
}

main "$@"
