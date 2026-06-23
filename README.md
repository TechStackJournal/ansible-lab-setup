# ansible-lab-setup

A self-contained Vagrant + VirtualBox lab that spins up a 6-VM Ansible environment on Windows 10/11 — one control node and five managed nodes, all running AlmaLinux 9.

Built to support Red Hat EX294 / RH294 exam practice, but usable as a general Ansible learning environment.

---

## What's inside

| Path | What it is |
|------|------------|
| `Vagrantfile` | Defines and provisions all 6 VMs automatically |
| `docs/SETUP-GUIDE.md` | Step-by-step setup for Windows beginners (VirtualBox → Vagrant → `vagrant up`) |
| `docs/VAGRANTFILE-REFERENCE.md` | Line-by-line explanation of every Vagrantfile setting |
| `config/.vimrc` | Vim config tuned for YAML / Ansible editing |
| `config/.bashrc` | Bash aliases and prompt helpers for the control node |

---

## Lab topology

```
Host (Windows 10/11)
└── VirtualBox (private_network: 192.168.56.0/24)
    ├── control   192.168.56.10   2 vCPU  2 GB RAM   ansible-core + ansible-navigator + Podman
    ├── node1     192.168.56.21   1 vCPU  1.5 GB RAM  python3 only
    ├── node2     192.168.56.22   1 vCPU  1.5 GB RAM
    ├── node3     192.168.56.23   1 vCPU  1.5 GB RAM
    ├── node4     192.168.56.24   1 vCPU  1.5 GB RAM
    └── node5     192.168.56.25   1 vCPU  1.5 GB RAM
```

---

## Quick start

```powershell
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/ansible-lab-setup.git
cd ansible-lab-setup

# 2. Start all VMs (takes 10–20 min on first run)
vagrant up

# 3. SSH into the control node
vagrant ssh control

# 4. Distribute SSH keys to managed nodes
sudo -u ansible bash /home/ansible/ansible-lab/ssh-copy-keys.sh
```

Full prerequisites and troubleshooting: [docs/SETUP-GUIDE.md](docs/SETUP-GUIDE.md)

---

## Requirements

- Windows 10 or 11 (64-bit)
- VirtualBox 7.x + Extension Pack
- Vagrant 2.4+
- ~12 GB free RAM (all 6 VMs running simultaneously)
- ~25 GB free disk space

---

## Who this is for

- Sysadmins learning Ansible for the first time
- Students preparing for Red Hat EX294 / RH294
- Anyone who wants a disposable, reproducible Ansible lab without cloud costs
