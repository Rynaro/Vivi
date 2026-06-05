# Changelog

All notable changes to **Vivi** are documented here. Vivi is the loop-native successor to [APIVR-Δ](https://github.com/Rynaro/APIVR-Delta), derived from `APIVR-Delta@v3.6.0`.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

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
