#!/usr/bin/env bats

setup() {
    ASDF_GODOT="$(dirname "$BATS_TEST_DIRNAME")"
    # If we put this in $BATS_RUN_TMPDIR, no teardown is required since it's
    # handled by bats.
    ASDF_TMPDIR="$(TMPDIR="${BATS_RUN_TMPDIR}" mktemp -t "test-${BATS_SUITE_TEST_NUMBER}.XXXXXXXXX" -d)"
    ASDF_DATA_DIR="$(bats_readlinkf "${ASDF_TMPDIR}")"
    export ASDF_DATA_DIR
    asdf plugin-add godot "${ASDF_GODOT}"
    asdf plugin-add redot "${ASDF_GODOT}"
}

@test "list all versions godot" {
    run asdf list-all godot
    
    echo "$output" 
}

@test "list all versions redot" {
    run asdf list-all redot
    echo "$output" >&3
}
