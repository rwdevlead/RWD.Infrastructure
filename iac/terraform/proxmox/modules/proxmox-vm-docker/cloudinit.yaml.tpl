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
    groups: [sudo, adm]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_public_key}

packages:
  - qemu-guest-agent

# Optional Docker installation (uncommented for this module)
runcmd:
  - |
    apt-get update
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) \
      signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io
