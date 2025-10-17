#!/usr/bin/env bats

# Test helper: Setup and teardown
setup() {
    # Use temporary directory for testing
    export RURA_SAVEPOINT_DIR="${BATS_TEST_TMPDIR}/rura_savepoints"
    export TEST_DIR="${BATS_TEST_TMPDIR}/test_dirs"

    # Create test directories
    mkdir -p "${TEST_DIR}/project1"
    mkdir -p "${TEST_DIR}/project2"

    # Set RURA to absolute path
    export RURA="${BATS_TEST_DIRNAME}/rura"
}

teardown() {
    # Clean up test files
    rm -rf "${RURA_SAVEPOINT_DIR}" "${TEST_DIR}"
}

# Basic command tests
@test "rura version shows version" {
    run "${RURA}" version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "rura version" ]]
}

@test "rura help shows help message" {
    run "${RURA}" help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "rura add creates savepoint" {
    run "${RURA}" add "${TEST_DIR}/project1" test1
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Saved" ]]
}

@test "rura list shows savepoints" {
    "${RURA}" add "${TEST_DIR}/project1" test1
    run "${RURA}" list
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test1" ]]
}

@test "rura delete removes savepoint" {
    "${RURA}" add "${TEST_DIR}/project1" test1
    run bash -c "echo y | '${RURA}' delete test1"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Removed:" ]]
}
