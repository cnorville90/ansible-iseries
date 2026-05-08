# Ansible + IBM iSeries (ibm.power_ibmi) Demo Suite — Roadmap

## Overview

A progressive series of demos showcasing Ansible Automation Platform 2.6
with IBM iSeries using the `ibm.power_ibmi` certified collection against
the public iSeries system at **pub400.com**.

---

## Environment

| Item | Detail |
|---|---|
| Target host | `pub400.com` |
| Protocol | SSH (PASE) |
| Collection | `ibm.power_ibmi` |
| Python on iSeries | `/QOpenSys/pkgs/bin/python3.6` |
| AAP Version | 2.6 |

---

## Demo Progression

### Demo 1 — System Discovery (`ibmi_facts`)
**Goal:** Validate full connectivity stack; gather OS version, PTF levels, hardware info.

- **Modules:** `ibmi_facts`
- **Status:** [x] Complete
- **Talking points:**
  - Zero-touch inventory enrichment
  - Dynamic hostvars for conditional logic in downstream playbooks
  - Ideal smoke test to prove SSH + PASE + collection are all working

---

### Demo 2 — System Value Audit (`ibmi_sysval`)
**Goal:** Read and report key system values such as `QSECURITY`, `QCCSID`, `QTIMZON`.

- **Modules:** `ibmi_sysval`
- **Status:** [x] Complete
- **Talking points:**
  - Compliance reporting and config drift detection
  - Exportable as structured data for CMDB or ticketing integration

---

### Demo 3 — SQL Query Reporting (`ibmi_sql_query`)
**Goal:** Query DB2 for i catalog tables — list libraries, users, or active jobs.

- **Modules:** `ibmi_sql_query`
- **Status:** [x] Complete
- **Talking points:**
  - Zero-footprint data extraction directly from the DB2 catalog
  - Feed results into reports, dashboards, or downstream automation decisions

---

### Demo 4 — Job & Subsystem Operations (`ibmi_job` / `ibmi_display_subsystem`)
**Goal:** Query active jobs and display subsystem status.

- **Modules:** `ibmi_job`, `ibmi_display_subsystem`
- **Status:** [x] Complete
- **Talking points:**
  - Workload visibility and operational reporting
  - Replace manual operator tasks with repeatable, audited playbook runs

---

### Demo 5 — PTF / Fix Compliance (`ibmi_fix_group_check`)
**Goal:** Check installed PTF groups and report fix levels.

- **Modules:** `ibmi_fix_group_check`
- **Status:** [x] Complete
- **Talking points:**
  - Automated security patch compliance reporting
  - Foundation for a full remediation workflow: check → download → apply

---

## Requires *SECADM Authority (Customer System Demos)

The following playbooks are built and ready but require elevated authority
not available on the shared pub400.com system. Use these when presenting
against a customer's own IBM i environment.

### Advanced Demo A — User Profile Management (`ibmi_user_and_group`)
**Goal:** Create a demo user profile with defined attributes, then remove it — idempotently.

- **Modules:** `ibmi_user_and_group`
- **Requires:** `*SECADM` special authority
- **Talking points:**
  - Day-2 lifecycle operations: create, modify, disable, delete
  - RBAC automation with full audit trail via AAP job history

### Advanced Demo B — Object Save & Restore (`ibmi_object_save` / `ibmi_object_restore`)
**Goal:** Save a library or object to a save file, fetch it locally, and restore it.

- **Modules:** `ibmi_object_save`, `ibmi_object_restore`, `ibmi_fetch`
- **Requires:** `*SAVSYS` or object authority
- **Talking points:**
  - Backup automation replacing manual `SAVLIB` / `RSTLIB` operator steps
  - Migration pipeline pattern: save → transfer → restore across systems

---

## Suggested Build Order

```
Demo 1 (facts) → Demo 2 (sysval) → Demo 3 (SQL) → Demo 4 (jobs) → Demo 5 (PTF)
```

Start with read-only, non-destructive demos (1–3) to build confidence and
validate access, then progress to operational demos (4–5).
