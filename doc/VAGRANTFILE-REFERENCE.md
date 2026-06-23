# Vagrantfile Reference

This document explains every setting in the `Vagrantfile` line by line. It is intended for people who are new to Vagrant and want to understand what the file actually does before running it.

---

## Table of contents

1. [Top-level constants](#1-top-level-constants)
2. [Global VM settings](#2-global-vm-settings)
3. [Control node definition](#3-control-node-definition)
4. [Control node provisioning script](#4-control-node-provisioning-script)
5. [Managed node definitions](#5-managed-node-definitions)
6. [Managed node provisioning script](#6-managed-node-provisioning-script)
7. [Network layout reference](#7-network-layout-reference)
8. [Customising the Vagrantfile](#8-customising-the-vagrantfile)

---

## 1. Top-level constants

```ruby
VAGRANT_API_VERSION = "2"

CONTROL_HOSTNAME = "control"
MANAGED_NODES    = %w[node1 node2 node3 node4 node5]

CONTROL_IP_BASE  = "192.168.56.10"
NODE_IP_BASE     = "192.168.56.2"

CONTROL_RAM_MB   = 2048
NODE_RAM_MB      = 1500
CONTROL_CPUS     = 2
NODE_CPUS        = 1
```

These are Ruby constants defined at the top so you can change your lab topology in one place rather than hunting through the file.

| Constant | Value | What it controls |
|----------|-------|-----------------|
| `VAGRANT_API_VERSION` | `"2"` | The Vagrant configuration schema version — always `"2"` for modern Vagrant |
| `CONTROL_HOSTNAME` | `"control"` | The hostname and Vagrant VM name for the control node |
| `MANAGED_NODES` | `%w[node1 ... node5]` | Ruby array shorthand — produces `["node1", "node2", "node3", "node4", "node5"]` |
| `CONTROL_IP_BASE` | `192.168.56.10` | Static IP assigned to the control node |
| `NODE_IP_BASE` | `192.168.56.2` | IP prefix for managed nodes — combined with index to produce `.21`, `.22`, etc. |
| `CONTROL_RAM_MB` | `2048` | RAM in MB for the control node (needs more for ansible-navigator + Podman) |
| `NODE_RAM_MB` | `1500` | RAM in MB for each managed node (python3 only, lighter load) |
| `CONTROL_CPUS` | `2` | vCPU count for the control node |
| `NODE_CPUS` | `1` | vCPU count for each managed node |

> **To reduce memory usage**, lower `NODE_RAM_MB` to `1024`. Managed nodes only need Python installed — they are not running Ansible itself.

---

## 2. Global VM settings

```ruby
Vagrant.configure(VAGRANT_API_VERSION) do |config|
  config.vm.box = "almalinux/9"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.ssh.insert_key = true
```

These settings apply to **every VM** defined inside this block.

| Setting | What it does |
|---------|-------------|
| `Vagrant.configure("2") do \|config\|` | Opens the Vagrant configuration block; `config` is the object you call settings on |
| `config.vm.box = "almalinux/9"` | The base box to use — downloaded from Vagrant Cloud on first run |
| `config.vm.synced_folder ".", "/vagrant", disabled: true` | Disables the default shared folder between your Windows host and the VMs. Disabled here to keep the lab self-contained and avoid VirtualBox Guest Additions dependency issues |
| `config.ssh.insert_key = true` | Vagrant replaces the default insecure SSH keypair with a unique per-machine key for each VM |

> **Re-enabling the synced folder:** If you want to transfer files between your Windows host and the VMs, change `disabled: true` to `disabled: false`. You may need to install the `vagrant-vbguest` plugin to handle Guest Additions automatically: `vagrant plugin install vagrant-vbguest`.

---

## 3. Control node definition

```ruby
config.vm.define CONTROL_HOSTNAME do |control|
  control.vm.hostname = CONTROL_HOSTNAME
  control.vm.network "private_network", ip: CONTROL_IP_BASE

  control.vm.provider "virtualbox" do |vb|
    vb.name   = "ansible-#{CONTROL_HOSTNAME}"
    vb.memory = CONTROL_RAM_MB
    vb.cpus   = CONTROL_CPUS
  end
```

| Setting | What it does |
|---------|-------------|
| `config.vm.define CONTROL_HOSTNAME` | Registers a VM named `"control"` — this is the name used in `vagrant ssh control` and `vagrant up control` |
| `control.vm.hostname` | Sets the Linux hostname inside the VM (what you see in the shell prompt) |
| `control.vm.network "private_network", ip: ...` | Creates a host-only network interface with a static IP. All VMs on this network can reach each other; your Windows host can also reach them at these IPs |
| `vb.name` | The display name in the VirtualBox Manager GUI |
| `vb.memory` | RAM allocated in MB |
| `vb.cpus` | Virtual CPU cores allocated |

---

## 4. Control node provisioning script

The provisioning script runs automatically inside the VM the first time `vagrant up` is called, as `root`.

```bash
set -e
```

| Command | What it does |
|---------|-------------|
| `set -e` | Exit immediately if any command returns a non-zero status — prevents silent failures mid-script |

```bash
sudo dnf -y update
sudo dnf -y install git vim python3 podman ansible-core
```

| Package | Why it's installed |
|---------|-------------------|
| `git` | Version control — needed to clone practice repos |
| `vim` | Text editor — the `.vimrc` in `config/` customises it for YAML |
| `python3` | Required by Ansible for running modules |
| `podman` | Container engine — used by ansible-navigator to run execution environments |
| `ansible-core` | The core Ansible engine (`ansible`, `ansible-playbook`, `ansible-vault`, etc.) |

```bash
sudo useradd -m ansible || true
echo "ansible:ansible" | sudo chpasswd
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible
```

| Command | What it does |
|---------|-------------|
| `useradd -m ansible \|\| true` | Creates the `ansible` user with a home directory; `\|\| true` prevents script failure if the user already exists |
| `echo "ansible:ansible" \| sudo chpasswd` | Sets the `ansible` user's password to `ansible` — used for initial SSH key distribution to managed nodes |
| `echo "ansible ALL=(ALL) NOPASSWD: ALL" \| sudo tee /etc/sudoers.d/ansible` | Grants the `ansible` user passwordless `sudo` — required for Ansible to run privileged tasks on managed nodes without interactive prompts |

> **Security note:** The `ansible:ansible` password and passwordless sudo are intentional for a local lab. Do not replicate this in production environments.

```bash
sudo -u ansible ssh-keygen -t rsa -b 4096 -N "" -f /home/ansible/.ssh/id_rsa
```

| Flag | What it does |
|------|-------------|
| `-u ansible` | Runs the command as the `ansible` user, so the key is created with correct ownership |
| `-t rsa` | Key type: RSA |
| `-b 4096` | Key length: 4096 bits |
| `-N ""` | Empty passphrase — allows Ansible to use the key without any interactive prompt |
| `-f /home/ansible/.ssh/id_rsa` | Output path for the private key (public key is written to `id_rsa.pub` automatically) |

```bash
sudo -u ansible mkdir -p /home/ansible/ansible-lab
sudo -u ansible touch /home/ansible/ansible-lab/inventory.ini
```

Creates the working directory and an empty inventory file for the `ansible` user. Populate `inventory.ini` with your managed node details after the lab is running.

```bash
sudo podman pull quay.io/ansible/creator-ee:latest || true
```

Pulls the `creator-ee` execution environment image from Red Hat's Quay registry. The `|| true` prevents a slow or failed network connection from aborting the entire provisioning run. If this fails silently, re-pull manually: `sudo podman pull quay.io/ansible/creator-ee:latest`.

```bash
cat <<EOF | sudo tee /home/ansible/ansible-navigator.yml
---
ansible-navigator:
  execution-environment:
    enabled: true
    container-engine: podman
    image: quay.io/ansible/creator-ee:latest
    pull:
      policy: missing
  inventory:
    entries:
      - /home/ansible/ansible-lab/inventory.ini
EOF
```

Writes the `ansible-navigator` configuration file. Key settings explained:

| Setting | What it does |
|---------|-------------|
| `execution-environment.enabled: true` | Tells ansible-navigator to run playbooks inside a container rather than on the host directly |
| `container-engine: podman` | Use Podman (not Docker) as the container runtime |
| `image: quay.io/ansible/creator-ee:latest` | The execution environment image to use |
| `pull.policy: missing` | Only pull the image if it is not already present locally — avoids re-downloading on every run |
| `inventory.entries` | Points ansible-navigator at your inventory file so you do not have to specify `-i` on every command |

```bash
sudo chown -R ansible:ansible /home/ansible
```

Recursively sets ownership of everything in `/home/ansible` to the `ansible` user. Necessary because some files above were created by `root` (via `sudo tee`).

---

## 5. Managed node definitions

```ruby
MANAGED_NODES.each_with_index do |name, index|
  config.vm.define name do |node|
    node.vm.hostname = name
    node.vm.network "private_network", ip: "#{NODE_IP_BASE}#{index + 1}"

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "ansible-#{name}"
      vb.memory = NODE_RAM_MB
      vb.cpus   = NODE_CPUS
    end
```

| Part | What it does |
|------|-------------|
| `MANAGED_NODES.each_with_index` | Loops through `["node1"..."node5"]`; `index` is `0` through `4` |
| `ip: "#{NODE_IP_BASE}#{index + 1}"` | Builds IPs: `192.168.56.21`, `192.168.56.22`, etc. (`NODE_IP_BASE` = `"192.168.56.2"`, index+1 = `1` through `5`) |

---

## 6. Managed node provisioning script

```bash
sudo dnf -y update
sudo dnf -y install python3
```

Managed nodes only need Python 3 — Ansible on the control node connects over SSH and uses Python on the remote host to execute modules.

```bash
sudo useradd -m ansible || true
echo "ansible:ansible" | sudo chpasswd
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible
```

Same user setup as the control node. The `ansible` user must exist on managed nodes with the same credentials so `ssh-copy-id` and subsequent Ansible connections work.

```bash
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
sudo systemctl restart sshd || true
```

| Command | What it does |
|---------|-------------|
| `sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/'` | Edits `/etc/ssh/sshd_config` in-place; the `^` anchors the match to the start of the line to avoid false matches |
| `systemctl restart sshd` | Restarts the SSH daemon so the config change takes effect |

This is required because AlmaLinux 9's default `sshd_config` disables password authentication. Without this change, `ssh-copy-id` cannot connect to copy the public key.

---

## 7. Network layout reference

```
192.168.56.0/24  (VirtualBox host-only network)
│
├── 192.168.56.10   control   (Ansible control node)
├── 192.168.56.21   node1
├── 192.168.56.22   node2
├── 192.168.56.23   node3
├── 192.168.56.24   node4
└── 192.168.56.25   node5
```

All VMs are on the same `/24` subnet. The control node can reach all managed nodes by IP. Your Windows host can also SSH to any VM at these IPs directly (useful for `scp` file transfers).

---

## 8. Customising the Vagrantfile

All common changes are made by editing the constants at the top of the file.

**Add more managed nodes:**

```ruby
MANAGED_NODES = %w[node1 node2 node3 node4 node5 node6 node7]
```

**Reduce memory on the managed nodes (if RAM is limited):**

```ruby
NODE_RAM_MB = 1024
```

**Use a different base box (e.g. Rocky Linux 9):**

```ruby
config.vm.box = "rockylinux/9"
```

**Re-enable the synced folder (to transfer files from Windows):**

```ruby
config.vm.synced_folder ".", "/vagrant", disabled: false
```

After any change to the Vagrantfile, run `vagrant reload` to apply hardware/network changes to already-running VMs, or `vagrant destroy -f && vagrant up` for a clean rebuild.

---

◀ Previous: [Setup Guide](SETUP-GUIDE.md) &nbsp;|&nbsp; Back to [README](../README.md)
