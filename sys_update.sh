#!/bin/bash
#
#
os_type() {
  dis_type=$(hostnamectl | grep Operating | awk '{print $3}')
  if [[ $dis_type == 'Red' || $dis_type == 'Fedora' ]]; then
    echo 'dnf'
  else
    echo 'apt'
  fi
}

OSINSTALLER=$(os_type)
user=rfathi

# Simple script to get local active IP addresses
get_local_ips() {
  # Try ip command first (Linux)
  if command -v ip &>/dev/null; then
    ip -4 addr show | grep -E 'inet ' | awk '{print $2}' | cut -d/ -f1 | grep -e '10\.6\.53\.' -e '10\.7\.31\.' # If you want all the addresses use: grep -v '^127\.' anything but 127
  # Fallback to ifconfig (macOS/BSD)
  elif command -v ifconfig &>/dev/null; then
    ifconfig | grep -E 'inet ' | grep -E '10\.' | awk '{print $2}'
  # Fallback to hostname
  else
    hostname -I 2>/dev/null || hostname -i 2>/dev/null || echo "Unable to determine IP"
  fi
}

basic_update() {
  if [[ $OSINSTALLER == 'apt' ]]; then
    sudo apt update && apt upgrade -y
    echo "alias update='sudo apt update && sudo apt upgrade -y'" >>~/.bashrc
    sudo apt install -y build-essential
  else
    sudo $OSINSTALLER -y update
    sudo lvresize -l +100%FREE --resizefs /dev/mapper/fedora-root
    sudo $OSINSTALLER install -y @development-tools
  fi
  echo "alias h=history" >>~/.bashrc
  echo "alias cl=clear"
  sudo $OSINSTALLER install -y tree git
  sudo $OSINSTALLER install -y ca-certificates curl
  sudo $OSINSTALLER install -y nodejs npm
  sudo $OSINSTALLER install -y bat fzf ripgrep fd-find pass jq
  IP=$(get_local_ips)
  DNS='10.7.31.5'
  ZONE='rlab.lan'
  RECORD="$HOSTNAME.rlab.lan"
  cat <<EOL | nsupdate
server $DNS
zone $ZONE
update delete $RECORD A
update add $RECORD 3600 A $IP
send
EOL
}
vim_install() {

  git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh
}
nvim_install() {
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm -rf nvim-linux-x86_64.tar.gz

  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >>~/.bashrc
  echo 'alias nv=nvim' >>~/.bashrc

}
python_uv_install() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "alias python=python3" >>~/.bashrc
  echo "alias ur='uv run'" >>~/.bashrc
  echo 'eval "$(uv generate-shell-completion bash)"' >>~/.bashrc
  echo 'eval "$(uvx --generate-shell-completion bash)"' >>~/.bashrc
  echo 'alias act="source ${PWD}/.venv/bin/activate"' >>~/.bashrc
  echo 'alias dact=deactivate' >>~/.bashrc

}
podman_install() {
  sudo $OSINSTALLER -y install podman
  sudo $OSINSTALLER -y install podman-compose
  ehco "alias pd=podman" >>~./bashrc
  echo "alisa pdc=pdoman-compose" >>~./bashrc
}

menu() {
  echo "
    System update
    ************
    1: Basic OS update
    2: Install vim config
    3: Install LazyVim
    4: Install Docker
    5: Install Kuberntes
    6: Install python-uv
    7: Install rust
    8: Setup git
    9: Install podman
    10: Exit
    "
  read -p "Select your option...> " selection
  case $selection in
  1)
    basic_update
    clear
    menu
    ;;
  2)
    vim_install
    clear
    menu
    ;;
  3)
    nvim_install
    clear
    menu
    ;;
  4)
    docker_install
    clear
    menu
    ;;
  5)
    kubernetes_install
    clear
    menu
    ;;
  6)
    python_uv_install
    clear
    menu
    ;;
  7)
    rust_install
    clear
    menu
    ;;
  8)
    git_config
    clear
    menu
    ;;
  9)
    podman_install
    clear
    menu
    ;;
  10)
    clear
    source ~/.bashrc
    exit
    ;;
  *)
    echo "Invelid Selection"
    menu
    ;;
  esac

}
clear
menu
