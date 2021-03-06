#!/usr/bin/env bats

. test_harness

VULNERABLE_ARCHS=(
    "x86_64"
    "i386"
    "i686"
)


@test "check_arch -- in list 1" {
    run check_arch "i386" "${VULNERABLE_ARCHS[@]}"
    [[ "$output" == "i386" ]]
    (( status == 0 ))
}


@test "check_arch -- in list 2" {
    run check_arch "i386" "x86_64" "i386" "i686"

    [[ "$output" == "i386" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list" {
    run check_arch "WashingMachine_64" "${VULNERABLE_ARCHS[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list" {
    run check_arch "" "${VULNERABLE_ARCHS[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}
