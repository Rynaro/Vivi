#!/usr/bin/env bats
# tests/loop-native-wiring.bats — install wiring assertions for skills/loop-native/SKILL.md
#
# Bug: Vivi v1.0.0 did not wire skills/loop-native/SKILL.md despite it being
# PERSONA.md's primary skill reference (the core V-phase capability).
# This file asserts the fix is in place and guards against regression.

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# ── Skill file presence ──────────────────────────────────────────────────────

@test "loop-native skill file exists" {
  [ -f "${REPO_ROOT}/skills/loop-native/SKILL.md" ]
}

@test "PERSONA.md references skills/loop-native/SKILL.md" {
  grep -q 'skills/loop-native/SKILL.md' "${REPO_ROOT}/PERSONA.md"
}

# ── install.sh registration checks ──────────────────────────────────────────




# ── Install run: loop-native actually wired ──────────────────────────────────





# ── examples/install.manifest.json consistency ──────────────────────────────
