#!/usr/bin/env bats

. test_harness


@test "print_array -- empty" {
    arr=()
    run print_array arr
    [[ "$output" == "" ]]
}

@test "print_array -- one" {
    arr=( 1 )
    run print_array arr
    [[ "$output" == "1" ]]
}

@test "print_array -- three" {
    arr=( 1 2 3 )
    run print_array arr
    [[ "$output" == "1
2
3" ]]
}

@test "print_array -- spaces" {
    arr=( 1 "2 3" 4 )
    run print_array arr
    [[ "$output" == "1
2 3
4" ]]
}
