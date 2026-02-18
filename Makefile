.PHONY: help init plan apply validate fmt clean destroy cleanup-vm convert-to-template \
	ansible-config base base-check docker docker-check storage storage-check \
	traefik traefik-check portainer portainer-check site site-check mailrise mailrise-check

# ==========================================================
# Load .env file (if present)
# ==========================================================
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ==========================================================
# Variables
# ==========================================================
ENV ?= unassigned
TARGET ?= unassigned

TEST_VAR ?= unassigned

TERRAFORM_DIR := iac/terraform/$(TARGET)


# ==========================================================
# Help
# ==========================================================
help: ## Show this help message
	@echo 'Usage: make [target] [TARGET=github|proxmox|...] [ENV=environment_name]'
	@echo
	@echo 'Examples:'
	@echo '  make plan TARGET=github ENV=dev'
	@echo '  make apply TARGET=proxmox'
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# ==========================================================
# Proxmox CLI Create Template Commands
# ==========================================================

# make cleanup-vm VM_USER=ubuntu VM_IP=192.168.50.101
.PHONY: cleanup-vm
cleanup-vm:
	@set -e; \
	echo "Running VM cleanup script..."; \
	./cleanup_vm.sh

# make convert-to-template PROXMOX_NODE=proxmox01 VM_ID=901
.PHONY: convert-to-template
convert-to-template:
	@echo "Converting VM $(VM_ID) to template on $(PROXMOX_NODE)..."
	@PROXMOX_NODE=$(PROXMOX_NODE) VM_ID=$(VM_ID) ./convert_to_template.sh


# ==========================================================
# Terraform Commands
# ==========================================================
destroy:  ## Destroy the existing setup.
	@echo "Running Terraform Destroy in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform destroy"; \
	fi

init: fmt ## Initialize Terraform working directory for selected target
	@echo "Initializing Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform init -upgrade; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform init"; \
	fi


plan: ## Create or update Terraform execution plan for selected target
	@echo "Planning Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform plan -out=tfplan; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform plan"; \
	fi



apply: ## Apply Terraform execution plan for selected target
	@echo "Applying Terraform plan in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ -f "$(TERRAFORM_DIR)/tfplan" ]; then \
		cd $(TERRAFORM_DIR) && terraform apply; \
	else \
		echo "No Terraform plan found in $(TERRAFORM_DIR), skipping terraform apply"; \
	fi


validate: init ## Validate Terraform, Packer, and Ansible configs
	@echo "Validating Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform validate; \
	else \
		echo "No Terraform files found, skipping terraform validate"; \
	fi


fmt: ## Format code
	@echo "Formatting Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform fmt; \
	else \
		echo "No Terraform files found, skipping terraform fmt"; \
	fi


clean: ## Clean up generated files in the selected Terraform target
	@echo "Cleaning Terraform and Packer files in $(TERRAFORM_DIR)..."
	rm -f $(TERRAFORM_DIR)/tfplan
	rm -rf $(TERRAFORM_DIR)/.terraform
	@echo "✅ Terraform state files (tfstate) are preserved."
	# Remove Packer cache
	rm -rf packer_cache/
	# Remove Ansible retry files
	rm -f *.retry
	

# ==========================================================
# Ansible Commands
# ==========================================================

ANSIBLE=ansible-playbook
ANSIBLE_DIR=iac/ansible

ansible-config:
	ansible-config dump --only-changed

base-check:
	ansible-playbook iac/ansible/playbooks/base.yml \
		-i iac/ansible/inventories/docker.yml \
		--check --diff

base:
	ansible-playbook iac/ansible/playbooks/base.yml \
		-i iac/ansible/inventories/docker.yml

docker-check:
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

docker:
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/docker.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

portainer-check:
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/apps/portainer.yml \
		--check --diff

portainer:
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/portainer.yml \
		-i $(ANSIBLE_DIR)/inventories/apps/portainer.yml

storage-check: ## Check storage configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/storage.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

storage: ## Deploy storage configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/storage.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

traefik-check: ## Check Traefik configuration
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

traefik: ## Deploy Traefik reverse proxy
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/traefik.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml

site-check: ## Check all site configurations
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/site.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml \
		--check --diff

site: ## Deploy all site configurations
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/site.yml \
		-i $(ANSIBLE_DIR)/inventories/docker.yml



mailrise: ## installs mailrise notification service
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/apps/mailrise.yml

mailrise-check:
	ansible-playbook iac/ansible/playbooks/mailrise.yml \
		-i iac/ansible/inventories/apps/mailrise.yml
		--check --diff


setup-updates: ## Run the base security setup & postfix relay
	ansible-playbook iac/ansible/playbooks/system_updates.yml -i iac/ansible/inventories/ubuntu.yml


run-upgrade: ## Run the manual full system upgrade (non-security + reboot)
	ansible-playbook iac/ansible/playbooks/system_updates.yml -i iac/ansible/inventories/ubuntu.yml --tags "manual_upgrade"



pihole: ## installs pihole DNS service
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/apps/pihole.yml

pihole-check:
	ansible-playbook iac/ansible/playbooks/pihole.yml \
		-i iac/ansible/inventories/apps/pihole.yml \
		--check --diff