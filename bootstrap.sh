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

  # Sync Zed editor settings
  mkdir -p "$HOME/.config/zed"
  rsync -avh --no-perms zed/ "$HOME/.config/zed/"

  # Determine Zen profile base depending on OS
  case "$(uname -s)" in
    Darwin)
      profiles_glob="$HOME/Library/Application Support/zen/Profiles/"'*'"(release)/"
      ;;
    Linux)
      profiles_glob="$HOME/.zen/Profiles/"'*'"(release)/"
      ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      return 1
      ;;
  esac

  # Expand matching profiles (if any)
  # Use an array to handle multiple matches
  mapfile -t zen_profiles < <(eval "printf '%s\n' $profiles_glob")

  if (( ${#zen_profiles[@]} == 0 )); then
    echo "No Zen profiles ending with '(release)' found." >&2
    return 1
  fi

  # Copy the zen-browser theme into each profile's chrome/ folder
  for p in "${zen_profiles[@]}"; do
    mkdir -p "$p/chrome"
    rsync -avh --no-perms zen-browser/ "$p/chrome/"
    echo "Synced Zen theme to: $p/chrome/"
  done

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
