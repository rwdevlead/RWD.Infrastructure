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
Steps 1–6, inline comment cleanup, NUT `diff: false` suppression, IaC bug-fix/cleanup pass, `proxmox/proxmox` Infisical folder path update (`/terraform/proxmox/proxmox`), full decommissioning/removal of `dev-docker-01`, rotation/re-deployment of NUT `USER_PASSWORD` and `ADMIN_PASSWORD` across `proxmox_cluster` (`make ups-nut`), and Docker Compose `.env` (`mode: "0600"`, `diff: false`) secret isolation across all `apps/` roles (including migrating `nebula-sync` and `watchtower` to Docker Compose) are all complete, committed (`eab16e2`, `e3bc5a3`), and pushed to `origin/chore/getLatest`.

## Operating Constraints (MANDATORY — read first)
- **PRIORITY 1 — NEVER ACT WITHOUT EXPLICIT APPROVAL:** Do **not** create, edit, or delete any file, and do **not** run any command, without explicit user approval first. When proposing a plan or batch of edits, **end the turn with no write/delete/command tool calls** and wait for the user's explicit go-ahead. "Approved plan" ≠ approval to execute each detail.
- **Chat formatting:** Do not use the section-sign character (`&sect;` / section symbol) in chat responses.
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
| Step 2 — shared `infrastructure.yml` (`refactor/shared-infrastructure-vars`) | Complete | Merged in PR #19 |
| Step 3 — Infisical secrets (`fix/infisical-secrets`) | Complete | Merged in PR #20 |
| Step 4 — Ansible docs (`docs/ansible-documentation`) | Complete | Merged into `main` (`4e34754`) |
| Step 5 — Root docs (`docs/ansible-documentation`) | Complete | Merged into `main` (`4e34754`) |
| Inline comments & `.env.example` cleanup (`docs/ansible-documentation`) | Complete | Merged into `main` (`4e34754`) |
| Step 6 — `.agents` skills/standards/templates + consolidate and remove `.github/instructions` and copilot instructions (Q7) | Complete | Merged into `main` (`fa7bdd6`) |
| Final NUT security (`diff: false`) & IaC bug-fix/cleanup pass (`fix/nut-security-and-bugs`) | Complete | Merged into `main` (`5af7f08`) |
| Rotate NUT `USER_PASSWORD` and `ADMIN_PASSWORD` in Infisical (`/ansible/nut`) and re-deploy `make ups-nut` | Complete | Deployed across `pve-d01`, `pve-p01`, and `proxmox` (`failed=0`) |
| Fix `proxmox/proxmox` Infisical folder path (`/terraform/proxmox/proxmox`) & remove decommissioned `dev-docker-01` across IaC and docs | Complete | Removed `dev-docker-01` from `infrastructure.yml`, Terraform, NUT `proxmox_cluster.yml`, and docs; deployed via `make ups-nut` |
| Standardize Docker Compose `.env` (`mode: "0600"`, `diff: false`) secret isolation across `apps/` roles (`traefik`, `pihole`, `portainer`, `portainer_agent`, `homarr`, `nebula-sync`, `watchtower`, plus `mailrise.conf` `0600`/`diff: false`) and `.agents/` + `RWD.Ai.Stack` | Complete | Keeps `docker-compose.yml` `--check --diff` output visible without exposing Infisical secrets; mirrored into `RWD.Ai.Stack` (`.agents/` and `starter/.agents/`) |
| Commit `.env` secret-isolation changes on `chore/getLatest` (`RWD.Infrastructure`) | Complete | Pushed commits `eab16e2` and `e3bc5a3` to `origin/chore/getLatest` |
| Sync GitHub CLI (`gh`) PR standard updates to `RWD.Infrastructure` (`AGENTS.md`, `git-and-pr-standards.md`, `workflow-standards.md`, `create-pr/SKILL.md`) | Complete | Aligned `RWD.Infrastructure` with `RWD.Ai.Stack` `gh` CLI guidelines |
| Open/merge PR for `chore/getLatest` (`RWD.Infrastructure`) and validate/commit in `RWD.Ai.Stack` | In Progress | PR #24 (`feat/pihole-cleanup-and-watchtower` -> `main`) merged; remaining: run `./scripts/validate-templates.sh` and commit in `RWD.Ai.Stack` |
| Roll out `.env` secret-isolation updates to `dev-docker-02` and `prod-docker-01` (`make <app>-check` / `make <app>`) | Pending | Note: stop/remove existing standalone `nebula-sync` (`prod-docker-01`) and `watchtower` (`dev-docker-02`, `prod-docker-01`) containers once before `docker_compose_v2` takes over management |
| Add `pull: always` to `apps/pihole` and create reusable `docker/image_cleanup` role (`docker_image_cleanup.yml`, `make docker-cleanup-check` / `make docker-cleanup`) | Complete | Verified with `make docker-cleanup-check` and `make pihole-check` (`failed=0`) after installing `infisicalsdk` into Homebrew Ansible Python |
| Update Pi-hole (`make pihole`) | Complete | Deployed across `dev-docker-02` and `prod-docker-01` (`failed=0`); `.env` isolation, `pull: always`, health assertions, and `docker/image_cleanup` all succeeded |
| Fix Watchtower notifications (`make watchtower-check` / `make watchtower`) | Complete | Removed old standalone `watchtower-d02` / `watchtower-p01` containers and deployed Compose-managed Watchtower with `pull: always`, `docker/image_cleanup`, and `WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT: "8025"` (`failed=0`) |
| Update Traefik (`make traefik`) | Complete | Added `pull: always` and `docker/image_cleanup`, verified with `make traefik-check`, and deployed cleanly on `dev-docker-02` (`failed=0`, healthy, `/ping` `200`) |
| Update Mailrise (`make mailrise`) | Complete | Added `pull: always`, `docker/image_cleanup`, `999:999` `0600` ownership on `mailrise.conf`, removed `outlook` medium, and verified `email`/`icloud` test notifications on `prod-docker-01` (`failed=0`) |

## Step 1 Resolved Decisions
1. **Remove the `infisical_secrets` debug task:** ✅ Removed lines 67–70 in `iac/ansible/roles/infisical_secrets/tasks/main.yaml`.
2. **Diff visibility on `upsd.users` / `upsmon.conf`:** ✅ Keep diffs visible during Step 1 verification/testing; set `diff: false` at the end when rotating NUT passwords in Infisical.
3. **Who runs `make ups-nut-check`:** ✅ Agent ran `make ups-nut-check` with user approval; added password rotation to the final TODO list.
4. **Template comments & paths:** ✅ Added concise header/section comments to all `.j2` config files and scripts, and updated `upssched.conf.j2` to use modern Debian `/run/nut/upssched.{pipe,lock}`.
5. **Hardware aliases & dynamic inventory:** ✅ Used `Alias(instance_name)` (`Tower(proxmox)`, `M900(pve-p01)`, `G9(pve-d01)`) in log output; all templates loop dynamically over `nut_instances` in `iac/ansible/inventories/group_vars/proxmox_cluster.yml` and `hostvars[node].ansible_host` from `iac/ansible/inventories/hosts.yml`.

## Step 2 Resolved Decisions
1. **No symlinks for `iac/shared/infrastructure.yml`:** ✅ Terraform reads `iac/shared/infrastructure.yml` via `yamldecode(file(...))` in `locals.tf`; Ansible reads it via `iac/ansible/inventories/group_vars/all.yml` using `lookup('ansible.builtin.file', inventory_dir ~ '/../../shared/infrastructure.yml') | from_yaml`.
2. **IP review resolutions:** ✅ `.14` (`prod-docker-01`) includes `uptime-kuma-p01`; `.16` (`dev-docker-02`) runs `homarr-d02` (replaced `homepage-d02`) and `pulse-d02`; `.12` (`dev-docker-01`) has been decommissioned on `proxmox` and removed from `iac/shared/infrastructure.yml`, Terraform `proxmox/proxmox`, NUT `proxmox_cluster.yml`, and documentation; `.8` printer stays out of the repo.
3. **Redundant code & broken reference cleanups:** ✅ Removed redundant `alias`/`id`/`ip` from `proxmox_cluster.yml`, removed per-host `ansible_user`/`mailrise_ip`/`alert_email` from `hosts.yml` (using `docker_hosts.yml` in `system_updates.yml`), deleted `inventories/host_vars/*.yml`, deleted obsolete `playbooks/truenas.yml` and `roles/truenas/nfs/`, removed dead `storage`/`storage-check` targets in `Makefile`, fixed `deploy_nas_storage.yml` role path (`truenas/nas_config`), fixed Watchtower `mailrise.port` string interpolation bug, and removed commented-out duplicate modules in `pve-d01/main.tf`.

## Step 3 Resolved Decisions
1. **Uptime Kuma Nebula push token:** ✅ Stored in Infisical at `/ansible/uptime_kuma` → `NEBULA_PUSH_TOKEN`; added `"/ansible/uptime_kuma"` to `playbooks/nebula_sync.yml` and referenced `{{ uptime_kuma.domain }}` in `docker_hosts.yml`.
2. **Unused `apps/semaphore` role:** ✅ Removed `iac/ansible/roles/apps/semaphore/` completely.
3. **Traefik ACME email (Q8):** ✅ Stored in Infisical at `/ansible/cloudflare` → `ACME_EMAIL` and referenced via `{{ secrets.ansible.cloudflare.ACME_EMAIL }}` in `roles/apps/traefik/defaults/main.yml`.
4. **Portable `ansible.cfg` paths:** ✅ Replaced hardcoded `/Users/ka8kgj/...` paths in `iac/ansible/ansible.cfg` with relative paths (`./collections:~/.ansible/collections`, `./inventories`, `./roles`) and exported `ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg` in `Makefile`.

## Recent Progress
- Planned and reviewed every file of Step 1 one-by-one with the user before writing.
- Deployed `make ups-nut` live across `proxmox_cluster`, verified zero drift (`changed=0, failed=0`), verified `nut-server` / `nut-client` / `upsc` telemetry, and completed a full physical cluster staged takedown and automated `nut-bringup.service` recovery test across `pve-d01`, `pve-p01`, and `proxmox`.
- Merged Step 1 (`UPS-NUT`), created `refactor/shared-infrastructure-vars` for Step 2, created `iac/shared/infrastructure.yml` and `iac/ansible/inventories/group_vars/all.yml`, refactored Terraform Proxmox environments and Ansible inventories/group_vars/playbooks/roles/templates onto the shared config, cleaned up 6 redundant/broken items, and verified zero drift in both Terraform and Ansible.
- Merged Step 2 (`refactor/shared-infrastructure-vars`), created `fix/infisical-secrets` for Step 3, moved `NEBULA_PUSH_TOKEN` and `ACME_EMAIL` to Infisical, removed unused `apps/semaphore`, converted `iac/ansible/ansible.cfg` to relative paths, verified with `make ansible-config`, `make nebula-check`, and `make traefik-check`, and merged PR #20.
- Merged `docs/ansible-documentation` (`4e34754`), `chore/agents-iac-tooling` (`fa7bdd6`), and `fix/nut-security-and-bugs` (`5af7f08`) into `main`.
- Updated `iac/terraform/environments/proxmox/proxmox/data.tf` (`folder_path = "/terraform/proxmox/proxmox"`), removed decommissioned `dev-docker-01` (and unused `default_username` / `default_password` in `proxmox/proxmox/variables.tf`) from `iac/shared/infrastructure.yml`, Terraform, NUT `proxmox_cluster.yml`, and documentation, rotated NUT `USER_PASSWORD` and `ADMIN_PASSWORD` in Infisical (`/ansible/nut`), and deployed `make ups-nut` cleanly across `pve-d01`, `pve-p01`, and `proxmox`.
- Implemented `.env.j2` (`mode: "0600"`, `diff: false`) secret isolation across all secret-bearing `apps/` roles (`traefik`, `pihole`, `portainer`, `portainer_agent`, `homarr`, `nebula-sync`, `watchtower`) and converted `nebula-sync` and `watchtower` to Docker Compose so `docker-compose.yml` diffs remain visible during `--check --diff` without leaking credentials; codified the pattern in `.agents/` and `RWD.Ai.Stack`.

## Immediate Next Action
1. Open and merge the pull request for `feat/mailrise-update` -> `main` in `RWD.Infrastructure` (`/create-pr`).
2. Roll out the remaining `.env` (`0600`, `diff: false`) + `docker-compose.yml` updates to `dev-docker-02` and `prod-docker-01` via `make <app>-check` and `make <app>` (`nebula`, `portainer`, `portainer-agent`, `homarr`), removing the old standalone `nebula-sync` container once so `docker_compose_v2` can manage it cleanly.
3. In `RWD.Ai.Stack`, run `./scripts/validate-templates.sh`, commit the mirrored IaC standards/templates/skills and `.env` isolation updates, and open/merge the PR to `main`.
