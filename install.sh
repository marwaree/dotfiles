#!/usr/bin/bash

echo "Installing yay..."
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si

echo "Installing required packages..."
sudo pacman -S meson gcc cpio sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg pamixer fzf hyprpolkitagent swww mako rofi nautilus waybar wl-clipboard stow firefox ttf-cascadia-mono-nerd neovim matugen fastfetch zsh hypridle eza zoxide bat impala bluetui hyprlock wget ghostty

yay -S rmtrash sddm-silent-theme python-pywalfox hyprshot-git

sudo pywalfox install

hyprpm update

hyprpm add https://github.com/zjeffer/split-monitor-workspaces # Add the plugin repository
hyprpm enable split-monitor-workspaces                         # Enable the plugin
hyprpm reload                                                  # Reload the plugins

mkdir ~/Pictures/Screenshots
export HYPRSHOT_DIR="~/Pictures/Screenshots"

chsh -s /usr/bin/zsh

read -p "Do you want to remove unnecesary packages for the dotfiles? (Y/n): " choice

case "$choice" in
y | Y | yes | Yes | YES)
  sudo pacman -Rns dunst wofi dolphin kitty
  ;;
n | N | no | No | NO) ;;
*)
  sudo pacman -Rns dunst wofi dolphin kitty
  ;;
esac

stow .
sudo stow . -t /root

read -p "Do you want to install the astronaut sddm theme? (Y/n): " choice

case "$choice" in
y | Y | yes | Yes | YES)

  sudo cp -r ~/.dotfiles/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme/
  # Configure SDDM
  echo "[Theme]
        Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null

  sudo mkdir -p /etc/sddm.conf.d
  echo "[General]
        InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

  info "Theme installed"
  ;;
n | N | no | No | NO) ;;
*)

  sudo cp -r sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme/
  # Configure SDDM
  echo "[Theme]
        Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null

  sudo mkdir -p /etc/sddm.conf.d
  echo "[General]
        InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

  info "Theme installed"
  ;;
esac

read -p "Finished installation. Do you want to exit hyprland to apply the changes now? (Y/n): " choice

case "$choice" in
y | Y | yes | Yes | YES)
  pkill hyprland
  ;;
n | N | no | No | NO) ;;
*)
  pkill hyprland
  ;;
esac
