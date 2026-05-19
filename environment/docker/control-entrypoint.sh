#!/bin/bash
set -e

echo "Memeriksa dan membuat SSH keypair untuk root di control node..."
if [ ! -f /root/.ssh/id_rsa ]; then
  mkdir -p /root/.ssh
  ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
fi

# Menyalin public key ke shared volume agar dapat diambil oleh managed nodes
mkdir -p /shared-keys
cp /root/.ssh/id_rsa.pub /shared-keys/control_node.pub
chmod 644 /shared-keys/control_node.pub

echo "======================================================================="
echo " Kontainer Control Node Ansible Berhasil Dijalankan!"
echo " Untuk masuk ke dalam control node dan menjalankan Ansible, gunakan:"
echo "   docker exec -it control-node bash"
echo ""
echo " Contoh perintah di dalam control node:"
echo "   ansible all -m ping"
echo "   ansible-playbook playbooks/site.yml"
echo "======================================================================="

# Menjaga kontainer tetap hidup
exec tail -f /dev/null
