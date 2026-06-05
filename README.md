# Vivi

**Vivi** is the Eidolons **coding Eidolon** — brownfield feature implementation through a **closed, autonomous, bounded edit-run-test loop**, with the discipline to do it safely.

Vivi is the **loop-native successor to [APIVR-Δ](https://github.com/Rynaro/APIVR-Delta)**. It inherits APIVR-Δ's validated spine — Internal-First reuse, anti-overfit test-anchoring, bounded failure recovery, diff-not-apply — and adds the one capability APIVR-Δ deliberately left out of scope: the closed loop that the 2025-26 evidence shows is the dominant performance lever for code agents.

> **Named for** Vivi Ornitier — methodical, precise, devastating; spell-as-tool composition that mirrors how a coding agent composes actions. Part of the Final-Fantasy-named Eidolons family (CRYSTALIUM, GAMBIT).

## What's new vs APIVR-Δ

- **Loop-native Verify.** The V phase drives `eidolons sandbox loop` as its `--fix-hook`: run → read **localized feedback** → repair → re-run, **bounded** and **fresh-context per attempt**. (APIVR-Δ emitted edits and handed running back; Vivi closes the loop.)
- **Anti-reward-hacking, mechanically gated.** A loop amplifies test-gaming, so the fix-hook can never edit the anchoring tests (`--protect`), must pass regression-first-then-reproduction, and a flaky green is BLOCKED (pass^k).
- **Localized feedback.** The fix-hook receives the failing assertion + `file:line` loci + the full log — not a raw tail.

## Positioning — two coders, two operating points

| | Vivi (default) | APIVR-Δ (opt-in fallback) |
|---|---|---|
| Loop | closed, autonomous | emit-then-hand-back |
| Best host | RL-trained / loop-competent | any (loop-incompetent-safe) |
| Install | default coder in the crew | `eidolons add apivr` |

Vivi is the **default `coder`**; APIVR-Δ is retained as the **conservative fallback** for loop-incompetent hosts and governance-maximal contexts (the loop's gain belongs to the host model — Vivi *exploits* it, never manufactures it).

## Status

**v0.1.0 — scaffold.** The inherited spine + the loop-native core are in place. The whole-cycle hardening and a **measured holdout result** (Vivi vs APIVR-Δ on a contamination-screened private suite) gate the path to v1.0. See `DESIGN-RATIONALE.md`.

## Install

```bash
bash install.sh            # auto-detect hosts; target ./.eidolons/vivi
bash install.sh --help     # flags: --target --hosts --force --dry-run --non-interactive ...
```

Full methodology: `SPEC.md` · always-loaded entry: `agent.md` · skills: `skills/`.
