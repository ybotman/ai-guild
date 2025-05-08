# Epic System - New Folder Structure and Process.
# Legacy system do not use

Do not use this to build Epics—there is a newer standard. This is legacy historical reference info only.

---

## Purpose

Epic documents capture major platform changes: system migrations, retirements, data model shifts, and major architectural refactors.  
They provide a phased, verifiable, auditable roadmap for implementation.
Note that some old Epics do not follow this document and we are not retrofitting old documents to new standards.

This README governs Epics created after the folder structure update.  
(Epics before this still live under the legacy system.)

---

## Folder Structure

Each Epic now lives in its own folder.

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

Why this large endeavor is being undertaken.

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

### Tasks

| Status         | Task                | Last Updated |
|----------------|---------------------|--------------|
| ✅ Complete    | Migrate DB schema   | 2025-04-23   |
| 🚧 In Progress | Deploy staging API  | 2025-04-23   |
| ⏳ Pending     | Run integration tests | -           |

---

### Rollback (if needed)

Step-by-step instructions for undoing this phase’s changes.

---

### Notes

Any clarifying context or decisions specific to this phase.

---

Use clear status indicators:  
- ✅ Complete  
- 🚧 In Progress  
- ⏳ Pending  
- ❌ Blocked  
- 🔁 Rolled Back  
- ⏸️ Deferred  

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

## Phase N:

### Goals

What the phase accomplishes.

### Tasks

| Status  | Task                 | Last Updated |
|---------|----------------------|--------------|
| ✅/🚧/⏳/❌ | Specific task description | YYYY-MM-DD   |

### Rollback (if needed)

How to undo this phase if problems occur.

### Notes

Phase-specific clarifications, side decisions, or extra context.

---

---

## Epic Process

1. Create Folder: `/AI-Guild/Tracking/Epics/Current/Epic_<topic>/`  
2. Write `Epic_<topic>.md` following the structure above.  
3. Optional: Add supporting files (Communication, API changes, etc.).  
4. Maintain Status & Next Steps table during active work.  
5. When completed:  
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

---
