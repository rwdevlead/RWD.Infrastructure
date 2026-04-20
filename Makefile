# ==========================================================
# Phony Targets (targets that don't produce files)
# ==========================================================
.PHONY: help \
	init plan apply validate fmt clean destroy \
	cleanup-vm convert-to-template \
	ansible-config \
	base base-check \
	docker docker-check \
	portainer portainer-check \
	storage storage-check \
	traefik traefik-check \
	mailrise mailrise-check \
	pihole pihole-check \
	homepage homepage-check \
	watchtower watchtower-check \
	truenas truenas-check \
	setup-updates run-upgrade

# ==========================================================
# Environment Setup (Load .env file if present)
# ==========================================================
# The .env file is optional and can override default variables
# It is gitignored to prevent committing sensitive credentials
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ==========================================================
# Global Variables (Configuration)
# ==========================================================
# ENV - Target environment (default: unassigned)
# TARGET - Terraform target directory (github, proxmox, etc)
# TERRAFORM_DIR - Full path to selected Terraform directory
# ANSIBLE - Command to run Ansible playbooks
# ANSIBLE_DIR - Path to Ansible configurations and playbooks

ENV ?= unassigned
TARGET ?= unassigned

TEST_VAR ?= unassigned

TERRAFORM_DIR := iac/terraform/$(TARGET)


# ==========================================================
# Help Target (displays all available targets)
# ==========================================================
help: ## Show this help message with all available targets
	@echo '═══════════════════════════════════════════════════════════════'
	@echo 'RWD.Infrastructure - Infrastructure as Code Automation'
	@echo '═══════════════════════════════════════════════════════════════'
	@echo
	@echo 'USAGE:'
	@echo '  make [target] [TARGET=github|proxmox|...] [ENV=environment_name]'
	@echo
	@echo 'EXAMPLES:'
	@echo '  make plan TARGET=github ENV=dev              # Plan GitHub infrastructure changes'
	@echo '  make apply TARGET=proxmox                    # Apply Proxmox VM provisioning'
	@echo '  make docker-check                            # Dry-run Docker deployment'
	@echo '  make docker                                  # Deploy Docker platform'
	@echo
	@echo 'AVAILABLE TARGETS:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo 'ENVIRONMENT VARIABLES:'
	@echo '  TARGET                          Terraform target (github, proxmox, etc)'
	@echo '  ENV                             Environment name (default, staging, production)'
	@echo
	@echo 'For more information, see:'
	@echo '  - Terraform instructions: instructions/TERRAFORM.md'
	@echo '  - Ansible instructions: instructions/ANSIBLE.md'
	@echo '  - Packer instructions: instructions/PACKER.md'
	@echo '═══════════════════════════════════════════════════════════════'


# ==========================================================
# Proxmox VM Templating Commands (Golden Image Creation)
# ==========================================================
# These targets help convert built VMs to reusable templates
# Usage: make cleanup-vm && make convert-to-template PROXMOX_NODE=<node> VM_ID=<id>

# make cleanup-vm VM_USER=ubuntu VM_IP=192.168.50.101
cleanup-vm: ## Remove temporary VM state (SSH keys, DHCP lease, etc.) before templating
	@set -e; \
	echo "Running VM cleanup script..."; \
	./cleanup_vm.sh

# make convert-to-template PROXMOX_NODE=proxmox01 VM_ID=901
convert-to-template: ## Convert cleanup VM to a reusable Proxmox template for cloning
	@echo "Converting VM $(VM_ID) to template on $(PROXMOX_NODE)..."
	@PROXMOX_NODE=$(PROXMOX_NODE) VM_ID=$(VM_ID) ./convert_to_template.sh


# ==========================================================
# Terraform Commands (Infrastructure Provisioning)
# ==========================================================
# Usage: make [target] TARGET=github|proxmox ENV=environment_name
# Example: make plan TARGET=github ENV=dev
# Example: make apply TARGET=proxmox

destroy: ## Destroy all infrastructure for selected TARGET (use with caution!)
	@echo "Running Terraform Destroy in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform destroy"; \
	fi

init: fmt ## Initialize Terraform (download providers and modules) for selected TARGET
	@echo "Initializing Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform init -upgrade; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform init"; \
	fi

plan: ## Create execution plan showing what infrastructure will be created/modified/destroyed
	@echo "Planning Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform plan -out=tfplan; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform plan"; \
	fi

apply: ## Apply the Terraform plan to provision/update actual infrastructure
	@echo "Applying Terraform plan in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ -f "$(TERRAFORM_DIR)/tfplan" ]; then \
		cd $(TERRAFORM_DIR) && terraform apply; \
	else \
		echo "No Terraform plan found in $(TERRAFORM_DIR), skipping terraform apply"; \
	fi

validate: init ## Validate Terraform configuration syntax and structure
	@echo "Validating Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform validate; \
	else \
		echo "No Terraform files found, skipping terraform validate"; \
	fi

fmt: ## Format all Terraform HCL files to canonical style
	@echo "Formatting Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform fmt; \
	else \
		echo "No Terraform files found, skipping terraform fmt"; \
	fi

clean: ## Delete generated Terraform files (plan, .terraform dir) but preserve state
	@echo "Cleaning Terraform and Packer files in $(TERRAFORM_DIR)..."
	rm -f $(TERRAFORM_DIR)/tfplan
	rm -rf $(TERRAFORM_DIR)/.terraform
	@echo "✅ Terraform state files (tfstate) are preserved."
	# Remove Packer cache
	rm -rf packer_cache/
	# Remove Ansible retry files
	rm -f *.retry
	

# ==========================================================
# Ansible Commands (Configuration Management & Deployment)
# ==========================================================
# Warning: Use -check targets first to preview changes!
# Each target has a corresponding -check target for dry-runs

# Configuration and Diagnostics
ANSIBLE=ansible-playbook
ANSIBLE_DIR=iac/ansible

ansible-config: ## Display current Ansible configuration settings
	ansible-config dump --only-changed

# === Base System Configuration ===

base-check: ## Dry-run: Review base system configuration (hostname, security, fail2ban)
	ansible-playbook iac/ansible/playbooks/base.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

base: ## Deploy base system configuration (hostname, security, fail2ban)
	ansible-playbook iac/ansible/playbooks/base.yml \
		-i iac/ansible/inventories/docker.yml

# === Docker Platform Setup ===

docker-check: ## Dry-run: Review Docker platform setup (NFS mounts, engine, compose)
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

docker: ## Deploy Docker platform (NFS mounts, engine, compose)
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

# === Storage Configuration for NAS ===

storage-check: ## Dry-run: Review storage configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/storage.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

storage: ## Deploy storage configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/storage.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

# === Reverse Proxy & Load Balancing ===

traefik-check: ## Dry-run: Review Traefik reverse proxy configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

traefik: ## Deploy Traefik reverse proxy for container routing
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

# === Container Management & Orchestration ===

portainer-check: ## Dry-run: Review Portainer container management deployment
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

portainer: ## Deploy Portainer container management platform
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

# === Application Services ===

mailrise-check: ## Dry-run: Review Mailrise email notification service
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

mailrise: ## Deploy Mailrise email notification service
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/docker.yml

pihole-check: ## Dry-run: Review Pi-hole DNS/ad-blocker deployment
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

pihole: ## Deploy Pi-hole DNS and ad-blocking service
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/docker.yml

homepage-check: ## Dry-run: Review Homepage dashboard deployment
	ansible-playbook iac/ansible/playbooks/homepage.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

homepage: ## Deploy Homepage dashboard service
	ansible-playbook iac/ansible/playbooks/homepage.yml \
		-i iac/ansible/inventories/docker.yml

watchtower-check: ## Dry-run: Review Watchtower auto-update service
	ansible-playbook iac/ansible/playbooks/watchtower.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

watchtower: ## Deploy Watchtower automated container updates service
	ansible-playbook iac/ansible/playbooks/watchtower.yml \
		-i iac/ansible/inventories/docker.yml

# === System Updates & Maintenance ===

setup-updates: ## Configure unattended security updates, email alerts, and smart reboots
	ansible-playbook iac/ansible/playbooks/system_updates.yml \
		-i iac/ansible/inventories/ubuntu.yml

run-upgrade: ## Execute full system upgrade on all packages with optional reboot (tag: manual_upgrade)
	ansible-playbook iac/ansible/playbooks/system_updates.yml \
		-i iac/ansible/inventories/ubuntu.yml --tags "manual_upgrade"

# === NAS Storage Configuration ===

truenas-check: ## Dry-run: Review TrueNAS pool, dataset, and share configuration
	ansible-playbook iac/ansible/playbooks/deploy_nas_storage.yml \
		-i iac/ansible/inventories/truenas.yml \
		--check --diff

truenas: ## Deploy TrueNAS storage pools, datasets, and NFS shares
	ansible-playbook iac/ansible/playbooks/deploy_nas_storage.yml \
		-i iac/ansible/inventories/truenas.yml
