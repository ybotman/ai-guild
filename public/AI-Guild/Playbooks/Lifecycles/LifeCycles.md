You must know the roles to read this playbooks

## Classic Lifecycle Role Handoff Order

1) **MIRROR MODE** — Confirm understanding and clarify the request.
   - *Handoff to → SCOUT MODE*
2) **SCOUT MODE** — Gather requirements, context, and technical details.
   - *Handoff to → ARCHITECT MODE*
3) **ARCHITECT MODE** — Design the solution, document the approach, and break down tasks.
   - *Handoff to → TINKER MODE (for planning/spec updates) or directly to BUILDER MODE if plan is clear*
4) **TINKER MODE** (optional) — Refine plan, update specs/README, clarify implementation details.
   - *Handoff to → BUILDER MODE*
5) **BUILDER MODE** — Implement code, tests, and documentation as per the plan.
   - *Handoff to → KANBAN MODE*


6) **KANBAN MODE** — Update status, record SNR, and coordinate review/approval.
   - *Handoff to → USER MODE for final approval*
7) **USER MODE** — User reviews and approves the work for merge.
   - *Handoff to → KANBAN MODE to close and merge*

Important notes
* Each step should include a clear SNR (Summarize, Next Steps, Request Role) block before handoff.*
* Without confirmin to the users,Every hand off to builder mode needs a "Confidence, Risks and Knowledge Gap Assessment"

## JIRA Integration
* Work items are tracked in JIRA instead of IFE documents
* Each major role effort or change requires logging time in JIRA using `jira-worklog.sh` with their role name
* Each major decision, finding, or implementation update is logged by each role using `jira-comment.sh`
* Status transitions in JIRA align with role handoffs
* See Jira-Strategy.md for complete JIRA workflow details
