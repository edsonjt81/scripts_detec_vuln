#!/usr/bin/env bats

. test_harness


@test "check_wifi_interfaces_active -- some" {
    export MOCK_SYS_CLASS_NET_PATH=file_mocks/network/net1
    
    run check_wifi_interfaces_active
    [[ "$output" == *"wlan0"* ]]
    [[ "$output" != *"wlp2s0"* ]]
}


@test "check_wifi_interfaces_Active -- none" {
    export MOCK_SYS_CLASS_NET_PATH=file_mocks/network/net3

    run check_wifi_interfaces_active
    [[ "$output" != *"wlan0"* ]]
    [[ "$output" != *"wlp2s0"* ]]
}
