#!/usr/bin/env bash
set -e

# Script to run all .bats tests for detection scripts.
bats -v
set -e
echo

run_bats_tests() {
    local dir_path="$1"
    echo
    echo -e "$dir_path"
    echo
    cd "$dir_path"
    bats .
    cd -
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then

    echo -e "Running tests..."
    echo -e "------------------------------"
    echo

    for d in * template/*; do
        if [[ -d "$d" ]]; then
            run_bats_tests "$d"
        fi
    done
fi
