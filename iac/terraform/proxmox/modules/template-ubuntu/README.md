This README provides a clear workflow for your "Golden Image" process: using Terraform to build the infrastructure and your script to perform the internal OS surgery and template locking.

---

# Proxmox Ubuntu Template Automation

This project automates the creation of a "Golden Image" Ubuntu template on Proxmox. It uses **Terraform** to provision the VM and a **Makefile + Bash script** to seal the OS and convert it into a template.

## The Workflow

1. **Provision**: Terraform creates a "Base VM" from a cloud image.
2. **Initialize**: Cloud-init installs the Guest Agent and sets up your user/SSH keys.
3. **Seal**: A script logs into the VM, wipes unique IDs (Machine-ID, SSH keys, logs), and shuts it down.
4. **Convert**: The script tells Proxmox to convert the stopped VM into a read-only template.

---

## Prerequisites

- **SSH Agent**: Your SSH key must be loaded in your local agent so it can be forwarded to the Proxmox host.

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

```

- **SSH Access**:
- Passwordless SSH access to the Proxmox Host as `root`.
- Your public key must be defined in the Terraform `initialization` block so the VM trusts you.

---

## Step 1: Provision the Base VM

Deploy the VM using Terraform. This VM is created in a "writable" state (`template = false`) so we can clean it.

```bash
terraform apply

```

**Note:** Ensure the `lifecycle` block in your Terraform code includes `ignore_changes = [ template, started ]`. This prevents Terraform from trying to "undo" the template conversion later.

---

## Step 2: Seal and Convert

Once the VM is running and reachable via the network, run the Makefile command.

```bash
make vm_to_template

```

### What happens during this step:

1. **Direct Connection**: The Makefile SSHs into your **Proxmox Host** using the `-A` flag (Agent Forwarding).
2. **OS Cleanup**: The script (running on Proxmox) SSHs into the **VM**, runs `cloud-init clean`, truncates `/etc/machine-id`, and deletes SSH host keys.
3. **Shutdown**: The VM shuts itself down to ensure disk consistency.
4. **Templating**: The script waits for the VM to stop, then runs `qm template <VMID>` on the Proxmox host.

---

## Step 3: Verify

In the Proxmox Web UI, your VM icon should change from a standard VM to a **Template icon (sheet of paper)**. The VM will be in a stopped state and is now ready to be cloned.

---

## Troubleshooting

| Error                           | Cause                    | Solution                                                                      |
| ------------------------------- | ------------------------ | ----------------------------------------------------------------------------- |
| `Permission denied (publickey)` | SSH Agent not forwarded. | Run `ssh-add` on your laptop and ensure the Makefile uses `ssh -A`.           |
| `sudo: command not found`       | Logged in as `root`.     | Ensure `CI_USER` in Makefile is set to your cloud-init user (e.g., `ka8kgj`). |
| `Connection timed out`          | VM not finished booting. | Wait 60 seconds after `terraform apply` before running `make`.                |

---

**Would you like me to add a "Testing" section to this README that shows the Terraform code for cloning a VM from this new template?**
