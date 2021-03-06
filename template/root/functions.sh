#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

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
