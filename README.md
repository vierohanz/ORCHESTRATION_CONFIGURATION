# Ansible Enterprise Lab (Multi-Server Docker Automation)

Project ini difokuskan pada otomatisasi infrastruktur dan manajemen konfigurasi menggunakan **Ansible** untuk mendeploy layanan heterogen berbasis **Docker** (Nginx Web Server, PostgreSQL Database, dan Redis Cache) ke dalam 3 Virtual Machine (VM) Ubuntu.

---

## Struktur Direktori Konfigurasi Ansible

```text
c:\laragon\www\ANSIBLE\
├── Makefile                      # Perintah singkat standardisasi DevOps (make ping, make deploy)
├── ansible/
│   ├── ansible.cfg               # Konfigurasi utama Ansible (lokasi inventory, default privilege escalation)
│   ├── inventory/
│   │   ├── hosts.ini             # Daftar IP VM target (Managed Nodes), Localhost & Kredensial SSH/Sudo
│   │   └── group_vars/
│   │       └── all.yml           # Variabel global (Nama Project, Nama Environment, Timezone, Admin Email)
│   ├── playbooks/
│   │   ├── site.yml              # Master Playbook (mengatur jalannya semua konfigurasi)
│   │   ├── server.yml            # Playbook khusus setup Nginx & Deploy Landing Page (ubuntu-1)
│   │   ├── database.yml          # Playbook khusus setup PostgreSQL Database (ubuntu-2)
│   │   └── cache.yml             # Playbook khusus setup Redis Cache (ubuntu-3)
│   └── roles/
│       └── common/               # Role dasar yang diterapkan ke semua VM
│           ├── tasks/main.yml    # Task dasar (update apt, install Docker, python3-docker, timezone, UFW, MOTD)
│           ├── templates/motd.j2 # Template banner selamat datang terminal ketika login SSH
│           └── handlers/main.yml # Handler pasif untuk reload Firewall (UFW)
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

   - **Penjelasan**: Membuat profil konfigurasi jaringan Ethernet baru bernama `enp0s8` untuk kartu jaringan fisik `enp0s8`.

2. **Atur alamat IP statis (sesuai VM target)**:

   ```bash
   sudo nmcli con mod enp0s8 ipv4.addresses 192.168.56.11/24
   ```

   - **Penjelasan**: Menentukan IP Address manual. Gunakan `192.168.56.11` untuk **ubuntu-1**, `192.168.56.12` untuk **ubuntu-2**, dan `192.168.56.13` untuk **ubuntu-3**. `/24` menunjukkan netmask `255.255.255.0`.

3. **Ubah mode pencarian IP menjadi manual (static)**:

   ```bash
   sudo nmcli con mod enp0s8 ipv4.method manual
   ```

   - **Penjelasan**: Memberitahu sistem untuk menggunakan IP manual secara permanen dan menonaktifkan pencarian otomatis (DHCP) yang seringkali gagal.

4. **Aktifkan konfigurasi baru**:

   ```bash
   sudo nmcli con up enp0s8
   ```

   - **Penjelasan**: Menerapkan dan menghidupkan profil jaringan tersebut dengan konfigurasi IP yang baru saja kita atur.

5. **Uji hasil konfigurasi**:

   ```bash
   ip a
   ```

   - **Penjelasan**: Periksa interface `enp0s8`, pastikan terdapat baris `inet 192.168.56.X/24` yang menunjukkan IP telah aktif.

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
3. Periksa status layanan SSH:
   ```bash
   sudo systemctl status ssh
   ```

### Langkah 4: Aktifkan SSH Authentication Menggunakan Password

Secara default, beberapa instalasi Ubuntu mematikan login SSH dengan password. Pastikan fitur ini aktif:

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
   # Masukkan password: changeme
   ```
2. Masukkan user tersebut ke dalam kelompok administrator (sudo):
   ```bash
   sudo usermod -aG sudo vboxuser
   ```

---

## 🚀 Cara Menjalankan Otomatisasi (DevOps Shortcut)

Gunakan perintah pintas di root folder proyek Anda `/mnt/c/laragon/www/ANSIBLE/` via terminal **WSL**:

### 1. Uji Konektivitas SSH ke Semua VM

```bash
make ping
```

_Jika sukses, Anda akan melihat pesan `"ping": "pong"` dari `ubuntu-1`, `ubuntu-2`, `ubuntu-3`, dan `localhost`._

### 2. Jalankan Proses Deployment Penuh

```bash
make deploy
```

_Ansible akan otomatis memperbarui OS, menginstal Docker, menyiapkan direktori data, serta menyalakan kontainer Nginx, PostgreSQL, dan Redis._

---

## 🖥️ Lokasi Folder dan Cara Pengecekan Hasil

Setelah proses `make deploy` selesai tanpa error:

1. **Web Server (`ubuntu-1`)**:
   - **Akses Halaman**: Buka **`http://192.168.56.11`** di browser Windows untuk melihat halaman monitoring berkonsep **Dark Neo-Brutalisme** yang dinamis.
   - **Lokasi File**: `/var/www/html/index.html` (di-mount ke Nginx Docker Container).
2. **Database Server (`ubuntu-2`)**:
   - **Lokasi Data**: `/var/lib/postgresql/data/` (Penyimpanan database Postgres).
   - **Lokasi Backup & Inisialisasi**: `/var/backups/postgres/init.log`.
3. **Cache Server (`ubuntu-3`)**:
   - **Lokasi Log Inisialisasi**: `/var/log/redis_ansible_init.log`.

_Developed with ❤️ for Advanced Infrastructure Automation._
