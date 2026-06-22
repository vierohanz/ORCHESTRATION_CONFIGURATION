# Orchestration Configuration Lab

Infrastruktur otomatis berbasis **AWS** yang dikelola menggunakan **Terraform** (provisioning) dan **Ansible** (konfigurasi). Terdiri dari 3 server EC2 dengan arsitektur Microservices.

---

## Arsitektur

```
Internet
   │
   ▼
┌─────────────────────────────────┐
│  Server 1 - Webserver (ubuntu-1) │
│  ┌──────────┐  ┌──────────────┐ │
│  │  Nginx   │→ │  Python Flask│ │
│  │ :80      │  │  (API) :5000 │ │
│  └──────────┘  └──────┬───────┘ │
└─────────────────────── │ ───────┘
                         │ :5701
┌─────────────────────── │ ───────┐
│  Server 3 - Cache (ubuntu-3)    │
│  ┌──────────────────────────┐   │
│  │  Hazelcast (In-Memory DB)│   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│  Server 2 - K8s Node (ubuntu-2) │
│  ┌──────────────────────────┐   │
│  │  K3s + Nginx Pod :30080  │   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

---

## Struktur Direktori

```
.
├── Makefile
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   │   ├── hosts.ini
│   │   └── group_vars/all/vars.yml
│   ├── playbooks/
│   │   ├── site.yml          # Master playbook
│   │   ├── server.yml        # Nginx + Calculator API (ubuntu-1)
│   │   ├── kubernetes.yml    # K3s cluster (ubuntu-2)
│   │   ├── cache.yml         # Hazelcast (ubuntu-3)
│   │   └── teardown.yml
│   └── roles/
│       ├── common/           # Docker, timezone, UFW
│       ├── nginx/            # Nginx + UI Kalkulator
│       ├── calculator/       # Python Flask API
│       ├── hazelcast/        # Hazelcast container
│       └── kubernetes/       # K3s + deployment
└── terraform/
    ├── main.tf               # Entry point
    ├── providers.tf          # AWS provider
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars      # Nilai non-secret
    ├── secrets.auto.tfvars   # AWS credentials (jangan commit!)
    └── modules/
        ├── compute/          # EC2 instance
        └── security/         # Key Pair + Security Group
```

---

## Prerequisites

- WSL (Ubuntu) dengan Ansible terinstall
- SSH key sudah digenerate di `~/.ssh/orchest_key`
- AWS credentials tersimpan di `terraform/secrets.auto.tfvars`

---

## Cara Penggunaan

### Provisioning Infrastruktur (Terraform)

```bash
make tf-init     # Download provider AWS
make tf-plan     # Preview perubahan
make tf-apply    # Buat server EC2 di AWS
```

Setelah `tf-apply` selesai, update IP server baru di `ansible/inventory/hosts.ini`.

### Deploy Aplikasi (Ansible)

```bash
make ping        # Uji koneksi SSH ke semua server
make deploy      # Deploy semua aplikasi
make teardown    # Hapus semua konfigurasi
```

### Destroy Infrastruktur

```bash
make tf-destroy  # Matikan dan hapus semua server EC2
```

---

## Hasil Deploy

| Layanan | URL |
|---------|-----|
| Kalkulator UI | `http://<ubuntu-1-ip>` |
| Calculator API | `http://<ubuntu-1-ip>:5000/calc?op=add&a=10&b=5` |
| Kubernetes Hello World | `http://<ubuntu-2-ip>:30080` |
| Hazelcast | `<ubuntu-3-ip>:5701` |

---

## Cek Status Server

```bash
# Cek container yang berjalan di Server 1
ansible ubuntu_1 -i ansible/inventory/hosts.ini -b -m shell -a "docker ps"

# Cek status K3s di Server 2
ansible ubuntu_2 -i ansible/inventory/hosts.ini -b -m shell -a "kubectl get nodes && kubectl get pods"

# Cek Hazelcast di Server 3
ansible ubuntu_3 -i ansible/inventory/hosts.ini -b -m shell -a "docker ps"
```

Atau masuk langsung via SSH:
```bash
ssh -i ~/.ssh/orchest_key ubuntu@<IP_SERVER>
```
