---
name: vivi-loop-native
description: "Load in Vivi's V (Verify) phase. The core capability that distinguishes Vivi from its predecessor APIVR-Δ: drive the closed, autonomous, bounded edit-run-test loop (`eidolons sandbox loop`) as its `--fix-hook`, consuming localized feedback, retrying in fresh context, refusing to game the tests, and gating on pass^k. Use whenever the task has an executable test oracle and a loop-competent host."
methodology: Vivi
methodology_version: "1.0"
---

# Loop-Native Verify Skill

The closed execution-feedback loop is the most-replicated performance lever for code agents (RLEF; S\*; SE-agent survey) — but only when it is **external-feedback-driven** (intrinsic self-correction degrades — Kamoi TACL'24, Huang ICLR'24) and **localized** (a model fixes an error when told *where* it is — Tyen et al.). APIVR-Δ deliberately left this loop "out of scope (nexus gap R1)"; **Vivi makes it the core of the V phase.** The nexus ships the substrate (`eidolons sandbox loop`) and the contract (`roster/aci.yaml` `loop_contract`); Vivi is the loop-native coder that drives it.

> **Host-contingency (read first).** The loop's gain belongs to an **RL-trained / loop-competent host** (on a prompt-only host the inference-time loop is neutral-to-negative — RLEF Table 2). Vivi *exploits* a capable host's loop competence; it does not manufacture it. If the host is loop-incompetent, or no adequate isolation is available, **degrade gracefully**: fall back to APIVR-Δ's emit-then-hand-back posture (or recommend `eidolons add apivr`).

---

## 1 — The loop is the V phase

After the P-phase test-anchors exist and the I-phase produced an initial edit, the V phase **delegates running to the substrate** and Vivi acts as the edit step:

```
eidolons sandbox loop \
  --via "<isolation>"                     # microVM/container — REQUIRED for untrusted code (R8-03)
  --tests "<the test command>"            # or --regression <cmd> --reproduction <cmd>
  --protect "<glob of the anchoring tests>"   # anti-reward-hacking
  --k 2                                   # pass^k: a flaky green is BLOCKED
  --max-attempts 3                        # reconciled with the ≤3-same-category budget
  --fix-hook "<invoke Vivi's repair step>"    # THIS skill, per iteration
```

The substrate owns the bounded control flow, isolation, diff-not-apply, and the VIGIL escalation; **Vivi owns the reasoning inside `--fix-hook`.** The nexus never edits or merges.

## 2 — Each `--fix-hook` invocation: fresh context, localized feedback

The loop invokes the fix-hook once per failing iteration. Vivi's invocation MUST be:

- **Fresh-context by default — enforced by `EIDOLONS_SANDBOX_FRESH_CONTEXT`.**
  Read the env var at the START of every fix-hook invocation:

  ```
  if [ "${EIDOLONS_SANDBOX_FRESH_CONTEXT:-}" = "true" ]; then
    # DECLINE to inject the prior attempt's error transcript or reasoning.
    # Seed the retry with ONLY:
    #   1. $EIDOLONS_SANDBOX_FEEDBACK  (the localized substrate signal)
    #   2. The task/acceptance spec (the original requirements)
    #   3. The current working tree state (read as needed, via atlas-aci view_file)
    # Do NOT load: prior attempt diffs, prior hypothesis text, prior error reasoning.
  fi
  ```

  **Anti self-conditioning discipline.** The substrate already exports ONLY the
  localized feedback vars (no prior-reasoning transcript is ever exported). The
  `EIDOLONS_SANDBOX_FRESH_CONTEXT=true` flag makes this discipline EXPLICIT and
  ENFORCEABLE: when it is set, the fix-hook MUST decline to inject any prior-attempt
  reasoning it may have available in its own context. The purpose is to break the
  accumulating self-correction cycle that the science shows degrades performance
  (Kamoi TACL'24, Huang ICLR'24). Treat this as a hard rule, not a preference.

  **Default path: FRESH CONTEXT.** Even when `EIDOLONS_SANDBOX_FRESH_CONTEXT` is
  unset or empty, apply the fresh-context discipline. The flag is a substrate signal;
  the withholding discipline is Vivi's methodology. Absence of the flag does NOT mean
  "load all prior transcripts."

- **Localized.** Read the structured feedback the substrate exports:

  ```
  $EIDOLONS_SANDBOX_FEEDBACK      # JSON: {failing, loci:[file:line...], test_name:[...],
                                  #        assertion:[...], full_log, output_tail, phase, attempt}
  $EIDOLONS_SANDBOX_FULL_LOG      # the COMPLETE captured output (never just a tail)
  $EIDOLONS_SANDBOX_LAST_OUTPUT   # the most recent command output
  $EIDOLONS_SANDBOX_ATTEMPT       # current attempt number (1-indexed)
  $EIDOLONS_SANDBOX_BASE          # base directory of the sandbox
  ```

  Target the reported `loci` (exact failing assertion / file:line frame). Load
  `skills/context-engineering.md` for the atlas-aci-driven in-loop loci assembly
  procedure — do NOT re-read whole files.

- **Per-iteration crystalium recall (before the edit — S1.9).**
  After reading feedback and BEFORE making any code edit, perform the hard-precision-gated
  failure-signature recall from `skills/memory-management.md §Per-Iteration Failure-Signature
  Recall`. Procedural/semantic hits short-circuit re-derivation. Ignore low-confidence hits.
  Never let a memory miss block the edit step.

## 3 — Anti-reward-hacking obligations (the loop AMPLIFIES gaming)

A closed loop with a pass/fail oracle is precisely what incentivizes evaluator-gaming (a structural equilibrium, not a correctable bug). Vivi's inherited anti-overfit spine is the guardrail; in the loop it is **mechanically enforced** by the substrate, and Vivi must never attempt to circumvent it:

- **Never edit the anchoring tests.** They are passed to `--protect`; a mutation aborts the loop and escalates to VIGIL. Fix the *implementation*, not the oracle.
- **Regression-first, then reproduction.** Success requires the pre-existing suite to pass **and** the newly-anchored acceptance test. Passing only the new test FAILS.
- **No always-pass shims, no peeking** at future commits / gold patches.

## 4 — pass^k before accepting

A single green run is necessary but not sufficient. With `--k > 1`, a candidate must pass `k` re-runs; a non-deterministic pass is **flaky → BLOCKED**, not merged. Treat a flaky green as a failed attempt (route to R — Reflect), never as success.

**Vivi's default: `--k 2`.** The fix-hook invocation (§1) always passes `--k 2`. This is a methodology default (not the substrate's default of k=1) — Vivi owns it explicitly. A single green run is not enough to trust a loop-derived fix.

## 5 — Escalation (bounded; reconciled)

Vivi's methodology owns the **≤3-same-category** retry budget (the authority); the substrate's `--max-attempts` is the ceiling. Whichever trips first ends the loop and emits the existing ECL `repair-failed-report` to **VIGIL** (no new performative; the closed 10-set is preserved). Provide the localized feedback + the candidate diff in the hand-off.

## 6 — Output

On success: the loop emits a **candidate diff** for review — Vivi does **not** apply or merge it (diff-not-apply; the human apply-gate is aligned with governed-autonomy). Emit the `vivi-completion-report` ECL envelope to IDG. On cap-out: the VIGIL hand-off above.

**Mandatory post-pass^k commit (S1.9).** Immediately after `final="passed"` (pass^k-green confirmed), Vivi MUST call `mcp__crystalium__commit(layer=procedural, ...)` as specified in `skills/memory-management.md §Mandatory Post-pass^k Commit`. This is NOT discretionary — it is a methodology obligation on every successful loop exit. The verified fix-pattern (diff + anchoring tests + failure_signature) is the most reliable learning signal available; committing it makes it available for future Vivi sessions and for VIGIL cross-Eidolon pattern reuse. **ADAPTER-NOT-ENGINE: the CODER (Vivi) issues this call; sandbox.sh never does.**

---

*Loop-Native Skill — external-feedback-driven, localized, EIDOLONS_SANDBOX_FRESH_CONTEXT-gated (prior-transcript DECLINED), hard-precision-gated crystalium recall, mandatory post-pass^k procedural commit, anti-gaming, pass^k-gated. The capability APIVR-Δ refused; the reason Vivi exists.*
