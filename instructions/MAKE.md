# Makefile Instructions

## Overview

The Makefile provides centralized orchestration for all Infrastructure-as-Code workflows. It abstracts complex command sequences into simple, memorable targets that handle Terraform, Packer, Ansible, and integration tasks.

## Project File Location

```
/Users/ka8kgj/Documents/Source/RWD.Infrastructure/Makefile
```

## Standard Make Targets

### Initialization and Setup

```bash
make init                    # Initialize Terraform working directory
make install                 # Install dependencies (collections, plugins)
make help                    # Display all available targets
```

### Planning and Validation

```bash
make lint                    # Validate and format all code
make plan                    # Create Terraform execution plan
make validate                # Validate configurations (no format changes)
```

### Deployment

```bash
make apply                   # Apply planned Terraform changes
make deploy                  # Full deployment (plan + apply)
make build                   # Build Packer images
```

### Cleanup and Destroy

```bash
make clean                   # Remove build artifacts
make destroy                 # Destroy Terraform infrastructure
make reset                   # Full reset (destroy + clean + init)
```

### Environment-Specific Targets

```bash
make ENV=staging plan        # Plan for staging environment
make ENV=production apply    # Apply to production environment
ENV=dev make build          # Build Packer image for dev environment
```

## Environment Variables

### Global Environment Variables

```makefile
ENV                         # Environment selector (default, staging, production)
TERRAFORM_DIR              # Terraform working directory
ANSIBLE_DIR                # Ansible working directory
PACKER_DIR                 # Packer working directory
VERBOSE                    # Enable verbose output
```

### Using Environment Variables

```bash
ENV=production make plan    # Set via command line
export ENV=staging
make apply                  # Use exported variable

# Multiple variables
ENV=prod VERBOSE=1 make deploy
```

## Make Target Structure

### Basic Target Format

```makefile
target_name:                           # Target name
	@echo "Starting target_name"        # Silent echo (@ suppresses command print)
	command1                            # Commands executed in shell
	command2
	@echo "Completed target_name"
```

### Dependencies Between Targets

```makefile
deploy: plan                           # deploy depends on plan
	@echo "Applying changes..."
	terraform apply tfplan

plan: validate                         # plan depends on validate
	@echo "Creating plan..."
	terraform plan -out=tfplan

validate:
	@echo "Validating..."
	terraform validate
```

### Conditional Execution

```makefile
ifdef VERBOSE
	@echo "Verbose mode enabled"
endif

ifeq ($(ENV),production)
	# Production-specific commands
endif
```

## Environmental Path Construction

### Setting Working Directories

```makefile
TERRAFORM_WORKING_DIR := iac/terraform/$(ENV)
CURRENT_ENV_FILE := $(TERRAFORM_WORKING_DIR)/terraform.tfvars

check-env-file:
	@if [ ! -f "$(CURRENT_ENV_FILE)" ]; then \
		echo "Error: $(CURRENT_ENV_FILE) not found"; \
		exit 1; \
	fi
```

### Dynamic Variable Files

```makefile
TFVARS_FILE = terraform.$(ENV).tfvars
PLAN_FILE = tfplan.$(ENV)

plan:
	cd $(TERRAFORM_DIR) && \
	terraform plan \
		-var-file=$(TFVARS_FILE) \
		-out=$(PLAN_FILE)
```

## Best Practices

### Clear and Descriptive Targets

```makefile
# GOOD - Clear intent
docker-deploy:
	ansible-playbook iac/ansible/playbooks/docker.yml

# AVOID - Unclear purpose
run-stuff:
	./some_script.sh
```

### Documentation

```makefile
.PHONY: help
help:                           # Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
```

### Phony Targets

```makefile
# Declare targets that don't create files
.PHONY: help lint plan apply deploy clean destroy

# Without .PHONY, make would skip if file named 'help' exists
```

### Silent Mode

```makefile
# Use @ to suppress command echo
@echo "Starting..."        # Only outputs the message
echo "Debug info"          # Outputs "echo Debug info" then the message

# Suppress all output for target
.SILENT: build
```

### Error Handling

```makefile
validate:
	@terraform validate || \
		{ echo "Validation failed"; exit 1; }

# Alternative using set -e
deploy:
	set -e; \
	echo "Validating..."; \
	terraform validate; \
	echo "Planning..."; \
	terraform plan
```

## Common Task Patterns

### Terraform Workflow

```makefile
.PHONY: tf-init tf-validate tf-plan tf-apply tf-destroy

tf-init:                          ## Initialize Terraform
	cd iac/terraform && terraform init

tf-validate:                       ## Validate Terraform configuration
	cd iac/terraform && terraform validate

tf-plan:                           ## Create Terraform plan
	cd iac/terraform && \
	terraform plan -out=tfplan -var-file=terraform.tfvars

tf-apply: tf-plan                 ## Apply Terraform changes
	cd iac/terraform && terraform apply tfplan

tf-destroy:                        ## Destroy Terraform infrastructure
	cd iac/terraform && \
	terraform destroy -var-file=terraform.tfvars
```

### Ansible Workflow

```makefile
.PHONY: ansible-lint ansible-check ansible-deploy

ansible-lint:                      ## Lint Ansible playbooks
	ansible-lint iac/ansible/

ansible-check:                     ## Check Ansible playbooks (dry-run)
	ansible-playbook \
		-i iac/ansible/inventories/$(ENV).yml \
		-c local \
		--check \
		iac/ansible/playbooks/deploy.yml

ansible-deploy:                    ## Deploy with Ansible
	ansible-playbook \
		-i iac/ansible/inventories/$(ENV).yml \
		iac/ansible/playbooks/deploy.yml
```

### Packer Workflow

```makefile
.PHONY: packer-fmt packer-validate packer-build

packer-fmt:                        ## Format Packer configurations
	packer fmt iac/packer/

packer-validate:                   ## Validate Packer templates
	cd iac/packer/ubuntu && packer validate ubuntu.pkr.hcl

packer-build:                      ## Build Packer image
	cd iac/packer/ubuntu && \
	packer build \
		-var-file=build.auto.pkrvars.hcl \
		ubuntu.pkr.hcl
```

### Combined Workflow

```makefile
.PHONY: lint plan apply

lint: tf-validate packer-validate ansible-lint  ## Validate all code

plan: lint                          ## Create all plans
	@echo "All plans created"

apply: tf-apply                     ## Apply all infrastructure
	@echo "Infrastructure deployed"

deploy: apply ansible-deploy        ## Full deployment
	@echo "Deployment complete"
```

## Environment-Aware Targets

### Staging vs Production

```makefile
ifdef ENV
    TF_DIR := iac/terraform/$(ENV)
    INVENTORY := iac/ansible/inventories/$(ENV).yml
else
    ENV := default
    TF_DIR := iac/terraform/default
    INVENTORY := iac/ansible/inventories/localhost.yml
endif

plan:                              ## Plan infrastructure changes
	cd $(TF_DIR) && terraform plan

status:                            ## Show environment status
	@echo "Environment: $(ENV)"
	@echo "Terraform dir: $(TF_DIR)"
	@echo "Ansible inventory: $(INVENTORY)"
```

### Environment Validation

```makefile
ifdef ENV
    ifeq ($(ENV),production)
        SAFETY_CHECK := true
    endif
endif

apply:
	@if [ "$(SAFETY_CHECK)" = "true" ]; then \
		read -p "Are you sure? [y/N] " -n 1 -r; \
		echo; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "Aborted"; \
			exit 1; \
		fi; \
	fi
	terraform apply tfplan
```

## Variables and Expansion

### Make Variable Types

```makefile
# := Immediate assignment
ASSIGNED := value

# = Deferred assignment
DEFERRED = value (expanded when used, not when assigned)

# ?= Conditional assignment (only if not already set)
OPTIONAL ?= default

# += Append to variable
LIST += item1
LIST += item2
```

### Variable Functions

```makefile
# String substitution
SOURCES = src/main.c src/util.c
OBJECTS = $(SOURCES:.c=.o)

# Pattern substitution
NEW_LIST = $(OBJECTS:%.o=%.bak)

# Directory and filename functions
$(dir /path/to/file.txt)    # Returns: /path/to/
$(notdir /path/to/file.txt) # Returns: file.txt
```

## Debugging Makefile

### Print Variables

```bash
make print-VAR              # Print VAR value
make -p                     # Print all variables and rules
```

### Add to Makefile

```makefile
print-%:
	@echo $* = $($*)
```

### Printing During Execution

```makefile
debug:
	$(info Variable: $(MY_VAR))
	@echo "Debug output"
```

## Common Issues and Solutions

### Command Not Found

```makefile
# WRONG - assumes terraform is in PATH
plan:
	terraform plan

# CORRECT - explicit path if needed
plan:
	/usr/local/bin/terraform plan

# CORRECT - check if available
plan:
	@command -v terraform >/dev/null || \
		{ echo "terraform not found"; exit 1; }
	terraform plan
```

### Directory Navigation

```makefile
# WRONG - changes affect subsequent commands
init:
	cd iac/terraform
	terraform init          # This runs in original directory!

# CORRECT - use subshell or combine commands
init:
	cd iac/terraform && terraform init

# CORRECT - use absolute paths
init:
	terraform -chdir=iac/terraform init
```

### Variable Not Expanding

```makefile
# Check for spaces around :=
VAR := value    # Correct spacing

# Incorrect - VAR contains " value"
VAR := value
```

## Integration with CI/CD

### GitHub Actions Example Target

```makefile
.PHONY: ci-validate ci-plan ci-apply

ci-validate:                       ## Validate in CI/CD
	terraform validate
	ansible-lint
	packer validate iac/packer/ubuntu/ubuntu.pkr.hcl

ci-plan:                           ## Plan in CI/CD
	terraform plan -out=tfplan

ci-apply:                          ## Apply in CI/CD
	terraform apply tfplan
```

## Related Documentation

- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [Make Best Practices](https://tech.davis-hansson.com/p/make/)
- [Makefile Conventions](https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html)
