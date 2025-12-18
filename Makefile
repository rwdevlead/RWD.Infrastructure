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

VMID = 903
PROX_HOST = root@192.168.50.11
IMG_URL = https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
IMG_FILE = noble-server-cloudimg-amd64.img
TEMPLATE_NAME = ubuntu-24.04-template
# SSH_KEY := $(shell cat /Users/ka8kgj/.ssh/id_ed25519.pub)
# SSH_KEY_ESCAPED := $(shell sed "s/'/'\\\\''/g" ~/.ssh/id_ed25519.pub)
CI_USER := ka8kgj
CI_PASSWORD := password123



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
# Proxmox CLI Create Template Commands - TEST Area
# ==========================================================

# 4. Consolidated Build, Cleanup, and Template Creation
.PHONY: vm_to_template
vm_to_template: 
	@echo "--- STARTING SCRIPT EXECUTION vm_to_template.sh ---"
	ssh $(PROX_HOST) "export VMID=$(VMID); export CI_USER=$(CI_USER); export CI_PASSWORD='$(CI_PASSWORD)'; export VM_IP=$(VM_IP); export IMG_FILE=$(IMG_FILE); bash -s" < TEMPLATE_FINAL_BUILD.sh
	@echo "--- TEMPLATE BUILD COMPLETE ---"



# ==========================================================
# Proxmox CLI Create Template Commands
# ==========================================================

# 1. Cleanup and Download
.PHONY: setup-template-build
setup-template-build: ## Prepare Proxmox template build environment
	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA setup_template_build.sh ---"
	# Execute the local script remotely, passing required environment variables
	ssh $(PROX_HOST) "export VMID=$(VMID); export IMG_FILE=$(IMG_FILE); export IMG_URL=$(IMG_URL); bash -s" < setup_template_build.sh
	@echo "--- SETUP COMPLETE ---"


# 2. Create VM and Configure Hardware
.PHONY: create-vm-config
create-vm-config: setup-template-build ## Create VM and base hardware configuration
	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA create_vm_and_config.sh ---"
	# Execute the local script remotely, passing required environment variables
	ssh $(PROX_HOST) "export VMID=$(VMID); export TEMPLATE_NAME=$(TEMPLATE_NAME); bash -s" < create_vm_config.sh
	@echo "--- VM CONFIGURATION COMPLETE ---"

# 3. Import Disk and Setup Storage
.PHONY: import-disk-and-storage
import-disk-and-storage: create-vm-and-config ## Import disk and configure storage
	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA import_disk_and_storage.sh ---"
	# Execute the local script remotely, passing required environment variables
	ssh $(PROX_HOST) "export VMID=$(VMID); export IMG_FILE=$(IMG_FILE); bash -s" < import_disk_storage.sh
	@echo "--- DISK/STORAGE CONFIGURATION COMPLETE ---"

# 4. Run Cloud-Init Initialization and Install Agent
.PHONY: initialize-cloud-init
initialize-cloud-init: import-disk-and-storage
	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA init_vm.sh ---"
	# Execute the local script remotely, passing shell variables as environment variables
	ssh $(PROX_HOST) "export VMID=$(VMID); export CI_USER=$(CI_USER); export CI_PASSWORD='$(CI_PASSWORD)'; bash -s" < init_vm.sh
	@echo "--- CLOUD-INIT INITIALIZATION COMPLETE ---"

# 5. Finalize VM and Convert to Template
.PHONY: finalize-template
finalize-template: initialize-cloud-init finalize_template.sh
	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA finalize_template.sh ---"
	# Execute the local script remotely, passing required environment variables
	ssh $(PROX_HOST) "export VMID=$(VMID); export IMG_FILE=$(IMG_FILE); bash -s" < finalize_template.sh
	@echo "--- TEMPLATE FINALIZATION COMPLETE ---"

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


# build-proxmox-template:
# 	ssh $(PROX_HOST) '\
# 		echo "== Checking if VM $(VMID) exists, destroying if it does ==" && \
# 		if qm status $(VMID) >/dev/null 2>&1; then \
# 			echo "VM $(VMID) exists — destroying..."; \
# 			qm destroy $(VMID) --purge --skiplock; \
# 		fi && \
# 		echo "== Checking for existing image ==" && \
# 		if [ ! -f "$(IMG_FILE)" ]; then \
# 			echo "Downloading $(IMG_FILE)..."; \
# 			wget $(IMG_URL); \
# 		else \
# 			echo "Image already present: $(IMG_FILE)"; \
# 		fi && \
# 		echo "== Creating VM $(VMID) ==" && \
# 		qm create $(VMID) --memory 8192 --cores 2 --name $(TEMPLATE_NAME) --net0 virtio,bridge=vmbr0 --machine q35 --bios ovmf --ostype l26 && \
# 		echo "== Importing disk ==" && \
# 		qm disk import $(VMID) $(IMG_FILE) local-lvm && \
# 		echo "== Attaching disk to VM ==" && \
# 		qm set $(VMID) --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$(VMID)-disk-0 && \
# 		echo "== Adding CloudInit drive ==" && \
# 		qm set $(VMID) --ide2 local-lvm:cloudinit && \
# 		echo "== Setting boot options ==" && \
# 		qm set $(VMID) --boot c --bootdisk scsi0 && \
# 		echo "== Setting CloudInit user + password ==" && \
# 		qm set $(VMID) --ciuser ka8kgj && \
# 		qm set $(VMID) --cipassword '\''I.h@t3.w33D$$'\'' && \
# 		echo "== Setting DHCP network for CloudInit ==" && \
# 		qm set $(VMID) --ipconfig0 ip=dhcp && \
# 		echo "== Booting VM ONCE to initialize cloud-init ==" && \
# 		qm start $(VMID) && \
# 		echo "Waiting 90 seconds for cloud-init to run..." && \
# 		sleep 90 && \
# 		qm shutdown $(VMID) && \
# 		echo "VM shut down, converting to template" && \
# 		echo "== Converting VM to Proxmox template ==" && \
# 		qm template $(VMID) && \
# 		echo "== Cleaning up downloaded image file ==" && \
# 		rm -f $(IMG_FILE) \
	'

# -----------------------------------------------------------------------

# # 1. Cleanup and Download
# .PHONY: setup-template-build
# setup-template-build:
# 	@echo "--- 1. SETTING UP BUILD ENVIRONMENT ---"
# 	ssh $(PROX_HOST) '\
#         echo "== 1.1 Checking if VM $(VMID) exists, destroying if it does ==" && \
#         if qm status $(VMID) >/dev/null 2>&1; then \
#             echo "VM $(VMID) exists — destroying..."; \
#             qm destroy $(VMID) --purge --skiplock; \
#         fi && \
#         echo "== 1.2 Checking for existing image $(IMG_FILE) ==" && \
#         if [ ! -f "$(IMG_FILE)" ]; then \
#             echo "Downloading $(IMG_FILE) from $(IMG_URL)..."; \
#             wget $(IMG_URL); \
#         else \
#             echo "Image already present: $(IMG_FILE)"; \
#         fi \
#     '
# 	@echo "--- SETUP COMPLETE ---"

# # 2. Create VM and Configure Hardware
# .PHONY: create-vm-and-config
# create-vm-and-config: setup-template-build
# 	@echo "--- 2. CREATING VM AND BASE CONFIGURATION ---"
# 	ssh $(PROX_HOST) '\
#         echo "== 2.1 Creating VM $(VMID) ==" && \
#         qm create $(VMID) --memory 8192 --cores 2 --name $(TEMPLATE_NAME) \
#                          --net0 virtio,bridge=vmbr0 --machine q35 --bios ovmf --ostype l26 && \
#         echo "== 2.2 Setting Optimized Hardware/Agent/Console Options ==" && \
#         qm set $(VMID) --cpu host && \
#         qm set $(VMID) --agent 1 && \
#         qm set $(VMID) --serial0 socket --vga serial0 && \
#         echo "== 2.3 Verification: Displaying VM configuration ==" && \
#         qm config $(VMID) \
#     '
# 	@echo "--- VM CONFIGURATION COMPLETE ---"

# # 3. Import Disk and Setup Storage
# .PHONY: import-disk-and-storage
# import-disk-and-storage: create-vm-and-config
# 	@echo "--- 3. IMPORTING DISK AND SETTING UP STORAGE ---"
# 	ssh $(PROX_HOST) '\
#         echo "== 3.1 Importing disk $(IMG_FILE) to local-lvm ==" && \
#         qm disk import $(VMID) $(IMG_FILE) local-lvm && \
#         echo "== 3.2 Attaching disk to VM ==" && \
#         qm set $(VMID) --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$(VMID)-disk-0 && \
#         echo "== 3.3 Adding CloudInit drive ==" && \
#         qm set $(VMID) --ide2 local-lvm:cloudinit && \
#         echo "== 3.4 Setting boot options ==" && \
#         qm set $(VMID) --boot c --bootdisk scsi0 && \
#         echo "== 3.5 Verification: Checking Disk and Boot settings ==" && \
#         qm config $(VMID) | grep -E "scsi0|ide2|boot" \
#     '
# 	@echo "--- DISK/STORAGE CONFIGURATION COMPLETE ---"

# # ... (Previous targets 1-3 remain the same) ...

# # Target to get the VM's IP address (needs QEMU agent to be working)
# # We will use this inline in the next step.
# # GET_VM_IP = $(shell ssh $(PROX_HOST) "qm agent $(VMID) network-get | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1")

# # 4. Run Cloud-Init Initialization and Install Agent
# .PHONY: initialize-cloud-init
# initialize-cloud-init: import-disk-and-storage
# 	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA init_vm.sh ---"
# 	# Execute the local script remotely, passing shell variables as environment variables
# 	ssh $(PROX_HOST) "export VMID=$(VMID); export CI_USER=$(CI_USER); export CI_PASSWORD='$(CI_PASSWORD)'; bash -s" < init_vm.sh
# 	@echo "--- CLOUD-INIT INITIALIZATION COMPLETE ---"

# # 5. Finalize VM and Convert to Template
# .PHONY: finalize-template
# finalize-template: initialize-cloud-init finalize_template.sh
# 	@echo "--- STARTING REMOTE SCRIPT EXECUTION VIA finalize_template.sh ---"
# 	# Execute the local script remotely, passing required environment variables
# 	ssh $(PROX_HOST) "export VMID=$(VMID); export IMG_FILE=$(IMG_FILE); bash -s" < finalize_template.sh
# 	@echo "--- TEMPLATE FINALIZATION COMPLETE ---"


# # The main target to run the entire process
# # .PHONY: build-proxmox-template
# # build-proxmox-template: finalize-template
# # 	@echo "*****************************************************"
# # 	@echo "*** Proxmox Template $(TEMPLATE_NAME) ($(VMID)) built successfully! ***"
# # 	@echo "*****************************************************"

# # Clean target to only remove the VM (useful for re-runs)
# .PHONY: clean-vm
# clean-vm:
# 	@echo "--- CLEANING UP VM $(VMID) ---"
# 	ssh $(PROX_HOST) '\
#         if qm status $(VMID) >/dev/null 2>&1; then \
#             echo "VM $(VMID) found. Checking status..."; \
#             if qm status $(VMID) | grep -q "running"; then \
#                 echo "VM is running. Shutting down gracefully..."; \
#                 qm shutdown $(VMID); \
#                 i=0; \
#                 while qm status $(VMID) | grep -q "running"; do \
#                     if [ $$i -ge 12 ]; then \
#                         echo "VM failed to shut down gracefully after 60s. Stopping forcefully..."; \
#                         qm stop $(VMID); \
#                         break; \
#                     fi; \
#                     sleep 5; \
#                     i=$$((i+1)); \
#                 done; \
#                 echo "VM $(VMID) is now stopped."; \
#             fi; \
#             echo "Destroying VM $(VMID)..."; \
#             qm destroy $(VMID) --purge --skiplock; \
#         else \
#             echo "VM $(VMID) does not exist. No action required."; \
#         fi \
#     '
# 	@echo "--- CLEANUP COMPLETE ---"
