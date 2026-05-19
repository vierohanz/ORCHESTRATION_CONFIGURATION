#!/bin/bash
set -e

echo "Menunggu public key SSH dari Control Node..."
mkdir -p /shared-keys

while [ ! -f /shared-keys/control_node.pub ]; do
  sleep 1
done

# Menambahkan public key ke user devops
mkdir -p /home/devops/.ssh
cat /shared-keys/control_node.pub > /home/devops/.ssh/authorized_keys
chmod 700 /home/devops/.ssh
chmod 600 /home/devops/.ssh/authorized_keys
chown -R devops:devops /home/devops/.ssh

# Generate host keys SSH jika belum ada
ssh-keygen -A

echo "Public key SSH berhasil dipasang. Menjalankan daemon SSH..."
exec /usr/sbin/sshd -D
