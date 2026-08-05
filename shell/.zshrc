# Portable Zsh configuration for the dotfiles bootstrap.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U path PATH
_brew_prefix="$(brew --prefix 2>/dev/null)"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}no matches found%f'
zmodload zsh/complist
if [[ -n "$_brew_prefix" ]]; then
  fpath=("$_brew_prefix/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit
_comp_dump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -s "$_comp_dump" ]]; then
  compinit -C -d "$_comp_dump"
else
  compinit -d "$_comp_dump"
fi
unset _comp_dump

# Keep user-installed tools ahead of system binaries when present.
path=("$HOME/.local/bin" $path)

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -la --group-directories-first --icons=auto --git'
  alias la='eza -a --group-directories-first --icons=auto'
elif [[ "$OSTYPE" == darwin* ]]; then
  export CLICOLOR=1
  export LSCOLORS="${LSCOLORS:-ExGxBxDxCxEgEdxbxgxcxd}"
  alias ls='ls -G'
  alias ll='ls -laG'
  alias la='ls -AG'
fi

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --cycle --info=inline'

if [[ -n "$_brew_prefix" ]]; then
  [[ ! -r "$_brew_prefix/opt/fzf/shell/completion.zsh" ]] ||
    source "$_brew_prefix/opt/fzf/shell/completion.zsh" 2>/dev/null
  [[ ! -r "$_brew_prefix/opt/fzf/shell/key-bindings.zsh" ]] ||
    source "$_brew_prefix/opt/fzf/shell/key-bindings.zsh" 2>/dev/null
fi

alias code='code-insiders'
alias cld='claude --dangerously-skip-permissions'
alias claude='claude --dangerously-skip-permissions'
alias codex='codex --dangerously-bypass-approvals-and-sandbox'

if [[ -n "$_brew_prefix" ]]; then
  source "$_brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -n "$_brew_prefix" ]]; then
  [[ ! -r "$_brew_prefix/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] ||
    source "$_brew_prefix/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi
unset _brew_prefix
