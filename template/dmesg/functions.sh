#!/bin/bash

# Copyright (c) 2020  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

check_dmesg() {
    # Checks if dmesg log or dmesg command contains the given string.
    #
    # Args:
    #     search_string - string to look for in dmesg and dmesg log
    #
    # Returns:
    #     0 if given string present, otherwise 1
    #
    # Notes:
    #     MOCK_DMESG_PATH can be used to mock /var/log/dmesg file

    local search_string="$1"
    local dmesg_log=${MOCK_DMESG_PATH:-/var/log/dmesg}
    local dmesg_cmd
    dmesg_cmd=$( dmesg )
    local journalctl_output
    local journalctl_success


    if grep --quiet -F "$search_string" "$dmesg_log" 2>/dev/null ; then
        return 0
    fi
    if grep --quiet -F "$search_string" <<< "$dmesg_cmd"; then
        return 0
    fi

    if command -v journalctl &> /dev/null; then
        journalctl_output="$( journalctl -k 2>/dev/null )"
        # Store inverted output value as a flag that is true when the command ended with a zero return value.
        # shellcheck disable=SC2181
        journalctl_success=$(( ! $? ))
        if (( journalctl_success )) ; then
            if grep --quiet -F "$search_string" <<< "$journalctl_output"; then
                return 0
            fi
        fi
    fi

    return 1
}
