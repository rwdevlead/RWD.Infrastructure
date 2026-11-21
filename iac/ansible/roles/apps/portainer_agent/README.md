# apps/portainer_agent

Deploys the Portainer Agent container via Docker Compose on hosts in the `portainer_agents` inventory group (`prod-docker-01`).

---

## Requirements

- Docker Engine and Compose v2 (`docker/engine`, `docker/compose`)
- External Docker network (`shared_docker_network`, default `traefik`)
- Infisical secrets populated under `/ansible/portainer`

---

## Variables

### Role Defaults (`defaults/main.yml`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `portainer_agent_dir` | Host directory for `docker-compose.yml` | `"{{ docker_base_dir }}/portainer-agent"` |
| `portainer_agent_port` | Host port mapped to container port `9001` | `9001` |
| `portainer_agent_secret` | Shared agent authentication secret | `"{{ secrets.ansible.portainer.AGENT_SECRET }}"` |
| `portainer_agent_watchtower_enable` | Add Watchtower notification label | `true` |

### Group Variables (`inventories/group_vars/docker_hosts.yml`)

- `portainer_agents[inventory_hostname].name`: Container name (`portainer-agent-p01` on `prod-docker-01`)
- `shared_docker_network`, `docker_base_dir`

---

## Infisical Secrets (`/ansible/portainer`)

| Secret Key | Description |
| :--- | :--- |
| `AGENT_SECRET` | Must match the `AGENT_SECRET` configured on `apps/portainer` |

---

## Dependencies

- `infisical_secrets` (invoked by `playbooks/portainer_agent.yml`)
- `community.docker` collection

---

## Example

```yaml
- name: Deploy Portainer Agent
  hosts: portainer_agents
  become: true
  vars:
    infisical_secret_paths:
      - "/ansible/portainer"
  roles:
    - infisical_secrets
    - apps/portainer_agent
    - docker/image_cleanup
```

---

## Make Targets

```bash
make portainer-agent-check
make portainer-agent
```

---

## Notes

- Runs `portainer/agent:latest` (`pull: always`) with `restart: always`, exposing `{{ portainer_agent_port }}:9001`, mounting `/var/run/docker.sock` and `/var/lib/docker/volumes`, and asserting the container reaches `running` state.
- Renders `AGENT_SECRET` into `{{ portainer_agent_dir }}/.env` (`mode: "0600"`, `diff: false`) and references `${AGENT_SECRET}` in `docker-compose.yml` (`mode: "0644"`).
