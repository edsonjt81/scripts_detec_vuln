#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VERSION="1.3"

# This script is meant for downloading all CPU vulnerability detection scripts, veryfying their
# GPG signatures, and then executing them in a batch.


basic_args() {
    # Parses basic commandline arguments and sets basic environment.
    #
    # Side effects:
    #     Exits if --help option is used
    #     Sets COLOR constants and debug variable, as well as it stores variable values for some
    #     options

    RED="\\033[1;31m"
    YELLOW="\\033[1;33m"
    GREEN="\\033[1;32m"
    BOLD="\\033[1m"
    RESET="\\033[0m"

    parameters=()

    while [[ "$1" ]]; do
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            echo "Usage: $( basename "$0" ) [-r | --run] [-n | --no-colors] [-d | --debug] [-p PROXY | --proxy PROXY ]"
            echo
            echo "By default the script downloads all CPU vulnerability detection scripts"
            echo "and checks their GPG signatures."
            echo
            echo "To run downloaded detection scripts in a batch, run this script with --run"
            echo "option. You can also add other options which will then be forwarded"
            echo "to executed detection scripts."
            echo
            echo "PROXY is supposed to be in the following format: http://user:pass@proxy-server:port"
            exit 1
        elif [[ "$1" == "-n" || "$1" == "--no-colors" ]]; then
            RED=""
            YELLOW=""
            GREEN=""
            BOLD=""
            RESET=""
            parameters+=( "$1" )
        elif [[ "$1" == "-r" || "$1" == "--run" ]]; then
            run=true
        elif [[ "$1" == "-p" || "$1" == "--proxy" ]]; then
            shift
            proxy="$1"
        elif [[ "$1" == "-d" || "$1" == "--debug" ]]; then
            parameters+=( "$1" )
        fi
        shift
    done
}


VULNERABILITY_ARTICLES=(
    "https://access.redhat.com/security/vulnerabilities/speculativeexecution"
    "https://access.redhat.com/security/vulnerabilities/ssbd"
    "https://access.redhat.com/security/vulnerabilities/L1TF"
    "https://access.redhat.com/security/vulnerabilities/mds"
    "https://access.redhat.com/articles/tsx-asynchronousabort"
    "https://access.redhat.com/security/vulnerabilities/ifu-page-mce"
)

GPG_SERVERS=( "keys.gnupg.net" "hkps.pool.sks-keyservers.net" "pgp.mit.edu" )


analyze_text(){
    text="$1"

    if grep -q -i 'not vulnerable' <<< "$text" && grep -q -i 'mitigation' <<< "$text"; then
        echo -e "${GREEN}Mitigated${RESET}"
    elif grep -q -i 'not vulnerable' <<< "$text" && grep -q -i 'not affected' <<< "$text"; then
        echo -e "${GREEN}Not affected${RESET}"
    elif grep -q -i 'vulnerable' <<< "$text"; then
        echo -e "${RED}Vulnerable${RESET}"
    elif grep -q -i 'mitigated' <<< "$text" || grep -q -i 'mitigation' <<< "$text"; then
        echo -e "${GREEN}Mitigated${RESET}"
    elif grep -q -i 'not affected' <<< "$text"; then
        echo -e "${GREEN}Not affected${RESET}"
    elif grep -q -i 'CPU is affected but KVM not used' <<< "$text"; then
        echo -e "${GREEN}Affected but known exploitation path is not available${RESET}"
    else
        echo -e "${BOLD}Unknown${RESET}"
    fi
}


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
        else
            # Some RHEL 6 versions do not support it either
            if [[ "$( curl -s -S --tlsv1.2 2>&1 )" == *"option --tlsv1.2: is unknown"* ]]; then
                echo -e "Unfortunately, the downloading part of this script does not work with your"
                echo -e "version of curl as it does not support newer TLS protocol versions."
                echo -e "Depending on your system you may try to update 'curl' and 'nss' packages or"
                echo -e "run it on different system and copy the results to this machine before continuing."
                exit 1
            fi
        fi

        # Get GPG key
        echo -e "${BOLD}Getting GPG key${RESET} ... this may take a while"

        for server in "${GPG_SERVERS[@]}"; do
            if [[ "$proxy" ]]; then
                echo "> gpg2 --keyserver $server --keyserver-options http-proxy=$proxy --recv 8B1220FC564E9583200205FF7514F77D8366B0D9"
                gpg2 --keyserver "$server" --keyserver-options http-proxy="$proxy" --recv 8B1220FC564E9583200205FF7514F77D8366B0D9
            else
                echo "> gpg --keyserver $server --recv 8B1220FC564E9583200205FF7514F77D8366B0D9"
                gpg --keyserver "$server" --recv 8B1220FC564E9583200205FF7514F77D8366B0D9
            fi
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
            if [[ "$proxy" ]]; then
                echo "> curl -s -S --tlsv1.2 -x $proxy $article"
                content=$( curl -s -S --tlsv1.2 -x "$proxy" "$article" )
            else
                echo "> curl -s -S --tlsv1.2 $article"
                content=$( curl -s -S --tlsv1.2 "$article" )
            fi
            result=$?
            if (( result != 0 )) ; then
                if (( result == 35 )); then
                    echo -e "${BOLD}SSL connect error, try updating 'nss' package.${RESET}"
                fi
                echo -e "${RED}Cannot download vulnerability article!${RESET}"
                exit 1
            fi
            script="$( sed -r -n 's/^.*(https[^ ]*\.sh)".*$/\1/p' <<< "$content" )"
            signature="$( sed -r -n 's/^.*(https[^ ]*\.sh\.asc)".*$/\1/p' <<< "$content" )"

            echo -e "${BOLD}Downloading detection script:${RESET} $script"
            if [[ "$proxy" ]]; then
                echo "> curl -s -S --tlsv1.2 -x $proxy -O $script"
                curl -s -S --tlsv1.2 -x "$proxy" -O "$script"
            else
                echo "> curl -s -S --tlsv1.2 -O $script"
                curl -s -S --tlsv1.2 -O "$script"
            fi
            result=$?
            if (( result != 0 )); then
                echo -e "${RED}Cannot download detection script!${RESET}"
                exit 1
            fi

            echo -e "${BOLD}Downloading signature:${RESET} $signature"
            if [[ "$proxy" ]]; then
                echo "> curl -s -S --tlsv1.2 -x $proxy -O $signature"
                curl -s -S --tlsv1.2 -x "$proxy" -O "$signature"
            else
                echo "> curl -s -S --tlsv1.2 -O $signature"
                curl -s -S --tlsv1.2 -O "$signature"
            fi
            result=$?
            if (( result != 0 )); then
                echo -e "${RED}Cannot download GPG signature!${RESET}"
                exit 1
            fi

            script_file="${script##*/}"
            signature_file="${signature##*/}"
            echo -e "${BOLD}Verify signature:${RESET} $signature_file <=> $script_file"
            echo "> gpg --verify $signature_file $script_file"
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
        scripts=( spectre-meltdown--*.sh cve-2018-3639--*.sh cve-2018-3620--*.sh
                  cve-2018-12130--*.sh cve-2019-11135--*.sh cve-2018-12207--*.sh )
        output=$(
            for script in "${scripts[@]}"; do
                echo -e "Executing $script"
                echo -e "============================================================"
                echo "> ./$script" "${parameters[@]}"
                bash "./$script" "${parameters[@]}" 2>&1
                return_code=$?
                echo -e "============================================================"
                echo -e "Return code: $return_code"
                echo
            done
        )
        echo "$output"

        # Make summary
        echo
        echo
        echo -e "${BOLD}SUMMARY:${RESET}"
        echo -e "============================================================"

        text=$( sed -r -n 's/^Variant #1 \(Spectre\): (.*)/\1/p' <<< "$output" )
        printf "CVE-2017-5753  (Spectre v1): "
        analyze_text "$text"

        text=$( sed -r -n 's/^Variant #2 \(Spectre\): (.*)/\1/p' <<< "$output" )
        printf "CVE-2017-5715  (Spectre v2): "
        analyze_text "$text"

        text=$( sed -r -n 's/^Variant #3 \(Meltdown\): (.*)/\1/p' <<< "$output" )
        printf "CVE-2017-5754  (Meltdown):   "
        analyze_text "$text"

        text=$( awk '/2018-3639/ { analyze = 1 } analyze && /Return code/ { exit } analyze && /This system is/ { print; exit }' <<< "$output" )
        printf "CVE-2018-3639  (SSBD):       "
        analyze_text "$text"

        text=$( awk '/2018-3620/ { analyze = 1 } analyze && /Return code/ { exit } analyze && /This system is/ { print; exit }' <<< "$output" )
        printf "CVE-2018-3620  (L1TF):       "
        analyze_text "$text"

        text=$( awk '/2018-12130/ { analyze = 1 } analyze && /Return code/ { exit } analyze && /Virtualization/ { bookmark = NR } (bookmark && NR == bookmark + 2) { print; exit }' <<< "$output" )
        printf "CVE-2018-12130 (MDS):        "
        analyze_text "$text"

        text=$( awk '/2019-11135/ { analyze = 1 } analyze && /Return code/ { exit } analyze && /Virtualization/ { bookmark = NR } (bookmark && NR == bookmark + 2) { print; exit }' <<< "$output" )
        printf "CVE-2019-11135 (TSX):        "
        analyze_text "$text"

        text=$( awk '/2018-12207/ { analyze = 1 } analyze && /Return code/ { exit } analyze && /Virtualization/ { bookmark = NR } analyze && /Kernel reports/ { bookmark = NR } (bookmark && NR == bookmark + 2) { print; exit }' <<< "$output" )
        printf "CVE-2018-12207 (IFU):        "
        analyze_text "$text"

        echo -e "============================================================"
    fi
fi
