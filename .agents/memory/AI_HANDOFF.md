# AI_HANDOFF.md — Active Session Handoff

## Current Objective
Enable QEMU guest agent in `omv-vm` module matching `clone-vm` pattern, expose VM outputs, and synchronize documentation.

## Current Status
Created feature branch `feature/omv-qemu-agent`. Added `agent { enabled = true }` to `iac/terraform/modules/proxmox/omv-vm/main.tf`, created `iac/terraform/modules/proxmox/omv-vm/outputs.tf`, updated `README.md` files, and verified via `make validate TARGET=proxmox/pve-p01`.

## Active Tasks
| Task | Status | Notes |
| :--- | :--- | :--- |
| Add QEMU guest agent to `omv-vm` | Complete | `agent { enabled = true }` added to `main.tf` |
| Add `outputs.tf` to `omv-vm` | Complete | Exports `vm_ipv4_address` and `vm_id` matching `clone-vm` pattern |
| Update module documentation | Complete | Documented guest agent and outputs in `omv-vm/README.md` and `modules/proxmox/README.md` |
| Validate Terraform configuration | Complete | Validated via `make validate TARGET=proxmox/pve-p01` |
| Commit and PR | Pending | Ready for `/commit-cleanup` and `/create-pr` |

## Recent Progress
- Switched to dedicated feature branch `feature/omv-qemu-agent`.
- Configured QEMU guest agent in `iac/terraform/modules/proxmox/omv-vm/main.tf` following standard established in `clone-vm`.
- Added `iac/terraform/modules/proxmox/omv-vm/outputs.tf` exporting `vm_ipv4_address` (via QEMU guest agent) and `vm_id`.
- Updated `iac/terraform/modules/proxmox/omv-vm/README.md` and `iac/terraform/modules/proxmox/README.md`.
- Formatted with `terraform fmt` and verified successfully with `make validate TARGET=proxmox/pve-p01`.

## Operating Constraints
- **No Guessing Policy:** AI agents must never guess or make assumptions about infrastructure configuration, variable values, secret mappings, or system behavior. Always research the codebase and documentation to find verified facts, or ask the user directly for clarification.

## Immediate Next Action
Run `/commit-cleanup` and `/create-pr` to commit changes and prepare the pull request into `main`.




