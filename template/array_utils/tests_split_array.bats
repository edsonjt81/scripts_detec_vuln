#!/usr/bin/env bats

. test_harness


@test "split_array -- no data" {
    data=""

    arr=()
    split_array arr '.' "$data"
    [[ "${arr[0]}" == "" ]]
}

@test "split_array -- 1.2.3" {
    data="1.2.3"

    arr=()
    split_array arr '.' "$data"
    [[ "${arr[0]}" == "1" ]]
    [[ "${arr[1]}" == "2" ]]
    [[ "${arr[2]}" == "3" ]]
}

@test "split_array -- a|b c|d" {
    data="a|b c|d"

    arr=()
    split_array arr '|' "$data"
    [[ "${arr[0]}" == "a" ]]
    [[ "${arr[1]}" == "b c" ]]
    [[ "${arr[2]}" == "d" ]]
}


@test "split_array -- multi-character 11, 12, 13" {
    data="11, 12, 13"

    arr=()
    split_array arr ', ' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11&12&13" {
    data="11&12&13"

    arr=()
    split_array arr '&' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11\;12\;13" {
    data="11\;12\;13"

    arr=()
    split_array arr '\;' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11[blabla]12[blabla]13" {
    data="11[blabla]12[blabla]13"

    arr=()
    split_array arr '[blabla]' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11.*12.*13" {
    data="11.*12.*13"

    arr=()
    split_array arr '.*' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test 'split_array -- multi-character 11`12`13' {
    data='11`12`13'

    arr=()
    split_array arr '`' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test 'split_array -- multi-character 11$12$13' {
    data='11$12$13'

    arr=()
    split_array arr '$' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11ȟẙ12ȟẙ13" {
    data="11ȟẙ12ȟẙ13"

    arr=()
    split_array arr 'ȟẙ' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11🛸12🛸13" {
    data="11🛸12🛸13"

    arr=()
    split_array arr '🛸' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}


@test "split_array -- multi-character 11𩶘12𩶘13" {
    data="11𩶘12𩶘13"

    arr=()
    split_array arr '𩶘' "$data"
    [[ "${arr[0]}" == "11" ]]
    [[ "${arr[1]}" == "12" ]]
    [[ "${arr[2]}" == "13" ]]
}
