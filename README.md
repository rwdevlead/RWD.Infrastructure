🧰 Infrastructure Makefile Usage Guide

This repository includes a universal Makefile that simplifies Terraform, Packer, and Ansible workflows.
Each folder under terraform/ is treated as an independent Terraform root module (e.g., terraform/github, terraform/proxmox, etc.).

⸻

🚀 Quick Start

For a fresh clone or new environment setup:

# 1️⃣ Choose a Terraform target (example: github)

make list-targets

# 2️⃣ Initialize Terraform in that target directory

make init TARGET=github

# 3️⃣ Review the planned infrastructure changes

make plan TARGET=github ENV=dev

# 4️⃣ Apply the plan to deploy resources

make apply TARGET=github

💡 Tip: You can replace github with any other target folder (like proxmox, network, etc.).

⸻

🏗️ Basic Commands

# Initialize Terraform for a specific target

make init TARGET=github

# Create a Terraform plan

make plan TARGET=proxmox ENV=dev

# Apply the most recent plan

make apply TARGET=proxmox

# Validate Terraform, Packer, and Ansible configs

make validate TARGET=github

# Format all Terraform and Packer code

make fmt

# Run Terraform and Ansible lint checks

make lint

# Clean up temporary Terraform and Packer files

make clean

⸻

🌎 Environment Support

You can load environment-specific variables by creating files under the env/ folder:

env/dev.mk
env/prod.mk

Then run any Make command with:

make plan TARGET=github ENV=dev

Each .mk file can set environment-specific credentials, regions, or other configuration values.

⸻

🔁 Multi-Target Operations

To perform actions across all Terraform root modules under terraform/:

# Initialize all Terraform projects

make all-init

# Generate plans for all Terraform projects

make all-plan

# Validate all Terraform projects

make all-validate

These commands loop through each Terraform directory (e.g., terraform/github, terraform/proxmox, etc.) automatically.

⸻

📋 Utility Commands

# Show the current environment, target, and paths

make status

# List all available Terraform root directories

make list-targets

⸻

⚙️ Example Directory Layout

terraform/
├── github/
│ ├── main.tf
│ ├── variables.tf
│ └── modules/
├── proxmox/
│ ├── main.tf
│ ├── variables.tf
│ └── modules/
env/
├── dev.mk
├── prod.mk
playbooks/
├── setup.yml
packer/
├── templates/

⸻

🪄 Tips
• TARGET defaults to github if not specified.
• ENV defaults to default if not provided.
• make all-\* commands run independently for each Terraform root — safe to use even if some projects fail validation.
• Designed for macOS (Zsh) but compatible with other Unix shells.
• You can extend this Makefile easily by adding new targets to automate CI/CD or cloud tasks.
