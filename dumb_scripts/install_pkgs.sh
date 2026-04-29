#!/bin/bash

# pacman packages
packages=(
  tmux
  kitty
  powertop
  gvim
  eza
  ripgrep
  fzf
  cpio
  cmake
  meson
  waybar
  hyprpolkitagent
  awww
  lz4
  nwg-displays
  cava
  mako
  rofi
  adw-gtk-theme
  qt5ct
  qt6ct
  kvantum
  breeze-icons
  spotify-player
  quickshell
  qt5-svg
  qt6-svg
  qt5-imageformats
  qt6-imageformats
  qt5-multimedia
  qt6-multimedia
  qt6-5compat
  7zip
  github-cli
  neovim
  ark
  acpi
  ttf-space-mono-nerd
  bluetui
  zoxide
  platformio-core
  nodejs
  npm
  grimblast
  swappy
  bear
  brightnessctl
  okular
  gwenview
  nwg-look
  docker
)

# paru packages
aur_packages=(
  opencode
  qt5-location
  stremio-enhanced-bin
  vesktop
  spicetify-cli
  wlogout
  zsh-theme-powerlevel10k
  bibata-cursor-theme
  wlrobs-hg
  protonplus
  losslesscut-bin
)

# system update + install respectively
sudo pacman -Syu
sudo pacman -S --needed "${packages[@]}"
paru -S --needed "${aur_packages[@]}"

# copy dotfiles
# declare -A dotfiles=(
#     ["$HOME/.config/backup-dotfiles/.zshrc"]="$HOME/.zshrc"
#     ["$HOME/.config/backup-dotfiles/.p10k.zsh"]="$HOME/.p10k.zsh"
#     ["$HOME/.config/backup-dotfiles/alsa.conf"]="etc/modprobe.d/alsa.conf"
#     ["$HOME/.config/backup-dotfiles/alc294-fix"]="lib/firmware/alc294-fix"
#     # add more mappings
# )
#
# for src in "${!dotfiles[@]}"; do
#     dest="${dotfiles[$src]}"
#     mkdir -p "$(dirname "$dest")"
#     cp "$DOTFILES_DIR/$src" "$dest"
#     echo "Copied $src -> $dest"
# done
