.PHONY: help init plan apply validate fmt lint clean packer-fmt packer-init packer-validate packer-build

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
PACKER_DIR := iac/packer
PACKER_VARS := $(PACKER_DIR)/build.pkrvars.hcl


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
# Terraform and Packer Commands
# ==========================================================

init: fmt ## Initialize Terraform working directory for selected target
	@echo "Initializing Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform init -upgrade; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform init"; \
	fi


packer-init: packer-fmt ## Initialize Packer working directory for selected target
	@echo "Initializing Packer templates in $(PACKER_DIR)..."
	@if find $(PACKER_DIR) -type f -name "*.pkr.hcl" | grep -q .; then \
		for file in $$(find $(PACKER_DIR) -type f -name "*.pkr.hcl"); do \
			if echo $$file | grep -q variables.pkr.hcl; then \
				continue; \
			fi; \
			echo "→ Initializing $$file"; \
			packer init $$file || exit 1; \
		done; \
	else \
		echo "No Packer templates found, skipping packer init."; \
	fi

plan: ## Create or update Terraform execution plan for selected target
	@echo "Planning Terraform in $(TERRAFORM_DIR)..."
	@if [ -d "$(TERRAFORM_DIR)" ] && [ "$(wildcard $(TERRAFORM_DIR)/*.tf)" != "" ]; then \
		cd $(TERRAFORM_DIR) && terraform plan -out=tfplan; \
	else \
		echo "No Terraform files found in $(TERRAFORM_DIR), skipping terraform plan"; \
	fi


packer-build: packer-validate ## Build all Packer templates
	@echo "Building Packer templates in $(PACKER_DIR)..."
	@if find $(PACKER_DIR) -type f -name "*.pkr.hcl" | grep -q .; then \
		for file in $$(find $(PACKER_DIR) -type f -name "*.pkr.hcl"); do \
			if echo $$file | grep -q variables.pkr.hcl; then continue; fi; \
			echo "→ Building $$file"; \
			packer build -var-file=$(PACKER_VARS) $$file || exit 1; \
		done; \
	else \
		echo "No Packer templates found, skipping packer build."; \
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


packer-validate: packer-init ## Validate all Packer templates
	@echo "Validating Packer templates in $(PACKER_DIR)..."
	@if find $(PACKER_DIR) -type f -name "*.pkr.hcl" | grep -q .; then \
		for file in $$(find $(PACKER_DIR) -type f -name "*.pkr.hcl"); do \
			if echo $$file | grep -q variables.pkr.hcl; then \
				continue; \
			fi; \
			echo "→ Validating $$file"; \
			packer validate $$file || exit 1; \
		done; \
	else \
		echo "No Packer templates found, skipping packer validate."; \
	fi

fmt: ## Format Packer code
	@echo "Formatting Terraform in $(TERRAFORM_DIR)..."
	@if [ -f "$(TERRAFORM_DIR)/main.tf" ] || [ -d "$(TERRAFORM_DIR)/modules" ]; then \
		cd $(TERRAFORM_DIR) && terraform fmt; \
	else \
		echo "No Terraform files found, skipping terraform fmt"; \
	fi

packer-fmt: ## Format Packer code
	@echo "Formatting Packer templates in $(PACKER_DIR)..."
	@if find $(PACKER_DIR) -type f \( -name "*.pkr.hcl" -o -name "*.pkr.json" \) | grep -q .; then \
		packer fmt -recursive $(PACKER_DIR); \
	else \
		echo "No Packer templates found, skipping packer fmt."; \
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







	*********************************

	.PHONY: help packer-validate packer-build packer-clean terraform-init terraform-plan terraform-apply terraform-destroy

# ==========================================================
# Variables
# ==========================================================
PACKER_DIR := iac/packer/ubuntu
TERRAFORM_DIR := iac/terraform/proxmox
TERRAFORM_VARS_FILE := $(TERRAFORM_DIR)/terraform.tfvars

# ==========================================================
# Help
# ==========================================================
help:
	@echo "Available targets:"
	@echo "  packer-validate   Validate the Packer template"
	@echo "  packer-build      Build the Ubuntu template with Packer"
	@echo "  packer-clean      Remove temporary Packer files"
	@echo "  terraform-init    Initialize Terraform"
	@echo "  terraform-plan    Plan Terraform changes"
	@echo "  terraform-apply   Apply Terraform changes"
	@echo "  terraform-destroy Destroy Terraform-managed resources"

# ==========================================================
# Packer Targets
# ==========================================================
packer-validate:
	@echo "Validating Packer template..."
	@cd $(PACKER_DIR) && packer validate ubuntu-template.pkr.hcl

packer-build:
	@echo "Building Packer template..."
	@cd $(PACKER_DIR) && packer build ubuntu-template.pkr.hcl

packer-clean:
	@echo "Cleaning Packer cache and temporary files..."
	@cd $(PACKER_DIR) && rm -rf packer_cache packer_build

# ==========================================================
# Terraform Targets
# ==========================================================
terraform-init:
	@echo "Initializing Terraform..."
	@cd $(TERRAFORM_DIR) && terraform init

terraform-plan:
	@echo "Planning Terraform deployment..."
	@cd $(TERRAFORM_DIR) && terraform plan -var-file=$(TERRAFORM_VARS_FILE)

terraform-apply:
	@echo "Applying Terraform deployment..."
	@cd $(TERRAFORM_DIR) && terraform apply -var-file=$(TERRAFORM_VARS_FILE) -auto-approve

terraform-destroy:
	@echo "Destroying Terraform-managed resources..."
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file=$(TERRAFORM_VARS_FILE) -auto-approve