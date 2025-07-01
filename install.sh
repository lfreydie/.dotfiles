#!/bin/bash

set -x

if groups | grep -q "sudo"; then

	if ! command -v nvim > /dev/null 2>&1; then
		echo "Installing nvim..."

		curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
		sudo rm -rf /opt/nvim
		sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

		echo "PATH=$PATH:/opt/nvim-linux-x86_64/bin" >> ~/.zshrc
		echo "nvim installed"
	fi

	if ! command -v rg > /dev/null 2>&1; then
		echo "Installing ripgrep..."

		sudo apt-get install ripgrep

		echo "ripgrep installed"
	fi

	if ! command -v fd > /dev/null 2>&1; then
		echo "Installing fd-find..."

		sudo apt-get install fd-find

		echo "fd-find installed"
	fi
else
	echo "No sudo access detected."
	echo "Enter local directory for installing nvim (relative to HOME or absolute): "
	read local_dir

	case "$local_dir" in
		/*) final_path="$local_dir/nvim" ;;
		*) final_path="$HOME/$local_dir/nvim" ;;
	esac

	mkdir -p $final_path

	if ! command -v nvim > /dev/null 2>&1; then
		echo "Installing nvim..."

		curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
		chmod u+x nvim-linux-x86_64.appimage
		mv nvim-linux-x86_64.appimage $final_path/nvim

		echo "nvim installed"
	fi

	if command -v cargo > /dev/null 2>&1; then
		echo "Installing rust..."

		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		. "$HOME/.cargo/env"

		echo "rust installed (in subshell)"
	fi

	if ! command -v rg > /dev/null 2>&1; then
		echo "Installing ripgrep..."

		git clone https://github.com/BurntSushi/ripgrep
		$(cd ripgrep && cargo build --release)
		mv ripgrep/target/release/rg $final_path
		rm -rf ripgrep

		echo "ripgrep installed"
	fi

	if ! command -v fd > /dev/null 2>&1; then
		echo "Installing fd-find..."

		git clone https://github.com/sharkdp/fd
		$(cd fd && cargo install --path .)

		echo "fd-find installed"
	fi
fi

echo "PATH=$PATH:$final_path" >> ~/.zshrc
echo "Please run 'source ~/.zshrc' or restart your terminal."
