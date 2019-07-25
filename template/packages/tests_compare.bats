#!/usr/bin/env bats

. test_harness


@test "compare -- Equal 1.1.1-1 = 1.1.1-1" {
    run compare "1.1.1-1" "=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Equal 1.1.1-1 = 2.1.1-1" {
    run compare "1.1.1-1" "=" "2.1.1-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.1.1-1 = 1.2.1-1" {
    run compare "1.1.1-1" "=" "1.2.1-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.1.1-1 = 1.1.2-1" {
    run compare "1.1.1-1" "=" "1.1.2-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.1.1-1 = 1.1.1-2" {
    run compare "1.1.1-1" "=" "1.1.1-2"
    (( status == 1 ))
}

@test "compare -- Equal 2.1.1-1 = 1.1.1-1" {
    run compare "2.1.1-1" "=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.2.1-1 = 1.1.1-1" {
    run compare "1.2.1-1" "=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.1.2-1 = 1.1.1-1" {
    run compare "1.1.2-1" "=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Equal 1.1.1-2 = 1.1.1-1" {
    run compare "1.1.1-2" "=" "1.1.1-1"
    (( status == 1 ))
}


@test "compare -- Greater 1.1.1-1 > 1.1.1-1" {
    run compare "1.1.1-1" ">" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Greater 2.1.1-1 > 1.1.1-1" {
    run compare "2.1.1-1" ">" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater 1.2.1-1 > 1.1.1-1" {
    run compare "1.2.1-1" ">" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater 1.1.2-1 > 1.1.1-1" {
    run compare "1.1.2-1" ">" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater 1.1.1-2 > 1.1.1-1" {
    run compare "1.1.1-2" ">" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater 1.1.1-1 > 2.1.1-1" {
    run compare "1.1.1-1" ">" "2.1.1-1"
    (( status == 1 ))
}

@test "compare -- Greater 1.1.1-1 > 1.2.1-1" {
    run compare "1.1.1-1" ">" "1.2.1-1"
    (( status == 1 ))
}

@test "compare -- Greater 1.1.1-1 > 1.1.2-1" {
    run compare "1.1.1-1" ">" "1.1.2-1"
    (( status == 1 ))
}

@test "compare -- Greater 1.1.1-1 > 1.1.1-2" {
    run compare "1.1.1-1" ">" "1.1.1-2"
    (( status == 1 ))
}

@test "compare -- Less 1.1.1-1 < 1.1.1-1" {
    run compare "1.1.1-1" "<" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less 2.1.1-1 < 1.1.1-1" {
    run compare "2.1.1-1" "<" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less 1.2.1-1 < 1.1.1-1" {
    run compare "1.2.1-1" "<" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less 1.1.2-1 < 1.1.1-1" {
    run compare "1.1.2-1" "<" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less 1.1.1-2 < 1.1.1-1" {
    run compare "1.1.1-2" "<" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less 1.1.1-1 < 2.1.1-1" {
    run compare "1.1.1-1" "<" "2.1.1-1"
    (( status == 0 ))
}

@test "compare -- Less 1.1.1-1 < 1.2.1-1" {
    run compare "1.1.1-1" "<" "1.2.1-1"
    (( status == 0 ))
}

@test "compare -- Less 1.1.1-1 < 1.1.2-1" {
    run compare "1.1.1-1" "<" "1.1.2-1"
    (( status == 0 ))
}

@test "compare -- Less 1.1.1-1 < 1.1.1-2" {
    run compare "1.1.1-1" "<" "1.1.1-2"
    (( status == 0 ))
}

@test "compare -- Greater Equal 1.1.1-1 >= 1.1.1-1" {
    run compare "1.1.1-1" ">=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater Equal 2.1.1-1 >= 1.1.1-1" {
    run compare "2.1.1-1" ">=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater Equal 1.2.1-1 >= 1.1.1-1" {
    run compare "1.2.1-1" ">=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater Equal 1.1.2-1 >= 1.1.1-1" {
    run compare "1.1.2-1" ">=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater Equal 1.1.1-2 >= 1.1.1-1" {
    run compare "1.1.1-2" ">=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Greater Equal 1.1.1-1 >= 2.1.1-1" {
    run compare "1.1.1-1" ">=" "2.1.1-1"
    (( status == 1 ))
}

@test "compare -- Greater Equal 1.1.1-1 >= 1.2.1-1" {
    run compare "1.1.1-1" ">=" "1.2.1-1"
    (( status == 1 ))
}

@test "compare -- Greater Equal 1.1.1-1 >= 1.1.2-1" {
    run compare "1.1.1-1" ">=" "1.1.2-1"
    (( status == 1 ))
}

@test "compare -- Greater Equal 1.1.1-1 >= 1.1.1-2" {
    run compare "1.1.1-1" ">=" "1.1.1-2"
    (( status == 1 ))
}


@test "compare -- Less Equal 1.1.1-1 <= 1.1.1-1" {
    run compare "1.1.1-1" "<=" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Less Equal 2.1.1-1 <= 1.1.1-1" {
    run compare "2.1.1-1" "<=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less Equal 1.2.1-1 <= 1.1.1-1" {
    run compare "1.2.1-1" "<=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less Equal 1.1.2-1 <= 1.1.1-1" {
    run compare "1.1.2-1" "<=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less Equal 1.1.1-2 <= 1.1.1-1" {
    run compare "1.1.1-2" "<=" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Less Equal 1.1.1-1 <= 2.1.1-1" {
    run compare "1.1.1-1" "<=" "2.1.1-1"
    (( status == 0 ))
}

@test "compare -- Less Equal 1.1.1-1 <= 1.2.1-1" {
    run compare "1.1.1-1" "<=" "1.2.1-1"
    (( status == 0 ))
}

@test "compare -- Less Equal 1.1.1-1 <= 1.1.2-1" {
    run compare "1.1.1-1" "<=" "1.1.2-1"
    (( status == 0 ))
}

@test "compare -- Less Equal 1.1.1-1 <= 1.1.1-2" {
    run compare "1.1.1-1" "<=" "1.1.1-2"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-1 <> 1.1.1-1" {
    run compare "1.1.1-1" "<>" "1.1.1-1"
    (( status == 1 ))
}

@test "compare -- Not Equal 2.1.1-1 <> 1.1.1-1" {
    run compare "2.1.1-1" "<>" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.2.1-1 <> 1.1.1-1" {
    run compare "1.2.1-1" "<>" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.2-1 <> 1.1.1-1" {
    run compare "1.1.2-1" "<>" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-2 <> 1.1.1-1" {
    run compare "1.1.1-2" "<>" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-1 <> 2.1.1-1" {
    run compare "1.1.1-1" "<>" "2.1.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-1 <> 1.2.1-1" {
    run compare "1.1.1-1" "<>" "1.2.1-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-1 <> 1.1.2-1" {
    run compare "1.1.1-1" "<>" "1.1.2-1"
    (( status == 0 ))
}

@test "compare -- Not Equal 1.1.1-1 <> 1.1.1-2" {
    run compare "1.1.1-1" "<>" "1.1.1-2"
    (( status == 0 ))
}


@test "compare -- Multi-digit 10.1.51-16 = 10.1.51-16" {
    run compare "10.1.51-16" "=" "10.1.51-16"
    (( status == 0 ))
}

@test "compare -- Multi-digit 1.10.1-1 > 1.1.1-1" {
    run compare "1.10.1-1" ">" "1.1.1-1"
    (( status == 0 ))
}

@test "compare -- Multi-digit 1.2.1-1 > 1.1.100-1" {
    run compare "1.2.1-1" ">" "1.1.100-1"
    (( status == 0 ))
}

@test "compare -- Multi-digit 1.1.2-1 < 1.1.10-1" {
    run compare "1.1.2-1" "<" "1.1.10-1"
    (( status == 0 ))
}

@test "compare -- Multi-digit 1.1.1-10 < 1.1.1-100" {
    run compare "1.1.1-10" "<" "1.1.1-100"
    (( status == 0 ))
}

@test "compare -- Different length - equal 1.1.0-0 == 1.1" {
    run compare "1.1.0-0" "=" "1.1"
    (( status == 0 ))
}

@test "compare -- Different length - equal 1.1.0-0 == 1.1.1" {
    run compare "1.1.0-0" "=" "1.1.1"
    (( status == 1 ))
}

@test "compare -- Different length - greater 2.1.1 > 2.1" {
    run compare "2.1.1" ">" "2.1"
    (( status == 0 ))
}

@test "compare -- Different length - greater 2.1.1 > 2.2" {
    run compare "2.1.1" ">" "2.2"
    (( status == 1 ))
}

@test "compare -- Different length - less 1.5 < 1.5.0.1" {
    run compare "1.5" "<" "1.5.0.1"
    (( status == 0 ))
}

@test "compare -- Different length - less 1.5 < 1.5.0.0" {
    run compare "1.5" "<" "1.5.0.0"
    (( status == 1 ))
}

@test "compare -- Different length - less equal 1.5 <= 1.5.0.1" {
    run compare "1.5" "<=" "1.5.0.1"
    (( status == 0 ))
}

@test "compare -- Different length - less equal 1.5 <= 1.5.0.1" {
    run compare "1.5" "<=" "1.5.0.0"
    (( status == 0 ))
}

@test "compare -- Different length - less equal 1.5 <= 1.5.0.1" {
    run compare "1.6" "<=" "1.5.9.0"
    (( status == 1 ))
}

@test "compare -- Different length - greater equal 7.0.0.0 >= 7.0" {
    run compare "7.0.0.0" ">=" "7.0"
    (( status == 0 ))
}

@test "compare -- Different length - greater equal 7.0.0.1 >= 7.0" {
    run compare "7.0.0.1" ">=" "7.0"
    (( status == 0 ))
}

@test "compare -- Different length - greater equal 7.0.0.1 >= 7.1" {
    run compare "7.0.0.1" ">=" "7.1"
    (( status == 1 ))
}
