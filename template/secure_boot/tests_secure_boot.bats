#!/usr/bin/env bats

. test_harness

export RHEL7_SECBOOT_DMESG="Secure boot enabled"

@test "secure_boot - Secure boot enabled (dmesg)" {
    dmesg() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    journalctl() {
        return 1
    }
    mokutil() {
        return 1
    }
    command() {
        if [[ "$2" == "mokutil" || "$2" == "journalctl" ]]; then
            return 1
        fi
        command "$@"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export -f command
    export MOCK_DMESG_PATH=/dev/null
    export MOCK_EFI_PATH=/dev/null

    run secure_boot_dmesg
    (( status == 0 ))

    run secure_boot_mokutil
    (( status == 1 ))

    run secure_boot_firmware
    (( status == 1 ))

    run secure_boot
    (( status == 0 ))
}


@test "secure_boot - Secure boot not enabled" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    mokutil() {
        echo "nothing relevant"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=/dev/null
    export MOCK_EFI_PATH=file_mocks/efivars/empty

    run secure_boot_dmesg
    (( status == 1 ))

    run secure_boot_mokutil
    (( status == 1 ))

    run secure_boot_firmware
    (( status == 1 ))

    run secure_boot
    (( status == 1 ))
}


@test "secure_boot - Secure boot enabled (dmesg via journalctl)" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    mokutil() {
        echo "EFI variables are not supported on this system"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=/dev/null
    export MOCK_EFI_PATH=file_mocks/efivars/disabled

    run secure_boot_dmesg
    (( status == 0 ))

    run secure_boot_mokutil
    (( status == 1 ))

    run secure_boot_firmware
    (( status == 1 ))

    run secure_boot
    (( status == 0 ))
}


@test "secure_boot - Secure boot enabled (mokutil)" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    mokutil() {
        echo "SecureBoot enabled"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=file_mocks/dmesg/disabled
    export MOCK_EFI_PATH=file_mocks/efivars/nonexistent

    run secure_boot_dmesg
    (( status == 1 ))

    run secure_boot_mokutil
    (( status == 0 ))

    run secure_boot_firmware
    (( status == 1 ))

    run secure_boot
    (( status == 0 ))
}


@test "secure_boot - Secure boot enabled (firmware)" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    mokutil() {
        echo "nothing relevant"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=/dev/null
    export MOCK_EFI_PATH=file_mocks/efivars/enabled

    run secure_boot_dmesg
    (( status == 1 ))

    run secure_boot_mokutil
    (( status == 1 ))

    run secure_boot_firmware
    (( status == 0 ))

    run secure_boot
    (( status == 0 ))
}


@test "secure_boot - Secure boot enabled (dmesg via log)" {
    dmesg() {
        echo "nothing relevant"
    }
    journalctl() {
        echo "nothing relevant"
    }
    mokutil() {
        echo "EFI variables are not supported on this system"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=file_mocks/dmesg/enabled
    export MOCK_EFI_PATH=file_mocks/efivars/disabled

    run secure_boot_dmesg
    (( status == 0 ))

    run secure_boot_mokutil
    (( status == 1 ))

    run secure_boot_firmware
    (( status == 1 ))

    run secure_boot
    (( status == 0 ))
}


@test "secure_boot - Secure boot enabled (dmesg, dmesg via log, firmware, mokutil)" {
    dmesg() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    journalctl() {
        echo "something"
        echo "Secure boot enabled"
        echo "something"
    }
    mokutil() {
        echo "SecureBoot enabled"
    }
    export -f dmesg
    export -f journalctl
    export -f mokutil
    export MOCK_DMESG_PATH=file_mocks/dmesg/enabled
    export MOCK_EFI_PATH=file_mocks/efivars/enabled

    run secure_boot_dmesg
    (( status == 0 ))

    run secure_boot_mokutil
    (( status == 0 ))

    run secure_boot_firmware
    (( status == 0 ))

    run secure_boot
    (( status == 0 ))
}
