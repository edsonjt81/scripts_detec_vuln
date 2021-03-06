#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

get_virtualization() {
    # Gets virtualization type.
    #
    # Prints:
    #     Virtualization type, "None", or "virt-what not available"

    local virt

    if command -v virt-what &> /dev/null; then
        virt=$( virt-what 2>&1 | tr '\n' ' ' | sed -r 's/[ ]$//' )
        if [[ "$virt" ]]; then
            echo "$virt"
        else
            echo "None"
        fi
    else
        echo "virt-what not available"
    fi
}
