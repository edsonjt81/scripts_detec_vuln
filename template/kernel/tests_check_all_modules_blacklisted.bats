#!/usr/bin/env bats

. test_harness


VULNERABLE_BT=(
    'bnep'
    'bluetooth'
    'btusb'
)

VULNERABLE_VHOST=( 'vhost_net' )


@test "check_all_modules_blacklisted -- blacklisted one module #1" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_blacklisted_1'

    run check_all_modules_blacklisted "${VULNERABLE_VHOST[@]}"
    (( status == 0 ))
}


@test "check_all_modules_blacklisted -- blacklisted one module #2" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_blacklisted_2'

    run check_all_modules_blacklisted "${VULNERABLE_VHOST[@]}"
    (( status == 0 ))
}


@test "check_all_modules_blacklisted -- not blacklisted one module #1" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_not_blacklisted_1'

    run check_all_modules_blacklisted "${VULNERABLE_VHOST[@]}"
    (( status == 1 ))
}


@test "check_all_modules_blacklisted -- not blacklisted one module #2" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_not_blacklisted_2'

    run check_all_modules_blacklisted "${VULNERABLE_VHOST[@]}"
    (( status == 1 ))
}


@test "check_all_modules_blacklisted -- not blacklisted multiple modules" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_multiple_not_blacklisted'

    run check_all_modules_blacklisted "${VULNERABLE_BT[@]}"
    (( status == 1 ))
}


@test "check_all_modules_blacklisted -- partially blacklisted multiple modules" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_multiple_partially_blacklisted'

    run check_all_modules_blacklisted "${VULNERABLE_BT[@]}"
    (( status == 1 ))
}


@test "check_all_modules_blacklisted -- blacklisted multiple modules" {
    export MOCK_MODPROBE_PATH='file_mocks/modprobe_multiple_blacklisted'

    run check_all_modules_blacklisted "${VULNERABLE_BT[@]}"
    (( status == 0 ))
}
