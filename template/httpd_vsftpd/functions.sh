#!/bin/bash

# Copyright (c) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# It is not needed to check imported functions as they are checked separately
# shellcheck disable=SC1091
. ../array_utils/functions.sh

check_httpd_configs() {
    # Searches httpd config files for usage of SSLv3.
    #
    # Prints:
    #     Lines which contain vulnerable configurations.
    #
    # Returns:
    #     0 when vulnerable configurations were found, 1 otherwise.
    #
    # Notes:
    #     MOCK_HTTPD_CONFIGS_PATH can be used to mock /etc/httpd directory

    local httpd_configs=${MOCK_HTTPD_CONFIGS_PATH:-/etc/httpd}

    local MINUS_ALL='^[^#]*\-all'
    local PLUS_SSLV3='^[^#]*\+sslv3'
    local MINUS_SSLV3='^[^#]*\-sslv3'
    local ALL='^[^#]*all'
    local SSLV3='^[^#]*sslv3'

    ssl_protocol=$( grep -E -R -s -i '^[[:space:]]*SSLProtocol' "$httpd_configs/conf/httpd.conf" "$httpd_configs/conf.d" )
    nss_protocol=$( grep -E -R -s -i '^[[:space:]]*NSSProtocol' "$httpd_configs/conf/httpd.conf" "$httpd_configs/conf.d" )
    ssl_protocol_lines=()
    nss_protocol_lines=()

    if [[ "$ssl_protocol" ]]; then
        read_array ssl_protocol_lines <<< "$ssl_protocol"
    fi
    if [[ "$nss_protocol" ]]; then
        read_array nss_protocol_lines <<< "$nss_protocol"
    fi

    vulnerable_protocol_lines=()
    for line in "${ssl_protocol_lines[@]}"; do
        line_lower=$( tr "[:upper:]" "[:lower:]" <<< "$line" )
        if [[ ( "$line_lower" =~ $MINUS_ALL && "$line_lower" =~ $PLUS_SSLV3 ) || \
              ( ! "$line_lower" =~ $MINUS_ALL && ! "$line_lower" =~ $MINUS_SSLV3 ) ]]; then
            vulnerable_protocol_lines+=("$line")
        fi
    done
    for line in "${nss_protocol_lines[@]}"; do
        line_lower=$( tr "[:upper:]" "[:lower:]" <<< "$line" )
        if [[ "$line_lower" =~ $ALL || "$line_lower" =~ $SSLV3 ]]; then
            vulnerable_protocol_lines+=("$line")
        fi
    done

    if (( ${#vulnerable_protocol_lines[@]} > 0 )); then
        for line in "${vulnerable_protocol_lines[@]}"; do
            echo "$line"
        done
        return 0  # Found vulnerable config lines
    else
        return 1
    fi
}


check_vsftpd_config() {
    # Searches vsftp config files for usage of SSLv3.
    #
    # Prints:
    #     Lines which contain vulnerable configurations.
    #
    # Returns:
    #     0 when vulnerable configurations were found, 1 otherwise.
    #
    # Notes:
    #     MOCK_VSFTP_CONFIG_PATH can be used to mock /etc/vsftpd/vsftpd.conf file

    local vsftpd_config=${MOCK_VSFTP_CONFIG_PATH:-/etc/vsftpd/vsftpd.conf}

    ssl_enable=$( grep -E -R -s -i '^[[:space:]]*ssl_enable[[:space:]]*=[[:space:]]*(yes|true|1)' "$vsftpd_config" )
    ssl_sslv3=$( grep -E -R -s -i '^[[:space:]]*ssl_sslv3[[:space:]]*=[[:space:]]*(yes|true|1)' "$vsftpd_config" )

    if [[ "$ssl_enable" && "$ssl_sslv3" ]]; then
        echo "$vsftpd_config:$ssl_enable"
        echo "$vsftpd_config:$ssl_sslv3"
        return 0  # Found vulnerable config lines
    else
        return 1
    fi
}


check_access() {
    # Checks if main httpd config and vsftpd config are readable if said software
    # is installed.
    #
    # Side effects:
    #     Exits when cannot read necessary config files
    #
    # Notes:
    #     MOCK_HTTPD_CONFIGS_PATH can be used to mock /etc/httpd directory
    #     MOCK_VSFTP_CONFIG_PATH can be used to mock /etc/vsftpd/vsftpd.conf file

    httpd_packages="$1"
    vsftpd_packages="$2"

    local httpd_configs=${MOCK_HTTPD_CONFIGS_PATH:-/etc/httpd}
    local vsftpd_config=${MOCK_VSFTP_CONFIG_PATH:-/etc/vsftpd/vsftpd.conf}

    if [[ "$httpd_packages" ]]; then
        if [[ ! -r "$httpd_configs/conf/httpd.conf" ]]; then
            echo -e "${RED}Cannot read '$httpd_configs/conf/httpd.conf', make sure you have permissions.${RESET}"
            exit 1
        fi
    fi
    if [[ "$vsftpd_packages" ]]; then
        if [[ ! -r "$vsftpd_config" ]]; then
            echo -e "${RED}Cannot read '$vsftpd_config', make sure you have permissions.${RESET}"
            exit 1
        fi
    fi
}
