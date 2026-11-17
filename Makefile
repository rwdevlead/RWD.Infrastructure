# Phony targets
.PHONY: help \
	init plan apply validate fmt clean destroy \
	cleanup-vm convert-to-template \
	ansible-config \
	base base-check \
	docker docker-check \
	portainer portainer-check \
	traefik traefik-check \
	mailrise mailrise-check \
	pihole pihole-check \
	watchtower watchtower-check \
	truenas truenas-check \
	ups-nut ups-nut-check \
	setup-updates run-upgrade \
	check-tf-vars

# Load optional gitignored .env overrides for Infisical auth and TF_VAR_* injection
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Forward Infisical Universal Auth credentials into Terraform variables
export TF_VAR_infisical_client_id := $(INFISICAL_CLIENT_ID)
export TF_VAR_infisical_client_secret := $(INFISICAL_CLIENT_SECRET)
export TF_VAR_infisical_project_id := $(INFISICAL_PROJECT_ID)

# Terraform target resolution (ENV is retained for compatibility; TARGET selects the root module)
ENV ?= unassigned
TARGET ?= unassigned

TERRAFORM_DIR := iac/terraform/environments/$(TARGET)


# Help target
help: ## Show this help message with all available targets
	@echo '═══════════════════════════════════════════════════════════════'
	@echo 'RWD.Infrastructure - Infrastructure as Code Automation'
	@echo '═══════════════════════════════════════════════════════════════'
	@echo
	@echo 'USAGE:'
	@echo '  make [target] [TARGET=proxmox/pve-p01|github/realworlddevelopers|...]'
	@echo
	@echo 'EXAMPLES:'
	@echo '  make plan TARGET=github/realworlddevelopers  # Plan GitHub infrastructure changes'
	@echo '  make apply TARGET=proxmox/pve-p01            # Apply Proxmox VM provisioning'
	@echo '  make docker-check                            # Dry-run Docker deployment'
	@echo '  make docker                                  # Deploy Docker platform'
	@echo
	@echo 'AVAILABLE TARGETS:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo 'ENVIRONMENT VARIABLES:'
	@echo '  TARGET                          Terraform root path under iac/terraform/environments/'
	@echo '  ENV                             Optional environment label'
	@echo
	@echo 'For more information, see:'
	@echo '  - Repository guide: README.md'
	@echo '  - Terraform guide:  iac/terraform/README.md'
	@echo '  - Ansible guide:    iac/ansible/README.md'
	@echo '═══════════════════════════════════════════════════════════════'


# Verify Infisical credentials were exported into Terraform variables
check-tf-vars:
	@echo "TF_VAR_infisical_client_id:     $$TF_VAR_infisical_client_id"
	@echo "TF_VAR_infisical_client_secret: $$TF_VAR_infisical_client_secret"
	@echo "TF_VAR_infisical_project_id:    $$TF_VAR_infisical_project_id"

# Proxmox VM templating (usage: make cleanup-vm && make convert-to-template PROXMOX_NODE=<node> VM_ID=<id>)

# Example: make cleanup-vm VM_USER=ubuntu VM_IP=192.168.50.x
cleanup-vm: ## Remove temporary VM state (SSH keys, DHCP lease, etc.) before templating
	@set -e; \
	echo "Running VM cleanup script..."; \
	./cleanup_vm.sh

# Example: make convert-to-template PROXMOX_NODE=pve-p01 VM_ID=901
convert-to-template: ## Convert cleanup VM to a reusable Proxmox template for cloning
	@echo "Converting VM $(VM_ID) to template on $(PROXMOX_NODE)..."
	@PROXMOX_NODE=$(PROXMOX_NODE) VM_ID=$(VM_ID) ./convert_to_template.sh


# Terraform commands (usage: make <target> TARGET=github/realworlddevelopers|proxmox/<instance>)

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
	rm -rf packer_cache/
	rm -f *.retry
	

# Ansible commands (run <target>-check before <target> to preview diffs)

ANSIBLE=ansible-playbook
ANSIBLE_DIR=iac/ansible
export ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg

ansible-config: ## Display current Ansible configuration settings
	ansible-config dump --only-changed

# OBJC_DISABLE_INITIALIZE_FORK_SAFETY prevents macOS Python Objective-C fork crashes on local lookup plugins
test-infisical: ## test the infisical secret vault
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook -c local iac/ansible/playbooks/test_infisical.yml

# Base system configuration

base-check: ## Dry-run: Review base system configuration (hostname, security, fail2ban)
	ansible-playbook iac/ansible/playbooks/system_base.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

base: ## Deploy base system configuration (hostname, security, fail2ban)
	ansible-playbook iac/ansible/playbooks/system_base.yml \
		-i iac/ansible/inventories/hosts.yml

# System updates & maintenance (scoped to dev-docker-02 to prevent unintended prod-docker-01 upgrades/reboots)

run-upgrade: ## Execute full system upgrade on all packages with optional reboot (tag: manual_upgrade)
	ansible-playbook iac/ansible/playbooks/system_updates.yml \
		-i iac/ansible/inventories/hosts.yml --tags "manual_upgrade" --limit dev-docker-02

setup-updates: ## Configure unattended security updates, email alerts, and smart reboots
	ansible-playbook iac/ansible/playbooks/system_updates.yml \
		-i iac/ansible/inventories/hosts.yml --limit dev-docker-02

# Docker platform setup (apply currently scoped to dev-docker-02 to protect prod-docker-01)

docker-check: ## Dry-run: Review Docker platform setup (NFS mounts, engine, compose)
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

docker: ## Deploy Docker platform (NFS mounts, engine, compose)
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--limit dev-docker-02 -v

# Reverse proxy & load balancing

traefik-check: ## Dry-run: Review Traefik reverse proxy configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

traefik: ## Deploy Traefik reverse proxy for container routing
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml

# Container management & orchestration

portainer-check: ## Dry-run: Review Portainer container management deployment
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

portainer-agent-check: ## Dry-run: Review Portainer Agent deployment
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer_agent.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

portainer: ## Deploy Portainer container management platform
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml

portainer-agent: ## Deploy Portainer Agent endpoint
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer_agent.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml

# Application services

mailrise-check: ## Dry-run: Review Mailrise email notification service
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

mailrise: ## Deploy Mailrise email notification service
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/hosts.yml

pihole-check: ## Dry-run: Review Pi-hole DNS/ad-blocker deployment
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

pihole: ## Deploy Pi-hole DNS and ad-blocking service
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/hosts.yml

nebula-check: ## Dry-run: Review Pi-hole Nebula deployment
	ansible-playbook iac/ansible/playbooks/nebula_sync.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

nebula: ## Deploy Nebula Pi-hole sync service
	ansible-playbook iac/ansible/playbooks/nebula_sync.yml \
		-i iac/ansible/inventories/hosts.yml 


homarr-check: ## Dry-run: Review Homarr dashboard deployment
	ansible-playbook iac/ansible/playbooks/homarr.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

homarr: ## Deploy Homarr dashboard service
	ansible-playbook iac/ansible/playbooks/homarr.yml \
		-i iac/ansible/inventories/hosts.yml

uptime-kuma-check: ## Dry-run: Review Uptime Kuma dashboard deployment
	ansible-playbook iac/ansible/playbooks/uptime_kuma.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

uptime-kuma: ## Deploy Uptime Kuma dashboard service
	ansible-playbook iac/ansible/playbooks/uptime_kuma.yml \
		-i iac/ansible/inventories/hosts.yml

pulse-check: ## Dry-run: Review Pulse dashboard deployment
	ansible-playbook iac/ansible/playbooks/pulse.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

pulse: ## Deploy Pulse dashboard service
	ansible-playbook iac/ansible/playbooks/pulse.yml \
		-i iac/ansible/inventories/hosts.yml

watchtower-check: ## Dry-run: Review Watchtower auto-update service
	ansible-playbook iac/ansible/playbooks/watchtower.yml \
		-i iac/ansible/inventories/hosts.yml \
		--check --diff

watchtower: ## Deploy Watchtower automated container updates service
	ansible-playbook iac/ansible/playbooks/watchtower.yml \
		-i iac/ansible/inventories/hosts.yml


truenas-check: ## Dry-run: Review TrueNAS pool, dataset, and share configuration
	ansible-playbook iac/ansible/playbooks/deploy_nas_storage.yml \
		-i iac/ansible/inventories/truenas.yml \
		--check --diff

truenas: ## Deploy TrueNAS storage pools, datasets, and NFS shares
	ansible-playbook iac/ansible/playbooks/deploy_nas_storage.yml \
		-i iac/ansible/inventories/truenas.yml

ups-nut-check: ## Dry-run: UPS with NUT configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/nut.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

ups-nut: ## Deploy UPS with NUT configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/nut.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml
