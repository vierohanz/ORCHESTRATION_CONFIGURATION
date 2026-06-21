# Ansible Enterprise Lab (Multi-Server Docker Automation)

Project ini difokuskan pada otomatisasi infrastruktur dan manajemen konfigurasi menggunakan **Ansible** untuk mendeploy layanan heterogen (Nginx Web Server, Kubernetes Cluster, dan Hazelcast Cache) ke dalam 3 Virtual Machine (VM) Ubuntu. Selain itu, terdapat pengenalan konsep **Infrastructure as Code (IaC)** menggunakan **Terraform**.

---

## Struktur Direktori Konfigurasi Ansible

```text
c:\laragon\www\ORCHESTRATION_CONFIGURATION\
├── Makefile                      # Perintah singkat standardisasi DevOps (make ping, make deploy)
├── ansible/
│   ├── ansible.cfg               # Konfigurasi utama Ansible (lokasi inventory, default privilege escalation)
│   ├── inventory/
│   │   ├── hosts.ini             # Daftar IP VM target (Managed Nodes), Localhost & Kredensial SSH/Sudo
│   │   └── group_vars/
│   │       └── all/vars.yml      # Variabel global (Nama Project, Nama Environment, Timezone)
│   ├── playbooks/
│   │   ├── site.yml              # Master Playbook (mengatur jalannya semua konfigurasi)
│   │   ├── server.yml            # Playbook khusus setup Nginx & Deploy Calculator UI (ubuntu-1)
│   │   ├── kubernetes.yml        # Playbook khusus setup Kubernetes / K3s (ubuntu-2)
│   │   └── cache.yml             # Playbook khusus setup Hazelcast Cache (ubuntu-3)
│   └── roles/
│       └── common/               # Role dasar yang diterapkan ke semua VM
│           ├── tasks/main.yml    # Task dasar (update apt, install Docker, python3-docker, timezone, UFW)
│           ├── templates/motd.j2 # Template banner selamat datang terminal ketika login SSH
│           └── handlers/main.yml # Handler pasif untuk reload Firewall (UFW)
├── terraform/
│   └── local/                    # Simulasi pengenalan Infrastructure as Code (IaC) lokal
│       └── main.tf               # Konfigurasi Local Terraform provider
```

---

## 🛠️ Panduan Konfigurasi Awal VM (VirtualBox & SSH)

Agar Ansible dapat mengontrol VM Anda, ketiga VM Ubuntu (`ubuntu-1`, `ubuntu-2`, `ubuntu-3`) harus dikonfigurasi jaringan, SSH, dan hak aksesnya terlebih dahulu. Berikut langkah-langkah detailnya:

### Langkah 1: Konfigurasi Jaringan di VirtualBox

1. Buka VirtualBox, klik kanan pada VM -> **Settings** -> **Network**.
2. **Adapter 1**: Set ke **NAT** (digunakan agar VM memiliki koneksi internet untuk mengunduh paket).
3. **Adapter 2**: Centang _Enable Network Adapter_ dan set ke **Host-only Adapter** (pilih `VirtualBox Host-Only Ethernet Adapter`). Ini digunakan untuk jalur komunikasi internal antara Windows/WSL dan VM Anda.

### Langkah 2: Konfigurasi IP Static di Setiap VM (NetworkManager / nmcli)

Pada Ubuntu Desktop, pengelolaan jaringan dikendalikan oleh **NetworkManager**. Kita menggunakan perintah **`nmcli`** di terminal hitam TTY untuk mengonfigurasi IP statis pada adapter Host-Only (`enp0s8`):

1. **Buat profil koneksi baru untuk `enp0s8`**:

   ```bash
   sudo nmcli con add type ethernet con-name enp0s8 ifname enp0s8
   ```

2. **Atur alamat IP statis (sesuai VM target)**:

   ```bash
   sudo nmcli con mod enp0s8 ipv4.addresses 192.168.56.11/24
   ```

   - **Penjelasan**: Menentukan IP Address manual. Gunakan `192.168.56.11` untuk **ubuntu-1**, `192.168.56.12` untuk **ubuntu-2**, dan `192.168.56.13` untuk **ubuntu-3**.

3. **Ubah mode pencarian IP menjadi manual (static)**:

   ```bash
   sudo nmcli con mod enp0s8 ipv4.method manual
   ```

4. **Aktifkan konfigurasi baru**:

   ```bash
   sudo nmcli con up enp0s8
   ```

5. **Uji hasil konfigurasi**:

   ```bash
   ip a
   ```

### Langkah 3: Install & Aktifkan OpenSSH Server

Pastikan VM Anda dapat menerima koneksi SSH:

1. Install paket SSH:
   ```bash
   sudo apt update && sudo apt install -y openssh-server
   ```
2. Pastikan layanan SSH otomatis berjalan saat VM dinyalakan:
   ```bash
   sudo systemctl enable --now ssh
   ```

### Langkah 4: Aktifkan SSH Authentication Menggunakan Password

1. Buka konfigurasi SSH Daemon:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Pastikan baris berikut tidak diberi tanda pagar (`#`) dan bernilai `yes`:
   ```text
   PasswordAuthentication yes
   ```
3. Restart layanan SSH untuk menerapkan perubahan:
   ```bash
   sudo systemctl restart ssh
   ```

### Langkah 5: Buat User & Berikan Akses Sudo

Kredensial default yang didefinisikan dalam file `hosts.ini` adalah username `vboxuser` dengan password `changeme`.

1. Jika user belum ada, buat user baru:
   ```bash
   sudo adduser vboxuser
   ```
2. Masukkan user tersebut ke dalam kelompok administrator (sudo):
   ```bash
   sudo usermod -aG sudo vboxuser
   ```

---

## 🚀 Cara Menjalankan Otomatisasi (DevOps Shortcut)

Gunakan perintah pintas di root folder proyek Anda `/mnt/c/laragon/www/ORCHESTRATION_CONFIGURATION/` via terminal **WSL**:

### 1. Uji Konektivitas SSH ke Semua VM

```bash
make ping
```

_Jika sukses, Anda akan melihat pesan `"ping": "pong"` dari `ubuntu-1`, `ubuntu-2`, `ubuntu-3`, dan `localhost`._

### 2. Jalankan Proses Deployment Penuh

```bash
make deploy
```

_Ansible akan otomatis memperbarui OS, menginstal Docker, menyalakan Web Calculator App, mengonfigurasi Java & Hazelcast, serta mem-provisioning node Kubernetes secara remote._

---

## 🖥️ Lokasi Folder dan Cara Pengecekan Hasil

Setelah proses `make deploy` selesai tanpa error:

1. **Web Server (`ubuntu-1`)**:
   - **Akses Halaman**: Buka **`http://192.168.56.11`** di browser Windows untuk melihat halaman UI Kalkulator berkonsep **Neo-Brutalism**.
   - **Lokasi File**: `/var/www/html/index.html` (di-mount ke Nginx Docker Container).
   - **Calculator API Service**: Buka **`http://192.168.56.11:5000/calc?op=add&a=10&b=5`** untuk mencoba API kalkulator berbasis Python Flask yang menyimpan riwayatnya ke Hazelcast.
2. **Kubernetes Node (`ubuntu-2`)**:
   - **Cluster K3s**: Cluster Kubernetes ringan yang terinstal otomatis via Ansible.
   - **Hello World App**: Buka **`http://192.168.56.12:30080`** untuk melihat Nginx Pod yang di-deploy ke dalam Kubernetes.
3. **Cache Server (`ubuntu-3`)**:
   - **Instalasi Java & Hazelcast**: Hazelcast diinstal secara native di `/opt/hazelcast` dan dikelola oleh `systemd` pada port `5701`.

---

## 🏗️ Infrastructure as Code (Terraform)

Repositori ini juga menyertakan simulasi pengenalan Terraform di direktori `terraform/local`.

Cara menjalankan simulasi provisioning lokal (Pastikan Terraform terinstal di sistem Anda):
```bash
cd terraform/local
terraform init
terraform apply
terraform destroy
```

_Developed with ❤️ for Advanced Infrastructure Automation._
