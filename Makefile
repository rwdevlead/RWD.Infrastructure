.PHONY: help init plan apply validate fmt lint clean

# Load environment specific variables
-include env/$(ENV).mk

help: ## Show this help message
	@echo 'Usage: make [target] [ENV=environment_name]'
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform working directory
	terraform init

plan: ## Create or update Terraform execution plan
	terraform plan -out=tfplan

apply: ## Apply Terraform execution plan
	terraform apply "tfplan"

validate: ## Basic error checking
	terraform validate
	packer validate .
	ansible-playbook --syntax-check playbooks/*.yml

fmt: ## Format code
	terraform fmt -recursive
	packer fmt .

lint: ## Run all linters
	terraform validate
	packer validate .
	ansible-lint

clean: ## Clean up generated files
	rm -f tfplan
	rm -rf .terraform/
	rm -rf packer_cache/
	rm -f *.retry