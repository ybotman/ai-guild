# Epic System - Large Effort, Multi-Phase, Multi-Branch Process

---

## Purpose

Epic documents define **large, multi-phase efforts** that drive major platform changes: migrations, retirements, data model shifts, and architectural refactors.  
By definition, an Epic is broken into multiple phases, each with its own branch, work effort, and commit cycle.  
**At any time, work is focused on a single phase branch of the larger Epic.**  
Each phase must be independently completed, reviewed, and merged before the next phase begins.

---

## Folder Structure

Each Epic lives in its own folder.

| Path                                               | Contents                                       |
|----------------------------------------------------|-----------------------------------------------|
| `/AI-Guild/Tracking/Epics/Current/Epic_<topic>/`   | Active Epic and all related documentation     |
| `/AI-Guild/Tracking/Epics/Completed/Epic_<topic>/` | Completed Epic and all supporting docs, archived |

Inside each Epic folder are documents. Build only the documents you deem necessary based on the scope:

- `Epic_<topic>.md` → Main document  
- Additional supporting files (optional):  
  - `Epic_<topic>_Communication.md`  
  - `Epic_<topic>_Summary.md`  
  - `Epic_<topic>_Approach.md`  
  - `Epic_<topic>_API_Changes.md`  
  - `Epic_<topic>_UI_Changes.md`  

---

## Required Structure for `Epic_<topic>.md`

Each Epic must follow this template:

---

# Epic_<topic>

### Summary

High-level purpose and context of this Epic.

### Scope

**Inclusions:**  
- What is covered.

**Exclusions:**  
- What is explicitly not covered.

### Motivation

Why this large, multi-phase effort is being undertaken.

### Changes

Describe the changes needed:  
- Backend  
- Frontend  
- Infrastructure (if any)  
- Database schema  
- API endpoints  

### Risks & Mitigations

| Risk | Mitigation |
|-------|------------|
|       |            |

### Rollback Strategy

Exact steps to revert the changes if needed.

### Dependencies

Other Epics, API versions, systems, or external services this Epic depends on.

### Linked Epics

Cross-references to related or prerequisite Epics.

### Owner

Primary owner (team or individual) responsible for this Epic.

---

### Phases

Each Epic is divided into multiple phases.  
**Each phase:**
- Has its own branch (e.g., `epic/5002-phase-1-db-migration`)
- Is worked on and committed independently
- Must be completed, reviewed, and merged before the next phase starts
- May remove, refactor, or retire existing code as needed

#### Example Phase Table

| Phase    | Status         | Branch Name                        | Last Updated | Description                  |
|----------|---------------|------------------------------------|--------------|------------------------------|
| Phase 1  | ✅ Complete    | epic/5002-phase-1-db-migration     | 2025-04-23   | DB schema migration          |
| Phase 2  | 🚧 In Progress | epic/5002-phase-2-api-refactor     | 2025-04-24   | API refactor                 |
| Phase 3  | ⏳ Pending     | epic/5002-phase-3-ui-update        | -            | UI updates                   |

---

### Phase Template

#### Phase N: <Phase Title>

**Goals:**  
- What this phase accomplishes.

**Tasks:**

| Status  | Task                 | Last Updated |
|---------|----------------------|--------------|
| ✅/🚧/⏳/❌ | Specific task description | YYYY-MM-DD   |

**Rollback (if needed):**  
- How to undo this phase if problems occur.

**Notes:**  
- Phase-specific clarifications, side decisions, or extra context.

---

### Rollback (if needed)

Step-by-step instructions for undoing this phase’s changes.

---

### Timeline

| Stage        | Date       |
|--------------|------------|
| Start        | YYYY-MM-DD |
| Deploy       | YYYY-MM-DD |
| Final Review | YYYY-MM-DD |

---

### Status & Next Steps

This centralizes status across all phases.  
Keep this table updated continuously.

| Phase     | Status                                | Next Step             | Last Updated |
|-----------|-------------------------------------|----------------------|--------------|
| Phase 1:  | ✅ Complete / 🚧 In Progress / ⏳ Pending / ❌ Blocked | Short action description | YYYY-MM-DD   |
| Phase 2:  |                                     |                      |              |
| Phase 3:  |                                     |                      |              |
| …         |                                     |                      |              |

✅ No more updating status in multiple places. This is the one source of truth.

---

## Epic Process

1. Create Folder: `/AI-Guild/Tracking/Epics/Current/Epic_<topic>/`  
2. Write `Epic_<topic>.md` following the structure above.  
3. For each phase:
   - Create a dedicated branch for the phase.
   - Work only on that phase branch until complete.
   - Complete, review, and merge before starting the next phase.
4. Optional: Add supporting files (Communication, API changes, etc.).
5. Maintain Status & Next Steps table during active work.
6. When all phases are completed:
   - Move folder to `/AI-Guild/Tracking/Epics/Completed/`
   - Update any cross-Epic references if needed.

---

## Best Practices

- **Markdown Only:** All Epics written in `.md` format.  
- **Small, Verifiable Phases:** Each phase should be individually stable and testable.  
- **Clear Status Tracking:** Always update the Status & Next Steps table first.  
- **Linked Documents:** Keep supporting files in the Epic folder itself.  
- **Rollback Plans:** Always be ready to revert safely.  
- **History Friendly:** Every major update should leave a clean audit trail.
- **Each phase may remove, refactor, or retire existing code as needed.**

---
