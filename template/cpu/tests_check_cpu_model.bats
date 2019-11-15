#!/usr/bin/env bats

. test_harness

CPU_MODELS_HEX=(
    '0x1E'
    '0x1F'
    '0x25'
    '0x2A'
    '0x2C'
    '0x2D'
)


@test "check_arch -- in list 1" {
    run check_cpu_model "37" "${CPU_MODELS_HEX[@]}"
    [[ "$output" == "0x25" ]]
    (( status == 0 ))
}


@test "check_arch -- in list 2" {
    run check_cpu_model "45" "0x2A" "0x2D" "0x25"

    [[ "$output" == "0x2D" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list" {
    run check_cpu_model "1" "${CPU_MODELS_HEX[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list - empty str" {
    run check_cpu_model "" "${CPU_MODELS_HEX[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}
