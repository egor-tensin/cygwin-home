#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

script_dir="$( cd "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
cp --remove-destination -- "$script_dir/%HOME%/.gitconfig" ~
