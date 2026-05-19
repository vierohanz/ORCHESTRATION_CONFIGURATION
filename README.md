# 🚀 Ansible Enterprise Lab (Pure Configuration Management)

Project ini difokuskan **100% pada ranah Configuration Management menggunakan Ansible**. 

Asumsinya, Anda sudah memiliki **3 Mesin Virtual (VM) Kali Linux** yang menyala di VirtualBox, dan Anda ingin menggunakan Ansible untuk mengonfigurasi sistem, menginstall paket aplikasi, serta men-deploy layanan web & database ke ketiga VM tersebut secara otomatis.

---

## 📂 Struktur Direktori Konfigurasi Ansible

```text
c:\laragon\www\ANSIBLE\ansible\
├── ansible.cfg                   # Konfigurasi utama Ansible (lokasi inventory, privilege escalation)
├── inventory/                    # Definisi daftar target server (Managed Nodes)
│   ├── hosts.ini                 # Daftar IP 3 VM Kali Linux & Kredensial SSH
│   └── group_vars/
│       └── all.yml               # Variabel global (Nama Project, Nama Environment, Timezone)
├── playbooks/                    # Kumpulan skenario otomatisasi (Playbooks)
│   ├── site.yml                  # Master Playbook (menjalankan webserver & database)
│   ├── webserver.yml             # Playbook khusus setup Nginx & Deploy HTML Landing Page
│   └── database.yml              # Playbook khusus setup PostgreSQL utility & direktori backup
└── roles/                        # Struktur modular standar Ansible
    └── common/                   # Role dasar yang diterapkan ke semua server
        ├── tasks/main.yml        # Task instalasi curl, git, htop, ufw, timezone, MOTD
        ├── templates/motd.j2     # Template Jinja2 untuk Message of the Day (Banner Terminal)
        └── handlers/main.yml     # Handlers untuk restart service jika diperlukan
```

---

## 🛠️ Persiapan Sebelum Menjalankan Ansible

Pastikan 3 VM Kali Linux Anda sudah menyala di VirtualBox dengan ketentuan berikut:

1. **IP Address VM** (sesuaikan di file `inventory/hosts.ini` jika berbeda):
   - `kali-web-1`: `192.168.56.11`
   - `kali-web-2`: `192.168.56.12`
   - `kali-db-1` : `192.168.56.13`
2. **Layanan SSH Aktif**: Pastikan layanan OpenSSH Server sudah berjalan di ketiga VM Anda. Di terminal masing-masing VM Kali Linux, Anda bisa memastikan dengan perintah:
   ```bash
   sudo systemctl enable --now ssh
   ```
3. **Kredensial SSH**: Di file `inventory/hosts.ini`, secara default telah diatur:
   ```ini
   ansible_user=kali
   ansible_password=kali
   ```
   *(Ubah nilai tersebut jika username atau password di VM Kali Linux Anda berbeda).*

---

## 🚀 Langkah-Langkah Eksekusi Konfigurasi

Buka terminal Anda (arahkan ke direktori `c:\laragon\www\ANSIBLE\ansible`), lalu jalankan perintah berikut:

### 1. Uji Koneksi (Ping Test)
Pastikan Ansible dapat terhubung ke ketiga VM Kali Linux melalui SSH:
```bash
ansible all -m ping
```
*Jika berhasil, output akan menampilkan status `SUCCESS` dengan respon `"pong"` dari ketiga VM.*

### 2. Jalankan Master Playbook (Konfigurasi Otomatis)
Eksekusi otomatisasi penuh untuk mengonfigurasi Web Server dan Database Server:
```bash
ansible-playbook playbooks/site.yml
```

### 💡 Apa yang Dilakukan Ansible Saat Perintah di Atas Dijalankan?
1. **Mengeksekusi Role `common` (di 3 VM)**: Mengupdate `apt cache`, menginstall `curl`, `git`, `htop`, `ufw`, mengatur timezone ke `Asia/Jakarta`, dan memasang banner terminal (MOTD) kustom.
2. **Mengeksekusi Playbook `webserver.yml` (di 2 VM Web)**: Menginstall Nginx, menyalakan service Nginx, dan men-deploy halaman web HTML berpenampilan modern yang menampilkan nama masing-masing server.
3. **Mengeksekusi Playbook `database.yml` (di 1 VM DB)**: Menginstall utilitas PostgreSQL client, membuat direktori `/var/backups/postgres`, dan mencatat log inisialisasi server.

---

## 🖥️ Verifikasi Hasil Konfigurasi

Setelah playbook selesai dijalankan, Anda bisa langsung membuka browser atau menggunakan `curl` untuk melihat hasil konfigurasi web server di VM target:

```bash
curl http://192.168.56.11
curl http://192.168.56.12
```

---
*Developed with ❤️ for Advanced Infrastructure Automation.*
