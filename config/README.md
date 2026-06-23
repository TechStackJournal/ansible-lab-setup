# config/

This directory contains optional configuration files for the Ansible control node.

| File | What it does | Where to put it |
|------|-------------|-----------------|
| `.vimrc` | Vim settings tuned for YAML and Ansible editing — 2-space indent, tab visibility, paste mode toggle | `/home/ansible/.vimrc` |
| `.bashrc` | Shell aliases for `ansible-playbook`, `ansible-vault`, `ansible-navigator`, and Vagrant, plus a coloured prompt with git branch display | Append to `/home/ansible/.bashrc` |

## Applying the files

SSH into the control node and run as the `ansible` user:

```bash
# .vimrc — copy directly (overwrites any existing file)
cp /vagrant/config/.vimrc ~/.vimrc

# .bashrc — append so existing content is preserved
cat /vagrant/config/.bashrc >> ~/.bashrc
source ~/.bashrc
```

> **Note:** The synced folder (`/vagrant`) is disabled by default in the Vagrantfile. To transfer these files without re-enabling it, see the customisation section in [docs/VAGRANTFILE-REFERENCE.md](../docs/VAGRANTFILE-REFERENCE.md).

## Highlights

**.vimrc**
- 2-space soft tabs (mandatory for valid YAML)
- `set list` with `listchars` — makes stray tabs and trailing spaces visible as `▸` and `·`
- `F2` toggles paste mode — prevents auto-indent from corrupting pasted YAML blocks
- Trailing whitespace stripped automatically on save for `.yml`, `.yaml`, `.ini`, `.cfg`
- Undo history persists across file closes

**.bashrc**
- `aping` — pings all Ansible hosts in one command
- `play <playbook>` — runs a playbook with the standard lab inventory pre-filled
- `nav <playbook>` — runs via ansible-navigator
- `apc` / `apdiff` — dry-run and diff shortcuts
- `ANSIBLE_INVENTORY` environment variable set — most `ansible` and `ansible-playbook` commands will pick up the inventory automatically without `-i`
