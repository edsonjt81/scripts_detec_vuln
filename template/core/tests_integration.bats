#!/usr/bin/env bats

export RHEL7="3.10.0-520.10.2.el7.x86_64"
export FEDORA="4.9.14-200.fc25.x86_64"
export SCRIPT_NAME=$( grep -E '^\. .*\.sh$' test_harness | sed -r 's/^\. (.*)$/\1/g' )

# TODO these are very simple tests, a lot of customization is needed. See older tests.

@test "Integration -- Fedora" {
    uname() {
        echo "$FEDORA"
    }
    export -f uname

    run ./"${SCRIPT_NAME}"
    (( status == 1 ))
}


@test "Integration -- RHEL7" {
    uname() {
        echo "$RHEL7"
    }
    export -f uname

    run ./"${SCRIPT_NAME}"
    (( status == 0 ))
}
