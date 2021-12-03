#!/bin/zsh

ScriptDir="$(cd "$(dirname "$0")"; pwd)"

source "${ScriptDir}/shared.sh"

main() {
    docker run --hostname 'soc-2021' \
               --interactive \
               --rm \
               --tty \
               --volume "${ScriptDir}/sources:/root/sources" \
               --volume "${GemVolume}:/usr/local/bundle" \
               "$Tag" \
               /bin/bash
}

main "$@"
