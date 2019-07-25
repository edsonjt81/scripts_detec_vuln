#!/usr/bin/env bats

. test_harness


@test "check_transparent_hugepages -- 0" {
    MOCK_THP_ZERO_PATH=file_mocks/zeropage/0

    run check_zero_page
    [[ "$output" == "0" ]]
}


@test "check_transparent_hugepages -- 1" {
    MOCK_THP_ZERO_PATH=file_mocks/zeropage/1

    run check_zero_page
    [[ "$output" == "1" ]]
}

@test "check_transparent_hugepages -- file does not exist" {
    MOCK_THP_ZERO_PATH=file_mocks/zeropage/asd

    run check_zero_page
    [[ "$output" == "" ]]
}
