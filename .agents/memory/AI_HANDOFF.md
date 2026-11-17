# AI_HANDOFF.md — Active Session Handoff

## Current Objective
Deliver the user's 6-step IaC improvement request:
1. Refactor NUT to fit existing Ansible patterns.
2. Share variables across Terraform and Ansible (`iac/shared/infrastructure.yml`).
3. Move values that belong in Infisical out of code.
4. Document all Ansible folders.
5. Update root documentation.
6. Create Ansible/Terraform skills, standards and templates in `.agents/`.

The full plan, decisions, IP map and IP review log are in [PLAN-iac-refactor.md](PLAN-iac-refactor.md).

## Current Status
Steps 1 (`UPS-NUT`) and 2 (`refactor/shared-infrastructure-vars`) are complete. `iac/shared/infrastructure.yml` is now the single source of truth for network, Proxmox node, and VM topology across Terraform (`yamldecode(file(...))`) and Ansible (`inventories/group_vars/all.yml` `lookup('ansible.builtin.file', ...) | from_yaml`), verified with zero drift across all 3 Terraform Proxmox environments and Ansible `ups-nut-check` / `traefik-check`. Next up is Step 3 (moving remaining hardcoded secrets to Infisical) on a new branch.

## Operating Constraints (MANDATORY — read first)
- **Plan before every action.** For each step (and each sub-action inside a step), describe exactly what will change and which commands will run. Wait for explicit user approval before editing files or running commands. "Approved plan" ≠ approval to execute each detail.
- **Speak up during planning.** Do not be a yes-man; provide reasoned pushback during planning if there is a better design or trade-off. Once the user decides, their decision is final.
- **Include line numbers on large file previews.** When showing large files or templates in chat, include line numbers on the left so the user can reference lines easily.
- **Dynamic Ansible patterns (like `pihole` and `traefik`).** Keep `defaults/main.yml` strictly for role-level constants/defaults (ports, timers, paths). Put host/instance topology in `group_vars` keyed by `inventory_hostname` (e.g., `nut_instances[inventory_hostname]`) and use `inventory_hostname`, `ansible_host`, `hostvars`, `secrets.ansible.<role>.*`, and Jinja loops directly in templates—never hardcode hostnames, VM names, or IPs in roles or templates.
- **Ask, don't build helpers.** Do not create helper scripts, harnesses or scratch tooling. To see what Ansible would change, use the existing `make <target>-check` (`--check --diff`), and only with user approval.
- **Stay in the repo.** All work stays inside `RWD.Infrastructure`. Never write to user folders (`~`, `~/.gemini`, `~/.ansible`, etc.).
- **Explain before running.** Before any command, say what it does and why. In particular, say whether it touches real hosts or Infisical.
- **No Guessing Policy:** never guess infrastructure configuration, variable values, secret mappings, or system behavior. Research the codebase or ask the user.
- **Broken references (Q6):** fix them, but ask the user about **each one** before changing it.
- **IP review (Q4):** review one IP at a time with the user.
- **Branching (Q5):** one new branch per step. Step 1 uses the existing branch `UPS-NUT`.

## Active Tasks
| Task | Status | Notes |
| :--- | :--- | :--- |
| Housekeeping: delete `nut_*.diff`, add `*.diff` to `.gitignore`, remove `pbcopy` from `ups-nut-check` | Complete | Merged in PR #18 (`UPS-NUT`) |
| Move plan into repo | Complete | `.agents/memory/PLAN-iac-refactor.md` (decisions recorded) |
| IP review — `.12`, `.14`, `.16`, `.8` | Complete | All resolved and applied via `iac/shared/infrastructure.yml` |
| Step 1 — NUT refactor (`UPS-NUT`) | Complete | Merged in PR #18 |
| Step 2 — shared `infrastructure.yml` (`refactor/shared-infrastructure-vars`) | Complete | Terraform `fmt`/`validate`/`plan` + Ansible `ups-nut-check`/`traefik-check` verified, redundant files/vars cleaned up, committed & pushed. |
| Step 3 — Infisical secrets | Pending | New branch. ACME email to be discussed separately (Q8). |
| Step 4 — Ansible docs | Pending | New branch |
| Step 5 — Root docs | Pending | New branch |
| Step 6 — `.agents` skills/standards/templates + consolidate and remove `.github/instructions` and copilot instructions (Q7) | Pending | New branch |
| Final: resolve all `TODO` / `DELETEME` markers + **rotate NUT `USER_PASSWORD` and `ADMIN_PASSWORD` in Infisical, re-deploy, and set `diff: false` on `upsd.users` / `upsmon.conf`** | Pending | **Remind the user before finishing.** |

## Step 1 Resolved Decisions
1. **Remove the `infisical_secrets` debug task:** ✅ Removed lines 67–70 in `iac/ansible/roles/infisical_secrets/tasks/main.yaml`.
2. **Diff visibility on `upsd.users` / `upsmon.conf`:** ✅ Keep diffs visible during Step 1 verification/testing; set `diff: false` at the end when rotating NUT passwords in Infisical.
3. **Who runs `make ups-nut-check`:** ✅ Agent ran `make ups-nut-check` with user approval; added password rotation to the final TODO list.
4. **Template comments & paths:** ✅ Added concise header/section comments to all `.j2` config files and scripts, and updated `upssched.conf.j2` to use modern Debian `/run/nut/upssched.{pipe,lock}`.
5. **Hardware aliases & dynamic inventory:** ✅ Used `Alias(instance_name)` (`Tower(proxmox)`, `M900(pve-p01)`, `G9(pve-d01)`) in log output; all templates loop dynamically over `nut_instances` in `iac/ansible/inventories/group_vars/proxmox_cluster.yml` and `hostvars[node].ansible_host` from `iac/ansible/inventories/hosts.yml`.

## Step 2 Resolved Decisions
1. **No symlinks for `iac/shared/infrastructure.yml`:** ✅ Terraform reads `iac/shared/infrastructure.yml` via `yamldecode(file(...))` in `locals.tf`; Ansible reads it via `iac/ansible/inventories/group_vars/all.yml` using `lookup('ansible.builtin.file', inventory_dir ~ '/../../shared/infrastructure.yml') | from_yaml`.
2. **IP review resolutions:** ✅ `.14` (`prod-docker-01`) includes `uptime-kuma-p01`; `.16` (`dev-docker-02`) runs `homarr-d02` (replaced `homepage-d02`) and `pulse-d02`; `.12` (`dev-docker-01`) is in `infrastructure.yml` (for TF and NUT) and kept out of `hosts.yml` `docker_hosts`; `.8` printer stays out of the repo.
3. **Redundant code & broken reference cleanups:** ✅ Removed redundant `alias`/`id`/`ip` from `proxmox_cluster.yml`, removed per-host `ansible_user`/`mailrise_ip`/`alert_email` from `hosts.yml` (using `docker_hosts.yml` in `system_updates.yml`), deleted `inventories/host_vars/*.yml`, deleted obsolete `playbooks/truenas.yml` and `roles/truenas/nfs/`, removed dead `storage`/`storage-check` targets in `Makefile`, fixed `deploy_nas_storage.yml` role path (`truenas/nas_config`), fixed Watchtower `mailrise.port` string interpolation bug, and removed commented-out duplicate modules in `pve-d01/main.tf`.

## Recent Progress
- Planned and reviewed every file of Step 1 one-by-one with the user before writing.
- Deployed `make ups-nut` live across `proxmox_cluster`, verified zero drift (`changed=0, failed=0`), verified `nut-server` / `nut-client` / `upsc` telemetry, and completed a full physical cluster staged takedown and automated `nut-bringup.service` recovery test across `pve-d01`, `pve-p01`, and `proxmox`.
- Merged Step 1 (`UPS-NUT`), created `refactor/shared-infrastructure-vars` for Step 2, created `iac/shared/infrastructure.yml` and `iac/ansible/inventories/group_vars/all.yml`, refactored Terraform Proxmox environments and Ansible inventories/group_vars/playbooks/roles/templates onto the shared config, cleaned up 6 redundant/broken items, and verified zero drift in both Terraform and Ansible.

## Immediate Next Action
Complete the `refactor/shared-infrastructure-vars` Pull Request review/merge on GitHub, then create a new branch for Step 3 (moving remaining hardcoded secrets to Infisical) and plan Step 3 with the user.
