# Terminal dotfiles

Portable Neovim, tmux, Zsh, and WezTerm configuration managed with GNU Stow.

The base packages require GNU Stow, tmux, Zsh, and Neovim. fzf, LazyGit, Codex, WezTerm, and TPM are optional integrations used by the richer workflow.

## Install

Install GNU Stow first, then run:

```sh
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
./install.sh
[ -e ~/.zshrc.local ] || cp zsh/.zshrc.local.example ~/.zshrc.local
```

The installer links the portable packages into `$HOME`. On macOS it also links the optional Aerospace and Karabiner package. It never uses `stow --adopt`.

Existing conflicting files are left untouched and reported by Stow. Preview the links with:

```sh
stow --simulate --restow --dir "$PWD" --target "$HOME" nvim tmux zsh wezterm bin
```

## Package layout

- `nvim` links `~/.config/nvim`.
- `tmux` links `~/.tmux.conf`.
- `zsh` links `~/.zshrc`.
- `wezterm` links `~/.wezterm.lua` and support files under `~/.config/wezterm`.
- `macos` links Aerospace and Karabiner configuration on macOS only.
- `bin` links helper commands under `~/.local/bin`.

`~/.wezterm.lua` is the only WezTerm entrypoint. The files under `~/.config/wezterm` are support modules and scripts, not a second configuration entrypoint.

## Local configuration

Keep secrets, project aliases, theme overrides, and machine-specific paths in `~/.zshrc.local`. That file is ignored by Git. The tracked shell configuration only loads it when present.

## Project workflow

Create or switch to a project session with:

```sh
tmux-project ~/Documents/projects/example
```

Running `tmux-project` without a path opens an fzf project picker. A new project session starts with:

- `edit` for the main Neovim instance.
- `review` for a second Neovim instance in the same project.
- `shell` for commands and logs.

Inside tmux, use:

| Keys | Action |
| --- | --- |
| `Ctrl-a f` | Project/session picker |
| `Ctrl-a C` | Codex popup |
| `Ctrl-a g` | LazyGit popup |
| `Ctrl-h/j/k/l` | Move through Neovim and tmux panes |
| `Ctrl-a r` | Reload tmux configuration |

The existing Diffview and Git history mappings remain in Neovim. The `review` window starts in the same directory so it can be used as the persistent diff surface.

To enable tmux plugins on a new machine, install TPM separately and press `Ctrl-a I` inside tmux. The base configuration remains usable without TPM.

## Validation

```sh
sh -n install.sh
zsh -n zsh/.zshrc
tmux -L dotfiles-check -f tmux/.tmux.conf new-session -d -s dotfiles-check
nvim --headless --clean -u nvim/.config/nvim/init.lua '+qa'
tmux -L dotfiles-check kill-server 2>/dev/null || true
```
