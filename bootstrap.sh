#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

cd "$(dirname "${BASH_SOURCE[0]}")"

git pull origin main

justDoIt() {
  # Sync dotfiles (contents of repo into $HOME) with some exclusions
  rsync -avh --no-perms \
    --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude "bootstrap.sh" \
    --exclude "yay.sh" \
    --exclude "brew.sh" \
    --exclude "README.md" \
    --exclude ".macos" \
    ./ "$HOME"/

  #  Sync ghostty config
  mkdir -p "$HOME/.config/ghostty"
  rsync -avh --no-perms "./ghostty.conf" "$HOME/.config/ghostty/config"

  # Sync Zed editor settings
  mkdir -p "$HOME/.config/zed"
  rsync -avh --no-perms zed/ "$HOME/.config/zed/"

  # Determine Zen profile base depending on OS
  if [[ "$(uname -s)" = "Darwin" ]]; then
  	zen_profile="$HOME/Library/Application Support/zen/Profiles/"*\(release\)/chrome
  else
    zen_profile="$HOME/.zen/"*\(release\)/chrome
  fi

  # Sync Zen theme
  rsync -avh --no-perms zen-browser/ $zen_profile

  # Reload shell config if present
  [[ -f "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile" || true
}

if [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]]; then
  justDoIt
else
  read -r -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " ans
  echo
  if [[ $ans =~ ^[Yy]$ ]]; then
    justDoIt
  fi
fi
