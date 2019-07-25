#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VULNERABLE_VERSIONS=(
    # Example: 'samba3x-3.5.4-0.70.el5'
)


compare() {
    # Compares two versions strings, such as 2.6.32-131, using comparison operators.
    #
    # Args:
    #     left - left version string to compare
    #     expression - valid comparison operator, or their combination, e.g. >, >=, =, <=, <, <>
    #     right - left version string to compare
    #
    # Returns:
    #     0 if comparison passes, 1 otherwise

    local left
    local right
    local expression="$2"

    read -r -a left <<< "$( tr ".-" "  " <<< "$1" )"
    read -r -a right <<< "$( tr ".-" "  " <<< "$3" )"

    # Find longer version string
    local nr
    if (( ${#left[@]} > ${#right[@]} )); then
        nr=${#left[@]}
    else
        nr=${#right[@]}
    fi

    # Balance shorter version string
    while (( ${#left[@]} < nr )); do
        left+=( "0" )
    done
    while (( ${#right[@]} < nr )); do
        right+=( "0" )
    done

    if [[ "$expression" == *">"* ]]; then
        for (( i = 0; i < nr; i++ )); do
            (( left[i] < right[i] )) && break
            (( left[i] > right[i] )) && return 0
        done
    fi

    if [[ "$expression" == *"<"* ]]; then
        for (( i = 0; i < nr; i++ )); do
            (( left[i] > right[i] )) && break
            (( left[i] < right[i] )) && return 0
        done
    fi

    if [[ "$expression" == *"="* ]]; then
        for (( i = 0; i < nr; i++ )); do
            (( left[i] != right[i] )) && break
            (( i == nr - 1 )) && return 0
        done
    fi

    return 1
}


check_package() {
    # Checks if installed package is in list of vulnerable packages.
    #
    # Args:
    #     installed_packages - installed packages string as returned by 'rpm -qa package'
    #                          (may be multiline)
    #     vulnerable_versions - an array of vulnerable versions
    #
    # Prints:
    #     First vulnerable package string as returned by 'rpm -qa package', or nothing

    # Convert to array, use word splitting on purpose
    # shellcheck disable=SC2206
    local installed_packages=( $1 )
    shift
    local vulnerable_versions=( "$@" )

    for tested_package in "${vulnerable_versions[@]}"; do
        for installed_package in "${installed_packages[@]}"; do
            installed_package_without_arch="${installed_package%.*}"
            if [[ "$installed_package_without_arch" == "$tested_package" ]]; then
                echo "$installed_package"
                return 0
            fi
        done
    done
}


get_installed_packages() {
    # Checks for installed packages of a 'package_name'. Compatible with RHEL5.
    #
    # Args:
    #     package_name - package name string
    #
    # Prints:
    #     Lines with N-V-R.A strings of all installed packages.

    local package_name="$1"

    rpm -qa --queryformat="%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n" "$package_name"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    result_installed_packages=$( get_installed_packages "TODO" )
    if [[ ! "$result_installed_packages" ]]; then
        echo -e "${GREEN}'TODO' is not installed${RESET}."
        exit 0
    fi

    vulnerable_package=$( check_package "$result_installed_packages" "${VULNERABLE_VERSIONS[@]}" )
    echo "$vulnerable_package"
fi
