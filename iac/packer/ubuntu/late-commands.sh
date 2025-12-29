# === ALL CONFIGURATION (Service Configuration) ===

# Set root password
curtin in-target --target=/target -- bash -c 'echo "root:ubuntu" | chpasswd'

# Enable root SSH login and password auth
curtin in-target --target=/target -- bash -c 'sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config'
curtin in-target --target=/target -- bash -c 'sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config'

# Enable and restart SSH server (Applying new config)
curtin in-target --target=/target -- systemctl enable ssh
curtin in-target --target=/target -- systemctl restart ssh

# Enable QEMU Guest Agent (Do not check status, just enable it)
curtin in-target --target=/target -- systemctl enable qemu-guest-agent
curtin in-target --target=/target -- systemctl start qemu-guest-agent


# === ESSENTIAL CLEANUP AND OPTIMIZATION (Keep these last) ===

# CLOUD-INIT CLEANUP
curtin in-target --target=/target -- cloud-init clean --logs --seed
curtin in-target --target=/target -- bash -c 'rm -rf /var/lib/cloud/*'
curtin in-target --target=/target -- bash -c 'truncate -s 0 /etc/machine-id'

# Optimization: Zero empty space and clean up
curtin in-target --target=/target -- bash -c 'dd if=/dev/zero of=/EMPTY bs=1M; rm -f /EMPTY; exit 0'

# Sync filesystem
curtin in-target --target=/target -- sync

# Final log (If this appears, late-commands was successful!)
curtin in-target --target=/target -- bash -c 'echo "Late commands finished successfully"'