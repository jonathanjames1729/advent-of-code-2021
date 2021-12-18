#!/bin/zsh

ScriptDir="$(cd "$(dirname "$0")"; pwd)"

source "${ScriptDir}/shared.sh"

main() {
    touch "${ScriptDir}/.bash_history"

    local container_id
    container_id="$(docker ps -f ancestor="$Tag" -q)"

    if [ -z "$container_id" ]; then
        docker run --hostname 'soc-2021' \
                   --interactive \
                   --rm \
                   --tty \
                   --volume "${ScriptDir}/.bash_history:/root/.bash_history" \
                   --volume "${ScriptDir}/sources:/root/sources" \
                   --volume "${GemVolume}:/usr/local/bundle" \
                   --volume "${EmacsVolume}:/root/.emacs.d" \
                   "$Tag" \
                   /bin/bash
    else
        docker exec --interactive \
                    --tty \
                    "$container_id" \
                    /bin/bash
    fi
}

main "$@"
