#!/usr/bin/env bats

. test_harness

VULNERABLE_VERSIONS=(
    "pkga-123-456"
    "pkga-123-457"
    "pkga-123-458"
    "pkgb-123-456"
    "pkgc-123-456"
)
export VULNERABLE_VERSIONS

@test "check_fixed_rpms_any -- 1" {
    rpmok=1
    rpm() {
        echo "pkga-123-457"
        echo "pkga-123-458"
        echo "pkga-123-459"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 1 ))
    [[ "$output" == "" ]]
}

@test "check_fixed_rpms_any -- 2" {
    rpm() {
        echo "pkga-123-557"
        echo "pkga-123-558"
        echo "pkga-123-559"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 1 ))
    [[ "$output" == "" ]]
}

@test "check_fixed_rpms_any -- 3" {
    rpm() {
        echo "pkga-123-457"
        echo "pkga-123-458"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 0 ))
    [[ "$output" == "" ]]
}

@test "check_fixed_rpms_any -- 4" {
    rpm() {
        echo "pkgd-123-457"
        echo "pkgd-123-458"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 1 ))
    [[ "$output" == "" ]]
}

@test "check_fixed_rpms_any -- 5" {
    rpm() {
        echo "pkgd-123-458"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 1 ))
    [[ "$output" == "" ]]
}

@test "check_fixed_rpms_any -- 6" {
    rpm() {
        echo "pkgc-123-456"
        return 0
    }
    export -f rpm

    run check_fixed_rpms_any "$( get_installed_packages pkga )"
    (( status == 0 ))
    [[ "$output" == "" ]]
}

