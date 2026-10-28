# Codebase Audit → Ticket → Fix — Prompt Flow

> **How to use this file:** A companion to `multi_agent_prompt_flow.md`, for a different job — finding and clearing out existing issues in a codebase rather than building new phases. Same conventions: agent role framing, a strict "flag only / ticket only / fix only" boundary per stage, and file-based handoffs so no agent needs the others' conversational memory. Uses the same `audit-[ID]-[short-name]` naming pattern as the `bug-[ID]-[short-name]` convention from Section 7 of the build pipeline — parallel but separate, since an audit finding isn't a reported bug, it's something the audit itself surfaced.

---

## 0. The Audit Loop (reference before running anything)

```
1. AUDITOR      → one full-repo pass, writes audit/findings.md (one row per issue, ticket-backlog style)
2. TICKET-WRITER → one ticket per finding: tasks/audit-[ID]-[short-name].md
3. ROUTE        → same rule as the build pipeline: FLASH for routine, PRO for anything
                  touching crypto, access-control, on-chain/contract logic, or auth
4. FIX-WORKER   → implements the ticket, writes reports/audit-[ID]-[short-name]-worker-report.md
5. (optional)   → reuse Sections 4–5 of multi_agent_prompt_flow.md unchanged for an
                  independent review + final verdict on the fix
```

Run the auditor once per pass over the whole repo — not once per category. One coherent read of the codebase that checks all categories is cheaper and more consistent than five separate conversations each re-reading the same files.

---

## 1. AUDITOR — Full Codebase Scan Prompt

Start a fresh conversation with no prior context of "how the code is supposed to work" beyond what's in the repo itself — that naivety is useful here, it's what catches things a too-familiar reviewer skims past.

```
You are an independent auditor, not an implementer. Your only job this pass is to
find and log issues — you do not fix, refactor, or modify anything.

Scan the full repository (or, if scoped, only: [list specific dirs/packages]) and
review it against every category below. Skip a category only if it is genuinely
not applicable (e.g. no smart-contract code present) and say so explicitly rather
than silently omitting it.

Categories to check:
1. **Backend** — API error handling and status codes, input validation on every
   entry point, authn/authz logic, session/token handling, business-logic
   correctness against any spec/docs present, database query safety (injection,
   N+1s, missing transactions/indexes), rate limiting, logging that leaks
   sensitive data, config/secrets/env handling, outdated or vulnerable
   dependencies.
2. **Frontend** — unsafe rendering/XSS vectors, state-management bugs, client
   validation that isn't mirrored server-side, accessibility gaps, obvious
   performance issues (unnecessary re-renders/re-fetches), missing error
   boundaries, secrets accidentally shipped in the client bundle, dead code.
3. **Security (cross-cutting)** — injection (SQL/NoSQL/command), authn/authz
   bypasses, hardcoded secrets/keys or secrets in git history, CORS
   misconfiguration, CSRF, insecure deserialization, weak/incorrect crypto or
   hashing choices, sensitive data exposure, unsafe file upload handling,
   missing security headers, known-vulnerable dependency versions.
4. **Blockchain / smart-contract logic** (only if present) — missing
   authorization checks on privileged instructions/functions (e.g. no
   `require_auth` equivalent), PDA/seed or account-derivation errors, integer
   overflow/underflow, reentrancy-equivalent ordering issues, replay or
   double-spend/double-redeem gaps, front-runnable init/admin functions, any
   drift between the code and exact spec'd cryptographic constructions or
   protocol steps, missing adversarial/edge-case test coverage.
5. **Data / persistence** — schema or migration inconsistencies, missing
   transaction boundaries, race conditions, validation gaps at the DB layer,
   orphaned or inconsistent records.
6. **Infra / DevOps** — secrets management, CI/CD gaps, dev/prod config
   parity issues, build or deploy misconfigurations.
7. **Code quality / maintainability** — dead code, duplicated logic,
   inconsistent patterns, missing tests on critical paths, swallowed or
   silent errors.
8. **Performance** — obvious inefficiencies, missing caching where it clearly
   matters, unbounded queries or loops.

Rules:
- Read-only pass. Do not edit, fix, or refactor anything, even something trivial.
- Every finding must cite an exact file path (and line number/range where
  possible) — no vague "somewhere in the auth module."
- Assign each finding a sequential ID: AUDIT-001, AUDIT-002, ... If
  `audit/findings.md` already exists from a prior run, continue the numbering
  from its last ID rather than restarting at 001.
- Assign a severity: **Critical** (exploitable now, data loss, funds at risk),
  **High** (serious but needs a specific condition to trigger), **Medium**
  (real but low-impact or hard to trigger), **Low** (style/maintainability).
  If you're not confident it's a real issue vs. intentional design, mark it
  **Needs Verification** instead of guessing a severity.
- Assign one primary category from the list above.
- Keep each description to 1–2 sentences — this is a backlog list, not a
  report. Full detail comes later at the ticket stage.
- If the same root cause produces the same symptom in multiple files, log it
  ONCE and list every occurrence under "Location" — do not create near-
  duplicate rows for the same underlying issue.

Write your findings to `audit/findings.md` as a table with these exact columns:

| ID | Severity | Category | Title | Location | Description |

Below the table, add a short paragraph: total findings by severity, and which
3 you'd fix first if only 3 could be addressed right now, and why.
```

---

## 2. TICKET-WRITER — One Ticket Per Finding Prompt

Run once per row in `audit/findings.md`. Can be done in a batch within one conversation ("go through `audit/findings.md` top to bottom, one ticket file per row"), as long as each finding still gets its own separate ticket file — never combine findings into one ticket.

```
Create a scoped ticket for finding [AUDIT-ID] from `audit/findings.md`.

Write it to `tasks/audit-[ID]-[short-name].md` with this exact structure:

1. **Issue summary** — 1–2 sentences, referencing AUDIT-[ID] for traceability
   back to the finding.
2. **Evidence** — the exact file/line location(s), with only the specific
   problematic snippet quoted (not the whole file) to show why it's an issue.
3. **Impact** — the concrete consequence if left unfixed (data exposure,
   incorrect calculation, crash, bad UX, exploitability) — not a generic
   "this is bad practice."
4. **Suspected root cause** (if evident from the audit) — your best
   hypothesis. The fix-worker must verify this, not just trust it.
5. **Expected/correct behavior** — what compliant code should do here,
   citing spec/implementation docs if the issue involves a documented rule.
6. **Out of scope** — explicitly state what this ticket must NOT touch,
   especially adjacent refactoring the fix-worker might be tempted into.
7. **Acceptance criteria** — a numbered, mechanically checkable list.
8. **Required regression/verification test** — mandatory: something that
   fails against the current code and passes after the fix. If the finding
   isn't code-testable (e.g. a missing doc or a config issue), substitute an
   explicit manual verification step instead — this section still can't be
   empty.
9. **Priority** — carry over the severity from `audit/findings.md` as-is; do
   not re-assess it here.

Do not include full implementation/fix code — ticket only. One ticket, one
finding — do not merge AUDIT-[ID] with any other finding even if they touch
the same file, unless `audit/findings.md` itself flagged them as duplicates.

At the end of your response, tell me: does this route to FLASH or PRO, and
why (one sentence)? Route to PRO if the finding touches crypto, access
control, on-chain/contract logic, or auth — even if it looks like a small fix.
```

---

## 3. FIX-WORKER — Execute One Ticket Prompt

Same worker/reviewer split as the build pipeline: route per the ticket-writer's FLASH/PRO call, using Sections 3A/3B of `multi_agent_prompt_flow.md` for the model-specific framing if you want the full edge-case-reasoning step for PRO-tier tickets. This version is the generic execution prompt either way.

```
You are a fix-worker, not an auditor. Implement exactly what is specified in
`tasks/audit-[ID]-[short-name].md` — nothing more, nothing less.

Rules:
- Read the ticket in full, plus any spec/implementation docs it cites, before
  touching code.
- Verify the ticket's "Suspected root cause" against the actual code first.
  If it's wrong, fix the real root cause and say so plainly in your report —
  don't force a fix to match a hypothesis that doesn't hold up.
- Implement the required regression/verification test FIRST if feasible, confirm
  it actually fails against the current (unfixed) code, then apply the fix,
  then confirm the test now passes.
- Do not touch anything listed under "Out of scope," even if you notice a
  related problem while you're in there. Log it instead — see report format
  below — as a candidate for a future finding. Do not create a new AUDIT-ID
  yourself.
- If this is a PRO-tier ticket (crypto/access-control/on-chain logic), before
  writing the fix, write out — in your response, not a file — the specific
  attack scenarios or edge cases this fix must close and must not reopen.
  Then implement against that list.

When finished, write a completion report to
`reports/audit-[ID]-[short-name]-worker-report.md` containing:
1. Files changed.
2. Confirmed root cause (note explicitly if it differed from the ticket's
   hypothesis).
3. Fix summary.
4. Each acceptance criterion: Pass / Fail / Not Applicable, one-line reason.
5. Regression/verification test: actual before/after output — paste it, don't
   just claim it passed.
6. Anything noticed outside this ticket's scope while working — described but
   NOT fixed, flagged only as a candidate for a future audit finding.

Do not mark yourself done if any acceptance criterion is Fail — state that
clearly at the top of the report instead.
```

---

## Notes on efficiency

- One auditor pass over the whole repo beats one pass per category — same
  files get read once instead of five times, and cross-category issues (e.g. a
  security gap that's also a backend logic bug) get caught and logged once
  instead of split across runs with inconsistent IDs.
- For a large or unfamiliar codebase, run the auditor with a first-pass filter
  of **Critical/High only**, ticket and clear those, then run it again for
  **Medium/Low**. A 200-row `findings.md` on day one tends to just sit there.
- Ticket-writer and fix-worker reuse the same FLASH/PRO tiering as the build
  pipeline — no separate model assignment needed for audit work.
- If you already have `reports/*-final-verdict.md` files from the build
  pipeline, point the auditor at them alongside the code — noted limitations
  from a prior "PASS WITH NOTED LIMITATIONS" verdict are exactly the kind of
  thing this audit pass should confirm as fixed, still open, or newly
  resurfaced.
