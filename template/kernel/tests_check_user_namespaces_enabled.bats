#!/usr/bin/env bats

. test_harness


@test "check_user_namespaces_enabled -- disabled" {
    export MOCK_CMDLINE_PATH=file_mocks/cmdline/cmdline_ns_disabled
    
    run check_user_namespaces_enabled
    (( status == 1 ))
}


@test "check_user_namespaces_enabled -- enabled" {
    export MOCK_CMDLINE_PATH=file_mocks/cmdline/cmdline_ns_enabled

    run check_user_namespaces_enabled
    (( status == 0 ))
}
