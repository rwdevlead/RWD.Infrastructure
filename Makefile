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
PACKER_VARS := ../build.pkrvars.hcl

VMID = 901
PROX_HOST = root@192.168.50.11
IMG_URL = https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
IMG_FILE = noble-server-cloudimg-amd64.img
TEMPLATE_NAME = ubuntu-24.04-template
SSH_KEY := $(shell cat /Users/ka8kgj/.ssh/id_ed25519.pub)
SSH_KEY_ESCAPED := $(shell sed "s/'/'\\\\''/g" ~/.ssh/id_ed25519.pub)


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
# Proxmox CLI Create Template Commands
# ==========================================================
build-proxmox-template:
	ssh $(PROX_HOST) '\
		echo "== Checking if VM $(VMID) exists, destroying if it does ==" && \
		if qm status $(VMID) >/dev/null 2>&1; then \
			echo "VM $(VMID) exists — destroying..."; \
			qm destroy $(VMID) --purge --skiplock; \
		fi && \
		echo "== Checking for existing image ==" && \
		if [ ! -f "$(IMG_FILE)" ]; then \
			echo "Downloading $(IMG_FILE)..."; \
			wget $(IMG_URL); \
		else \
			echo "Image already present: $(IMG_FILE)"; \
		fi && \
		echo "== Creating VM $(VMID) ==" && \
		qm create $(VMID) --memory 8192 --cores 2 --name $(TEMPLATE_NAME) --net0 virtio,bridge=vmbr0 --machine q35 --bios ovmf --ostype l26 && \
		echo "== Importing disk ==" && \
		qm disk import $(VMID) $(IMG_FILE) local-lvm && \
		echo "== Attaching disk to VM ==" && \
		qm set $(VMID) --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$(VMID)-disk-0 && \
		echo "== Adding CloudInit drive ==" && \
		qm set $(VMID) --ide2 local-lvm:cloudinit && \
		echo "== Setting boot options ==" && \
		qm set $(VMID) --boot c --bootdisk scsi0 && \
		echo "== Setting CloudInit user + password ==" && \
		qm set $(VMID) --ciuser ka8kgj && \
		qm set $(VMID) --cipassword '\''I.h@t3.w33D$$'\'' && \
		echo "== Setting DHCP network for CloudInit ==" && \
		qm set $(VMID) --ipconfig0 ip=dhcp && \
		echo "== Converting VM to Proxmox template ==" && \
		qm template $(VMID) && \
		echo "== Cleaning up downloaded image file ==" && \
		rm -f $(IMG_FILE) \
	'

# ==========================================================
# Terraform Commands
# ==========================================================
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


fmt: ## Format Packer code
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
# Packer Commands
# ==========================================================
packer-fmt: ## Format Packer code
	@echo "Formatting Packer templates in $(PACKER_DIR)..."
	@if find $(PACKER_DIR) -type f \( -name "*.pkr.hcl" -o -name "*.pkr.json" \) | grep -q .; then \
		packer fmt -recursive $(PACKER_DIR); \
	else \
		echo "No Packer templates found, skipping packer fmt."; \
	fi

packer-init: packer-fmt ## Initialize Packer working directory for all targets
	@echo "Initializing all Packer template directories under $(PACKER_DIR)..."
	@for dir in $(PACKER_DIR)/*; do \
		if [ -d "$$dir" ] && find "$$dir" -maxdepth 1 -type f -name "*.pkr.hcl" | grep -q .; then \
			echo "→ Initializing $$dir"; \
			(cd "$$dir" && packer init -upgrade .) || exit 1; \
		fi; \
	done

packer-validate: packer-init ## Validate all Packer templates
	@echo "Validating Packer templates under $(PACKER_DIR)..."
	@for dir in $(PACKER_DIR)/*; do \
		if [ -d "$$dir" ] && find "$$dir" -maxdepth 1 -type f -name "*.pkr.hcl" | grep -q .; then \
			echo "→ Validating configuration in $$dir"; \
			(cd "$$dir" && packer validate .) || exit 1; \
		fi; \
	done

packer-build: packer-validate ## Build all Packer templates
	@echo "Building Packer templates under $(PACKER_DIR)..."
	@for dir in $(PACKER_DIR)/*; do \
		if [ -d "$$dir" ] && find "$$dir" -maxdepth 1 -type f -name "*.pkr.hcl" | grep -q .; then \
			echo "→ Building configuration in $$dir"; \
			SSH_KEY="$$(cat ~/.ssh/id_ed25519.pub)"; \
			( cd "$$dir" && packer build -var "ssh_pub_key=$$SSH_KEY" . ) || exit 1; \
		fi; \
	done



