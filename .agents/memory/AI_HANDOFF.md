# AI_HANDOFF.md — Active Session Handoff

## Current Objective
Add required `vm_on_boot` configuration to `clone-vm` module, enforce `vm_on_boot = false` across all Proxmox environments, and ensure all Terraform workflows use `Makefile` commands.

## Current Status
All Proxmox VM modules (`clone-vm`, `truenas-vm`, `homeassistant`, `omv-vm`) updated with required `vm_on_boot` setting. All active environments (`proxmox/proxmox`, `proxmox/pve-d01`, `proxmox/pve-p01`) applied successfully with `make apply`. Ready for commit and pull request.

## Active Tasks
| Task | Status | Notes |
| :--- | :--- | :--- |
| Add `vm_on_boot` property to `clone-vm` | Complete | `on_boot = var.vm_on_boot` mapped in `main.tf`, required in `variables.tf`, documented in `README.md` |
| Add `vm_on_boot` property to `truenas-vm` | Complete | `on_boot = var.vm_on_boot` mapped in `main.tf`, required in `variables.tf`, documented in `README.md` |
| Add `vm_on_boot` property to `homeassistant` | Complete | `on_boot = var.vm_on_boot` mapped in `main.tf`, required in `variables.tf`, documented in `README.md` |
| Add `vm_on_boot` property to `omv-vm` | Complete | `on_boot = var.vm_on_boot` mapped in `main.tf`, required in `variables.tf`, configured in `pve-p01` |
| Set `vm_on_boot = false` across active VMs | Complete | Updated `Dev_Docker_01`, `homeassistant`, `dev-truenas-01` in `proxmox/proxmox`, `dev-docker-02` in `pve-d01`, and `prod-docker-01`, `dev-omv-01` in `pve-p01` |
| Fix `homeassistant` cascading replacement | Complete | Added `ignore_changes` to `ha_image.source_file` and `home_assistant.disk` |
| Apply configuration across environments | Complete | `make apply` completed successfully in `proxmox/proxmox`, `proxmox/pve-d01`, and `proxmox/pve-p01` |
| Review & update Terraform documentation | Complete | Documented `omv-vm` and `infisical`, updated `pve-d01`, corrected inverted storage VM references, reconciled GitHub repository inventories, synced module inputs, usage snippets, and Makefile-first commands |
| Future: Refactor `homeassistant` for multi-VM reusability | Backlog | Decouple local image uploading (`files/haos_ova-16.3.img`) from VM instantiation; parameterize `image_file_id` or download URL |

## Recent Progress
- Added required `vm_on_boot` (no default) to all Proxmox VM modules (`clone-vm`, `truenas-vm`, `homeassistant`, `omv-vm`).
- Set `vm_on_boot = false` on all active VM instances in `proxmox/proxmox`, `pve-d01`, and `proxmox/pve-p01`.
- Protected `homeassistant` from destructive replacement using `ignore_changes` on installer file and disk.
- Successfully applied Terraform in all three target environments via `Makefile`.
- Conducted comprehensive documentation review across `iac/terraform/` and all child folders (Proxmox, GitHub, Infisical); created `omv-vm/README.md` and `infisical/README.md`, updated `pve-d01/README.md`, corrected storage references in `pve-p01` and `proxmox/proxmox`, reconciled managed repository catalogs in `github/realworlddevelopers` and `github/rwdevlead`, documented Infisical vault auth patterns, and synchronized directory trees and Makefile-first commands.

## Operating Constraints
- **No Guessing Policy:** AI agents must never guess or make assumptions about infrastructure configuration, variable values, secret mappings, or system behavior. Always research the codebase and documentation to find verified facts, or ask the user directly for clarification.

## Immediate Next Action
Run `/commit-cleanup` and `/create-pr` to commit changes and prepare the pull request into `main`.




