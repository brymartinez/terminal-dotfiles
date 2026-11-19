# Keep this file portable. Put secrets and machine-specific paths in ~/.zshrc.local.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
plugins=(git)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    ZSH_THEME="powerlevel10k/powerlevel10k"
  fi
  source "$ZSH/oh-my-zsh.sh"
else
  HISTFILE=${HISTFILE:-$HOME/.zsh_history}
  HISTSIZE=10000
  SAVEHIST=10000
  setopt share_history
  autoload -Uz compinit
  compinit
  PROMPT='%n@%m %~ %# '
fi

if (( $+functions[p10k] )); then
  if [[ -r "$HOME/.p10k.zsh" ]]; then
    source "$HOME/.p10k.zsh"
  else
    source "${ZSH_CUSTOM:-$ZSH/custom}/themes/powerlevel10k/config/p10k-lean.zsh"
  fi
fi

export EDITOR="${EDITOR:-nvim}"
alias vim='nvim'
alias dcu='docker compose up'
alias dcdv='docker compose down --volumes'
alias dcr='dcdv && dcu'
alias gitstd='git add src/ test/ docs/ && git status'

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
  source "/opt/homebrew/opt/nvm/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
elif [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]]; then
  source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
fi
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"

if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
  export PATH="$PNPM_HOME:$PATH"
elif [[ -d "$HOME/.local/share/pnpm" ]]; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
  export PATH="$PNPM_HOME:$PATH"
fi

if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

if [[ -d "/opt/homebrew/opt/openjdk@21/bin" ]]; then
  export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
fi

if [[ -r "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
fi
if [[ -r "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"
fi
if [[ -d "/opt/homebrew/opt/libpq/bin" ]]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
fi

if [[ -t 0 && -o zle ]] && (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
