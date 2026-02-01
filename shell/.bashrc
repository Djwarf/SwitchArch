#
# ~/.bashrc - SwitchArch Shell Configuration
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Path configuration
export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR=nvim
export VISUAL=nvim

# Color for grep
alias grep='grep --color=auto'

# eza (better ls)
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'

# bat (better cat)
alias cat='bat'

# Starship prompt
eval "$(starship init bash)"

# Zoxide (smarter cd - use 'z' instead of 'cd')
eval "$(zoxide init bash)"

# fzf keybindings (Ctrl+R for history, Ctrl+T for files)
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

# Cargo (Rust) - uncomment if using Rust
# [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# NPM global packages - uncomment if needed
# export PATH="$HOME/.npm-global/bin:$PATH"
