#!/usr/bin/env bash

# Copyright (c) 2016 Egor Tensin <Egor.Tensin@gmail.com>
# This file is part of the "Cygwin configuration files" project.
# For details, see https://github.com/egor-tensin/cygwin-home.
# Distributed under the MIT License.

sums_path='sha1sums.txt'

sums_list_paths() (
    set -o errexit -o nounset -o pipefail

    local fmt='%s\n'

    while [ "$#" -gt 0 ]; do
        local key="$1"
        shift
        case "$key" in
            -h|--help)
                echo "usage: ${FUNCNAME[0]} [-h|--help] [-0|-z]"
                return 0
                ;;

            -0|-z)
                fmt='%s\0'
                ;;

            *)
                echo "${FUNCNAME[0]}: unrecognized parameter: $key" >&2
                return 1
                ;;
        esac
    done

    [ -f "$sums_path" ] || return 0

    local path
    while IFS= read -r path; do
        printf "$fmt" "$path"
    done < <( sed --binary 's/^\\\?[[:alnum:]]\+ [ *]//' "$sums_path" )
)

sums_update() (
    set -o errexit -o nounset -o pipefail

    local path

    local -A existing
    while IFS= read -d '' -r path; do
        existing[$path]=1
    done < <( sums_list_paths -z )

    local -a missing
    for path in "$@"; do
        if [ -z "${existing[$path]+x}" ]; then
            missing+=("$path")
        fi
    done

    sha1sum -- ${missing[@]+"${missing[@]}"} >> "$sums_path"
)

sums_update_distr() (
    set -o errexit -o nounset -o pipefail

    local -a paths
    local path

    while IFS= read -d '' -r path; do
        paths+=("$path")
    done < <( find . -type f -\( -iname '*.exe' -o -iname '*.iso' -\) -printf '%P\0' )

    sums_update ${paths[@]+"${paths[@]}"}
)

sums_verify() {
    sha1sum --check -- "$sums_path"
}
