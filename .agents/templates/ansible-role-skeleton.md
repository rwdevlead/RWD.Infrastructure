# Ansible Role Skeleton Snippets

Reference snippets for scaffolding a new application role under `iac/ansible/roles/apps/<app>/` following `.agents/standards/ansible-standards.md`.

---

## `defaults/main.yml`

```yaml
---
<app>_image: "<repo/image>"
<app>_tag: "latest"

<app>_base_dir: "{{ docker_base_dir }}/{{ <app>.container }}"
<app>_data_dir: "{{ docker_base_mnt }}/{{ <app>.container }}"
<app>_watchtower_enable: true
```

---

## `tasks/main.yml`

```yaml
---
- name: Ensure <App> directories exist
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: "0755"
  loop:
    - "{{ <app>_base_dir }}"
    - "{{ <app>_data_dir }}"

- name: Render <App> docker-compose.yml
  ansible.builtin.template:
    src: docker-compose.yml.j2
    dest: "{{ <app>_base_dir }}/docker-compose.yml"
    owner: root
    group: root
    mode: "0644"
  notify: Restart <App>

- name: Deploy <App> via Docker Compose
  community.docker.docker_compose_v2:
    project_src: "{{ <app>_base_dir }}"
    state: present
  when: not ansible_check_mode

- name: Wait for <App> container to become healthy
  community.docker.docker_container_info:
    name: "{{ <app>.container }}"
  register: <app>_container
  until:
    - <app>_container.container is defined
    - <app>_container.container.State.Health.Status | default('') == "healthy"
  retries: 15
  delay: 5
  when: not ansible_check_mode

- name: Assert <App> is healthy
  ansible.builtin.assert:
    that:
      - <app>_container.container.State.Health.Status == "healthy"
    fail_msg: "Container {{ <app>.container }} failed to reach healthy state."
  when: not ansible_check_mode
```

---

## `handlers/main.yml`

```yaml
---
- name: Restart <App>
  community.docker.docker_compose_v2:
    project_src: "{{ <app>_base_dir }}"
    state: restarted
  when: not ansible_check_mode
```

---

## `iac/ansible/playbooks/<app>.yml`

```yaml
---
- name: Deploy <App>
  hosts: <app>
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/<app>"
  roles:
    - infisical_secrets
    - apps/<app>
```

---

## Root `Makefile` Targets

Add `<app>` and `<app>-check` to `.PHONY` and under `# Application services`:

```makefile
<app>-check: ## Dry-run: Review <App> deployment
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/<app>.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml \
		--check --diff

<app>: ## Deploy <App> service
	$(ANSIBLE) $(ANSIBLE_DIR)/playbooks/<app>.yml \
		-i $(ANSIBLE_DIR)/inventories/hosts.yml
```
