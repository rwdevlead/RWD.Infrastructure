# Packer Templates

This directory contains Packer templates for building VM images on Proxmox.

## Overview

Packer automates the creation of VM templates on Proxmox using Infrastructure as Code. Templates are built once and cloned multiple times, reducing deployment time and ensuring consistency.

## Directory Structure

```
packer/
├── ubuntu/                    # Ubuntu template
│   ├── ubuntu.pkr.hcl         # Main Packer HCL template
│   ├── variables.pkr.hcl      # Variable definitions
│   ├── build.auto.pkrvars.hcl # Proxmox connection + build settings (local)
│   └── http/                  # Cloud-init datasource files
│       ├── user-data          # Ubuntu autoinstall + cloud-init config
│       └── meta-data          # Instance metadata
└── README.md                  # This file
```

## Templates

### Ubuntu 24.04 Server (`ubuntu/`)

**Purpose:** Base Ubuntu server template on Proxmox with automated installation and provisioning.

**Features:**

- ✅ Automated installation via Ubuntu Subiquity autoinstall
- ✅ Cloud-init configured for first-boot customization
- ✅ QEMU guest agent enabled for Proxmox integration
- ✅ SSH configured (root password auth + key injection support)
- ✅ Predictable sizing (2 cores, 8GB RAM, 20GB disk)

**Key Configuration Files:**

1. **`ubuntu.pkr.hcl`** — Main template

   - Proxmox source configuration (connection, hardware, networking)
   - Boot command with kernel parameters for unattended installation
   - Provisioners: SSH key injection, cloud-init cleanup
   - Output: Proxmox VM template

2. **`variables.pkr.hcl`** — Variable declarations

   - Proxmox URL, credentials (username + token)
   - VM destination (node, vm_id, template_name)
   - SSH settings (username, public key)
   - ISO file path and network settings

3. **`build.auto.pkrvars.hcl`** — Local configuration (⚠️ gitignored)

   - Proxmox connection details (URL, user, token)
   - Build target (node, vm_id, template_name, ISO)
   - **Warning:** Contains sensitive credentials; keep local and never commit

4. **`http/user-data`** — Cloud-init autoinstall config

   - Ubuntu autoinstall YAML (unattended OS installation)
   - Identity, storage, SSH, package configuration
   - Late-commands to set root password, enable qemu-guest-agent, disable cloud-init on subsequent boots

5. **`http/meta-data`** — Instance metadata
   - Minimal metadata for cloud-init datasource

## Building Templates

### Prerequisites

1. **Packer** (v1.14.2+) installed locally
2. **Proxmox** host with API access (credentials in `build.auto.pkrvars.hcl`)
3. **Ubuntu Live Server ISO** uploaded to Proxmox storage (path in `build.auto.pkrvars.hcl`)

### Build Process

#### Option A: Using Makefile (Recommended)

```bash
cd /Users/ka8kgj/Documents/Source/RWD.Infrastructure

# Validate template
make packer-validate

# Build template (injects your SSH key from ~/.ssh/id_ed25519.pub)
make packer-build
```

The Makefile:

- Formats HCL files
- Initializes plugins and modules
- Validates configuration
- Builds and converts VM to template
- Automatically injects your public SSH key into root user

#### Option B: Direct Packer Commands

```bash
cd iac/packer/ubuntu

# Validate
packer validate .

# Format
packer fmt .

# Build (with SSH key injection)
SSH_KEY="$(cat ~/.ssh/id_ed25519.pub)"
packer build -var "ssh_pub_key=$SSH_KEY" .
```

### Build Workflow

1. **VM Creation** — Packer creates ephemeral VM (ID 901) on Proxmox node
2. **ISO Boot** — VM boots from Ubuntu Live Server ISO
3. **Autoinstall** — Kernel parameters trigger unattended installation via Subiquity
4. **Cloud-init** — OS install complete; cloud-init runs late-commands:
   - Set root password (ubuntu)
   - Enable SSH with password auth
   - Enable qemu-guest-agent (Proxmox integration)
   - Disable cloud-init datasource lookups (prevents re-provisioning on clone)
5. **Provisioning** — Packer provisions via SSH:
   - Wait for system stability
   - Inject public SSH key to /root/.ssh/authorized_keys
   - Clean up cloud-init state and reset machine-id
6. **Template Creation** — VM converted to Proxmox template
7. **Cleanup** — Ephemeral VM destroyed; template ready for cloning

### Build Output

**Success:**

- Proxmox template created (default name: `ubuntu-24.04-template`)
- Root user configured with password auth (`ubuntu`) + SSH key auth
- Cloud-init disabled on subsequent boots (won't interfere with Terraform provisioning)
- QEMU guest agent running (Proxmox can fetch VM IP, hostname, etc.)

**Troubleshooting:**

| Issue                 | Cause                            | Solution                                                           |
| --------------------- | -------------------------------- | ------------------------------------------------------------------ |
| VM 901 already exists | Previous build VM not cleaned up | Manually delete VM 901 in Proxmox before re-running                |
| SSH timeout           | Autoinstall failed; VM has no IP | Check Proxmox VM console for installer errors; verify network/DHCP |
| Provisioner fails     | SSH key not injected             | Verify `~/.ssh/id_ed25519.pub` exists and is readable              |
| Template not created  | Build error during provisioning  | Check Packer logs: `PACKER_LOG=DEBUG make packer-build`            |

## Using Templates with Terraform

When cloning the template via Terraform:

1. **Cloning** — Terraform creates a new VM from the template
2. **Cloud-init** — Terraform passes `user-data` via Proxmox cloud-init data source
3. **SSH Key Injection** — Cloud-init receives public key in `user-data` and injects it (Option 1 approach)
4. **Result** — VM is ready for SSH key-based authentication

See `iac/terraform/proxmox/` for Terraform VM provisioning using this template.

## Maintenance

### Updating the Template

If you need to modify the base image:

1. Edit `iac/packer/ubuntu/http/user-data` (cloud-init config) or `ubuntu.pkr.hcl` (Packer config)
2. Run `make packer-build` to create a new template
3. Delete the old template in Proxmox (keep only the latest version)
4. Update any Terraform variables that reference the template ID

### Customization

Common changes:

- **Packages:** Add to `user-data` under `packages:` section
- **Disk size:** Modify `local.disk.disk_size` in `ubuntu.pkr.hcl`
- **Memory/Cores:** Modify `local.memory` and `local.cores` in `ubuntu.pkr.hcl`
- **Hostname:** Change `identity.hostname` in `user-data`
- **Network:** Modify `local.network` in `ubuntu.pkr.hcl`

## References

- [Packer Documentation](https://www.packer.io/docs)
- [Proxmox Builder for Packer](https://github.com/hashicorp/packer-plugin-proxmox)
- [Ubuntu Autoinstall Documentation](https://ubuntu.com/server/docs/install/autoinstall)
- [Cloud-init Documentation](https://cloud-init.io/)
