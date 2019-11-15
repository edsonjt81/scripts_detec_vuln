#!/usr/bin/env bats

. test_harness

CPU_FLAGS=(
    "hle"
    "avx2"
    "smep"
    "bmi2"
    "erms"
    "invpcid"
    "rtm"
    "mpx"
    "rdseed"
    "adx"
    "smap"
    "clflushopt"
    "intel_pt"
)


@test "check_arch -- in list 1" {
    run check_cpu_flag "smap" "${CPU_FLAGS[@]}"
    [[ "$output" == "smap" ]]
    (( status == 0 ))
}


@test "check_arch -- in list 2" {
    run check_cpu_flag "rtm" "hle" "vmx" "rtm"

    [[ "$output" == "rtm" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list" {
    run check_cpu_flag "foobar" "${CPU_FLAGS[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}


@test "check_arch -- not in list - empty str" {
    run check_cpu_flag "" "${CPU_FLAGS[@]}"
    [[ "$output" == "" ]]
    (( status == 0 ))
}
