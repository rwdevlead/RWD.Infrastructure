# Agents.md - AI System Integration Guide

## Purpose

This document provides instructions for integrating multiple AI systems and agents into the RWD.Infrastructure development workflow. It enables consistent, coordinated work across different Claude models, external AI services, or specialized agents.

## Quick Start for AI Agents

### If You're an AI Agent Starting Work on This Project

1. **Read these files first** (in order):
   - [copilot-instructions.md](copilot-instructions.md) - Project overview and current state
   - Language-specific guide from `/instructions/` matching your task
   - This file (Agents.md) for multi-agent coordination

2. **Key things to know immediately**:
   - Project uses Terraform, Ansible, Packer, Jinja2, Shell, and Make
   - Current focus: Docker NFS integration and application deployment
   - All secrets are gitignored - never attempt to commit sensitive data
   - Test code with `make lint` and `--check` modes before applying
   - Update copilot-instructions.md when significant work completes

3. **Before making changes**:
   - Read the existing code in the relevant directory
   - Check established patterns in similar files
   - Verify your changes match the project conventions
   - Test with dry-run/check modes first

## Multi-Agent Collaboration

### Agent Roles and Responsibilities

#### **Primary Agent (Claude Haiku 4.5)**

- **Responsibility**: Main development coordination
- **Expertise**: All languages in the stack
- **Duties**:
  - Execute code changes
  - Maintain instruction documents
  - Coordinate between tools
  - Update project state

### Specialized Agents

#### **Terraform Specialist** (if deployed)

- **Expertise**: Terraform/HCL infrastructure provisioning
- **Focus**: GitHub and Proxmox resource definitions
- **Responsibilities**:
  - Review Terraform code for best practices
  - Optimize module structure
  - Validate provider configurations
  - Coordinate infrastructure changes

#### **Ansible Configuration Expert** (if deployed)

- **Expertise**: Ansible playbooks and roles
- **Focus**: Post-deployment system configuration
- **Responsibilities**:
  - Design and implement configuration roles
  - Ensure idempotency and error handling
  - Optimize playbook execution
  - Maintain role documentation

#### **Infrastructure Validation Agent** (if deployed)

- **Expertise**: Testing and verification
- **Focus**: Ensuring infrastructure health
- **Responsibilities**:
  - Run validation tests
  - Monitor state configurations
  - Report on compliance
  - Health checks and assertions

## Information Sharing Between Agents

### Shared Context File Structure

When working as multiple agents, use this directory structure:

```
/instructions/                          # Shared instruction files
├── copilot-instructions.md            # Current project state
├── TERRAFORM.md                       # Language guides
├── ANSIBLE.md
├── PACKER.md
├── JINJA2.md
├── SHELL.md
├── MAKE.md
└── Agents.md                          # This file
```

### Handoff Protocol

When one agent hands off work to another:

1. **Update copilot-instructions.md**:

   ```markdown
   ## Recent Conversation Notes

   ### [Date] - [Task Name]

   **Topic**: Brief description

   - **Tasks Completed**: List what was done
   - **Current Status**: What's done, what's in progress
   - **Next Steps**: What the next agent should do
   - **Blockers**: Any issues encountered
   ```

2. **Provide Clear Context**:
   - Specify which files were changed
   - Highlight what succeeded and what didn't
   - Note any special considerations
   - Link relevant documentation

3. **State Final Status**:
   - Mark tasks as complete or in-progress
   - Provide reproduction steps if needed
   - List any resources or dependencies created

### Example Handoff

````markdown
### March 30, 2026 - Docker NFS Integration

**Topic**: Adding NFS mounts to docker playbook
**Assigned To**: [Next Agent Name]

**Completed**:

- Created docker/nfs-mounts role
- Updated docker.yml to include NFS setup
- Created mount point subdirectories

**In Progress**:

- Testing playbook execution
- Verifying mount persistence

**Next Steps**:

1. Execute docker.yml playbook against docker_hosts
2. Verify NFS mounts available at /mnt/docker and /mnt/backups
3. Check subdirectories created: /mnt/docker/volumes, /mnt/docker/stacks
4. Test Docker service startup with mounted volumes

**Files Modified**:

- iac/ansible/roles/docker/nfs-mounts/tasks/main.yml (new)
- iac/ansible/roles/docker/nfs-mounts/defaults/main.yml (new)
- iac/ansible/playbooks/docker.yml (updated)

**Commands to Run**:

```bash
make lint                              # Validate code
ansible-playbook playbooks/docker.yml --check  # Test
ansible-playbook playbooks/docker.yml  # Deploy
```
````

````

## Communication Between Agents

### No Direct Communication Model
- Agents do not communicate directly with each other
- All communication happens through updated files and documentation
- Use copilot-instructions.md as the single source of truth

### Update Frequency
- Update after significant work completion (30+ minutes of work)
- Update before handing off to another agent
- Update when encountering blockers or decisions
- Update when starting major new features

## Coordination Patterns

### Serial Work (One Agent After Another)
1. Agent A completes work on feature X
2. Agent A updates copilot-instructions.md with status
3. Agent B reads instructions and copilot-instructions.md
4. Agent B continues from where Agent A left off
5. Repeat until feature complete

### Parallel Work (Multiple Agents on Different Features)
Each agent works independently on separate features:
- Agent A: Terraform infrastructure changes
- Agent B: Ansible role improvements
- Agent C: Documentation updates

**Coordination Rules**:
- Don't modify files another agent is working on
- Update copilot-instructions.md with which features you're working on
- Commit frequently with clear messages
- Notify other agents of breaking changes via copilot-instructions.md

### Conflict Resolution
If agents work on overlapping areas:
1. Document in copilot-instructions.md which agent is responsible
2. Wait for one agent to complete before starting similar work
3. Coordinate filesystem changes to avoid conflicts
4. Use git branches for parallel development if needed

## Agent-Specific Instructions

### When Starting Work

**All Agents Should**:
1. Read [copilot-instructions.md](copilot-instructions.md) first
2. Read the relevant language-specific guide
3. Check git history for recent related changes
4. Look at existing code patterns before creating new code
5. Ask questions in copilot-instructions.md if uncertain

**Terraform Agents Should Additionally**:
- Review module structure in [TERRAFORM.md](TERRAFORM.md)
- Understand state management implications
- Check provider configurations before changes
- Plan changes with `terraform plan` before applying

**Ansible Agents Should Additionally**:
- Review role patterns in [ANSIBLE.md](ANSIBLE.md)
- Understand variable precedence
- Test with `--check` mode first
- Verify idempotency of roles

**Packer Agents Should Additionally**:
- Review cloud-init configuration in [PACKER.md](PACKER.md)
- Understand implications of image changes
- Test builds in non-production first
- Document image versions and timestamps

### When Completing Work

**Checklist for All Agents**:
- [ ] Code formatted and validated (`make lint`)
- [ ] Tested with check/dry-run modes
- [ ] Documentation updated (READMEs, comments)
- [ ] Commit messages clear and descriptive
- [ ] copilot-instructions.md updated with completion status
- [ ] Next steps documented for following agent

**Checklist for Infrastructure Changes**:
- [ ] Plan created and reviewed (`terraform plan`)
- [ ] Existing infrastructure impact understood
- [ ] Rollback plan defined if needed
- [ ] health checks defined (via Ansible assertions)

**Checklist for Configuration Changes**:
- [ ] Playbook runs in check mode successfully
- [ ] Tasks are idempotent
- [ ] Error handling defined
- [ ] Documentation includes variables and outputs

## Project State Tracking

### Current Work Items
See [copilot-instructions.md](copilot-instructions.md) for:
- What agents are currently working on
- What's completed and tested
- What's planned next
- Known blockers or issues

### Status Indicators
- ✅ Complete and tested
- 🔄 In progress
- ⏳ Planned
- ⚠️ Blocked or has issues
- 🐛 Known bug

### Updating Status
Add to "Recent Conversation Notes" section:

```markdown
### [Date] - [Feature Name]
**Status**: [Complete/In Progress/Blocked]
**Assigned To**: [Agent Name or "Unassigned"]
**Details**: Brief description of work
````

## Knowledge Base

### Project-Specific Decisions

Document important architectural decisions:

```markdown
## Architecture Decisions

### Docker NFS Integration (March 2026)

**Decision**: Use separate nfs-mounts role for Docker storage
**Rationale**: Reusable pattern, separate concern from Docker engine
**Impact**: Docker depends on NFS module now
**Alternatives Considered**: Direct mount in Docker role, manual fstab

### VM Templating Strategy

**Decision**: Build templates with Packer, store in Proxmox
**Rationale**: Ensures consistent, reproducible deployments
**Impact**: All new VMs clone from templates
```

### Common Issues and Solutions

Document recurring problems:

```markdown
## Troubleshooting Guide

### NFS Mounts Not Persisting After Reboot

**Problem**: NFS mounts unmount after VM restart
**Solution**: Ensure `state: mounted` in ansible.builtin.mount task
**Prevention**: Test mount persistence before deploying to production
**Related Files**: iac/ansible/roles/docker/nfs-mounts/tasks/main.yml

### Ansible Variables Undefined During Template Rendering

**Problem**: Jinja2 template references undefined variable
**Solution**: Check variable naming (case-sensitive), add defaults
**Prevention**: Document all variables in role README
**Related Files**: iac/ansible/roles/\*/README.md
```

## Agent Capabilities and Limitations

### What AI Agents Can Do

- ✅ Read and understand code across all languages
- ✅ Write new code following established patterns
- ✅ Update documentation and comments
- ✅ Run validation tools (`make lint`, `terraform plan`, `ansible-lint`)
- ✅ Review code against best practices
- ✅ Refactor existing code for clarity
- ✅ Update instruction documents

### What AI Agents Should NOT Do

- ❌ Apply infrastructure changes without human review
- ❌ Destroy infrastructure without explicit confirmation
- ❌ Commit secrets or sensitive data
- ❌ Make major architectural decisions without documenting
- ❌ Skip testing and validation steps
- ❌ Override established project conventions
- ❌ Work on production without explicit authorization

### When to Request Human Intervention

- Blocking technical issue preventing progress
- Major architectural decision needed
- Conflict with existing code patterns
- Security implications identified
- Production environment changes
- Uncertainty about intent or requirements

## Integration Examples

### Scenario 1: Adding a New Application Role

1. **Agent A starts**:
   - Reads [ANSIBLE.md](ANSIBLE.md) app role pattern
   - Creates role directory structure
   - Updates copilot-instructions.md: "Starting homepage app role"

2. **Agent B continues**:
   - Reads copilot-instructions.md progress
   - Examines existing app roles for patterns
   - Implements tasks and templates
   - Updates status: "Tasks and compose file complete"

3. **Agent C finishes**:
   - Reads progress from Agent B
   - Writes role README
   - Tests playbook with `--check`
   - Marks complete in copilot-instructions.md

### Scenario 2: Terraform Infrastructure Update

1. **Agent researches**:
   - Reads [TERRAFORM.md](TERRAFORM.md)
   - Reviews module structure
   - Checks existing GitHub provider configuration

2. **Agent implements**:
   - Creates or modifies resource definitions
   - Validates with `terraform validate`
   - Creates plan with `terraform plan -out=tfplan`

3. **Human reviews**:
   - Reviews tfplan output
   - Approves changes
   - Agent applies with `terraform apply tfplan`

4. **Agent verifies**:
   - Confirms resources created
   - Checks state file
   - Updates documentation

## Best Practices for Agent Collaboration

### Code Quality

- Follow existing patterns - consistency matters
- Write clear comments for complex logic
- Document all variables and outputs
- Test changes before considering done
- Keep commits focused and descriptive

### Communication

- Update copilot-instructions.md frequently
- Be explicit about blocking issues
- Provide clear context in handoffs
- Document decisions and rationale
- Link to relevant documentation

### Process

- Always validate before applying changes
- Use dry-run/check modes first
- Keep language-specific guides up to date
- Update troubleshooting section with learnings
- Maintain chronological notes of work

## Related Documentation

- [copilot-instructions.md](copilot-instructions.md) - Main project guide
- [TERRAFORM.md](TERRAFORM.md) - Terraform/HCL instructions
- [ANSIBLE.md](ANSIBLE.md) - Ansible/YAML instructions
- [PACKER.md](PACKER.md) - Packer/HCL instructions
- [JINJA2.md](JINJA2.md) - Jinja2 template instructions
- [SHELL.md](SHELL.md) - Shell/Bash script instructions
- [MAKE.md](MAKE.md) - Makefile orchestration instructions

## Support and Escalation

### Questions About Instructions

- Check the relevant language-specific guide first
- Search copilot-instructions.md for similar questions
- Document the question in a new section if not answered

### Blocked on Technical Issue

- Document the blocking issue in copilot-instructions.md
- Provide error messages and reproduction steps
- Note which configuration is failing
- Include attempted solutions and results

### Need to Change Instructions

- Propose change in copilot-instructions.md
- Explain why change is needed
- Update relevant language-specific guide
- Notify other agents of major changes

---

**Last Updated**: March 30, 2026
**Status**: Active Collaboration Ready
**Primary Contact**: Development Team
