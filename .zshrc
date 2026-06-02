export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions fzf)
source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"

eval "$(zoxide init zsh)"
source <(fzf --zsh)
alias claude="claude --dangerously-skip-permissions"
alias c="clear"

export PNPM_HOME="/Users/billy/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="/Users/billy/.antigravity/antigravity/bin:$PATH"

# CLASH_PROXY="127.0.0.1:7890"
# _proxy_export() {
#   export http_proxy="http://$CLASH_PROXY"   https_proxy="http://$CLASH_PROXY"
#   export HTTP_PROXY="http://$CLASH_PROXY"    HTTPS_PROXY="http://$CLASH_PROXY"
#   export ALL_PROXY="socks5h://$CLASH_PROXY"  all_proxy="socks5h://$CLASH_PROXY"
#   export no_proxy="localhost,127.0.0.1,::1,*.local"  NO_PROXY="localhost,127.0.0.1,::1,*.local"
# }
# _proxy_unset() {
#   unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy no_proxy NO_PROXY
# }
# proxyon()  { _proxy_export; echo "proxy ON  -> $CLASH_PROXY"; }
# proxyoff() { _proxy_unset;  echo "proxy OFF"; }
# if nc -z -G1 ${CLASH_PROXY%:*} ${CLASH_PROXY#*:} 2>/dev/null; then
#   _proxy_export
# fi

export PATH=/Users/billy/.opencode/bin:$PATH
export PATH="/Users/billy/.pixi/bin:$PATH"

alias nobg='pixi run --manifest-path /Users/billy/Projects/tools/bg-remove/pixi.toml bg-remove'

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# Cursor Agent в yolo-режиме (перекрывает grok-овский agent)
alias agent="cursor-agent --yolo"

alias proxyoff='networksetup -setwebproxystate Wi-Fi off && networksetup -setsecurewebproxystate Wi-Fi off && networksetup -setsocksfirewallproxystate Wi-Fi off && echo "Прокси выключен"'
