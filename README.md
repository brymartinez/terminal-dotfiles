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

## Using the setup

The normal stack has three layers:

- WezTerm is the outer terminal. It owns tabs, outer panes, themes, and fonts.
- tmux owns the durable project workspace.
- Neovim owns editing and Git review.

The usual flow is:

```text
WezTerm -> tmux project session -> edit/review/shell windows
```

Start a project with:

```sh
tmux-project ~/Documents/projects/my-project
```

Or run `tmux-project` without a path to choose a project with fzf.

## Project workflow

A new project session starts with:

- `edit` for the main Neovim instance.
- `review` for a second Neovim instance in the same project.
- `shell` for commands and logs.

Inside tmux, use:

| Keys | Action |
| --- | --- |
| `Ctrl-a 0` | Edit window |
| `Ctrl-a 1` | Review window |
| `Ctrl-a 2` | Shell window |
| `Ctrl-a n` / `Ctrl-a p` | Next / previous window |
| `Ctrl-a f` | Project/session picker |
| `Ctrl-a`, then `Shift-c` | Codex popup |
| `Ctrl-a g` | LazyGit popup |
| `Ctrl-h/j/k/l` | Move through Neovim and tmux panes |
| `Ctrl-a \|` | Split horizontally |
| `Ctrl-a -` | Split vertically |
| `Ctrl-a m` | Zoom or unzoom the current tmux pane |
| `Ctrl-a r` | Reload tmux configuration |

The `review` window starts in the same directory as `edit`, so it can be used as the persistent diff surface. In Neovim, LazyVim uses `Space` as the leader key:

| Keys | Action |
| --- | --- |
| `Space g d` | Open Diffview |
| `Space g H` | Show history for the current file |
| `Space g q` | Find Git hunks |
| `Space h l` | Show the last HTTP response |
| `Space h f` | Filter the HTTP response with jq |
| `Space h r` | Repeat the jq filter |

Use `Ctrl-h/j/k/l` to move through both Neovim splits and tmux panes. Use `Ctrl-a g` for staging, commits, branches, and history in LazyGit. Use `Ctrl-a`, then `Shift-c` for a temporary Codex consultation.

## WezTerm controls

On macOS, the WezTerm leader is `Shift-Cmd-L`. Press it, then the second key within two seconds:

| Keys | Action |
| --- | --- |
| `Shift-Cmd-L`, then `t` | Switch theme |
| `Shift-Cmd-L`, then `o` | Toggle opacity |
| `Shift-Cmd-L`, then `d` | Toggle pane desaturation |
| `Shift-Cmd-L`, then `s` | Select an outer WezTerm pane |
| `Shift-Cmd-L`, then `z` | Zoom an outer WezTerm pane |
| `Shift-Cmd-Enter` | Smart outer split |
| `Shift-Cmd-\|` / `Shift-Cmd--` | Explicit outer split |
| `Cmd-t` | New WezTerm tab |
| `Cmd-n` | New WezTerm window |
| `Cmd-w` | Close the current outer pane |
| `Cmd-,` | Edit the WezTerm configuration |

Use tmux for project structure. Use WezTerm tabs and panes only when you deliberately want another outer terminal surface.

To enable tmux plugins on a new machine, install TPM separately and press `Ctrl-a I` inside tmux. The base configuration remains usable without TPM.

## Stow model

Stow creates symlinks from package paths into `$HOME`. For example:

```text
tmux/.tmux.conf              -> ~/.tmux.conf
wezterm/.wezterm.lua         -> ~/.wezterm.lua
nvim/.config/nvim             -> ~/.config/nvim
bin/.local/bin/tmux-project  -> ~/.local/bin/tmux-project
```

Editing a tracked file changes the live configuration immediately. Rerun `./install.sh` after adding or moving packages. Keep machine-specific settings in `~/.zshrc.local` rather than editing the tracked files.

## Validation

```sh
sh -n install.sh
zsh -n zsh/.zshrc
tmux -L dotfiles-check -f tmux/.tmux.conf new-session -d -s dotfiles-check
nvim --headless --clean -u nvim/.config/nvim/init.lua '+qa'
tmux -L dotfiles-check kill-server 2>/dev/null || true
```
