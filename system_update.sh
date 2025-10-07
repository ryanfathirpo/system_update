#!/bin/bash
#
#
user='rfathi'
basic_prep() {
  sudo apt update
  sudo apt upgrade -y
  echo "alias update='sudo apt update && sudo apt upgrade -y'" >>~/.bashrc
  echo "alias h=history" >>~/.bashrc
  sudo apt install tree -y
  # Add vim configuration
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
  sudo apt install curl nodejs npm -y
}
# Add Docker's official GPG key:
docker_install() {
  sudo apt-get update
  sudo apt-get install ca-certificates curl -y
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
}
python_uv_install() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "alias python=python3" >>~/.bashrc
  echo "source $HOME/.local/bin/env" >>~/.bashrc
  source ~/.bashrc

}
#echo "alias k=kubectl" >>~/.bashrc

#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
menu() {
  echo "
    System update
    *************
    1: Basic prepration
    2: Install vim config
    3: Install LazyVim
    4: Install Docker
    5: Install Kuberntes
    6: Install python-uv
    7: Exit
    "
  read -p "Select your option...> " selection
  case $selection in
  1) basic_prep ;;
  2) vim_install ;;
  3) nvim_install ;;
  4) docker_install ;;
  5) kubernetes_install ;;
  6) python_uv_install ;;
  7)
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
