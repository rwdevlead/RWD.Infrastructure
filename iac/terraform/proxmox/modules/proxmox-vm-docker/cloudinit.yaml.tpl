#cloud-config
hostname: ${hostname}
preserve_hostname: false

# network:
#   config: disabled

timezone: America/New_York
locale: en_US.UTF-8
keyboard:
  layout: us
  variant: ""

ssh_pwauth: false

users:
  - name: root
    ssh_authorized_keys:
      - ${ssh_public_key}

  - name: ka8kgj
    gecos: "Jim Stevens"
    groups: [sudo, adm]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_public_key}

packages:
  - qemu-guest-agent

write_files:
  - path: /etc/netplan/98-static-netcfg.yaml
    permissions: "0644"
    content: |
      network:
        version: 2
        renderer: networkd
        ethernets:
          ens18:
            dhcp4: no
            addresses:
              - "${ip_address}/${netmask}"
            routes:
              - to: default
                via: "${gateway}"
            nameservers:
              addresses:
                - "${gateway}"
                - "1.1.1.1"
              search: []

runcmd:
  #activate static ip netplan
  - netplan apply

  # Docker installation
  - apt-get update
  - apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  - install -m 0755 -d /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  - chmod a+r /etc/apt/keyrings/docker.gpg

  - echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  - usermod -aG docker ka8kgj
