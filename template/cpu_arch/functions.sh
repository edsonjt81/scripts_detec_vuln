#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

check_arch() {
    # Checks CPU architecture against a list of vulnerable architectures.
    #
    # Args:
    #     cpu_arch - CPU architecture as determined by 'lscpu' or 'uname -p'
    #     vulnerable_archs - An array of vulnerable architectures
    #
    # Prints:
    #     Detected vulnerable architecture, or nothing

    local cpu_arch="$1"
    shift
    local vulnerable_archs=( "$@" )

    for tested_arch in "${vulnerable_archs[@]}"; do
        if [[ "$cpu_arch" == *"$tested_arch"* ]]; then
            echo "$cpu_arch"
            break
        fi
    done
}

detect_cpu_arch() {
    # Gets CPU architecture of the system from multiple sources.
    #
    # If `uname -p` provides the information, that is used.
    # If not, it falls back to `uname -m`, even though it technically
    # doesn't describe the CPU architecture on some machines.
    #
    # Prints:
    #     Detected architecture, e.g. 'x86_64'.

    local uname

    uname=$( uname -p )
    if [[ "$uname" == "unknown" || "$uname" == "" ]]; then
        uname=$( uname -m )
    fi

    echo "$uname"
}

