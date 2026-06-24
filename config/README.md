# config/

This directory contains configuration files for the Ansible control node. There are two `.vimrc` variants — choose based on context.

| File | Purpose | Where to put it |
|------|---------|-----------------|
| `.vimrc` | Full lab config — rich feedback, whitespace visibility, split navigation, undo persistence | `/home/ansible/.vimrc` |
| `.vimrc-exam` | Lean exam config — minimal, plugin-free, only what EX294 requires | `/home/ansible/.vimrc` (on exam day) |
| `.bashrc` | Shell aliases for `ansible-playbook`, `ansible-vault`, `ansible-navigator`, and Vagrant, plus a coloured prompt with git branch display | Append to `/home/ansible/.bashrc` |

---

## Which .vimrc should I use?

| | `.vimrc` (full) | `.vimrc-exam` (lean) |
|---|---|---|
| **Best for** | Daily lab practice | EX294 exam environment |
| **Paste mode** | `F2` | `F2` + `p` |
| **Tab/trailing space visibility** | Yes (`▸` and `·`) | No |
| **Trailing whitespace auto-strip on save** | Yes | No |
| **Undo persistence across file closes** | Yes | No |
| **Cursor column highlight** | No | Yes (`cursorcolumn`) |
| **Split navigation shortcuts** | Yes | No |
| **Plugin-free / exam-safe** | Yes | Yes |

Both files correctly enforce 2-space soft tabs for YAML via `autocmd FileType yaml`.

---

## Applying the files

SSH into the control node and run as the `ansible` user.

### For daily lab practice

```bash
cp /vagrant/config/.vimrc ~/.vimrc
```

### For exam preparation (switch to the lean version)

```bash
cp /vagrant/config/.vimrc-exam ~/.vimrc
```

Switch back at any time by copying the full version again.

### .bashrc

```bash
# Append — preserves any existing content
cat /vagrant/config/.bashrc >> ~/.bashrc
source ~/.bashrc
```

> **Note:** The synced folder (`/vagrant`) is disabled by default in the Vagrantfile. To transfer these files without re-enabling it, see the customisation section in [docs/VAGRANTFILE-REFERENCE.md](../docs/VAGRANTFILE-REFERENCE.md).

---

## Highlights

**.vimrc (full)**
- 2-space soft tabs enforced via `autocmd FileType yaml`
- `set list` with `listchars` — stray tabs show as `▸`, trailing spaces as `·`
- `F2` toggles paste mode
- Trailing whitespace stripped automatically on save for `.yml`, `.yaml`, `.ini`, `.cfg`
- Undo history persists across file closes (`~/.vim/undodir`)
- Split navigation with `Ctrl-h/j/k/l`

**.vimrc-exam (lean)**
- 7 lines of config — everything is a built-in Vim setting, no plugins
- `cursorcolumn` highlights the current column — makes vertical indentation alignment errors immediately visible
- `F2` + `p` toggles paste mode — matches the key binding used in the full `.vimrc` so muscle memory transfers
- `foldlevelstart=20` keeps all folds open so nothing is hidden when a file opens
- Safe to use in any RHCE/EX294 exam environment

**.bashrc**
- `aping` — pings all Ansible hosts in one command
- `play <playbook>` — runs a playbook with the standard lab inventory pre-filled
- `nav <playbook>` — runs via ansible-navigator
- `apc` / `apdiff` — dry-run and diff shortcuts
- `ANSIBLE_INVENTORY` environment variable set — most `ansible` and `ansible-playbook` commands pick up the inventory automatically without `-i`
