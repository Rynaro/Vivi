#!/usr/bin/env bats
# tests/loop-native-wiring.bats — install wiring assertions for skills/loop-native.md
#
# Bug: Vivi v1.0.0 did not wire skills/loop-native.md despite it being
# agent.md's primary skill reference (the core V-phase capability).
# This file asserts the fix is in place and guards against regression.

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# ── Skill file presence ──────────────────────────────────────────────────────

@test "loop-native skill file exists" {
  [ -f "${REPO_ROOT}/skills/loop-native.md" ]
}

@test "agent.md references skills/loop-native.md" {
  grep -q 'skills/loop-native.md' "${REPO_ROOT}/agent.md"
}

# ── install.sh registration checks ──────────────────────────────────────────

@test "install.sh registers loop-native in wire_skill calls" {
  grep -q 'wire_skill "loop-native"' "${REPO_ROOT}/install.sh"
}

@test "install.sh records skills/loop-native.md in manifest (add_fw)" {
  grep -q 'add_fw "skills/loop-native.md"' "${REPO_ROOT}/install.sh"
}

@test "install.sh records loop-native in add_skill (skills[] array)" {
  grep -q 'add_skill "loop-native"' "${REPO_ROOT}/install.sh"
}

# ── Install run: loop-native actually wired ──────────────────────────────────

@test "install produces skills/loop-native.md in target" {
  local tmp_target
  tmp_target="$(mktemp -d)"
  bash "${REPO_ROOT}/install.sh" \
    --target "${tmp_target}" \
    --hosts none \
    --non-interactive \
    --force
  [ -f "${tmp_target}/skills/loop-native.md" ]
  rm -rf "${tmp_target}"
}

@test "install with claude-code produces .claude/skills/vivi-loop-native/SKILL.md" {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  # Create minimal claude-code signal
  touch "${tmp_dir}/CLAUDE.md"
  (
    cd "${tmp_dir}"
    bash "${REPO_ROOT}/install.sh" \
      --target "./.eidolons/vivi" \
      --hosts claude-code \
      --non-interactive \
      --force
  )
  [ -f "${tmp_dir}/.claude/skills/vivi-loop-native/SKILL.md" ]
  rm -rf "${tmp_dir}"
}

@test "install manifest files_written includes skills/loop-native.md" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  local tmp_target
  tmp_target="$(mktemp -d)"
  bash "${REPO_ROOT}/install.sh" \
    --target "${tmp_target}" \
    --hosts none \
    --non-interactive \
    --force
  run jq -r '[.files_written[] | select(.path=="skills/loop-native.md")] | length' \
    "${tmp_target}/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
  rm -rf "${tmp_target}"
}

@test "install manifest skills[] array includes loop-native entry" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  local tmp_target
  tmp_target="$(mktemp -d)"
  bash "${REPO_ROOT}/install.sh" \
    --target "${tmp_target}" \
    --hosts none \
    --non-interactive \
    --force
  run jq -r '[.skills[] | select(.name=="loop-native")] | length' \
    "${tmp_target}/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
  rm -rf "${tmp_target}"
}

# ── examples/install.manifest.json consistency ──────────────────────────────

@test "examples/install.manifest.json skills[] includes loop-native" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '[.skills[] | select(.name=="loop-native")] | length' \
    "${REPO_ROOT}/examples/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "examples/install.manifest.json files_written[] includes skills/loop-native.md" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '[.files_written[] | select(.path=="skills/loop-native.md")] | length' \
    "${REPO_ROOT}/examples/install.manifest.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}
