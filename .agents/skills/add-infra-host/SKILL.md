---
name: add-infra-host
description: Add a new VM or host consistently across iac/shared/infrastructure.yml, Terraform, Ansible inventories, and NUT orchestration. Trigger with "/add-infra-host".
argument-hint: "<hostname> (e.g. prod-docker-02)"
---

# Purpose

Add a new VM or physical host across the single source of truth (`iac/shared/infrastructure.yml`), Terraform Proxmox environments, and Ansible inventories without duplicating IPs or VM IDs.

---

## Step 1 — Confirm Topology Details

1. Read `.agents/standards/shared-config-standards.md` and `iac/shared/infrastructure.yml`.
2. Confirm with the user (never guess):
   - Hostname (`<env>-<role>-<nn>`), static IPv4 address, Proxmox node (`pve-d01`, `pve-p01`, `proxmox`), and VM ID.
   - Terraform module parameters (template, cores, memory, disk size, `vm_on_boot`).
   - Ansible groups (`docker_hosts`, app groups), service instance entries (`group_vars/docker_hosts.yml`), and NUT shutdown tier (`group_vars/proxmox_cluster.yml`, if covered by UPS takedown).
3. Present the exact plan across all files and wait for user approval.

---

## Step 2 — Update Shared Topology, Terraform & Ansible

1. **`iac/shared/infrastructure.yml`:** Add the host under `vms:` (or `proxmox_nodes:`) with `vm_id`, `node`, and `ip`.
2. **Terraform (`iac/terraform/environments/proxmox/<node>/main.tf`):** Add the VM module referencing `local.infra.vms["<host>"]` and `local.infra.network.{gateway,prefix}`.
3. **Ansible (`iac/ansible/inventories/hosts.yml`):** Add the host with `ansible_host: "{{ vms['<host>'].ip }}"` and assign it to the appropriate groups.
4. **Ansible Group Vars:** Add any per-host service config to `group_vars/docker_hosts.yml` and NUT shutdown/startup tier metadata to `group_vars/proxmox_cluster.yml` (`nut_instances`).

---

## Step 3 — Verify Both Layers

1. Run `make fmt TARGET=proxmox/<node>`, `make validate TARGET=proxmox/<node>`, and `make plan TARGET=proxmox/<node>` to confirm the Terraform diff matches only the intended VM.
2. With user approval, run `make base-check`, `make docker-check`, or `make ups-nut-check` (`--check --diff`) to confirm Ansible inventory resolution and dry-run diffs.
3. Update `iac/ansible/inventories/README.md` or environment READMEs if needed.
