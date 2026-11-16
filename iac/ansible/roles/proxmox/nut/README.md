# proxmox/nut

Deploys and configures Network UPS Tools (NUT) across the Proxmox VE cluster (`proxmox_cluster`), including dependency-ordered VM takedown on battery depletion and automated staged bring-up after power restoration.

## Overview

- **Master Node (`role: "master"`):** Connects directly to the UPS via USB (`usbhid-ups`), runs `nut-server` (`upsd`) bound to localhost and its LAN IP, runs `upssched` to start a countdown timer on battery events, and orchestrates cluster-wide staged VM/host shutdown and recovery.
- **Slave Nodes (`role: "slave"`):** Run `nut-client` (`upsmon`) connected to the master node's `upsd` server over the LAN (`3493/tcp`).
- **Staged Takedown (`staged_takedown.sh`):** Iterates through `shutdown_tier` `1..3` from `nut_instances`:
  - **Tier 1:** Non-blocking shutdown of secondary VMs (`dev-omv-01`, `homeassistant`, `dev-docker-01`).
  - **Tier 2:** Graceful shutdown of `prod-docker-01` (waits for exit so Mailrise finishes sending alerts), then powers off `M900(pve-p01)`.
  - **Tier 3:** Graceful shutdown of local `dev-docker-02` (waits for exit so NFS clients disconnect), graceful shutdown of storage VM `dev-truenas-01` (waits for exit), powers off `Tower(proxmox)`, and triggers `/sbin/upsmon -c fsd`.
- **Staged Bring-Up (`staged_bringup.sh` + `nut-bringup.service`):** Runs on boot if `/etc/nut/power_outage.flag` is present. Waits for slave Proxmox hosts to respond to SSH, boots storage VMs (`is_storage: true`) first and waits for ping + NFS initialization, then starts remaining slave and master VMs before removing the outage flag.

## Requirements

- Proxmox VE hosts defined under `proxmox_cluster` in `iac/ansible/inventories/hosts.yml`
- Passwordless SSH (`root`) from the NUT master node to slave Proxmox nodes
- Infisical secrets populated under `/ansible/nut`

## Infisical Secrets (`/ansible/nut`)

| Secret Key       | Description                                      |
| ---------------- | ------------------------------------------------ |
| `ADMIN_USER`     | NUT administrative username (`upsd.users`)       |
| `ADMIN_PASSWORD` | NUT administrative password (`upsd.users`)       |
| `USER`           | NUT `upsmon` monitoring username                 |
| `USER_PASSWORD`  | NUT `upsmon` monitoring password                 |

## Role Defaults (`defaults/main.yml`)

| Variable                        | Description                                           | Default                      |
| ------------------------------- | ----------------------------------------------------- | ---------------------------- |
| `nut_port`                      | TCP port for `upsd` server                            | `3493`                       |
| `nut_poll_interval`             | Driver poll interval in seconds (`ups.conf`)          | `2`                          |
| `nut_max_retry`                 | Driver max retry count (`ups.conf`)                   | `3`                          |
| `nut_min_supplies`              | Minimum power supplies required (`upsmon.conf`)       | `1`                          |
| `nut_poll_freq`                 | Normal `upsmon` polling frequency (seconds)           | `5`                          |
| `nut_poll_freq_alert`           | On-battery `upsmon` polling frequency (seconds)       | `2`                          |
| `nut_host_sync`                 | Slave sync timeout (seconds)                          | `15`                         |
| `nut_deadtime`                  | Seconds before declaring a UPS dead                   | `15`                         |
| `nut_rb_warn_time`              | Replace-battery warning interval (seconds)            | `43200`                      |
| `nut_nocomm_warn_time`          | No-communication warning interval (seconds)           | `300`                        |
| `nut_final_delay`               | Delay before final shutdown command (seconds)         | `5`                          |
| `nut_onbatt_timer_seconds`      | Seconds on battery before triggering staged takedown  | `300`                        |
| `nut_storage_init_wait_seconds` | Seconds to wait after storage VM responds to ping     | `45`                         |
| `nut_ssh_connect_timeout`       | SSH connect timeout (seconds) for remote `qm` calls   | `5`                          |
| `nut_config_dir`                | NUT configuration directory                           | `/etc/nut`                   |
| `nut_shutdown_cmd`              | System poweroff command                               | `/sbin/poweroff`             |
| `nut_notify_cmd`                | Notification scheduler binary                         | `/sbin/upssched`             |
| `nut_powerdown_flag`            | NUT killpower flag file                               | `/etc/killpower`             |
| `nut_upssched_pipe_file`        | `upssched` FIFO pipe path                             | `/run/nut/upssched.pipe`     |
| `nut_upssched_lock_file`        | `upssched` lock file path                             | `/run/nut/upssched.lock`     |
| `nut_outage_flag_file`          | Flag file indicating an active outage takedown        | `/etc/nut/power_outage.flag` |
| `nut_takedown_log`              | Log file for `staged_takedown.sh`                     | `/var/log/nut_takedown.log`  |
| `nut_bringup_log`               | Log file for `staged_bringup.sh`                      | `/var/log/nut_bringup.log`   |

## Group Variables (`inventories/group_vars/proxmox_cluster.yml`)

Cluster topology and VM shutdown/startup dependencies are defined in `nut_instances` keyed by `inventory_hostname` (`pve-d01`, `pve-p01`, `proxmox`). Each node specifies:
- `alias`: Hardware nickname (`G9`, `M900`, `Tower`) used in log output (`Alias(hostname)`)
- `role`: `master` or `slave`
- `poweroff_tier` *(slaves)*: Tier (`2` or `3`) at which the physical slave host powers off
- `ups` *(master)*: USB driver settings (`name`, `desc`, `driver`, `port`, `vendorid`, `productid`)
- `notifications` *(master)*: Mailrise SMTP settings (`mailrise_url`, `mail_from`, `mail_recipient`)
- `vms`: List of VMs managed during outage takedown/bring-up (`id`, `name`, `shutdown_tier`, `wait_for_stop`, `is_storage`, `ip`)

## Make Targets

```bash
# Dry-run with diff preview against proxmox_cluster
make ups-nut-check

# Deploy NUT configuration across proxmox_cluster
make ups-nut
```
