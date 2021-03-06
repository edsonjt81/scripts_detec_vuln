#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

check_smt_enabled() {
    # Check if hyper-threading (SMT) is enadled.
    # 'lscpu' is not available on rhel-5 and cannot be used for detection.
    #
    # Returns:
    #     1 if smt enabled, otherwise 0
    #
    # Notes:
    #     MOCK_CPU_DIRS_PATH can be used to mock files in /sys/devices/system/cpu.

    local sysfs_cpu_dirs=${MOCK_CPU_DIRS_PATH:-/sys/devices/system/cpu}
    local cpu_number
    local main_thread_number
    local siblings_list_file

    # At least one SMT CPU thread is enabled.
    for cpu_directory in "${sysfs_cpu_dirs}"/cpu[0-9]*; do
        cpu_number="${cpu_directory##*cpu}"
        siblings_list_file="$cpu_directory/topology/thread_siblings_list"
        # Example output with disabled SMT: '0'
        # Example output with enabled SMT: '0-1'
        if [[ -r "${siblings_list_file}" ]]; then
            main_thread_number=$( < "$siblings_list_file" )
            if (( cpu_number != main_thread_number )); then
                return 1  # SMT enabled
            fi
        fi
    done

    return 0  # SMT disabled
}


require_root() {
    # Checks if user is root.
    #
    # Side effects:
    #     Exits when user is not root.
    #
    # Notes:
    #     MOCK_EUID can be used to mock EUID variable

    local euid=${MOCK_EUID:-$EUID}

    # Am I root?
    if (( euid != 0 )); then
        echo "This script must run with elevated privileges (e.g. as root)"
        exit 1
    fi
}


get_virtualization() {
    # Gets virtualization type.
    #
    # Prints:
    #     Virtualization type, "None", or "virt-what not available"

    local virt
    if command -v virt-what &> /dev/null; then
        virt=$( virt-what 2>&1 | tr '\n' ' ' )
        if [[ "$virt" ]]; then
            echo "$virt"
        else
            echo "None"
        fi
    else
        echo "virt-what not available"
    fi
}
