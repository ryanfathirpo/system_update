#!/bin/bash
#
#
user='rfathi'
OSINSTALLER=$(os_type)
sudo $OSINSTALLER -y update
basic_update() {
  if OSINSTALLER == 'apt'; then
    sudo apt upgrade -y
    echo "alias update='sudo apt update && sudo apt upgrade -y'" >>~/.bashrc
  else
    sudo $OSINSTALLER -y update
  fi
  echo "alias h=history" >>~/.bashrc
  sudo $OSINSTALLER install -y tree
  sudo $OSINSTALLER install -y ca-certificates curl
  sudo $OSINSTALLER install -y nodejs npm
  sudo $OSINSTALLER install -y bat fzf rg fd pass jq

}
# Add vim configuration
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
# Add Docker's official GPG key:
docker_install() {
  os_type() if [[ $OSINSTALLER == Ubuntu ]]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo usermod -aG docker $user
    sudo apt install docker-compose-plugin -y
  else
    sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $user
  fi

}
python_uv_install() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "alias python=python3" >>~/.bashrc
  echo "alias ur='uv run'" >>~/.bashrc
  echo 'eval "$(uv generate-shell-completion bash)"'
  echo 'eval "$(uvx --generate-shell-completion bash)"'

}
rust_install() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  echo "source \"$HOME/.cargo/env\"" >>~/.bashrc
  source ~/.bashrc
}
# Install git if it installed, configure git
git_config() {
  if ! command -v git &>/dev/null; then
    # *************************
    # Need to figure this out
    sudo $OSINSTALLER install -y git
  fi
  git config --global user.name ryanfathirpo
  git config --global user.email "rf13430916@gmail.com"
}
podman_install() {
  sudo $OSINSTALLER -y install podman
  sudo $OSINSTALLER -y install podman-compose
  ehco "alias pd=podman" >>~./bashrc
  echo "alisa pdc=pdoman-compose" >>./bashrc
}
os_type() {
  dis_type=hostnamectl | grep Operating | awk '{print $3}'
  if [[ dis_type == 'Red' || dis_type == 'Fedora' ]]; then
    echo'dnf'
  else
    echo'apt'
  fi
}
#echo "alias k=kubectl" >>~/.bashrc

#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
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
  1) basic_update ;;
  2) vim_install ;;
  3) nvim_install ;;
  4) docker_install ;;
  5) kubernetes_install ;;
  6) python_uv_install ;;
  7) rust_install ;;
  8) git_config ;;
  9) podman_install ;;
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
