# Changelog

All notable changes to **Vivi** are documented here. Vivi is the loop-native successor to [APIVR-Δ](https://github.com/Rynaro/APIVR-Delta), derived from `APIVR-Delta@v3.6.0`.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

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
