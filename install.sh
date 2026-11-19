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
	install_arch_packages() {
		if ! pacman -Q "$@" >/dev/null 2>&1; then
			sudo pacman -Syu --needed "$@"
		fi
	}
	install_arch_packages stow git neovim tmux zsh wezterm \
		fzf ripgrep fd lazygit jq \
		curl gcc tree-sitter-cli unzip nodejs npm go
fi

for command in stow git zsh wezterm nvim tmux chsh curl unzip; do
	if ! command -v "$command" >/dev/null 2>&1; then
		printf 'Required command missing: %s\n' "$command" >&2
		exit 1
	fi
done

zsh_path=$(command -v zsh)
if ! grep -Fxq "$zsh_path" /etc/shells; then
	if [ -x /bin/zsh ] && grep -Fxq /bin/zsh /etc/shells; then
		zsh_path=/bin/zsh
	else
		printf 'Register %s in /etc/shells before running this installer.\n' "$zsh_path" >&2
		exit 1
	fi
fi

stow --restow --dir "$repo_dir" --target "$HOME" "$@"

oh_my_zsh_dir=${ZSH:-$HOME/.oh-my-zsh}
if [ ! -r "$oh_my_zsh_dir/oh-my-zsh.sh" ]; then
	if [ -e "$oh_my_zsh_dir" ] || [ -L "$oh_my_zsh_dir" ]; then
		printf 'Oh My Zsh is missing oh-my-zsh.sh in %s\n' "$oh_my_zsh_dir" >&2
		exit 1
	fi
	git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$oh_my_zsh_dir"
fi

p10k_dir=${ZSH_CUSTOM:-$oh_my_zsh_dir/custom}/themes/powerlevel10k
if [ ! -r "$p10k_dir/powerlevel10k.zsh-theme" ]; then
	git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
fi

case "$(uname -s)" in
	Darwin) font_dir="$HOME/Library/Fonts/dotfiles-nerd-fonts" ;;
	*) font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/dotfiles-nerd-fonts" ;;
esac

install_nerd_font() (
	archive=$1
	font_name=$2
	if [ -r "$font_dir/$archive/$font_name-Regular.ttf" ]; then
		exit 0
	fi
	mkdir -p "$font_dir"
	stage=$(mktemp -d "$font_dir/.download.XXXXXXXX")
	trap 'rm -rf "$stage"' EXIT
	curl -fsSL --retry 3 \
		"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/$archive.zip" \
		-o "$stage/fonts.zip"
	unzip -q "$stage/fonts.zip" "$font_name-*.ttf" -d "$stage/$archive"
	mkdir -p "$font_dir/$archive"
	mv "$stage/$archive/"*.ttf "$font_dir/$archive/"
)

install_nerd_font FiraCode FiraCodeNerdFont
install_nerd_font JetBrainsMono JetBrainsMonoNerdFont
install_nerd_font NerdFontsSymbolsOnly SymbolsNerdFontMono
if command -v fc-cache >/dev/null 2>&1; then
	fc-cache "$font_dir"
fi

if [ ! -e "$HOME/.zshrc.local" ] && [ ! -L "$HOME/.zshrc.local" ]; then
	(set -C; cat "$repo_dir/zsh/.zshrc.local.example" > "$HOME/.zshrc.local")
fi

wezterm ls-fonts >/dev/null
nvim --headless '+Lazy! install' \
	'+lua if vim.v.errmsg ~= "" or not vim.g.colors_name then vim.cmd.cquit() end' +qa

case "$(uname -s)" in
	Darwin) login_shell=$(dscl . -read "/Users/$(id -un)" UserShell | cut -d ' ' -f 2-) ;;
	*) login_shell=$(getent passwd "$(id -un)" | cut -d : -f 7) ;;
esac

case "$login_shell" in
	*/zsh) ;;
	*)
		chsh -s "$zsh_path"
		printf '%s\n' 'Sign out and back in to pick up the new login shell.'
		;;
esac
