#!/usr/bin/env bats

setup() {
    ASDF_GODOT="$(dirname "$BATS_TEST_DIRNAME")"
    # If we put this in $BATS_RUN_TMPDIR, no teardown is required since it's
    # handled by bats.
    ASDF_TMPDIR="$(TMPDIR="${BATS_RUN_TMPDIR}" mktemp -t "test-${BATS_SUITE_TEST_NUMBER}.XXXXXXXXX" -d)"
    ASDF_DATA_DIR="$(bats_readlinkf "${ASDF_TMPDIR}")"
    export ASDF_DATA_DIR
    # echo "$ASDF_GODOT"  >&3
    asdf plugin add godot "${ASDF_GODOT}"
    echo "$(asdf info)" >&3
}


@test "can install godot 4.3" {
    run asdf install godot 4.3-stable
    echo "$output" >&3
}

# @test "can install godot latest" {
#     run asdf install godot latest-stable
# }

# @test "command fails on invalid version" {
#     run asdf install godot ref
#     [ "$status" -eq 1 ]
# }


