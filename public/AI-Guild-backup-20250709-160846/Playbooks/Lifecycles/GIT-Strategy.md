# Git Promotion and CI/CD Strategy with JIRA Integration

## 🌐 Environment Promotion Flow

```

DEVL  → BRANCHES  → DEVL
DEVL → TEST → PROD

```

## 📋 JIRA Integration

All work is now tracked through JIRA tickets instead of I/F/E documents:
- **Bugs** (replaces Issues): Technical fixes and defects
- **Tasks**: Technical work items
- **Stories** (replaces Features): User-facing capabilities
- **Epics**: Large multi-phase efforts

See `Jira-Strategy.md` for complete JIRA workflow details.

---

## 🔧 Assumptions

1. **User Responsibility:** Developers are responsible for placing correct versions into `DEVL` before beginning work.
2. **Explicit Promotion:** Versions do **not** auto-promote. Promotions to `TEST`, or `PROD` require explicit Guild approval and execution.
3. **JIRA Ticket References:** All work must reference a JIRA ticket (e.g., TIEMPO-123)
4. **New Work Creation:** Create JIRA ticket first, then create branch with ticket reference.

---

## 🚧 Git Workflow — DEVL Phase

### 🔹 Strategy
Each **JIRA ticket** (Bug, Task, Story, or Epic) is developed in an individual branch created from `DEVL`. All progress is tracked in JIRA with time logging by AI-Guild role.

---

### 🔁 Workflow Steps

| Step | Description |
|------|-------------|
| 1. | Confirm current branch is `DEVL`. Abort if not. |
| 2. | Create or assign JIRA ticket to yourself. |
| 3. | Create branch with JIRA reference: <br>`bugfix/TIEMPO-123-title`, `feature/TIEMPO-124-title`, `epic/TIEMPO-125-phase-1` |
| 4. | Initial commit must reference JIRA ticket in message. |
| 5. | Code in small commits. Log time in JIRA with AI-Guild role. Update JIRA status as work progresses. |
| 6. | Run ESLint: `npm run lint` |
| 7. | Run Build: `npm run build` |
| 8. | Run Locally: `npm run dev` |
| 9. | Request final review and approval. |
| 10. | Upon approval, merge into `DEVL`. |
| 11. | Delete the working branch after successful merge. |
| 12. | Update JIRA ticket to "Done" status after merge. |

---

### 🏷 Branch Naming Conventions

| JIRA Type | Format                              |
|-----------|-------------------------------------|
| Bug       | `bugfix/TIEMPO-123-user-name-blank` |
| Task      | `task/TIEMPO-124-refactor-auth`    |
| Story     | `feature/TIEMPO-125-add-location`  |
| Epic      | `epic/TIEMPO-126-phase-1-migration` |

- Use lowercase only.
- Replace spaces with hyphens.
- Always include JIRA ticket reference.
- Always prefix with `bugfix/`, `task/`, `feature/`, or `epic/`.

---

## ✅ Merge Requirements (into DEVL)

- ✔ No ESLint errors.
- ✔ Successful build.
- ✔ Local `npm run dev` test passes.
- ✔ JIRA ticket updated with progress.
- ✔ Time logged by AI-Guild role.
- ✔ PR references JIRA ticket.

---

## 📓 JIRA Updates (Mandatory)

After every working session:
1. **Log time** in JIRA with your AI-Guild role
2. **Update status** if work state changed
3. **Add comments** for significant findings or decisions
4. **Update PR** with latest changes

Commit messages should reference JIRA:
```
TIEMPO-123: Brief description

- Detailed point 1
- Detailed point 2

AI-Guild Role: Builder
```

---

## 🧭 Visual Flow Summary

```

Start
↓
Create JIRA Ticket
↓
Check DEVL Branch
↓
Create Branch with JIRA Ref
↓
Initial Commit (ref JIRA)
↓
Code + JIRA Updates
↓
Lint → Build → Dev Run
↓
Final Review
↓
Merge into DEVL
↓
Delete Branch
↓
Update JIRA to Done

```

---

## 📌 Next Phase Work

- Define TEST Promotion Rules (DEVL → TEST)
- Add GitHub Action for enforcing lint/build prior to merges (optional)
- Integrate JIRA status transitions with Git hooks

---

✅ Always verify you are on the correct branch  
✅ Always pass lint, build, and local dev run before merge  
✅ Always update JIRA ticket with progress and time logs

🔐 Guild Rules Implied and Enforced:
Guild works in local DEVL branch only.

No local work is done in TEST or PROD.

Promotion is always a GitHub push to remote origin/TEST or origin/PROD, using explicit, documented merge.

Merge events are the only mechanism by which code moves forward.

Guild updates JIRA ticket status and logs final time entries. All tracking is centralized in JIRA.

[DEV Work: Local Branches from DEVL]
       ↓
[Merge into Local DEVL]  ← Guild merges
       ↓
[Push Local DEVL to origin/DEVL]
       ↓
[Guild merges DEVL → origin/TEST] (remote only)
       ↓
[Guild merges TEST → origin/PROD] (remote only)
       ↓
[Guild updates JIRA ticket to Done status]

---

*Maintained under: `/public/readmes/Git_Strategy.md`*