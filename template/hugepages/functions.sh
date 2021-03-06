#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

check_transparent_hugepages() {
    # Checks if transparent hugepages are enabled on the system.
    #
    # Prints:
    #     Transparent hugepage enabled setting, e.g. [always] madvise never => always.
    #     If file does not exist, does not print anything.

    local thp_enabled_path=${MOCK_THP_ENABLED_PATH:-/sys/kernel/mm/transparent_hugepage/enabled}
    if [[ -f "$thp_enabled_path" ]]; then
        sed -r -n 's/^.*\[(.*)\].*$/\1/p' "$thp_enabled_path"
    fi
}


check_zero_page() {
    # Checks if the zero page is prevented from being mapped as a huge page.
    #
    # Prints:
    #     Transparent hugepage use_zero_page setting, i.e. 0 | 1.
    #     If file does not exist, does not print anything.

    local thp_zero_path=${MOCK_THP_ZERO_PATH:-/sys/kernel/mm/transparent_hugepage/use_zero_page}
    if [[ -f "$thp_zero_path" ]]; then
        cat "$thp_zero_path"
    fi
}
