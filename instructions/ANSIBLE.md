# Ansible (YAML) Instructions

## Overview

Ansible is the configuration management system for post-deployment system setup, service installation, and application deployment. The project uses a role-based architecture with reusable, modular playbooks.

## Project Structure

```
iac/ansible/
├── ansible.cfg              # Ansible configuration
├── playbooks/               # Top-level orchestration playbooks
│   ├── docker.yml          # Docker platform setup
│   ├── base.yml            # Base system configuration
│   ├── traefik.yml         # Traefik reverse proxy
│   └── ...                 # App-specific playbooks
├── inventories/            # Host inventories
│   ├── docker.yml
│   ├── ubuntu.yml
│   ├── truenas.yml
│   └── apps/               # App-specific host groups
├── roles/                  # Reusable configuration roles
│   ├── apps/               # Application deployment roles
│   ├── base/               # OS-level configuration
│   ├── docker/             # Docker runtime & orchestration
│   └── storage/            # Storage configuration
├── vars/                   # Global variables
│   ├── global.yml
│   └── secrets.yml         # GITIGNORED - sensitive data
└── collections/            # Ansible collections
    ├── requirements.yml
    └── ansible_collections/
```

## File Organization

### Playbooks

- **Location**: `playbooks/*.yml`
- **Purpose**: Orchestrate multiple roles for specific features
- **Naming**: Descriptive names matching feature (docker.yml, traefik.yml)
- **Structure**: Define hosts, include roles, set variables

### Roles

- **Location**: `roles/<category>/<rolename>/`
- **Structure** (standard):
  ```
  roles/apps/pihole/
  ├── README.md           # Usage documentation
  ├── defaults/main.yml   # Default variables
  ├── tasks/main.yml      # Task definitions
  ├── handlers/main.yml   # Event handlers (if needed)
  ├── templates/          # Jinja2 template files
  ├── files/              # Static files
  └── vars/main.yml       # Role-specific variables (optional)
  ```

### Inventories

- **Location**: `inventories/*.yml`
- **Purpose**: Define host groups and inventory-specific variables
- **Naming**: Match target environment or service type

### Variables

- **Location**: `vars/global.yml`, `vars/secrets.yml`
- **global.yml**: Non-sensitive, shared configuration
- **secrets.yml**: GITIGNORED - sensitive credentials and API keys

## Naming Conventions

### Playbooks

- snake_case filenames
- Descriptive names: `deploy_nas_storage.yml` not `deploy.yml`
- Match role names when single-purpose

### Roles

- Directory names: lowercase with hyphens: `github-teams`
- Task/handler names: Clear, action-oriented descriptions
- Variable names: lowercase with underscores

### Task Names

- Start with action verb: "Install", "Configure", "Deploy", "Create"
- Be specific: "Install Docker Engine from official repository" not just "Install Docker"
- Include context: "Add users to docker group" clearly indicates what's happening

### Variables

- Prefix with role or feature: `pihole_base_dir`, `docker_users`
- Snake_case for all variable names
- Use descriptive names: `homepage_enabled` not `he`

## Development Workflow

### Before Running Playbooks

```bash
ansible-lint                          # Check for style issues
ansible-playbook playbooks/docker.yml --check  # Dry-run
```

### Testing with Check Mode

```bash
ansible-playbook playbooks/docker.yml --check -i inventories/docker.yml
```

### Running Playbooks

```bash
ansible-playbook playbooks/docker.yml -i inventories/docker.yml
make apply                            # Via Makefile
```

### Using Make

```bash
make lint                             # Run ansible-lint
make plan                             # Test with --check mode
make apply ENV=staging                # Apply to staging
```

## Best Practices

### Role Design

- **Single Responsibility**: Each role has one clear purpose
- **Defaults First**: Provide sensible defaults in `defaults/main.yml`
- **Override Variables**: Allow role customization via inventories
- **Documentation**: Include README explaining role purpose and variables
- **Idempotency**: Tasks should be safe to run multiple times

### Task Writing

- Use fully qualified collection names: `ansible.builtin.file`, `community.docker.docker_compose_v2`
- Register variables for later use in conditionals
- Use loops for multiple similar tasks
- Include meaningful task names for log clarity

### Error Handling

```yaml
- name: Run command with error handling
  ansible.builtin.command: ...
  register: result
  failed_when: result.rc not in [0, 2]
  changed_when: result.rc == 0
```

### Conditional Execution

```yaml
- name: Task with conditions
  ansible.builtin.file: ...
  when:
    - enable_feature | default(false)
    - ansible_distribution == "Ubuntu"
```

### Check Mode Handling

```yaml
- name: Task that should skip check mode
  ansible.builtin.shell: docker compose up -d
  when: not ansible_check_mode
```

## Docker Application Pattern

Standard pattern for `apps/<appname>/tasks/main.yml`:

1. **Create directories** - Use `file` module with loop
2. **Deploy configuration** - Use `template` module for Jinja2 files
3. **Start services** - Use `community.docker.docker_compose_v2`
4. **Health checks** - Use `community.docker.docker_container_info`
5. **Assertions** - Verify success with `assert` module

Example from pihole role:

```yaml
- name: Create directories
  file:
    path: "{{ item }}"
    state: directory
  loop:
    - "{{ pihole_base_dir }}"
    - "{{ pihole_base_dir }}/etc-pihole"

- name: Deploy docker-compose file
  template:
    src: docker-compose.yml.j2
    dest: "{{ pihole_base_dir }}/docker-compose.yml"

- name: Start service
  community.docker.docker_compose_v2:
    project_src: "{{ pihole_base_dir }}"
    state: present
  when: not ansible_check_mode

- name: Wait for health
  community.docker.docker_container_info:
    name: "pihole"
  register: container_info
  until: container_info.container.State.Health.Status == "healthy"
  retries: 15
  delay: 10

- name: Assert healthy state
  ansible.builtin.assert:
    that:
      - container_info.container.State.Health.Status == "healthy"
```

## NFS Mount Pattern

Standard pattern for mounting NFS shares:

1. **Install NFS client**

   ```yaml
   - name: Install NFS client packages
     ansible.builtin.package:
       name: nfs-common
   ```

2. **Create mount points** with proper permissions

   ```yaml
   - name: Create mount directories
     ansible.builtin.file:
       path: "{{ item.path }}"
       state: directory
       mode: "0755"
     loop: "{{ nfs_mounts }}"
   ```

3. **Mount NFS shares** with `/etc/fstab` persistence

   ```yaml
   - name: Mount NFS shares
     ansible.builtin.mount:
       path: "{{ item.path }}"
       src: "{{ item.src }}"
       fstype: nfs
       opts: "{{ item.opts }}"
       state: mounted
     loop: "{{ nfs_mounts }}"
   ```

4. **Set appropriate permissions** for Docker access
   ```yaml
   - name: Set mount permissions
     ansible.builtin.file:
       path: "{{ item.path }}"
       mode: "0777"
     loop: "{{ nfs_mounts }}"
   ```

## Common Tasks

### Adding New Playbook

1. Create `playbooks/feature.yml` with hosts and roles
2. List required roles (create if needed)
3. Define role-specific variables in `inventories/`
4. Test with `--check` mode
5. Verify with `ansible-lint`

### Creating New Role

1. Create `roles/category/rolename/` directory structure
2. Add README explaining purpose and variables
3. Create `defaults/main.yml` with default variables
4. Implement `tasks/main.yml`
5. Add `templates/` or `files/` as needed

### Adding Variables

- **Global variables**: Add to `vars/global.yml`
- **Sensitive data**: Add to `vars/secrets.yml` (mark in code, exclude from git)
- **Role defaults**: Add to `roles/category/role/defaults/main.yml`
- **Inventory overrides**: Add to `inventories/host.yml` under `vars:`

### Testing Role in Check Mode

```bash
ansible-playbook playbooks/feature.yml --check -i inventories/ubuntu.yml -l hostname
```

## Collections & Dependencies

### Required Collections

Stored in `collections/requirements.yml`:

- `community.docker` - Docker/Docker Compose operations
- `community.general` - General-purpose modules

### Installing Collections

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

## Security Considerations

### Secrets Management

- Store sensitive data in `vars/secrets.yml` (gitignored)
- Use `ansible-vault` for encrypting files
- Never commit credentials
- Rotate secrets regularly

### Variable Precedence

1. Extra vars (highest)
2. Task vars
3. Block vars
4. Play vars
5. Inventory vars
6. Role defaults (lowest)

Use this when designing variable hierarchy.

## Troubleshooting

### Task Fails with "undefined variable"

- Check variable naming (exact case sensitive)
- Verify variable defined in defaults/inventory/play
- Check scoping (role, play, block, task)

### Conditional Not Working

- Verify quote usage: `when: var | bool`
- Check variable type conversion
- Use `debug` module to inspect variables

### Docker Operations Fail

- Ensure check mode handling: `when: not ansible_check_mode`
- Verify container is running before querying
- Check community.docker collection installed

## Related Documentation

- [Ansible Documentation](https://docs.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/)
- [Playbook Keywords](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html)
- [Module Index](https://docs.ansible.com/ansible/latest/collections/index.html)
- [Community Docker Collection](https://github.com/ansible-collections/community.docker)
