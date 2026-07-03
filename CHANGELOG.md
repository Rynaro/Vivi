# Changelog

All notable changes to **Vivi** are documented here. Vivi is the loop-native successor to [APIVR-Δ](https://github.com/Rynaro/APIVR-Delta), derived from `APIVR-Delta@v3.6.0`.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

## [1.3.0] — 2026-07-03 — ECL v2.0 adoption (ISE trust-hierarchy, drift kill)

### Added
- **ECL v2.0 vendoring.** `schemas/ecl-envelope.v2.json` — self-contained vendored copy of `eidolons-ecl@v2.0.0`'s `schemas/envelope.v2.json` (spec/ecl-2.0.md §6.5), following the same inlined-enum, self-contained convention as the existing `schemas/ecl-envelope.v1.json`. The v1 file is **retained**, not replaced — Vivi's own tooling can still validate a v1.x sidecar received during the ECL §7.3 compatibility window (through 2027-05-13). Wired into `install.sh` (`do_cp` + `add_fw`, role `other`).
- **ISE (Intent, Source, Entitlement) emission on all three outbound envelope templates** (ECL v2.0 §6.5). `templates/vivi-completion-report.envelope.json` sets `ise.assertion_grade="validated"` — the only one of Vivi's three kinds that earns it, because it is the only exit gated by the loop-native V-phase's pass^k verification (`skills/loop-native.md` §4, §6 — spec-mandated gates, not a self-report). `templates/reasoning-request.envelope.json` and `templates/repair-failed-report.envelope.json` set `ise.assertion_grade="self-attested"` (neither exits through the pass^k gate). All three set `ise.receiver_authorization = {auto_route:true, auto_merge:false, auto_deploy:false}` and `ise.provenance.methodology_version="vivi-1.3.0"`. Justification documented in `skills/loop-native.md` §6 and cross-referenced from `skills/methodology.md`'s three "ECL emit" sections (not embedded as a JSON field, to avoid polluting every real emission).

### Changed
- **ECL prose drift kill (all → v2.0).** `CLAUDE.md`, `skills/failure-recovery.md`, `skills/context-engineering.md` referenced "ECL v1.0" in section headers/prose while `agent.md`, `SPEC.md`, and `skills/memory-management.md` already said "ECL v2.0" — reconciled to v2.0 throughout. `install.sh` `ECL_VERSION_VAL` `"1.0"` → `"2.0"` (was drifted from the already-v2.0 `ECL_VERSION` file it also copies). All 7 envelope templates (3 outbound + 4 inbound fixtures) `envelope_version` `"1.0"` → `"2.0"`. `schemas/install.manifest.v1.json` `comm.envelope_version` pattern widened `^1\.0(\.\d+)?$` → `^(1\.[012]|2\.0)(\.\d+)?$` (was load-bearing — would have rejected Vivi's own "2.0" manifest declaration) and its §7.2 citation bumped. `examples/install.manifest.json` `comm.envelope_version` `"1.0"` → `"2.0"`.
- **Canonical verify-incoming convergence with `../Kupo`.** `skills/verify-incoming.md` failure-code list gains `CONTEXT_OVER_BUDGET` and `MISSING_REQUIRED_SECTION` (ECL v2.0 §5.3 canonical set; Kupo already listed both). "All six Eidolons ship this gate" → "All Eidolons in the roster ship this gate" (Kupo's phrasing; the "six" count was stale). Vivi's per-Eidolon accepted-artifact table is unchanged.
- **Degraded-mode prose, additive (`skills/loop-native.md` §1).** The ITERATE/FANOUT host-tier branch now states that the shape choice is DATA, not prose guidance alone: the nexus `roster/routing.yaml` (routing_version 1.1) declares `vivi.degraded_mode: fanout` (FANOUT is the declared default on a weak/undeclared host tier) and `vivi.fallback: apivr` (the kernel's S1.7 host-tier gate in `cli/src/run.sh` routes to APIVR-Δ as the *declared* conservative peer, `fallthrough_reason: "declared-fallback"`, rather than a generic next-ranked pick). Purely additive — the skill's structure and existing prose are unchanged.
- **Version stamp 1.2.0 → 1.3.0** in the 5 canonical homes: `install.sh` (`EIDOLON_VERSION`), `AGENTS.md` frontmatter, `SPEC.md`, `examples/install.manifest.json`, and the `tests/install.bats` version assertion.

### Tests
- `tests/install.bats`: updated version/ECL-version assertions; added `ecl-envelope.v2.json` presence check.
- New `tests/ecl-v2-adoption.bats`: v2 schema shape (ISE `$defs`, `envelope_version` pattern), ISE block presence + grade correctness on all three outbound templates (asserts `vivi-completion-report`'s `validated` grade differs from the other two `self-attested` templates), `receiver_authorization` shape, install.sh wiring, and drift-kill greps (no remaining "ECL v1.0" prose outside the retained v1 schema; all 7 templates declare `envelope_version: "2.0"`).

## [1.2.0] — 2026-06-25 — ESL lifecycle-hop adoption (MAKER at `in_progress`)

### Added
- **`skills/esl-hop.md` — ESL implement-hop skill (opt-in).** In an ESL-enabled project (`mcp__tonberry__*` available), when the cortex routes a non-trivial change to Vivi at `in_progress`, Vivi is the **MAKER**: it declares `has_code` via `mcp__tonberry__transition --to_status in_progress --has_code true` (persists by default in tonberry v0.4.0), implements via its loop-native A→P→I→V→Δ/R cycle in an isolated worktree (`change.json.maker == vivi`), and on green hands off to the **CHECKER** (Kupo at `verified`, VIGIL on failure) — Vivi does **NOT self-verify** (maker ≠ checker is mechanically enforced by tonberry's C4). References the nexus cortex `methodology/cortex/esl-protocol.md` for the full lifecycle. **Graceful skip:** absent tonberry, Vivi implements normally — ESL is opt-in and Vivi remains EIIS-standalone-conformant. Wired into `install.sh` (`wire_skill`/`add_fw`/`add_skill`), `agent.md` + `SPEC.md` skill indices, and `examples/install.manifest.json` (`skills[]` + `files_written[]`, role `skill`) so the I5 manifest-skill-ref gate and the strict canonical-inventory sweep both pass.

### Changed
- **Version stamp 1.1.2 → 1.2.0** in `install.sh` (`EIDOLON_VERSION`), `agent.md`-adjacent `AGENTS.md` frontmatter, `SPEC.md`, `examples/install.manifest.json`, and the `tests/install.bats` version assertion.

## [1.1.2] — 2026-06-10 — broad Bash allowlist (loop-native mandate)

### Changed
- **tools line: enumerated Bash prefixes → `Bash` (broad).** Vivi's loop-native mandate requires driving `eidolons sandbox loop` as the fix-hook and invoking arbitrary project verifiers (make, bats, shellcheck, npm, cargo, etc.) that vary per consumer repo. Enumerated Bash prefixes (`Bash(git:*)`, `Bash(jest:*)`, …) are incompatible with this mandate and have caused breakage three times across the ecosystem. Broad `Bash` is the correct boundary; boundary-respect lives in Vivi's methodology (P0 invariants), not in a Bash prefix allowlist. D3 also retires PARENT_FILLS_* placeholders — Vivi computes its own ECL envelope `sha256`/`size_bytes` via `shasum`/`wc` under broad Bash. Updated in `install.sh` heredoc and the checked-in `.claude/agents/vivi.md`.

## [1.1.1] — 2026-06-10 — SPEC lint-gate pointer (nexus doctor D11 advisory)

### Added
- **SPEC.md invariant I-11 — Lint-gated edits (ACI edit gate).** Documents that the coder class declares `requires_edit_gate: true` (roster ACI; SWE-agent edit-with-linter) and that each loop iteration runs the per-edit lint/compile gate (`eidolons sandbox loop --lint-hook <cmd>`, after the fix-hook, before tests). Clears the nexus `doctor --deep` D11 advisory ("SPEC.md does not yet reference the lint/edit gate").

## [1.1.0] — 2026-06-10 — loop-native wiring fix + stamp hygiene + canonical skill template

### Fixed
- **FUNCTIONAL BUG: `skills/loop-native.md` was never wired by `install.sh`.** Consumers installing Vivi v1.0.0 received 6 skills but were missing Vivi's core skill — the loop-native verify capability that distinguishes Vivi from APIVR-Δ. Added `wire_skill "loop-native"`, `add_fw "skills/loop-native.md"`, and `add_skill "loop-native"` to install.sh; updated examples/install.manifest.json to include loop-native (and parallel-tracks) in both `files_written[]` and `skills[]`.

### Changed
- **Stamp hygiene (inherited 3.x values corrected):** `EIDOLON_VERSION` bumped to 1.1.0 in install.sh, AGENTS.md, SPEC.md, README. Schemas `$id` URLs updated from `blob/v3.1.0/` to `blob/v1.1.0/`. Outbound template `from.version` and inbound fixture `to.version` updated from 3.1.0 to 1.1.0. Test helpers default updated. examples/install.manifest.json version updated from 3.3.0 to 1.1.0.
- **Unversioned cycle headings:** `agent.md` `## Cycle (v0.1)` → `## Cycle`; `AGENTS.md` `## Vivi Cycle (v3.0)` → `## Vivi Cycle`; `skills/methodology.md` H1 + footer stripped of version string.
- **Trace placeholder fix:** `verify-incoming.md` trace events `"to":"vivi@3.4"` → `"to":"vivi@<version>"`.
- **Canonical skill frontmatter (D2):** All 7 skills migrated from top-level `methodology`/`methodology_version` to `metadata: { methodology, phase }` block; `methodology_version` dropped from all skills.
- **docs/PAPER.md identity fix:** "Version 3.0 — February 2026" / "Vivi v3.0" corrected to "Version 1.0 — June 2026" / "Vivi v1.0" throughout.
- **ECL untouched:** `ECL_VERSION_VAL`, `ECL_VERSION` file, and `envelope_version` values left verbatim (ecosystem V3 item, out of scope per campaign spec).

## [1.0.0] — 2026-06-09 — loop-native coder, host-adaptive, measurement-validated

### Added
- **Stage 2 — host-adaptive loop shape (iterate vs fanout) + red gate + judge gate.** `skills/loop-native.md` + `skills/methodology.md`: on a **thinking / loop-competent host** Vivi iterates (`--max-attempts 3 --k 2 --require-red`); on a **standard / weak host** it switches the SHAPE to **fanout** (`--fanout 3 --max-attempts 1`) — N independent fresh-context single-shot candidates from the same base tree + the same localized base-failure feedback, selected EXTERNALLY by the substrate (tests + pass^k + sealed holdout + judge); the weak-host model never judges its own retry (self-repair degrades on weak hosts — RLEF / Olausson; parallel-sample-and-select is the evidence-backed alternative — R2E-Gym). **Fanout candidate discipline:** candidates diversify by `EIDOLONS_SANDBOX_CANDIDATE` index over the P-phase strategy ranking. **RED-GATE rule** (P-phase, mandatory): the reproduction anchor must FAIL on the unmodified base tree (`--require-red`; vacuous → return to P, never weaken the test — TDFlow). **Judge gate**: `--judge-hook` diff-review rejection is final per candidate. **EVIDENCE GATE** (backported from the APIVR-Δ spine): no feedback artefact → no edit, exit non-zero — never hallucinate a failure to fix. Escalation gains the **`loop_detected` oscillation flag**. 11 new wiring tests (119/119).

### Changed
- **Stage 2 Track A — whole-cycle methodology authored loop-native.** `skills/methodology.md` V→R rewritten: **V drives** `eidolons sandbox loop` (regression-first, `--protect`, pass^k, `--via` isolation) instead of running checks once and handing back; **R repairs fresh-context per attempt** (localized feedback + acceptance criteria + working tree — NOT the accumulated transcript; reverses the predecessor's same-context self-conditioning retry), with the 3-same-category cap reconciled against the loop's `--max-attempts`. `skills/failure-recovery.md` retry matrix gains the fresh-context discipline; `skills/parallel-tracks.md` reverses the "autonomous loop out of scope (nexus gap R1)" note (each track's Verify now drives the loop). A/P/I/Δ preserved (the validated spine — evidence-anchored "preserve" verdict); host-contingency degrade-path documented.

## [0.1.0] — 2026-06-05 — Scaffold (loop-native successor to APIVR-Δ)

### Added
- **Vivi scaffold**, derived from `APIVR-Delta@v3.6.0` (inherits the validated discipline spine: Internal-First, anti-overfit test-anchoring, bounded recovery, diff-not-apply, context-engineering, TRANCE multi-track, the ECL/CRYSTALIUM/VIGIL seams).
- **`skills/loop-native.md`** — the core new capability and the reason Vivi exists: drive the closed, autonomous, bounded `eidolons sandbox loop` as `--fix-hook` (external-feedback-driven, **localized** feedback via `EIDOLONS_SANDBOX_FEEDBACK`, **fresh context per retry**, `--protect` anti-reward-hacking, regression-first-then-reproduction, **pass^k**). Reverses APIVR-Δ's "loop out of scope (nexus gap R1)" decision.
- Identity re-authored for Vivi: `agent.md` (≤1000-token always-loaded entry, loop-native cycle), `SPEC.md` (methodology reference + invariants I-1…I-10 + ECL kinds), `README.md`, `DESIGN-RATIONALE.md` (D1–D7 + research mapping + the gated roadmap to v1.0), host wiring, install surface.
- ECL: `vivi-completion-report` envelope + profile (renamed from `apivr-completion-report`); ECL v2.0, EIIS v1.4.

### Notes
- **Scaffold status.** The inherited spine + the loop-native core are in place; the whole-cycle hardening and a **measured holdout result** (Vivi vs APIVR-Δ control, contamination-screened, pass^k, loop-competent host) gate the path to v1.0 — see `DESIGN-RATIONALE.md` §Roadmap. Confidence 0.62 (M) until measured.
- **Positioning.** Vivi is the default `coder`; APIVR-Δ is retained as the conservative / loop-incompetent-host opt-in fallback (`eidolons add apivr`).
