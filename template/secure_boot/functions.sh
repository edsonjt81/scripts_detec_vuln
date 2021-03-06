#!/bin/bash

# Copyright (c) 2020  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

secure_boot_dmesg() {
    # Uses dmesg to detect whether secure boot is active.
    #
    # Returns:
    #     0 if secure boot is active, or 1 if it is not.

    check_dmesg "Secure boot enabled"
}


secure_boot_mokutil() {
    # Uses mokutil to detect whether secure boot is active.
    #
    # Returns:
    #     0 if secure boot is active, or 1 if it is not.

    if command -v mokutil &> /dev/null; then
        if [[ "$( mokutil --sb-state )" == "SecureBoot enabled" ]]; then
            return 0
        fi
    fi
    return 1
}


secure_boot_firmware() {
    # Uses /sys/firmware/efi/efivars/SecureBoot-* to detect whether secure boot is active.
    #
    # Returns:
    #     0 if secure boot is active, or 1 if it is not.
    #
    # Notes:
    #     MOCK_EFI_PATH can be used to mock /sys/firmware/efi/efivars directory

    # See https://github.com/koalaman/shellcheck/wiki/SC2144 for the reason of this for/if/break type of file existence check
    for sb_efivar in "${MOCK_EFI_PATH:-/sys/firmware/efi/efivars}"/SecureBoot-*; do
        if [[ -f "$sb_efivar" ]]; then
            if [[ "$(od --address-radix=n --format=u1 "$sb_efivar" | awk '{print $5}')" == "1" ]]; then
                return 0
            fi
            break
        fi
    done
    return 1
}


secure_boot() {
    # Detects whether Secure Boot is active.
    #
    # Returns:
    #     0 if secure boot is active, or 1 if it is not.
    #
    # NOTE How to use the return value:
    #     1) # Use the return value directly. Zero == True.
    #        if secure_boot; then echo "Secure Boot active"; fi
    #     2) # Store inverted return value as a flag that is true
    #        # when the command ended with a zero return value.
    #        secure_boot
    #        flag=$(( ! $? ))
    #        if (( flag )) ; then echo "Secure Boot active"; fi


    # All three work the same. They are all used here because relying only on
    # one way of detection might break on some non-standard configurations, e.g.:
    # * all dmesg logging is disabled and the system runs long enough so that dmesg wraps
    # * mokutil on an UEFI system is uninstalled
    # * efivars on an UEFI system is unmounted

    secure_boot_dmesg || secure_boot_mokutil || secure_boot_firmware
}
