#!/bin/bash

# Ask for sudo access at start of script
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Add private keys of repos
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub

# Add repos
sudo zypper -n addrepo https://packages.microsoft.com/yumrepos/vscode VSCode
sudo zypper -n addrepo https://brave-browser-rpm-release.s3.brave.com/x86_64/ Brave-Browser
sudo zypper -n addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome

# Initial upgrade of system
sudo zypper -n refresh
sudo zypper -n update

# Installations
## Essential
sudo zypper -n install gnome-extensions
sudo zypper -n install neovim
sudo zypper -n install curl
sudo zypper -n install git
sudo zypper -n install zsh

### nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
source ~/.bashrc
nvm install --lts

### npm global packages
npm install -g tldr # summary of 'man'
npm install -g yo # yeoman for scaffolding
npm install -g how-2 # stackoverflow for the terminal

## C/CPP Specific
sudo zypper -n install gcc
sudo zypper -n install gdb

## Programming Languages/Tools
sudo zypper -n install docker
sudo zypper -n install python3-docker-compose

## Enable docker
sudo systemctl enable docker
sudo usermod -G docker -a $USER
sudo systemctl restart docker

## Desktop Apps
sudo zypper -n install tilix
sudo zypper -n install telegram-desktop
sudo zypper -n install code
sudo zypper -n install brave-browser
sudo zypper -n install google-chrome-stable

# Other Options
## Switch from wayland to xorg
sudo sed /etc/gdm/custom.conf -i -e \
    's/#WaylandEnable=false/WaylandEnable=false/g'

## Change default resolution of grub menu on boot
sudo sed 's/#GRUB_GFXMODE="[[:digit:]]\+x[[:digit:]]\+"/GRUB_GFXMODE="1920x1080"/' /etc/default/grub
sudo update-grub

## git configurations
git config --global user.email "pa_perz@outlook.es"
git config --global user.name "PabloPerezPerez"
git config --system core.editor "nvim"

## git aliases
git config --global alias.co checkout
git config --global alias.a add
git config --global alias.b branch
git config --global alias.c commit
git config --global alias.l log
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'

## Add Spanish keyboard input
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'es')]"

## Set default wallpaper
mkdir -p $HOME/Pictures/Wallpapers
cp ./default_wallpaper.jpg $HOME/Pictures/Wallpapers/
gsettings set org.gnome.desktop.background picture-uri \
  "file://$HOME/Pictures/Wallpapers/default_wallpaper.jpg"

## Change hostname
hostnamectl set-hostname 'hive'

## Config zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

# Add dotfiles
git clone --recurse-submodules https://github.com/pa-perz/dotfiles
cd dotfiles && ./install.sh
rm -rf dotfiles

## Run oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
