# Shell/Bash Scripts Instructions

## Overview

Shell scripts provide automation for VM cleanup, template conversion, and Packer provisioning. Scripts are kept minimal to maintain clarity and portability.

## Project Structure

```
/
├── cleanup_vm.sh              # VM state cleanup before templating
├── convert_to_template.sh     # Proxmox template conversion
└── iac/packer/ubuntu/
    └── late-commands.sh       # Final image provisioning
```

## Naming Conventions

### Script Files

- lowercase with underscores: `cleanup_vm.sh`, `late-commands.sh`
- Descriptive action: `backup_database.sh` not `script.sh`
- `.sh` extension for shell scripts

### Functions

- lowercase with underscores: `install_packages()`, `configure_system()`
- Verb-first naming: `setup_network()`, `verify_connectivity()`

### Variables

- UPPERCASE_WITH_UNDERSCORES for constants: `SCRIPT_DIR`, `CONFIG_FILE`
- lowercase for local variables: `result`, `count`

## Script Structure

### Standard Header

```bash
#!/bin/bash

################################################################################
# Script: script_name.sh
# Purpose: Clear description of what script does
# Author: Name/Organization
# Date: YYYY-MM-DD
################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script directory for relative path references
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configuration
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_NONE='\033[0m'
```

### Function Definitions

```bash
# Print colored output
log_info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_NONE} $*"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_NONE} $*" >&2
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NONE} $*" >&2
}

# Execute command with error handling
run_command() {
    local cmd="$*"
    log_info "Executing: $cmd"
    if ! eval "$cmd"; then
        log_error "Command failed: $cmd"
        return 1
    fi
}

# Script entry point
main() {
    log_info "Starting script execution"
    # Main logic here
    log_info "Script completed successfully"
}

# Entry point
main "$@"
```

## Best Practices

### Error Handling

```bash
# Exit on any error
set -e

# Exit on undefined variable
set -u

# Exit on pipe failure (not just last command)
set -o pipefail

# Combined form
set -euo pipefail

# Function with proper error handling
safe_function() {
    if ! some_command; then
        log_error "Command failed"
        return 1
    fi
}
```

### Quoting Variables

```bash
# CORRECT - Always quote variables
echo "$variable"
cp "$source_file" "$dest_file"

# WRONG - Unquoted variables can expand unexpectedly
echo $variable
cp $source_file $dest_file
```

### Command Substitution

```bash
# Preferred modern syntax
result="$(command)"

# Legacy syntax (avoid)
result=`command`
```

### Test Conditions

```bash
# String tests
[[ -z "$variable" ]]        # String is empty
[[ -n "$variable" ]]        # String is not empty
[[ "$var1" == "$var2" ]]    # String equals

# File tests
[[ -f "$filepath" ]]        # File exists and is regular file
[[ -d "$dirpath" ]]         # Directory exists
[[ -e "$path" ]]            # Path exists (file or dir)
[[ -x "$filepath" ]]        # File is executable

# Always use [[ ]] not [ ] in bash
```

### Command Execution

```bash
# Check command success
if command; then
    log_info "Success"
else
    log_error "Failed"
    exit 1
fi

# Use || for alternatives
command1 || command2  # Run command2 if command1 fails

# Use && for dependent commands
command1 && command2  # Run command2 only if command1 succeeds
```

## Packer Provisioning Script Pattern

Template for cloud-init provisioning (`late-commands.sh`):

```bash
#!/bin/bash

################################################################################
# Script: late-commands.sh
# Purpose: Final image customization during Packer build
# Runs during Ubuntu image build - executes as root
################################################################################

set -euo pipefail

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_NONE='\033[0m'

log_info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_NONE} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NONE} $*" >&2
}

# Clean package manager caches
clean_packages() {
    log_info "Cleaning package caches..."
    apt-get autoremove -y
    apt-get clean
    apt-get autoclean
}

# Remove temporary files
clean_temp_files() {
    log_info "Removing temporary files..."
    rm -rf /tmp/* /var/tmp/*
    rm -f /var/log/*.log
}

# Finalize image
finalize_image() {
    log_info "Finalizing image..."
    # Remove machine-specific identifiers
    rm -f /etc/machine-id /var/lib/dbus/machine-id
    touch /etc/machine-id

    # Clear SSH keys for template
    rm -f /etc/ssh/ssh_host_*
}

main() {
    log_info "Starting image finalization"

    clean_packages || log_error "Failed to clean packages"
    clean_temp_files || log_error "Failed to clean temp files"
    finalize_image || log_error "Failed to finalize"

    log_info "Image finalization completed"
}

main
```

## VM Management Script Pattern

Template for VM operations:

```bash
#!/bin/bash

################################################################################
# Script: manage_vm.sh
# Purpose: Manage VM lifecycle in Proxmox
################################################################################

set -euo pipefail

# Configuration
VM_NAME="${1:-}"
ACTION="${2:-}"
PROXMOX_HOST="proxmox.example.com"
PROXMOX_USER="root@pam"

usage() {
    cat <<EOF
Usage: $0 <vm_name> <action>

Actions:
    start       Start the VM
    stop        Stop the VM
    restart     Restart the VM
    status      Check VM status
    clone       Clone VM to template

Environment:
    PROXMOX_PASSWORD    Proxmox password
    PROXMOX_HOST        Proxmox host (default: $PROXMOX_HOST)
    PROXMOX_USER        Proxmox user (default: $PROXMOX_USER)
EOF
    exit 1
}

# Validate inputs
if [[ -z "$VM_NAME" || -z "$ACTION" ]]; then
    usage
fi

# Main logic
main() {
    case "$ACTION" in
        start)
            log_info "Starting VM: $VM_NAME"
            # Implementation
            ;;
        stop)
            log_info "Stopping VM: $VM_NAME"
            # Implementation
            ;;
        *)
            log_error "Unknown action: $ACTION"
            usage
            ;;
    esac
}

main
```

## Common Operations

### Check if Running as Root

```bash
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
fi
```

### Create Directories Safely

```bash
mkdir -p /path/to/directory
chmod 755 /path/to/directory
```

### Parse Command Arguments

```bash
# Positional arguments
FIRST_ARG="$1"
SECOND_ARG="${2:-default}"

# Named arguments with defaults
CONFIG_FILE="${CONFIG_FILE:-/etc/default.conf}"
DEBUG_MODE="${DEBUG_MODE:-false}"
```

### Logging Output

```bash
# Log to both console and file
log_to_file() {
    local message="$*"
    echo "$message"
    echo "$message" >> /var/log/script.log
}
```

## Testing Scripts

### Syntax Check

```bash
bash -n script.sh          # Check syntax without execution
```

### Trace Execution

```bash
bash -x script.sh          # Execute with trace output
```

### Shellcheck Validation

```bash
shellcheck script.sh       # Check for common issues
```

## Security Considerations

### Input Validation

```bash
# Validate variable not empty
if [[ -z "${VARIABLE}" ]]; then
    log_error "VARIABLE cannot be empty"
    exit 1
fi

# Validate numeric input
if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    log_error "Input must be numeric"
    exit 1
fi
```

### Secure File Handling

```bash
# Create temp files securely
TEMP_FILE=$(mktemp)
trap "rm -f '$TEMP_FILE'" EXIT

# Set restrictive permissions
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
```

### Avoid Command Injection

```bash
# WRONG - Vulnerable to injection
rm -rf $directory

# CORRECT - Quoted variables
rm -rf "$directory"

# CORRECT - Use arrays for arguments
args=(-r "$directory")
rm "${args[@]}"
```

## Troubleshooting

### Script Fails Silently

- Add `set -euo pipefail` to exit on errors
- Add logging throughout execution
- Run with `-x` flag for trace output

### Variable Undefined Error

- Check variable initialization before use
- Use `${VAR:-default}` for defaults
- Check variable scope (local vs global)

### File Not Found

- Use `set -u` to catch undefined variables
- Verify paths before operations
- Use absolute paths in production

## Related Documentation

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck Documentation](https://www.shellcheck.net/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
