# Advanced Demos — Requires Elevated Authority

These playbooks are built and tested but require special authority not available
on the shared **pub400.com** system. Present these against a **customer's own IBM i
environment** where the automation account has been granted the necessary authority.

---

## Why Elevated Authority?

The public demos (1–5) are intentionally read-only and safe to run on any system.
The advanced demos perform **state-changing operations** — creating objects, moving
data, patching software — that IBM i protects behind special authority levels.

This mirrors real-world automation deployments where Ansible runs under a dedicated
service account with scoped, auditable authority.

---

## Advanced Demo A — User Profile Management

**Playbook:** `advanced_demo_a_ibmi_user.yml`
**Requires:** `*SECADM` special authority

### What it does
1. Creates a demo user profile (`ANSIDEMO`) with defined attributes
2. Verifies the profile exists via DB2 SQL query
3. Disables the profile (`*DISABLED` status)
4. Deletes the profile — full idempotent lifecycle

### Modules Used
- `ibm.power_ibmi.ibmi_user_and_group`
- `ibm.power_ibmi.ibmi_sql_query`

### Talking Points
- **Day-2 lifecycle automation** — replace manual `CRTUSRPRF` / `CHGUSRPRF` / `DLTUSRPRF` operator steps
- **RBAC at scale** — onboard and offboard users consistently across multiple partitions
- **Full audit trail** — every change timestamped in AAP job history with who ran it and when
- **Idempotency** — safe to re-run; won't fail if the profile already exists or is already gone

---

## Advanced Demo B — Object Save & Restore

**Playbook:** `advanced_demo_b_ibmi_save_restore.yml`
**Requires:** `*SAVSYS` or object-level save authority

### What it does
1. Creates a save file (`QGPL/ANSISAVE`)
2. Saves an entire library (`APPLIB`) into the save file
3. Fetches the save file from IBM i to the Ansible controller (`/tmp/`)
4. Restores the library from the save file
5. Cleans up the temporary save file

### Modules Used
- `ibm.power_ibmi.ibmi_object_save`
- `ibm.power_ibmi.ibmi_object_restore`
- `ibm.power_ibmi.ibmi_fetch`
- `ibm.power_ibmi.ibmi_cl_command`

### Talking Points
- **Backup automation** — replace manual `SAVLIB` / `RSTLIB` operator steps with a scheduled, audited playbook
- **Cross-system migration pipeline** — save on source → pull to controller → push and restore on target
- **Disaster recovery** — combine with AWX schedules for nightly save + offsite transfer
- **Compliance evidence** — every backup run logged in AAP with RC and file size

---

## Advanced Demo C — PTF Download & Apply

**Playbook:** `advanced_demo_c_ibmi_ptf_apply.yml`
**Requires:** `*IOSYSCFG` or `*ALLOBJ` to order/apply PTFs

### What it does
1. Checks current installed PTF group level (pre-check)
2. Orders and downloads the PTF group from IBM Fix Central
3. Applies downloaded PTFs with `*DELAYED` (activates at next IPL)
4. Reports before/after status

### Modules Used
- `ibm.power_ibmi.ibmi_fix_group_check`
- `ibm.power_ibmi.ibmi_fix_network_install_client`
- `ibm.power_ibmi.ibmi_fix`

### Talking Points
- **Patch compliance automation** — close the loop from Demo 5's compliance report: check → download → apply
- **Controlled activation** — `*DELAYED` flag means PTFs stage safely without forcing an immediate IPL
- **Multi-partition orchestration** — loop this across a fleet of LPAR inventories in a single job
- **Audit-ready** — group number, level, and RC captured in every job run

---

## Advanced Demo D — Subsystem & Job Queue Control

**Playbook:** `advanced_demo_d_ibmi_subsystem.yml`
**Requires:** `*JOBCTL` special authority

### What it does
1. Checks current subsystem status (`QBATCH`)
2. Holds the job queue — pauses new job dispatch
3. Verifies the held state via DB2 `QSYS2.JOB_QUEUE_INFO`
4. Releases the job queue — restores normal operations

### Modules Used
- `ibm.power_ibmi.ibmi_display_subsystem`
- `ibm.power_ibmi.ibmi_cl_command`
- `ibm.power_ibmi.ibmi_sql_query`

### Talking Points
- **Maintenance window automation** — drain queues before applying PTFs or taking backups, then release
- **Change control enforcement** — trigger queue holds from a Change Management system via AAP API
- **Workload orchestration** — coordinate batch windows across partitions without manual operator involvement
- **Verification built in** — SQL confirmation step proves the state change before proceeding

---

## Authority Summary

| Demo | Playbook | Authority Required |
|------|----------|--------------------|
| Advanced A | `advanced_demo_a_ibmi_user.yml` | `*SECADM` |
| Advanced B | `advanced_demo_b_ibmi_save_restore.yml` | `*SAVSYS` |
| Advanced C | `advanced_demo_c_ibmi_ptf_apply.yml` | `*IOSYSCFG` / `*ALLOBJ` |
| Advanced D | `advanced_demo_d_ibmi_subsystem.yml` | `*JOBCTL` |

---

## Recommended Talking Track

> "Everything you've seen in Demos 1 through 5 runs against a shared public IBM i
> with zero elevated authority — pure read access, no risk to the system.
>
> These advanced demos show what happens when you give Ansible a scoped service
> account with the right authority. You're now doing things operators do manually
> every day — creating users, backing up libraries, patching, controlling workload —
> but now it's repeatable, auditable, and integrated with your change management
> and ticketing systems through AAP's API."
