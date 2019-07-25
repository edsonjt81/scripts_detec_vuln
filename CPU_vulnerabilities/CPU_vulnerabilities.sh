#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VERSION="1.0"

# This script is meant for downloading all CPU vulnerability detection scripts, veryfying their
# GPG signatures, and then executing them in a batch.


basic_args() {
    # Parses basic commandline arguments and sets basic environment.
    #
    # Args:
    #     parameters - an array of commandline arguments
    #
    # Side effects:
    #     Exits if --help parameters is used
    #     Sets COLOR constants and debug variable

    local parameters=( "$@" )

    RED="\\033[1;31m"
    YELLOW="\\033[1;33m"
    GREEN="\\033[1;32m"
    BOLD="\\033[1m"
    RESET="\\033[0m"
    for parameter in "${parameters[@]}"; do
        if [[ "$parameter" == "-h" || "$parameter" == "--help" ]]; then
            echo "Usage: $( basename "$0" ) [-r | --run] [-n | --no-colors] [-d | --debug]"
            echo
            echo "By default the script downloads all CPU vulnerability detection scripts"
            echo "and checks their GPG signatures."
            echo
            echo "To run downloaded detection scripts in a batch, run this script with --run"
            echo "option. You can also add other options which will then be forwarded"
            echo "to executed detection scripts."
            exit 1
        elif [[ "$parameter" == "-n" || "$parameter" == "--no-colors" ]]; then
            RED=""
            YELLOW=""
            GREEN=""
            BOLD=""
            RESET=""
        elif [[ "$parameter" == "-r" || "$parameter" == "--run" ]]; then
            run=true
        fi
    done
}



VULNERABILITY_ARTICLES=(
    "https://access.redhat.com/security/vulnerabilities/speculativeexecution"
    "https://access.redhat.com/security/vulnerabilities/ssbd"
    "https://access.redhat.com/security/vulnerabilities/L1TF"
    "https://access.redhat.com/security/vulnerabilities/mds"
)

GPG_SERVERS=( "keys.gnupg.net" "hkps.pool.sks-keyservers.net" "pgp.mit.edu" )

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    basic_args "$@"

    echo
    echo -e "${BOLD}CPU vulnerability combined detection script (v$VERSION)${RESET}"
    echo

    if [[ ! "$run" ]]; then
        # RHEL 5 cannot download files as curl only supports TLS1.0
        if uname -r | grep -q 'el5'; then
            echo -e "Unfortunately, the downloading part of this script does not work on RHEL 5"
            echo -e "as curl does not support newer TLS protocol versions. Run it on different"
            echo -e "system and copy the results to this machine before continuing."
            exit 1
        fi

        # Get GPG key
        echo -e "${BOLD}Getting GPG key${RESET} ... this may take a while"

        for server in "${GPG_SERVERS[@]}"; do
            echo "gpg --keyserver $server --recv 8B1220FC564E9583200205FF7514F77D8366B0D9"
            gpg --keyserver "$server" --recv 8B1220FC564E9583200205FF7514F77D8366B0D9
            result=$?
            if (( result == 0 )); then
                break
            fi
        done
        if (( result )); then
            echo -e "${RED}Could not import GPG key!${RESET}"
            exit 1
        else
            echo -e "${GREEN}GPG key imported${RESET}"
        fi
        echo

        # Get scripts
        for article in "${VULNERABILITY_ARTICLES[@]}"; do
            echo -e "${BOLD}Parsing vulnerability article:${RESET} $article"
            if ! content=$( curl -s -S "$article" ); then
                echo -e "${RED}Cannot download vulnerability article!${RESET}"
                exit 1
            fi
            script="$( sed -r -n 's/^.*(https[^ ]*\.sh)".*$/\1/p' <<< "$content" )"
            signature="$( sed -r -n 's/^.*(https[^ ]*\.sh\.asc)".*$/\1/p' <<< "$content" )"

            echo -e "${BOLD}Downloading detection script:${RESET} $script"
            if ! curl -s -S -O "$script"; then
                echo -e "${RED}Cannot download detection script!${RESET}"
                exit 1
            fi

            echo -e "${BOLD}Downloading signature:${RESET} $signature"
            if ! curl -s -S -O "$signature"; then
                echo -e "${RED}Cannot download GPG signature!${RESET}"
                exit 1
            fi

            script_file="${script##*/}"
            signature_file="${signature##*/}"
            echo -e "${BOLD}Verify signature:${RESET} $signature_file <=> $script_file"
            echo "gpg --verify $signature_file $script_file"
            if ! gpg --verify "$signature_file" "$script_file"; then
                echo -e "${RED}Signature check failed!${RESET}"
                # For security reasons remove the downloaded script which failed signature check
                # and exit
                rm "$script_file"
                exit 1
            else
                echo -e "${GREEN}Signature check passed${RESET}"
            fi

            echo
        done
        echo -e "Everything was downloaded successfully and the GPG signature checks passed."
        echo -e "Now run:"
        echo -e "${YELLOW}# bash $0 --run${RESET}"
    else
        # Run scripts
        scripts=( spectre-meltdown--*.sh cve-2018-3639--*.sh cve-2018-3620--*.sh cve-2018-12130--*.sh )
        for script in "${scripts[@]}"; do
            echo -e "Executing $script"
            echo -e "============================================================"
            bash ./"$script" "$@"
            return_code=$?
            echo -e "============================================================"
            echo -e "Return code: $return_code"
            echo
        done
    fi
fi
