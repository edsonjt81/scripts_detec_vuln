#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

selinux_check() {
    # Checks if SELinux is enabled.
    #
    # Returns:
    #     0 if SELinux is enabled and enforcing, otherwise different exit code
    #

    if command -v getenforce &> /dev/null 2>&1; then
        if [[ $( getenforce ) == "Enforcing" ]]; then
            return 0
        fi
    fi
    return 1
}


get_selinux_mode() {
    # Checks SELinux mode.
    #
    # Returns:
    #     0 when getenforce command is available, 1 otherwise
    #
    # Prints:
    #     SELinux mode in lowercase.

    if command -v getenforce &> /dev/null 2>&1; then
        getenforce | awk '{ print tolower($0) }'
        return 0
    fi
    return 1
}


get_selinux_policy() {
    # Checks SELinux policy.
    #
    # Returns:
    #     0 when sestatus command is available, 1 otherwise
    #
    # Prints:
    #     SELinux policy in lowercase.

    local policy

    if command -v sestatus &> /dev/null 2>&1; then
        policy=$( sestatus | awk '/Loaded policy name:/ { print $4 }' )
        if [[ ! "$policy" ]]; then
            # RHEL5
            policy=$( sestatus | awk '/Policy from config file:/ { print $5 }' )
        fi
        echo "$policy"
        return 0
    fi
    return 1
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    selinux_check
    # Store result as a flag, 1 as True, 0 as False
    # shellcheck disable=SC2181
    selinux=$(( !$? ))
    echo "$selinux"
fi
