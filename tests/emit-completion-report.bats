#!/usr/bin/env bats
# tests/emit-completion-report.bats — completion-report emit conformance

load helpers.bash

setup() {
  setup_envelope_fixture "vivi-completion-report" "vivi" "3.1.0"
}

teardown() {
  teardown_fixture
}

@test "fixture envelope is valid JSON" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq empty "${ENVELOPE_PATH}"
  [ "$status" -eq 0 ]
}

@test "fixture envelope_version is 1.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.envelope_version' "${ENVELOPE_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" == "1.0" ]]
}

@test "fixture from.eidolon is vivi" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.from.eidolon' "${ENVELOPE_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" == "vivi" ]]
}

@test "fixture to.eidolon is idg for completion-report" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  # The template sets to=idg; the fixture helper uses to=vivi (inbound).
  # For outbound, we check the template directly.
  run jq -r '.to.eidolon' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "idg" ]]
}

@test "template performative is PROPOSE" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.performative' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "PROPOSE" ]]
}

@test "template artifact.kind is vivi-completion-report" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.artifact.kind' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "vivi-completion-report" ]]
}

@test "integrity sha256 recompute matches declared value in fixture" {
  computed="$(sha256_of "${PAYLOAD_PATH}")"
  declared="$(jq -r '.integrity.value' "${ENVELOPE_PATH}" 2>/dev/null || echo "jq-missing")"
  if [[ "$declared" == "jq-missing" ]]; then
    skip "jq not available"
  fi
  [[ "$computed" == "$declared" ]]
}

@test "profile schema ref validates base fields" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  # Check that the profile schema has the required allOf structure
  run jq '.allOf | length' "${REPO_ROOT}/schemas/vivi-completion-report-profile.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "2" ]]
}

@test "profile schema requires files_changed_count tests_run tests_passed" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.allOf[1].required[]' "${REPO_ROOT}/schemas/vivi-completion-report-profile.v1.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"files_changed_count"* ]]
  [[ "$output" == *"tests_run"* ]]
  [[ "$output" == *"tests_passed"* ]]
}
