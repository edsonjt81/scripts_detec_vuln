#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

check_wifi_interfaces() {
    # Checks if WiFi interfaces are present. This works on RHEL5, RHEL6, and RHEL7.
    #
    # Prints:
    #     List of WiFi interfaces
    #
    # Note:
    #     MOCK_SYS_CLASS_NET_PATH can be used to mock /sys/class/net directory

    local sys_class_net_path=${MOCK_SYS_CLASS_NET_PATH:-/sys/class/net}

    find "$sys_class_net_path" \( -name 'wlan*' -o -name 'wlp*' \) -printf "%f\n"
}


check_wifi_interfaces_active() {
    # Checks if active WiFi interfaces are present. This works on RHEL5, RHEL6, and RHEL7.
    #
    # Prints:
    #     List of active WiFi interfaces
    #
    # Note:
    #     MOCK_SYS_CLASS_NET_PATH can be used to mock /sys/class/net directory

    local sys_class_net_path=${MOCK_SYS_CLASS_NET_PATH:-/sys/class/net}
    local interfaces

    # Use word-splitting for multi-line value
    # shellcheck disable=SC2207
    interfaces=( $( check_wifi_interfaces ) )
    for interface in "${interfaces[@]}"; do
        if grep --quiet up "$sys_class_net_path/$interface/operstate"; then
            echo "$interface"
        fi
    done
}
