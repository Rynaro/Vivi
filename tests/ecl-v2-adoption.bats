#!/usr/bin/env bats
# tests/ecl-v2-adoption.bats — Wave-3 ECL v2.0 adoption sweep
#
# Covers: the vendored v2 envelope schema shape, ISE (Intent, Source,
# Entitlement) block presence + grade correctness on the three outbound
# templates, install.sh wiring for the new schema file, canonical
# verify-incoming convergence with Kupo's failure-code set, and drift-kill
# greps (no stray "ECL v1.0" prose left behind by the sweep).

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# ─────────────────────────────────────────────────────────────────────────────
# v2 envelope schema — shape
# ─────────────────────────────────────────────────────────────────────────────

@test "v2: schemas/ecl-envelope.v2.json exists and is valid JSON" {
  [ -f "${REPO_ROOT}/schemas/ecl-envelope.v2.json" ]
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq empty "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
}

@test "v2: schemas/ecl-envelope.v1.json is RETAINED (not removed by the sweep)" {
  [ -f "${REPO_ROOT}/schemas/ecl-envelope.v1.json" ]
}

@test "v2: envelope_version pattern accepts 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.properties.envelope_version.pattern' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* ]]
}

@test "v2: schema declares an ise \$defs block with assertion_grade required" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.["$defs"].ise.required[0]' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "assertion_grade" ]]
}

@test "v2: ise.assertion_grade enum has the four ECL v2.0 §6.5.2 values" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.["$defs"].ise.properties.assertion_grade.enum[]' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unverified"* ]]
  [[ "$output" == *"self-attested"* ]]
  [[ "$output" == *"validated"* ]]
  [[ "$output" == *"human-reviewed"* ]]
}

@test "v2: top-level ise property refs the \$defs/ise block" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.properties.ise["$ref"]' "${REPO_ROOT}/schemas/ecl-envelope.v2.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "#/\$defs/ise" ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# install.sh wiring — v2 schema
# ─────────────────────────────────────────────────────────────────────────────




# ─────────────────────────────────────────────────────────────────────────────
# ISE blocks — the three outbound templates
# ─────────────────────────────────────────────────────────────────────────────

@test "ise: vivi-completion-report.envelope.json declares envelope_version 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.envelope_version' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "2.0" ]]
}

@test "ise: vivi-completion-report.envelope.json ise.assertion_grade is validated" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "validated" ]]
}

@test "ise: reasoning-request.envelope.json ise.assertion_grade is self-attested" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/reasoning-request.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "self-attested" ]]
}

@test "ise: repair-failed-report.envelope.json ise.assertion_grade is self-attested" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  run jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/repair-failed-report.envelope.json"
  [ "$status" -eq 0 ]
  [[ "$output" == "self-attested" ]]
}

@test "ise: completion-report's grade DIFFERS from the other two templates (validated is earned, not default)" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  local completion_grade reasoning_grade repair_grade
  completion_grade="$(jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/vivi-completion-report.envelope.json")"
  reasoning_grade="$(jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/reasoning-request.envelope.json")"
  repair_grade="$(jq -r '.ise.assertion_grade' "${REPO_ROOT}/templates/repair-failed-report.envelope.json")"
  [[ "$completion_grade" == "validated" ]]
  [[ "$reasoning_grade" == "self-attested" ]]
  [[ "$repair_grade" == "self-attested" ]]
  [[ "$completion_grade" != "$reasoning_grade" ]]
  [[ "$completion_grade" != "$repair_grade" ]]
  # The two self-attested templates agree with each other (only completion-report is special-cased).
  [[ "$reasoning_grade" == "$repair_grade" ]]
}

@test "ise: all three outbound templates set receiver_authorization to the declared defaults" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  for f in \
    "${REPO_ROOT}/templates/vivi-completion-report.envelope.json" \
    "${REPO_ROOT}/templates/reasoning-request.envelope.json" \
    "${REPO_ROOT}/templates/repair-failed-report.envelope.json"; do
    run jq -r '.ise.receiver_authorization.auto_route' "$f"
    [[ "$output" == "true" ]]
    run jq -r '.ise.receiver_authorization.auto_merge' "$f"
    [[ "$output" == "false" ]]
    run jq -r '.ise.receiver_authorization.auto_deploy' "$f"
    [[ "$output" == "false" ]]
  done
}

@test "ise: all three outbound templates carry a well-formed provenance.methodology_version" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  for f in \
    "${REPO_ROOT}/templates/vivi-completion-report.envelope.json" \
    "${REPO_ROOT}/templates/reasoning-request.envelope.json" \
    "${REPO_ROOT}/templates/repair-failed-report.envelope.json"; do
    run jq -r '.ise.provenance.methodology_version' "$f"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^vivi-[0-9]+\.[0-9]+\.[0-9]+$ ]]
  done
}

@test "ise: justification for the validated grade is documented in skills/loop-native/SKILL.md" {
  grep -qi 'ise.assertion_grade="validated"' "${REPO_ROOT}/skills/loop-native/SKILL.md"
  grep -qi 'pass\^k' "${REPO_ROOT}/skills/loop-native/SKILL.md"
}

# ─────────────────────────────────────────────────────────────────────────────
# All 7 templates (3 outbound + 4 inbound fixtures) declare envelope_version 2.0
# ─────────────────────────────────────────────────────────────────────────────

@test "drift: all outbound + inbound templates declare envelope_version 2.0" {
  if ! command -v jq &>/dev/null; then
    skip "jq not available"
  fi
  for f in \
    "${REPO_ROOT}/templates/vivi-completion-report.envelope.json" \
    "${REPO_ROOT}/templates/repair-failed-report.envelope.json" \
    "${REPO_ROOT}/templates/reasoning-request.envelope.json" \
    "${REPO_ROOT}/templates/inbound/scout-report.envelope.fixture.json" \
    "${REPO_ROOT}/templates/inbound/spec.envelope.fixture.json" \
    "${REPO_ROOT}/templates/inbound/root-cause-report.envelope.fixture.json" \
    "${REPO_ROOT}/templates/inbound/reasoning-report.envelope.fixture.json"; do
    run jq -r '.envelope_version' "$f"
    [ "$status" -eq 0 ]
    [[ "$output" == "2.0" ]] || { echo "Stale envelope_version in $f: $output" >&3; false; }
  done
}

# ─────────────────────────────────────────────────────────────────────────────
# Drift-kill: no stray "ECL v1.0" prose left in documentation
# ─────────────────────────────────────────────────────────────────────────────


@test "drift: skills/failure-recovery/SKILL.md escalation envelope header is ECL v2.0" {
  grep -q 'Escalation Envelope (ECL v2.0)' "${REPO_ROOT}/skills/failure-recovery/SKILL.md"
  run grep -c 'ECL v1\.0' "${REPO_ROOT}/skills/failure-recovery/SKILL.md"
  [[ "$output" == "0" ]]
}

@test "drift: skills/context-engineering/SKILL.md verify-upstream header is ECL v2.0" {
  grep -q 'Verify Upstream Envelopes (ECL v2.0)' "${REPO_ROOT}/skills/context-engineering/SKILL.md"
  run grep -c 'ECL v1\.0' "${REPO_ROOT}/skills/context-engineering/SKILL.md"
  [[ "$output" == "0" ]]
}




# ─────────────────────────────────────────────────────────────────────────────
# Canonical verify-incoming convergence with ../Kupo
# ─────────────────────────────────────────────────────────────────────────────

@test "convergence: verify-incoming.md failure codes include CONTEXT_OVER_BUDGET (matches Kupo)" {
  grep -q 'CONTEXT_OVER_BUDGET' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
}

@test "convergence: verify-incoming.md failure codes include MISSING_REQUIRED_SECTION (matches Kupo)" {
  grep -q 'MISSING_REQUIRED_SECTION' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
}

@test "convergence: verify-incoming.md accepted-artifact table is preserved (Vivi-specific inbound edges)" {
  grep -q '| `atlas` | PROPOSE, INFORM, REFUSE | `scout-report` |' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  grep -q '| `spectra` | PROPOSE, INFORM, REFUSE | `spec` |' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  grep -q '| `vigil` | PROPOSE, CRITIQUE, INFORM | `root-cause-report` |' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
  grep -q '| `forge` | PROPOSE, INFORM, CRITIQUE | `reasoning-report` |' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
}

@test "convergence: verify-incoming.md posture is still BLOCKING (unchanged by convergence)" {
  grep -qE 'REFUSE|SHALL NOT|blocking' "${REPO_ROOT}/skills/verify-incoming/SKILL.md"
}

# ─────────────────────────────────────────────────────────────────────────────
# Degraded-mode prose amendment (loop-native.md §1) — additive, S1.7 declared-fallback
# ─────────────────────────────────────────────────────────────────────────────

@test "degraded-mode: loop-native.md references roster/routing.yaml degraded_mode: fanout" {
  grep -q 'degraded_mode: fanout' "${REPO_ROOT}/skills/loop-native/SKILL.md"
}

@test "degraded-mode: loop-native.md references the declared apivr fallback + S1.7 gate" {
  grep -q 'fallback: apivr' "${REPO_ROOT}/skills/loop-native/SKILL.md"
  grep -q 'S1.7' "${REPO_ROOT}/skills/loop-native/SKILL.md"
  grep -q 'declared-fallback' "${REPO_ROOT}/skills/loop-native/SKILL.md"
}

@test "degraded-mode: loop-native.md ITERATE/FANOUT code blocks are unchanged (additive-only amendment)" {
  grep -q -- '--max-attempts 3 ' "${REPO_ROOT}/skills/loop-native/SKILL.md"
  grep -q -- '--fanout 3 --max-attempts 1' "${REPO_ROOT}/skills/loop-native/SKILL.md"
}

# ─────────────────────────────────────────────────────────────────────────────
# Version stamp — 5 canonical homes at 1.3.0
# ─────────────────────────────────────────────────────────────────────────────
