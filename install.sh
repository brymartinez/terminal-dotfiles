#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
set -- nvim tmux zsh wezterm
install_dependencies=false

case "$(uname -s)" in
Darwin)
	set -- "$@" macos
	;;
Linux)
	if [ -r /etc/os-release ]; then
		. /etc/os-release
		case "${ID:-}" in
		endeavouros|arch) install_dependencies=true ;;
		esac
	fi
	;;
esac

if [ "$(id -u)" -eq 0 ]; then
	printf '%s\n' "Run ./install.sh as your regular user." >&2
	exit 1
fi

if [ "$install_dependencies" = true ]; then
	sudo pacman -Syu --needed stow git neovim tmux zsh wezterm \
		ttf-fira-code ttf-nerd-fonts-symbols-mono fzf ripgrep fd lazygit jq \
		curl gcc tree-sitter-cli unzip nodejs npm go
fi

if ! command -v stow >/dev/null 2>&1; then
	printf '%s\n' "GNU Stow is required: https://www.gnu.org/software/stow/" >&2
	exit 1
fi

stow --restow --dir "$repo_dir" --target "$HOME" "$@"

if [ ! -e "$HOME/.zshrc.local" ] && [ ! -L "$HOME/.zshrc.local" ]; then
	(set -C; cat "$repo_dir/zsh/.zshrc.local.example" > "$HOME/.zshrc.local")
fi

if [ "$install_dependencies" = true ]; then
	nvim --headless '+Lazy! install' +qa
fi
