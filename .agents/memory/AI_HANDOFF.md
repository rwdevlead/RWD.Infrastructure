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
Step 1 (`UPS-NUT` branch) is complete: `proxmox/nut` role refactored, deployed live via `make ups-nut`, verified with `make ups-nut-check` (`changed=0, failed=0`), tested end-to-end with a full physical cluster staged takedown and automated `nut-bringup.service` recovery across `pve-d01`, `pve-p01`, and `proxmox`, and pushed on `UPS-NUT` with PR ready for review. Next up is Step 2 (`iac/shared/infrastructure.yml`) on a new branch.

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
| Housekeeping: delete `nut_*.diff`, add `*.diff` to `.gitignore`, remove `pbcopy` from `ups-nut-check` | Complete | Committed on `UPS-NUT` |
| Move plan into repo | Complete | `.agents/memory/PLAN-iac-refactor.md` (decisions recorded) |
| IP review — `.12` | Complete | `mailrise_ip` → prod-docker-01 (.14). `truenas/nfs` `nfs_server` → dev-truenas-01 (.13). Not yet applied in code. |
| IP review — remaining IPs | Pending | Next candidates: `.14`, `.16`, `.12`, `.8` (see Open Questions) |
| Step 1 — NUT refactor (`UPS-NUT`) | Complete | Deployed (`make ups-nut`), idempotency verified (`make ups-nut-check`), full cluster takedown/bring-up tested, committed & pushed on `UPS-NUT`. |
| Step 2 — shared `infrastructure.yml` | Pending | New branch |
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

## Open Questions — IP Review (one at a time, for Step 2)
- **.14 prod-docker-01:** the repo also runs Uptime Kuma (`uptime-kuma-p01`, port 3001) here. It's not in the user's list.
- **.16 dev-docker-02:** the repo runs `pulse-d02` and `homarr-d02` here. The user's list has `homepage-d02`. Is homarr the "homepage"?
- **.12 dev-docker-01:** the user lists services here, but dev-docker-01 is not in `inventories/hosts.yml` (only `host_vars/dev-docker-01.yml` exists).
- **.8 printer:** should it go in the shared file?

## Recent Progress
- Planned and reviewed every file of Step 1 one-by-one with the user before writing.
- Removed the secret-printing debug task (`#DELETEME`) from `iac/ansible/roles/infisical_secrets/tasks/main.yaml`.
- Flattened `proxmox_cluster` in `iac/ansible/inventories/hosts.yml` (`pve-d01`, `pve-p01`, `proxmox`) and removed `nut_config` from `iac/ansible/inventories/group_vars/docker_hosts.yml`.
- Created `iac/ansible/inventories/group_vars/proxmox_cluster.yml` with `ansible_user: root` and `nut_instances` keyed by `inventory_hostname`.
- Created `iac/ansible/roles/proxmox/nut/` (`defaults/main.yml`, `tasks/main.yml`, `handlers/main.yml`, 10 dynamic `.j2` templates in `templates/`, and `README.md`), and removed the old `iac/ansible/roles/nut/` directory.
- Updated `iac/ansible/playbooks/nut.yml` to use `proxmox/nut` and updated `Makefile` (`ups-nut`, `ups-nut-check` in `.PHONY`, `$(ANSIBLE)`/`$(ANSIBLE_DIR)` vars, removed trailing `\`).
- Ran `make ups-nut-check` against `pve-d01`, `proxmox`, and `pve-p01` (all succeeded with `failed=0`) and reviewed the live-file comparison with the user (notably fixing `pve-d01` `nut.conf` from `MODE=standalone` to `MODE=netserver` and updating `upssched.conf.j2` to `/run/nut/upssched.{pipe,lock}`).
- Deployed `make ups-nut` live across `proxmox_cluster`, verified zero drift (`changed=0, failed=0`), verified `nut-server` / `nut-client` / `upsc` telemetry, and completed a full physical cluster staged takedown and automated `nut-bringup.service` recovery test across `pve-d01`, `pve-p01`, and `proxmox`.
- Committed and pushed Step 1 on `UPS-NUT` and prepared the Pull Request package.

## Immediate Next Action
Complete the `UPS-NUT` Pull Request review/merge on GitHub, then create a new branch for Step 2 (`iac/shared/infrastructure.yml`), finish the 1-by-1 IP reviews (`.14`, `.16`, `.12`, `.8`), and plan Step 2 with the user.
