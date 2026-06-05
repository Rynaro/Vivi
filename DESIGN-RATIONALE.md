# Vivi — Design Rationale

Research → decision mapping for the **APIVR-Δ → Vivi succession**. Full evidence base: the nexus dossier `DOSSIER-APIVR-OVERHAUL-2026-06.md` + digest `.spectra/research/apivr-overhaul-digest.md` (workflow `wf_b026e797-5d9`: 53 peer-reviewed findings, 39 corroborated / 0 refuted). Confidence in the succession: **0.62 (M)** — capped until a measured holdout result exists (§Roadmap).

## Lineage

Vivi is **derived from `APIVR-Delta@v3.6.0`** and inherits its validated discipline spine verbatim (the skills, templates, schemas). The identity is new because the change is a *whole-cycle, loop-native* redesign of the Verify phase — effectively a new organism — not a point fix. APIVR-Δ is **not retired from existence**: it is repositioned as the conservative, non-loop, opt-in fallback (`eidolons add apivr`).

## Decisions

**D1 — Close the loop (the reason Vivi exists).** APIVR-Δ declared the autonomous edit-run-test loop "out of scope (nexus gap R1)" in four places. The evidence makes the closed execution-feedback loop the **dominant performance lever** for code agents (RLEF, ICLR'25; S\*, EMNLP-Findings'25; SE-agent survey 2510.09721). Vivi reverses that scope decision: the V phase **is** the loop (`skills/loop-native.md`), driving the shipped `eidolons sandbox loop` substrate.

**D2 — External feedback only; fresh context per retry.** Intrinsic self-correction without external feedback degrades (Kamoi, TACL'24; Huang, ICLR'24); models self-condition on prior errors; a model fixes an error when told *where* it is (Tyen et al.). So the loop is driven by **real test execution + localized feedback**, and each retry starts from **fresh context** — reversing APIVR-Δ's default single-track retry, which re-attempted in the same context window (self-conditioning).

**D3 — Inherit the anti-overfit spine; it is the reward-hacking guardrail.** A closed loop *amplifies* evaluator-gaming — a structural equilibrium, not a correctable bug (arXiv 2603.28063; the "always-print-PASS" / future-commit-peeking incidents). APIVR-Δ's anti-overfit test-anchoring is exactly the guardrail a from-scratch loop agent would lack, so Vivi **inherits it** and the substrate enforces it mechanically (`--protect` test immutability, regression-first-then-reproduction, pass^k). This is the decisive reason the succession **inherits** rather than rewrites from zero.

**D4 — Keep diff-not-apply + the human apply-gate.** Governed autonomy / human-on-the-loop is the 2026 enterprise norm; full autonomy fails long-horizon. Vivi adds the **inner** iterate-until-green loop while keeping the **human apply boundary** — it emits a candidate diff, never merges.

**D5 — Refuse greenfield (inherited).** Greenfield/novel-architecture is the highest-hallucination surface; the refusal is a designed defense carried from APIVR-Δ. Revisited only if a checkpoint shows the closed loop + test-anchoring safely handles build-to-passing-tests greenfield (future, evidence-gated).

**D6 — Honest host-contingency.** RLEF Table 2: on an untrained/prompt-only host the inference-time loop is neutral-to-negative; the gains require an RL-trained host. A methodology cannot train — it can only **exploit** a capable host's loop competence. Vivi therefore (a) targets RL-trained frontier hosts, (b) degrades gracefully when the host/runtime is weak, and (c) cedes those cases to the APIVR-Δ fallback.

**D7 — Two coders, not bloat.** Vivi takes the **default** `coder` seat (1-for-1 with APIVR-Δ in the crew/pipeline/presets); APIVR-Δ moves to opt-in. The default crew stays single-coder (anti-bloat); the two-coder offering is principled (D6), not redundant.

## Roadmap to v1.0 (gated)

This scaffold (v0.1.0) has the inherited spine + the loop-native core. Before v1.0:
1. **Whole-cycle hardening** — author the full loop-native A/P/I/V/Δ (per-phase evidence-anchored review; promote fresh-context everywhere).
2. **Measured holdout** — run Vivi vs the APIVR-Δ control on a contamination-screened, private, budget-matched, pass^k suite, on a declared loop-competent host. **This number gates v1.0** and tests the reversal conditions.
3. **Nexus intake** — roster entry + crew recomposition (`ATLAS→SPECTRA→Vivi→IDG`) + APIVR-Δ demotion (the `default_for_class` routing tiebreak is already shipped, dormant).

## Inherited research base

`docs/PAPER.md` (carried from APIVR-Δ) + the nexus dossier above. The inherited skills (context-engineering, failure-recovery, memory-management, parallel-tracks, verify-incoming) retain APIVR-Δ's research mapping; Vivi adds D1–D6.
