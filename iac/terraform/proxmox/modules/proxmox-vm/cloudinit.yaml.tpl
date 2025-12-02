#cloud-config
hostname: ${hostname}
preserve_hostname: false

timezone: America/New_York
locale: en_US.UTF-8
keyboard:
  layout: us
  variant: ""

ssh_pwauth: false

users:
  - name: ubuntu
    gecos: Ubuntu User
    groups: [ sudo, adm ]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_public_key}

packages:
  - qemu-guest-agent

# Optional Docker installation (commented out)
#runcmd:
#  - echo "Docker installation placeholder"