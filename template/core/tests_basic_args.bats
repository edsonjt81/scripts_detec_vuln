#!/usr/bin/env bats

. test_harness


@test "basic_args -- Help" {
    run basic_args -h
    [[ "$output" == *"Usage"* ]]
    (( status == 1 ))
}


@test "basic_args -- Debug #1" {
    basic_args -d; run basic_args -d
    (( status == 0 ))
    [[ "$debug" ]]
    [[ "$RED" == "\033[1;31m" ]]
    [[ "$YELLOW" == "\033[1;33m" ]]
    [[ "$GREEN" == "\033[1;32m" ]]
    [[ "$BOLD" == "\033[1m" ]]
    [[ "$RESET" == "\033[0m" ]]
}


@test "basic_args -- Debug #2" {
    basic_args --debug; run basic_args --debug
    (( status == 0 ))
    [[ "$debug" ]]
    [[ "$RED" == "\033[1;31m" ]]
    [[ "$YELLOW" == "\033[1;33m" ]]
    [[ "$GREEN" == "\033[1;32m" ]]
    [[ "$BOLD" == "\033[1m" ]]
    [[ "$RESET" == "\033[0m" ]]
}


@test "basic_args -- No colors #1" {
    basic_args -n; run basic_args -n
    (( status == 0 ))
    [[ ! "$debug" ]]
    [[ ! "$RED" ]]
    [[ ! "$YELLOW" ]]
    [[ ! "$GREEN" ]]
    [[ ! "$BOLD" ]]
    [[ ! "$RESET" ]]
}


@test "basic_args -- No colors #2" {
    basic_args --no-colors; run basic_args --no-colors
    (( status == 0 ))
    [[ ! "$debug" ]]
    [[ ! "$RED" ]]
    [[ ! "$YELLOW" ]]
    [[ ! "$GREEN" ]]
    [[ ! "$BOLD" ]]
    [[ ! "$RESET" ]]
}


@test "basic_args -- Regular" {
    basic_args; run basic_args
    (( status == 0 ))   
    [[ ! "$debug" ]]
    [[ "$RED" == "\033[1;31m" ]]
    [[ "$YELLOW" == "\033[1;33m" ]]
    [[ "$GREEN" == "\033[1;32m" ]]
    [[ "$BOLD" == "\033[1m" ]]
    [[ "$RESET" == "\033[0m" ]]
}
