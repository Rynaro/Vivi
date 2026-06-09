#!/usr/bin/env bats
# tests/skills-wiring.bats — skill-content assertions for S1.6/S1.8/S1.9 wiring
#
# These are grep-based content-presence tests. They do NOT run any MCP tools or
# the sandbox loop. Their job: confirm that the methodology documents contain the
# load-bearing wiring text the Stage-1 spec requires.
#
# Run with: bats tests/skills-wiring.bats
# Or via the project's full suite runner.

load helpers.bash

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
CONTEXT_ENG="${REPO_ROOT}/skills/context-engineering.md"
LOOP_NATIVE="${REPO_ROOT}/skills/loop-native.md"
MEMORY_MGMT="${REPO_ROOT}/skills/memory-management.md"
AGENT_MD="${REPO_ROOT}/agent.md"

# ─────────────────────────────────────────────────────────────────────────────
# S1.8 — context-engineering.md references all 7 atlas-aci tools
# ─────────────────────────────────────────────────────────────────────────────

@test "S1.8: context-engineering.md references mcp__atlas-aci__list_dir (L1 domain scan)" {
  grep -q 'mcp__atlas-aci__list_dir' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__search_text (L2 file identification)" {
  grep -q 'mcp__atlas-aci__search_text' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__search_symbol (L3 symbol identification)" {
  grep -q 'mcp__atlas-aci__search_symbol' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__graph_query (L3 caller/dependency chain)" {
  grep -q 'mcp__atlas-aci__graph_query' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__view_file (L4 paginated context gathering)" {
  grep -q 'mcp__atlas-aci__view_file' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__test_dry_run (test oracle probe)" {
  grep -q 'mcp__atlas-aci__test_dry_run' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md references mcp__atlas-aci__memex_read (stored excerpt retrieval)" {
  grep -q 'mcp__atlas-aci__memex_read' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md view_file calls are documented as PAGINATED (never full-dump)" {
  # The skill must contain start_line and end_line pagination parameters.
  grep -q 'start_line' "${CONTEXT_ENG}"
  grep -q 'end_line' "${CONTEXT_ENG}"
}

@test "S1.8 S1.4-assembly: context-engineering.md references EIDOLONS_SANDBOX_FEEDBACK for in-loop loci assembly" {
  grep -q 'EIDOLONS_SANDBOX_FEEDBACK' "${CONTEXT_ENG}"
}

@test "S1.8 S1.4-assembly: context-engineering.md has in-loop loci-driven section covering loci from feedback" {
  # The section must name the loci field from feedback.json.
  grep -q 'loci' "${CONTEXT_ENG}"
}

@test "S1.8 S1.4-assembly: context-engineering.md documents view_file keyed by loci for in-loop assembly" {
  # The in-loop assembly procedure must mention view_file called around loci (file:line).
  grep -q 'mcp__atlas-aci__view_file' "${CONTEXT_ENG}"
  # And it must be in the context of loci-driven assembly (both terms appear in the file).
  grep -q 'loci' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md documents a manual fallback when atlas-aci is not wired" {
  # The skill must contain a documented degradation path.
  grep -qi 'fallback\|unavailable\|degrade' "${CONTEXT_ENG}"
}

@test "S1.8: context-engineering.md manual fallback references grep or ls (classic tooling)" {
  # The fallback must name at least one manual alternative.
  grep -q 'grep\|ls\|find' "${CONTEXT_ENG}"
}

# ─────────────────────────────────────────────────────────────────────────────
# S1.9 — crystalium recall (precision-gated) in memory-management.md + loop-native.md
# ─────────────────────────────────────────────────────────────────────────────

@test "S1.9: memory-management.md references mcp__crystalium__recall for per-iteration failure-signature" {
  grep -q 'mcp__crystalium__recall' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md leads recall with procedural layer (CTIM-Rover precision gate)" {
  # The recall call must explicitly list procedural before or alongside semantic,
  # NOT raw episodic as the primary layer for the per-iteration recall.
  grep -q 'procedural' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md leads recall with semantic layer (not just episodic)" {
  grep -q 'semantic' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md documents precision-gate / ignoring low-confidence recall" {
  # The skill must state that low-confidence hits are ignored, not blindly applied.
  grep -qi 'low.confidence\|ignore\|precision' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md has mandatory post-pass^k procedural commit" {
  # The mandatory commit must be called out — not discretionary.
  grep -qi 'mandatory\|MANDATORY' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md mandatory commit uses layer=procedural" {
  # The post-pass^k commit must commit to the procedural layer.
  grep -q 'layer.*=.*"procedural"' "${MEMORY_MGMT}"
}

@test "S1.9: memory-management.md mandatory commit includes failure_signature field" {
  # The admission record must carry the failure_signature for future retrieval.
  grep -q 'failure_signature' "${MEMORY_MGMT}"
}

@test "S1.9: loop-native.md references mcp__crystalium__recall before the edit step" {
  grep -q 'mcp__crystalium__recall\|crystalium.*recall\|recall.*crystalium' "${LOOP_NATIVE}"
}

@test "S1.9: loop-native.md references mandatory post-pass^k mcp__crystalium__commit with layer=procedural" {
  # The success path (§6) must name the mandatory procedural commit.
  grep -q 'mcp__crystalium__commit(layer=procedural' "${LOOP_NATIVE}"
}

@test "S1.9: loop-native.md states adapter-not-engine for crystalium calls (coder, never sandbox.sh)" {
  grep -qi 'ADAPTER-NOT-ENGINE\|adapter.not.engine' "${LOOP_NATIVE}"
}

@test "S1.9: memory-management.md states adapter-not-engine for crystalium calls" {
  grep -qi 'ADAPTER-NOT-ENGINE\|adapter.not.engine' "${MEMORY_MGMT}"
}

# ─────────────────────────────────────────────────────────────────────────────
# S1.6-methodology — fresh-context withholding in loop-native.md
# ─────────────────────────────────────────────────────────────────────────────

@test "S1.6: loop-native.md references EIDOLONS_SANDBOX_FRESH_CONTEXT env var" {
  grep -q 'EIDOLONS_SANDBOX_FRESH_CONTEXT' "${LOOP_NATIVE}"
}

@test "S1.6: loop-native.md documents declining prior error transcript when FRESH_CONTEXT is set" {
  # The skill must say DECLINE (or equivalent) for prior attempt reasoning.
  grep -qi 'DECLINE\|decline.*transcript\|decline.*prior\|withhold' "${LOOP_NATIVE}"
}

@test "S1.6: loop-native.md specifies fresh-context seed: only feedback.json signal + spec + working tree" {
  # The three allowed inputs must be named.
  grep -q 'EIDOLONS_SANDBOX_FEEDBACK' "${LOOP_NATIVE}"
}

@test "S1.6: loop-native.md states fresh-context is the DEFAULT path (not opt-in)" {
  # Must say that absent flag also means fresh context — not "load all transcripts".
  grep -qi 'default.*fresh\|fresh.*default\|even when.*unset\|absence.*does.*not' "${LOOP_NATIVE}"
}

@test "S1.6: loop-native.md notes the substrate exports no prior-reasoning transcript var" {
  # The discipline note must acknowledge the substrate's transcript-free env.
  grep -qi 'no prior.*transcript\|transcript.*free\|no.*reasoning.*var\|never.*transcript' "${LOOP_NATIVE}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Agent.md guard — wiring must NOT be in agent.md (P0 token budget)
# ─────────────────────────────────────────────────────────────────────────────

@test "GUARD: agent.md does NOT contain inline mcp__atlas-aci__ tool references" {
  # All atlas-aci wiring lives in skills/context-engineering.md, not the <=1000-token agent.md.
  if grep -q 'mcp__atlas-aci__' "${AGENT_MD}"; then
    echo "FAIL: agent.md contains mcp__atlas-aci__ wiring — must stay in skills/" >&3
    return 1
  fi
}

@test "GUARD: agent.md does NOT contain inline mcp__crystalium__ tool references" {
  # All crystalium wiring lives in skills/memory-management.md + skills/loop-native.md.
  if grep -q 'mcp__crystalium__' "${AGENT_MD}"; then
    echo "FAIL: agent.md contains mcp__crystalium__ wiring — must stay in skills/" >&3
    return 1
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# S2 — host-adaptive shape (iterate vs fanout) + red gate + judge gate wiring
# ─────────────────────────────────────────────────────────────────────────────

METHODOLOGY="${REPO_ROOT}/skills/methodology.md"

@test "S2: loop-native.md documents the FANOUT shape (--fanout with --max-attempts 1)" {
  grep -q -- '--fanout 3 --max-attempts 1' "${LOOP_NATIVE}"
}

@test "S2: loop-native.md passes --require-red in both shapes" {
  [ "$(grep -c -- '--require-red' "${LOOP_NATIVE}")" -ge 2 ]
}

@test "S2: loop-native.md carries the fanout candidate discipline keyed by EIDOLONS_SANDBOX_CANDIDATE" {
  grep -q 'EIDOLONS_SANDBOX_CANDIDATE' "${LOOP_NATIVE}"
  grep -qi 'candidate 2 the runner-up' "${LOOP_NATIVE}"
}

@test "S2: loop-native.md carries the EVIDENCE GATE (no feedback -> no edit, exit non-zero)" {
  grep -qi 'EVIDENCE GATE' "${LOOP_NATIVE}"
  grep -qi 'Never hallucinate a failure to fix' "${LOOP_NATIVE}"
}

@test "S2: loop-native.md documents vacuous-reproduction as a return-to-P signal" {
  grep -q 'vacuous-reproduction' "${LOOP_NATIVE}"
}

@test "S2: loop-native.md documents the judge gate (judge-rejected)" {
  grep -q 'judge-rejected' "${LOOP_NATIVE}"
  grep -q -- '--judge-hook' "${LOOP_NATIVE}"
}

@test "S2: loop-native.md escalation carries the oscillation flag (loop_detected)" {
  grep -q 'loop_detected' "${LOOP_NATIVE}"
}

@test "S2: methodology.md P-phase carries the RED-GATE rule (fail on base before implementing)" {
  grep -qi 'RED-GATE rule' "${METHODOLOGY}"
  grep -qi 'FAIL on the unmodified base tree' "${METHODOLOGY}"
}

@test "S2: methodology.md V-phase carries the host-adaptive shape table (iterate vs fanout)" {
  grep -qi 'Host-adaptive shape' "${METHODOLOGY}"
  grep -q -- '--fanout 3 --max-attempts 1' "${METHODOLOGY}"
}

@test "S2: methodology.md keeps graceful degradation for a substrate-less host" {
  grep -qi 'graceful degradation' "${METHODOLOGY}"
  grep -q 'eidolons add apivr' "${METHODOLOGY}"
}

@test "S2: agent.md stays a pointer — no inline Stage-2 loop wiring in the always-loaded entry" {
  ! grep -q -- '--fanout' "${AGENT_MD}"
  ! grep -q -- '--require-red' "${AGENT_MD}"
}
