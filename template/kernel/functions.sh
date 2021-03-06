#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VULNERABLE_KERNELS=(
    # Example: '2.6.18-8.1.1.el5'
    "2.6.32-71.7.1.el6"  # TODO this is just for template testing
    "3.10.0-123.el7"  # TODO this is just for template testing

)

KPATCH_MODULE_NAMES=(
    # Example: "kpatch_3_10_0_327_36_1_1_1"
    "kpatch_3_10_0_327_36_1_1_1"  # TODO this is just for template testing
)

VULNERABLE_KERNEL_MODULE_NAMES=(
    'bnep'  # TODO this is just for template testing
    'bluetooth'  # TODO this is just for template testing
    'btusb'  # TODO this is just for template testing
)

# for detection of the VULNERABLE_KERNEL_MODULE_NAMES being blocklisted
MITIGATION_PATTERNS=()

# add a regexp into the MITIGATION_PATTERNS array for every module name
for module_name in "${VULNERABLE_KERNEL_MODULE_NAMES[@]}"; do
    MITIGATION_PATTERNS+=( "^[[:space:]]*install[[:space:]]+${module_name}[[:space:]]+/bin/true" )
done


check_kernel() {
    # Checks kernel if it is in list of vulnerable kernels.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #     vulnerable_versions - an array of vulnerable versions
    #
    # Prints:
    #     Vulnerable kernel string as returned by 'uname -r', or nothing

    local running_kernel="$1"
    shift
    local vulnerable_versions=( "$@" )

    for tested_kernel in "${vulnerable_versions[@]}"; do
        if [[ "$running_kernel" == *"$tested_kernel"* ]]; then
            echo "$running_kernel"
            break
        fi
    done
}


check_kpatch() {
    # Checks if specific kpatch listed in a kpatch list is applied.
    #
    # Args:
    #     kpatch_module_names - an array of kpatches
    #
    # Prints:
    #     Found kpatch, or nothing

    local kpatch_module_names=( "$@" )
    local modules

    # Get loaded kernel modules
    modules=$( lsmod )

    # Check if kpatch is installed
    for tested_kpatch in "${kpatch_module_names[@]}"; do
        if [[ "$modules" == *"$tested_kpatch"* ]]; then
            echo "$tested_kpatch"
            break
        fi
    done
}


check_user_namespaces_enabled() {
    # Checks if 'user_namespace.enable=1' is contained in '/proc/cmdline'
    #
    # Returns:
    #     0 if user namespaces are enabled, othervise different exit code
    #
    # Notes:
    #     MOCK_CMDLINE_PATH can be used to mock /proc/cmdline file

    cmdline_path=${MOCK_CMDLINE_PATH:-/proc/cmdline}

    grep -E 'user_namespace\.enable=1' "$cmdline_path" &> /dev/null  # return value
}


check_kernel_modules() {
    # Checks if modules listed in a list are loaded.
    #
    # Args:
    #     kernel_module_names - an array of kernel module names
    #
    # Prints:
    #     Found kernel module names as one string, or an empty string

    local kernel_module_names=( "$@" )
    local modules
    local matching_modules=()

    # Get loaded kernel modules
    modules=$( lsmod )

    for tested_module in "${kernel_module_names[@]}"; do
        if [[ "$modules" == *"$tested_module"* ]]; then
            matching_modules+=( "$tested_module" )
        fi
    done

    echo "${matching_modules[*]}"
}


check_all_modules_blocklisted() {
    # Checks if all specified kernel modules are blocklisted.
    #
    # Args:
    #     module_names - an array of kernel modules to be checked
    #
    # Returns:
    #     0 if all modules were blocklisted, 1 otherwise
    #
    # Notes:
    #     MOCK_MODPROBE_PATH can be used to mock /etc/modprobe.d directory

    local modprobe_dir=${MOCK_MODPROBE_PATH:-/etc/modprobe.d}

    local module_names=( "$@" )
    local mitigation_patterns=()
    local current_pattern_found

    # Prepare regular expressions
    for module_name in "${module_names[@]}"; do
        mitigation_patterns+=( "^[[:space:]]*install[[:space:]]+${module_name}[[:space:]]+/bin/(true|false)" )
    done

    # Check if all patterns are found at least once
    for pattern in "${mitigation_patterns[@]}"; do
        current_pattern_found=0
        # Check recommended mitigation
        for file in "$modprobe_dir/"*; do
            if grep -E --quiet "$pattern" "$file"; then
                current_pattern_found=1
                break
            fi
        done
        if (( ! current_pattern_found )); then
            return 1  # No need to search for the rest of the patterns, already have the answer
        fi
    done

    return 0
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    vulnerable_kernel=$( check_kernel "$running_kernel" "${VULNERABLE_KERNELS[@]}" )
    applied_kpatch=$( check_kpatch "${KPATCH_MODULE_NAMES[@]}" )

    check_user_namespaces_enabled
    # Store result as a flag, 1 as True, 0 as False
    # shellcheck disable=SC2181
    user_namespaces_enabled=$(( !$? ))

    vulnerable_loaded_kernel_modules=$( check_kernel_modules "${VULNERABLE_KERNEL_MODULE_NAMES[@]}" )

    check_all_modules_blocklisted "${VULNERABLE_KERNEL_MODULE_NAMES[@]}"
    # Store result as a flag, 1 as True, 0 as False
    # shellcheck disable=SC2181
    all_vulnerable_modules_loading_disabled=$(( !$? ))

    # Check sysctl mitigation
    sysctl_option='vm\.legacy_va_layout'
    sysctl_line_pattern='^[[:blank:]]*'"$sysctl_option"'[[:blank:]]*\=[[:blank:]]*\([[:digit:]]\+\).*$'

    sysctl_live_line=$( sysctl -a 2> /dev/null | grep "$sysctl_line_pattern" )
    # Can't use bash string substitution because we use sed to extract a specific capturing group.
    # shellcheck disable=SC2001
    sysctl_live_value=$( sed 's/'"$sysctl_line_pattern"'/\1/g' <<< "$sysctl_live_line" )

    sysctl_conf_line=$( grep "$sysctl_line_pattern" /etc/sysctl.conf )
    # Can't use bash string substitution because we use sed to extract a specific capturing group.
    # shellcheck disable=SC2001
    sysctl_conf_value=$( sed 's/'"$sysctl_line_pattern"'/\1/g' <<< "$sysctl_conf_line" )

    SYSCTL_MITIGATED_FULLY="SYSCTL_MITIGATED_FULLY"
    SYSCTL_MITIGATED_ONLY_LIVE="SYSCTL_MITIGATED_ONLY_LIVE"
    SYSCTL_NO_MITIGATION="SYSCTL_NO_MITIGATION"
    SYSCTL_RECOMMENDED_VALUE=1

    sysctl_mitigation=${SYSCTL_NO_MITIGATION}
    if (( sysctl_live_value == SYSCTL_RECOMMENDED_VALUE)); then
        sysctl_mitigation=${SYSCTL_MITIGATED_ONLY_LIVE}
    fi
    # This is the only correct mitigation
    # TODO: based on the type of sysctl, it might be better to use if (( sysctl_live_value >= SYSCTL_RECOMMENDED_VALUE && sysctl_conf_value == sysctl_live_value )); then
    if (( sysctl_live_value == SYSCTL_RECOMMENDED_VALUE && sysctl_conf_value == sysctl_live_value )); then
        sysctl_mitigation=${SYSCTL_MITIGATED_FULLY}
    fi

    echo "$vulnerable_kernel $applied_kpatch $user_namespaces_enabled $vulnerable_loaded_kernel_modules"
    echo "$all_vulnerable_modules_loading_disabled $sysctl_mitigation"
fi
