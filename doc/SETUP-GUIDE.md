# Ansible Lab Setup Guide — Windows 10/11

This guide walks you through every step to get a fully working 6-VM Ansible lab running on your Windows machine using VirtualBox and Vagrant.

By the end you will have one Ansible control node and five managed nodes, all networked together and ready for practice.

---

## Table of contents

1. [Prerequisites and system requirements](#1-prerequisites-and-system-requirements)
2. [Install VirtualBox and the Extension Pack](#2-install-virtualbox-and-the-extension-pack)
3. [Install Vagrant](#3-install-vagrant)
4. [Enable virtualisation in BIOS/UEFI](#4-enable-virtualisation-in-biosuefi)
5. [Clone or download this repository](#5-clone-or-download-this-repository)
6. [Start the lab with vagrant up](#6-start-the-lab-with-vagrant-up)
7. [Verify all VMs are running](#7-verify-all-vms-are-running)
8. [Connect to the control node](#8-connect-to-the-control-node)
9. [Distribute SSH keys to managed nodes](#9-distribute-ssh-keys-to-managed-nodes)
10. [Apply the optional config files](#10-apply-the-optional-config-files)
11. [Day-to-day lab commands](#11-day-to-day-lab-commands)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Prerequisites and system requirements

Before you begin, confirm your machine meets these requirements:

| Item | Minimum | Recommended |
|------|---------|-------------|
| OS | Windows 10 64-bit | Windows 11 64-bit |
| RAM | 16 GB | 24 GB or more |
| Disk | 25 GB free | 40 GB free (SSD preferred) |
| CPU | Intel/AMD with VT-x or AMD-V | Any modern multi-core |
| Internet | Required for first run | Broadband (box download ~1 GB) |

> **Note on RAM:** All 6 VMs together use approximately 9.5 GB RAM (2 GB for control + 5 × 1.5 GB for nodes). Windows itself needs 4–6 GB. 16 GB total is workable; 8 GB will struggle.

---

## 2. Install VirtualBox and the Extension Pack

VirtualBox is the hypervisor that creates and runs your virtual machines.

### Step 2a — Download VirtualBox

1. Go to [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
2. Click **Windows hosts** under the latest 7.x release
3. Run the downloaded installer and accept all defaults

### Step 2b — Download and install the Extension Pack

The Extension Pack is required for USB support and proper host-only networking.

1. On the same downloads page, find **VirtualBox Extension Pack** — click the link that says **All supported platforms**
2. Double-click the downloaded `.vbox-extpack` file — VirtualBox will open and prompt you to install it
3. Accept the licence agreement

### Verify the installation

Open **VirtualBox Manager**. The window should open without errors and show an empty VM list.

---

## 3. Install Vagrant

Vagrant is the tool that reads the `Vagrantfile` and automates VM creation.

1. Go to [https://developer.hashicorp.com/vagrant/downloads](https://developer.hashicorp.com/vagrant/downloads)
2. Select **Windows** and download the latest **AMD64** installer
3. Run the `.msi` installer and accept all defaults
4. **Restart your computer** when prompted — this is required for the PATH update to take effect

### Verify the installation

Open **PowerShell** and run:

```powershell
vagrant --version
```

Expected output (version number will vary):

```
Vagrant 2.4.1
```

---

## 4. Enable virtualisation in BIOS/UEFI

If VirtualBox gives an error about virtualisation not being enabled, you need to turn it on in your firmware settings.

> **Skip this step if vagrant up completes without errors.** Many machines have this enabled by default.

### How to access BIOS/UEFI on Windows 10/11

1. Go to **Settings → System → Recovery**
2. Under **Advanced startup**, click **Restart now**
3. Choose **Troubleshoot → Advanced options → UEFI Firmware Settings → Restart**

### What to look for

The setting is under different menus depending on your manufacturer:

| Manufacturer | Menu location | Setting name |
|---|---|---|
| Intel | Advanced → CPU Configuration | Intel Virtualization Technology (VT-x) |
| AMD | Advanced → CPU Configuration | SVM Mode or AMD-V |
| Dell | Virtualization Support | Virtualization |
| HP | Security → System Security | Virtualization Technology |

Set it to **Enabled**, save, and reboot.

---

## 5. Clone or download this repository

Open **PowerShell** and run:

```powershell
git clone https://github.com/YOUR_USERNAME/ansible-lab-setup.git
cd ansible-lab-setup
```

**Breakdown:**

| Part | What it does |
|------|-------------|
| `git clone` | Downloads the repo from GitHub to your machine |
| `https://github.com/...` | The URL of this repository |
| `cd ansible-lab-setup` | Moves your terminal into the downloaded folder |

> **No Git installed?** Download it from [https://git-scm.com/download/win](https://git-scm.com/download/win) and reopen PowerShell after installing.

Alternatively, click **Code → Download ZIP** on GitHub, extract it, and `cd` into the extracted folder.

---

## 6. Start the lab with vagrant up

From inside the `ansible-lab-setup` directory, run:

```powershell
vagrant up
```

What happens:

1. Vagrant downloads the `almalinux/9` box from Vagrant Cloud (~900 MB, first time only)
2. VirtualBox creates 6 VMs and boots them
3. Each VM runs its provisioning script automatically — installing packages, creating the `ansible` user, and configuring SSH

**This will take 10–20 minutes on the first run** depending on your internet speed and machine performance. Subsequent `vagrant up` calls (when VMs already exist) take under 2 minutes.

You will see a lot of output scroll by — this is normal. Look for errors starting with `==> control: Error` or `==> node1: Error` if something goes wrong.

---

## 7. Verify all VMs are running

```powershell
vagrant status
```

Expected output:

```
Current machine states:

control                   running (virtualbox)
node1                     running (virtualbox)
node2                     running (virtualbox)
node3                     running (virtualbox)
node4                     running (virtualbox)
node5                     running (virtualbox)

This environment represents multiple VMs.
```

---

## 8. Connect to the control node

```powershell
vagrant ssh control
```

**Breakdown:**

| Part | What it does |
|------|-------------|
| `vagrant ssh` | Opens an SSH session into a VM |
| `control` | The name of the VM defined in the Vagrantfile |

You will land as the `vagrant` user. Switch to the `ansible` user for all Ansible work:

```bash
sudo su - ansible
```

Verify Ansible is installed:

```bash
ansible --version
ansible-navigator --version
```

---

## 9. Distribute SSH keys to managed nodes

The control node generated an SSH key pair during provisioning. You now need to copy the public key to all five managed nodes so Ansible can connect without a password.

From inside the control node as the `ansible` user:

```bash
for node in node1 node2 node3 node4 node5; do
  ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@192.168.56.2${node: -1}
done
```

When prompted for a password, enter `ansible` (this is the password set during provisioning).

**Breakdown:**

| Part | What it does |
|------|-------------|
| `for node in ...` | Loops through each node name |
| `ssh-copy-id` | Copies your public key to the remote host's `authorized_keys` |
| `-i ~/.ssh/id_rsa.pub` | Specifies which public key to copy |
| `ansible@192.168.56.2...` | The user and IP address on each managed node |

### Verify key-based access

```bash
ansible all -i /home/ansible/ansible-lab/inventory.ini -m ping
```

You should see `pong` back from all five nodes with no password prompt.

---

## 10. Apply the optional config files

The `config/` directory contains `.vimrc` and `.bashrc` files tuned for Ansible work.

From inside the control node as the `ansible` user:

```bash
# Copy .vimrc
cp /vagrant/config/.vimrc ~/.vimrc

# Copy .bashrc (appends to existing, does not replace)
cat /vagrant/config/.bashrc >> ~/.bashrc
source ~/.bashrc
```

> **Note:** The synced folder is disabled in this Vagrantfile. To transfer these files you can either re-enable it, use `scp` from the host, or paste the contents manually. See [docs/VAGRANTFILE-REFERENCE.md](VAGRANTFILE-REFERENCE.md) for details on the synced folder setting.

---

## 11. Day-to-day lab commands

Run all of these from your Windows PowerShell inside the repo directory.

| Command | What it does |
|---------|-------------|
| `vagrant up` | Start all VMs (or specific one: `vagrant up control`) |
| `vagrant halt` | Gracefully shut down all VMs |
| `vagrant suspend` | Pause all VMs (saves RAM to disk, fast resume) |
| `vagrant resume` | Resume suspended VMs |
| `vagrant reload` | Restart VMs and re-apply Vagrantfile network/hardware changes |
| `vagrant provision` | Re-run provisioning scripts without destroying VMs |
| `vagrant destroy -f` | Delete all VMs and their disks completely |
| `vagrant ssh control` | SSH into the control node |
| `vagrant ssh node1` | SSH into node1 |
| `vagrant status` | Show current state of all VMs |
| `vagrant snapshot save NAME` | Save a snapshot of all VMs |
| `vagrant snapshot restore NAME` | Restore a snapshot |

---

## 12. Troubleshooting

### VMs fail to start — "VT-x is not available"

Virtualisation is not enabled in BIOS/UEFI. See [Section 4](#4-enable-virtualisation-in-biosuefi).

### vagrant up hangs or times out during provisioning

- Check that your VirtualBox Host-Only Network adapter exists: open VirtualBox → **File → Tools → Network Manager** and confirm a `192.168.56.0/24` host-only network exists
- Retry: `vagrant provision control` to re-run just the provisioning step

### SSH key distribution fails — "Connection refused" or "Permission denied"

- Confirm `PasswordAuthentication yes` is set on the node: `vagrant ssh node1` → `sudo grep PasswordAuthentication /etc/ssh/sshd_config`
- If it reads `no`, run: `sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart sshd`

### ansible-navigator cannot pull the execution environment image

The `creator-ee` pull happens at provision time but can fail on slow or restricted connections. Re-pull manually from the control node:

```bash
sudo podman pull quay.io/ansible/creator-ee:latest
```

### Everything is broken — clean reset

```powershell
vagrant destroy -f
vagrant up
```

This deletes all VMs and starts fresh. Your `Vagrantfile` and any files on your Windows host are unaffected.

---

◀ Back to [README](../README.md) &nbsp;|&nbsp; ▶ Next: [Vagrantfile Reference](VAGRANTFILE-REFERENCE.md)
