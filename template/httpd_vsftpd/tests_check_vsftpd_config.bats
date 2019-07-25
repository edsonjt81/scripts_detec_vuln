#!/usr/bin/env bats

. test_harness


@test "check_vsftp_configs -- vulnerable #1" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_1.conf
    
    run check_vsftpd_config
    (( status == 0 ))
    [[ "$output" == "file_mocks/vsftpd/vsftpd_1.conf:ssl_enable=YES
file_mocks/vsftpd/vsftpd_1.conf:ssl_sslv3=YES" ]]
}


@test "check_vsftp_configs -- vulnerable #2" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_2.conf
    
    run check_vsftpd_config
    (( status == 0 ))
    [[ "$output" == "file_mocks/vsftpd/vsftpd_2.conf:ssl_enable = yes
file_mocks/vsftpd/vsftpd_2.conf:ssl_sslv3 = yes" ]]
}


@test "check_vsftp_configs -- not vulnerable #1" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_3.conf
    
    run check_vsftpd_config
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_vsftp_configs -- not vulnerable #2" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_4.conf
    
    run check_vsftpd_config
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_vsftp_configs -- not vulnerable #3" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_5.conf
    
    run check_vsftpd_config
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_vsftp_configs -- vulnerable #3" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_6.conf
    
    run check_vsftpd_config
    (( status == 0 ))
    [[ "$output" == "file_mocks/vsftpd/vsftpd_6.conf:ssl_enable = true
file_mocks/vsftpd/vsftpd_6.conf:ssl_sslv3 = 1" ]]
}


@test "check_vsftp_configs -- not vulnerable #4" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_7.conf
    
    run check_vsftpd_config
    (( status == 1 ))
    [[ "$output" == "" ]]
}


@test "check_vsftp_configs -- not vulnerable #5" {
    MOCK_VSFTP_CONFIG_PATH=file_mocks/vsftpd/vsftpd_8.conf
    
    run check_vsftpd_config
    (( status == 1 ))
    [[ "$output" == "" ]]
}
