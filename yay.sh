#!/usr/bin/env bash

# basically the same as brew.sh but for Arch Linux

if command -v yay --version > /dev/null; then
	echo "yay is already installed going forward with installation.";
else
	echo "yay not found. Installing it via AUR."
	# Installing yay (AUR helper)
	sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si;
fi

# Do system update/upgrade
echo "Starting system upgrade"
yay -Syu

# Add or remove packages from here
packages="base-devel git coreutils moreutils findutils sed bash bash-completion grep openssh php lua 7zip pigz pv tree zopfli python nodejs angular-cli go ghostty zed jdk-temurin legcord element-desktop tidal-hifi-bin obsidian zen-browser-bin google-chrome proton-mail-bin proton-pass-bin jetbrains-toolbox apple-fonts"

echo "Starting package install"
yay -Sy --needed --noconfirm $packages

# Change shell to bash (just for sanity or if you have previously changed it)
chsh -s $(which bash)

echo "Reboot your machine for all changes to take effect!"
