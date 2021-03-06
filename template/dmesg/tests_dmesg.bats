#!/usr/bin/env bats

. test_harness

@test "dmesg - match in dmesg" {
    dmesg() {
        echo "something"
        echo "something text MATCH something"
        echo "something"
    }
    journalctl() {
        return 1
    }
    command() {
        if [[ "$2" == "journalctl" ]]; then
            return 1
        fi
        command "$@"
    }
    export -f dmesg
    export -f journalctl
    export -f command
    export MOCK_DMESG_PATH=/dev/null

    run check_dmesg "text MATCH"
    (( status == 0 ))
}


@test "dmesg - no match" {
    dmesg() {
        echo "nothing relevant"
        echo "something TEXT match (or rather not)"
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=/dev/null

    run check_dmesg "text MATCH"
    (( status == 1 ))
}


@test "dmesg - no match and journalctl error" {
    dmesg() {
        echo "nothing relevant"
        echo "something TEXT match (or rather not)"
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
        return 1
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=/dev/null

    run check_dmesg "text MATCH"
    (( status == 1 ))
}


@test "dmesg - match in dmesg, journalctl error" {
    dmesg() {
        echo "something"
        echo "something text MATCH something"
        echo "something"
    }
    journalctl() {
        return 1
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=/dev/null

    run check_dmesg "text MATCH"
    (( status == 0 ))
}


@test "dmesg - match via journalctl" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "something"
        echo "something text MATCH something"
        echo "something"
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=/dev/null

    run check_dmesg "text MATCH"
    (( status == 0 ))
}


@test "dmesg - match via log" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=file_mocks/dmesg/enabled

    run check_dmesg "Secure boot enabled"
    (( status == 0 ))
}


@test "dmesg - multiple matches (dmesg, log, journalctl)" {
    dmesg() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    journalctl() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    export -f dmesg
    export -f journalctl
    export MOCK_DMESG_PATH=file_mocks/dmesg/enabled

    run check_dmesg "Secure boot enabled"
    (( status == 0 ))
}
