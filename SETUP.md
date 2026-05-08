# Demo Suite Setup Guide
## Ansible Automation Platform 2.6 + IBM iSeries (`ibm.power_ibmi`)

This guide walks a Solutions Architect through standing up the full demo suite
from scratch against their own AAP 2.6 instance and the public IBM i system
at **pub400.com**.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Ansible Automation Platform | 2.6 — your own instance (any deployment) |
| pub400.com account | Free — register at [pub400.com](https://www.pub400.com) |
| Workstation tools | `ansible-navigator` |
| Python | 3.9+ on your workstation |

> **No Automation Hub token or container build required.** A pre-built Execution Environment
> is publicly available at `quay.io/cnorvill/ee-iseries:latest` and includes
> `ibm.power_ibmi`, `ansible.utils`, and `infra.aap_configuration`.

---

## Step 1 — Get a pub400.com Account

1. Go to [https://www.pub400.com](https://www.pub400.com) and register for a free account.
2. Once approved, you will receive your **username** (all caps, e.g. `JSMITH`) and SSH access on **port 2222**.
3. Generate an SSH key pair for the demo:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_pub400 -C "pub400 demo key"
   ```
4. Add your public key to pub400.com via their web portal or by logging in with password first:
   ```bash
   ssh -p 2222 JSMITH@pub400.com
   # Then follow their SSH key setup instructions in the member portal
   ```
5. Verify SSH key login works:
   ```bash
   ssh -i ~/.ssh/id_rsa_pub400 -p 2222 JSMITH@pub400.com
   ```

---

## Step 2 — Fork and Clone This Repository

```bash
# Fork https://github.com/cnorville90/ansible-iseries on GitHub, then:
git clone https://github.com/YOUR_GITHUB_USERNAME/ansible-iseries.git
cd ansible-iseries
```

---

## Step 3 — Configure Your Inventory

Edit `inventory` and replace with your pub400.com username and SSH key path:

```ini
[iseries]
pub400.com ansible_user=JSMITH ansible_port=2222 ansible_ssh_private_key_file=~/.ssh/id_rsa_pub400

[iseries:vars]
ansible_python_interpreter=/QOpenSys/pkgs/bin/python3.6
```

> **Note:** Python 3.6 is required — `itoolkit` (the `ibm.power_ibmi` dependency) is only
> installed for Python 3.6 on pub400.com.

---

## Step 4 — Set Up Ansible Vault

Create a vault password file (never commit this):

```bash
echo 'YourVaultPassword' > .vault_pass
chmod 600 .vault_pass
```

Create an encrypted vars file for your AAP token:

```bash
ansible-vault create vault_vars.yml --vault-password-file .vault_pass
```

Add these contents (replace with your values):

```yaml
controller_token: "YOUR_AAP_OAUTH_TOKEN"
```

To generate an AAP OAuth token:
- Log in to your AAP Controller → **User menu (top right)** → **User Details** → **Tokens** → **Add**
- Set scope to **Write**, save the token value

---

## Step 5 — Update the AAP Config Playbook

Edit `demo_iseries_aap_config.yml` and replace the following values:

```yaml
vars:
  aap_hostname: https://YOUR_AAP_HOSTNAME        # your AAP Controller URL
  aap_username: YOUR_AAP_USERNAME                # your AAP login

  controller_credentials:
    - name: "pub400-ssh"
      inputs:
        username: YOUR_PUB400_USERNAME            # e.g. JSMITH
        ssh_key_data: "{{ lookup('file', 'id_rsa_pub400') }}"

  controller_hosts:
    - name: pub400.com
      inventory: "IBM iSeries — pub400"
      variables:
        ansible_user: YOUR_PUB400_USERNAME        # e.g. JSMITH
        ansible_port: 2222
        ansible_python_interpreter: /QOpenSys/pkgs/bin/python3.6
```

> **The EE image (`quay.io/cnorvill/ee-iseries:latest`) and project SCM URL do not need
> to change** — leave them as-is. AAP will pull the shared public EE and clone the
> upstream repo directly.

Copy your SSH private key into the project directory (gitignored):

```bash
cp ~/.ssh/id_rsa_pub400 ./id_rsa_pub400
```

---

## Step 6 — Run the AAP Config Playbook

This single playbook creates all inventories, credentials, projects, and job
templates in your AAP Controller:

```bash
ansible-navigator run demo_iseries_aap_config.yml \
  -e @vault_vars.yml \
  --vault-password-file .vault_pass \
  --mode stdout
```

Expected: all roles complete with no failures. The project sync (`controller_project_update`)
may take 30–60 seconds while AAP clones the GitHub repo.

---

## Step 7 — Verify the Demo Suite

Run a quick smoke test from the CLI to confirm connectivity:

```bash
ansible-navigator run demo1_ibmi_facts.yml \
  --vault-password-file .vault_pass \
  --mode stdout
```

You should see IBM i system facts returned from pub400.com.

Then log in to your AAP Controller and confirm:
- **Execution Environments:** `ee-iseries` is listed
- **Credentials:** `pub400-ssh` is listed
- **Inventories:** `IBM iSeries — pub400` exists with host `pub400.com` in group `iseries`
- **Projects:** `ansible-iseries` shows a successful sync
- **Job Templates:** Demos 1–5 and Advanced Demos A–D are all present

---

## Demo Run Order

Start with read-only demos to validate connectivity, then progress to operational demos:

```
Demo 1 — System Discovery       (ibmi_facts)
Demo 2 — System Value Audit     (ibmi_sysval)
Demo 3 — SQL Query Reporting    (ibmi_sql_query)
Demo 4 — Job & Subsystem Ops    (ibmi_job / ibmi_display_subsystem)
Demo 5 — PTF Compliance         (ibmi_fix_group_check)
```

Advanced demos (A–D) require elevated authority — use against a **customer's own IBM i**,
not pub400.com. See [ADVANCED_DEMOS.md](ADVANCED_DEMOS.md) for talking points and
authority requirements.

---

## Files That Are Gitignored (You Must Create Locally)

| File | Purpose |
|---|---|
| `.vault_pass` | Vault password file |
| `id_rsa_pub400` | SSH private key for pub400.com |
| `vault_vars.yml` | Encrypted AAP token |

---

## Troubleshooting

**`itoolkit` errors / Python not found**
Ensure `ansible_python_interpreter` is set to `/QOpenSys/pkgs/bin/python3.6` in inventory.

**AAP config roles fail with 401**
Regenerate your AAP OAuth token — tokens can expire. Update `vault_vars.yml`.

**`ibmi_cl_command` tasks work but lose state between tasks**
Each task runs in a new IBM i job. QTEMP is job-scoped and does not persist — design
playbooks to use persistent libraries (e.g. QGPL) for any inter-task objects.

**pub400.com SSH connection refused**
pub400.com uses **port 2222**, not 22. Confirm `ansible_port: 2222` is set.
