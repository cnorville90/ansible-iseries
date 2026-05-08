# Ansible + IBM iSeries Demo Suite

A progressive demo series showcasing **Ansible Automation Platform 2.6** managing
IBM i (iSeries / AS400) systems using the `ibm.power_ibmi` certified collection.

All demos run against the public IBM i system at **pub400.com** — no customer system
required to get started.

---

## What This Demonstrates

- Ansible's ability to manage IBM i alongside Linux, Windows, and cloud infrastructure
- Read-only, non-destructive operations (facts, SQL queries, job/subsystem reporting, PTF compliance)
- A purpose-built Execution Environment with `ibm.power_ibmi` ready to deploy in AAP
- A single config playbook that stands up the full demo suite in any AAP 2.6 instance

## Demo Overview

| Demo | Playbook | What It Shows |
|------|----------|---------------|
| Demo 1 | `demo1_ibmi_facts.yml` | System discovery — OS version, hardware, network |
| Demo 2 | `demo2_ibmi_sysval.yml` | System value audit — security and compliance values |
| Demo 3 | `demo3_ibmi_sql_query.yml` | SQL reporting — active jobs, user profiles, libraries |
| Demo 4 | `demo4_ibmi_jobs.yml` | Job & subsystem operations — workload visibility |
| Demo 5 | `demo5_ibmi_ptf.yml` | PTF compliance — fix group levels vs IBM PSP |

Advanced demos (user management, backup/restore, PTF apply, job queue control) are
also included for use against a customer's own IBM i with elevated authority.
See [ADVANCED_DEMOS.md](ADVANCED_DEMOS.md) for details.

---

## Getting Started

See **[SETUP.md](SETUP.md)** for full setup instructions.
