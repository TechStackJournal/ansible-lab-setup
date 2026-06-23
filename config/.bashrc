# ============================================================
# .bashrc — Ansible lab additions for the control node
# Append to /home/ansible/.bashrc with:
#   cat /vagrant/config/.bashrc >> ~/.bashrc && source ~/.bashrc
# ============================================================

# --- Colour prompt: user@host:dir (git branch if available) ---
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/\* //'
}

export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(b=$(parse_git_branch); [ -n "$b" ] && echo " ($b)")\[\e[0m\]\$ '
# Green user@host, blue working directory, yellow git branch

# --- Ansible shortcuts ---
alias ap='ansible-playbook'                          # ap site.yml
alias apv='ansible-playbook --syntax-check'          # apv site.yml  (syntax check only)
alias aps='ansible-playbook --step'                  # aps site.yml  (confirm each task)
alias apc='ansible-playbook --check'                 # apc site.yml  (dry run)
alias apdiff='ansible-playbook --check --diff'       # apdiff site.yml  (dry run + show diffs)
alias av='ansible-vault'                             # av encrypt vars/secrets.yml
alias ave='ansible-vault encrypt'                    # ave vars/secrets.yml
alias avd='ansible-vault decrypt'                    # avd vars/secrets.yml
alias ave='ansible-vault edit'                       # ave vars/secrets.yml
alias avv='ansible-vault view'                       # avv vars/secrets.yml
alias ang='ansible-navigator'                        # ang run site.yml
alias angr='ansible-navigator run'                   # angr site.yml
alias angi='ansible-navigator images'                # angi  (list EE images)
alias angc='ansible-navigator collections'           # angc  (list collections)
alias ainv='ansible-inventory --list'                # ainv  (show inventory as JSON)
alias aping='ansible all -m ping'                    # aping (ping all hosts)
alias afacts='ansible all -m setup'                  # afacts (gather facts from all hosts)
alias agather='ansible all -m gather_facts'          # alias for setup

# Quick ad-hoc command with inventory pre-filled
# Usage: arun all -m command -a "uptime"
arun() {
  ansible -i /home/ansible/ansible-lab/inventory.ini "$@"
}

# Run a playbook with the standard inventory
# Usage: play site.yml
play() {
  ansible-playbook -i /home/ansible/ansible-lab/inventory.ini "$@"
}

# Run a playbook with ansible-navigator
# Usage: nav site.yml
nav() {
  ansible-navigator run "$@"
}

# --- Vagrant shortcuts (useful if you SSH to control and want reminders) ---
alias vup='vagrant up'
alias vhalt='vagrant halt'
alias vssh='vagrant ssh'
alias vstatus='vagrant status'
alias vsuspend='vagrant suspend'
alias vresume='vagrant resume'
alias vreload='vagrant reload'
alias vprovision='vagrant provision'
alias vdestroy='vagrant destroy -f'
alias vsnap='vagrant snapshot'

# --- Lab inventory shortcut ---
export ANSIBLE_INVENTORY=/home/ansible/ansible-lab/inventory.ini
# Means you don't need -i on ansible commands (ansible-playbook picks it up from env)

# --- ansible-navigator config location ---
export ANSIBLE_NAVIGATOR_CONFIG=/home/ansible/ansible-navigator.yml

# --- Useful ls aliases ---
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# --- Safety nets ---
alias rm='rm -i'            # Prompt before deleting
alias cp='cp -i'            # Prompt before overwriting
alias mv='mv -i'            # Prompt before overwriting

# --- Misc helpers ---
alias h='history | tail -30'           # Last 30 commands
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias myip='hostname -I'               # Show all IPs for this VM
alias ports='ss -tulnp'                # Show listening ports
alias psg='ps aux | grep'              # psg ansible — find process by name

# --- Lab summary on login ---
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  Ansible Lab — Control Node              │"
echo "  │  ansible-core: $(ansible --version 2>/dev1/null | head -1 | awk '{print $3}' || echo 'not found')                  │"
echo "  │  Inventory:    \$ANSIBLE_INVENTORY        │"
echo "  │                                          │"
echo "  │  Quick commands:                         │"
echo "  │    aping        ping all nodes           │"
echo "  │    play X.yml   run playbook             │"
echo "  │    nav  X.yml   run via navigator        │"
echo "  └─────────────────────────────────────────┘"
echo ""

# ============================================================
# Alias reference
# ============================================================
# ap        ansible-playbook
# apv       ansible-playbook --syntax-check
# aps       ansible-playbook --step
# apc       ansible-playbook --check (dry run)
# apdiff    ansible-playbook --check --diff
# av        ansible-vault
# ang       ansible-navigator
# angr      ansible-navigator run
# angi      ansible-navigator images
# ainv      ansible-inventory --list
# aping     ansible all -m ping
# afacts    ansible all -m setup
# arun      ansible with standard inventory (pass remaining args)
# play      ansible-playbook with standard inventory
# nav       ansible-navigator run
#
# vup/vhalt/vssh/vstatus/vreload/vdestroy  vagrant shortcuts
# ============================================================
