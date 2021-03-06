#!/usr/bin/env bats

. test_harness


@test "check_httpd_configs -- vulnerable #1" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/01

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/01/conf/httpd.conf:SSLProtocol -ALL +SSLv3
file_mocks/httpd/01/conf.d/config.conf:SSLProtocol All
file_mocks/httpd/01/conf.d/config.conf:NSSProtocol ALL" ]]
}


@test "check_httpd_configs -- vulnerable #2" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/02

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/02/conf/httpd.conf:SSLProtocol -ALL +SSLv3" ]]
}


@test "check_httpd_configs -- vulnerable #3" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/03

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/03/conf.d/config.conf:NSSProtocol SSLV3 TLSV1.0" ]]
}


@test "check_httpd_configs -- vulnerable #4" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/04

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/04/conf/httpd.conf:    SSLProtocol all -SSLv2" ]]
}


@test "check_httpd_configs -- vulnerable #5" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/05

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/05/conf.d/config.conf:NSSProtocol ALL" ]]
}


@test "check_httpd_configs -- not vulnerable #1" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/06

    run check_httpd_configs
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_httpd_configs -- vulnerable #6" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/07

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/07/conf.d/config.conf:NSSProtocol ALL" ]]
}


@test "check_httpd_configs -- not vulnerable #2" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/08

    run check_httpd_configs
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_httpd_configs -- not vulnerable #3" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/09

    run check_httpd_configs
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_httpd_configs -- vulnerable #7" {
    MOCK_HTTPD_CONFIGS_PATH=file_mocks/httpd/10

    run check_httpd_configs
    (( status == 0 ))
    [[ "$output" == "file_mocks/httpd/10/conf.d/config.conf:NSSProtocol ALL" ]]
}
