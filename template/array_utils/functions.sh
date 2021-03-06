#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

read_array() {
    # Reads lines from stdin and saves them in a global array referenced by a name.
    # It is a poor man's readarray compatible with Bash 3.1.
    #
    # Args:
    #     array_name - name of the global array
    #
    # Side effects:
    #     Overwrites content of the array 'array_name' with lines from stdin
    local array_name="$1"

    local i=0
    while IFS= read -r line; do
        read -r "${array_name}[$(( i++ ))]" <<< "$line"
    done
}


unregex() {
    # Escapes characters which are special in `sed` when used in ERE mode (`sed -r`).
    # http://stackoverflow.com/a/2705678/120999
    # It does not handle newlines in the string.
    #
    # Args:
    #     string - string to be escaped
    #
    # Prints:
    #     Escaped string.

    string="$1"

    sed 's/[]\/()$*.^|[]/\\&/g' <<< "$string"
}


split_array() {
    # Splits a string to array of strings based on separator which can be multi-character.
    # It does not handle newlines in the string.
    #
    # Args:
    #     array_name - name of the global array
    #     separator - string to be used as a separator, may be multi-character
    #     string - input string
    #
    # Side effects:
    #     Overwrites content of the array 'array_name' with split strings

    local array_name="$1"
    local separator
    separator=$( unregex "$2" )
    local string="$3"

    read_array "$array_name" <<< "$( sed -r 's/'"$separator"'/\n/g' <<< "$string" )"
}


print_array() {
    # Prints array, one element per line.
    #
    # Args:
    #     array_name - name of the global array
    #
    # Prints:
    #     Content of the array, one element per line.

    local array_name="$1[@]"
    local array=( "${!array_name}" )

    for (( i = 0; i < "${#array[@]}"; i++ )); do
        echo "${array[i]}"
    done
}


in_array() {
    # Checks if an element is contained in the array.
    #
    # Args:
    #    array_name - name of the global array
    #
    # Returns:
    #    0 if element is found, 1 otherwise.

    local array_name="$1[@]"
    local array=( "${!array_name}" )
    local element="$2"

    for (( i = 0; i < "${#array[@]}"; i++ )); do
        if [[ "$element" == "${array[i]}" ]]; then
            return 0
        fi
    done
    return 1
}
