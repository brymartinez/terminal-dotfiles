#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
packages="nvim tmux zsh wezterm bin"

if [ "$(uname -s)" = "Darwin" ]; then
	packages="$packages macos"
fi

if ! command -v stow >/dev/null 2>&1; then
	printf '%s\n' "GNU Stow is required: https://www.gnu.org/software/stow/" >&2
	exit 1
fi

exec stow --restow --dir "$repo_dir" --target "$HOME" $packages
