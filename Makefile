.PHONY: help init plan apply validate fmt lint clean

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
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ==========================================================
# Terraform Commands
# ==========================================================
init: fmt ## Initialize Terraform working directory for selected target
	@echo "Initializing Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform init; \
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

	@echo "Validating Packer templates..."
	@if ls *.pkr.hcl 1> /dev/null 2>&1 || ls *.pkr.json 1> /dev/null 2>&1; then \
		packer validate .; \
	else \
		echo "No Packer templates found, skipping packer validate"; \
	fi

	@echo "Validating Ansible playbooks..."
	@if ls playbooks/*.yml 1> /dev/null 2>&1; then \
		ansible-playbook --syntax-check playbooks/*.yml || true; \
	else \
		echo "No Ansible playbooks found, skipping syntax check"; \
	fi

fmt: ## Format Terraform and Packer code
	@echo "Formatting Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform fmt; \
	else \
		echo "No Terraform files found, skipping terraform fmt"; \
	fi

	@echo "Formatting Packer templates..."
	@if ls *.pkr.hcl 1> /dev/null 2>&1 || ls *.pkr.json 1> /dev/null 2>&1; then \
		packer fmt .; \
	else \
		echo "No Packer templates found, skipping packer fmt"; \
	fi

lint: ## Run validation and lint checks
	@echo "Linting Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform validate; \
	else \
		echo "No Terraform files found, skipping terraform validate"; \
	fi

	@echo "Linting Packer templates..."
	@if ls *.pkr.hcl 1> /dev/null 2>&1 || ls *.pkr.json 1> /dev/null 2>&1; then \
		packer validate .; \
	else \
		echo "No Packer templates found, skipping packer validate"; \
	fi

	@echo "Linting Ansible playbooks..."
	@if ls playbooks/*.yml 1> /dev/null 2>&1; then \
		ansible-lint || true; \
	else \
		echo "No Ansible playbooks found, skipping ansible-lint"; \
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
# Meta
# ==========================================================
status: ## Show active target and environment
	@echo "Environment: ${ENV}"
	@echo "Target: ${TARGET}"
	@echo "Terraform directory: ${TERRAFORM_DIR}"
	@echo "TEST_VAR: ${TEST_VAR}"

# ----------------------------------------------------------
# Check Terraform-related environment variables and outputs
# ----------------------------------------------------------
check-vars: ## Display key Terraform env vars and outputs
	@echo "=== Terraform Environment Variables ==="
	@echo "TF_VAR_github_owner_primary:  ${TF_VAR_github_owner_primary}"
	@echo "TF_VAR_github_token_primary:  [hidden]"
	@echo "TF_VAR_github_owner_secondary: ${TF_VAR_github_owner_secondary}"
	@echo "TF_VAR_github_token_secondary: [hidden]"
	@echo ""
	@echo "=== Terraform Directory ==="
	@echo "$(TERRAFORM_DIR)"
	@echo ""
	@echo "=== Terraform Outputs (if any) ==="
	@terraform -chdir=$(TERRAFORM_DIR) output 2>/dev/null || echo "No outputs found. Did you run 'terraform apply'?"