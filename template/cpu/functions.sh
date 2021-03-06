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

check_cpu_flag() {
    # Checks CPU flag if it is in list of cpu flags.
    #
    # Args:
    #     flag - cpu flag string to check
    #     cpuinfo_flags - an array of cpu flags as parsed from /proc/cpuinfo
    #
    # Prints:
    #     Detected vulnerable cpu flag or nothing
    local flag="$1"
    shift
    local cpuinfo_flags=( "$@" )

    for tested_flag in "${cpuinfo_flags[@]}"; do
        if [[ "$flag" == "$tested_flag" ]]; then
            echo "$flag"
            break
        fi
    done
}

check_cpu_model() {
    # Checks CPU model if it is in list of vulnerable models.
    #
    # Args:
    #     model - cpu model number string as parsed from /proc/cpuinfo
    #     vulnerable_models - an array of vulnerable cpu model numbers
    #
    # Prints:
    #     Vulnerable cpu model number as parsed from /proc/cpuinfo, or nothing
    local model="$1"
    shift
    local vulnerable_models=( "$@" )

    model=$(printf "0x%X" "$model")

    for tested_model in "${vulnerable_models[@]}"; do
        if [[ "$model" == "$tested_model" ]]; then
            echo "$model"
            break
        fi
    done
}
