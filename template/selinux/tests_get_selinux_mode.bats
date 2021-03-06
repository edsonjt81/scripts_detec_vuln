#!/usr/bin/env bats

. test_harness


@test "get_selinux_mode -- not available" {
    command() {
        return 1
    }

    run get_selinux_mode
    (( status == 1 ))
}


@test "get_selinux_mode -- Enforcing" {
    command() {
        return 0
    }
    getenforce() {
        echo "Enforcing"
    }

    run get_selinux_mode
    [[ "$output" == "enforcing" ]]
}


@test "get_selinux_mode -- Permissive" {
    command() {
        return 0
    }
    getenforce() {
        echo "Permissive"
    }

    run get_selinux_mode
    [[ "$output" == "permissive" ]]
}
