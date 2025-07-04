
# ─── Fastfetch или Neofetch ───────────────────────────────
# fastfetch
# neofetch --kitty ~/Pictures/neofetch1.jpg --size 175
# fastfetch --logo ~/.config/fastfetch/logo.jpg --logo-type kitty-direct --logo-width 30 --logo-height 15

# ─── Powerlevel10k Instant Prompt ─────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Пути и среда ─────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export PATH="/sbin:$HOME/.local/bin:$PATH"

# ─── Тема ─────────────────────────────────────────────────
ZSH_THEME="powerlevel10k/powerlevel10k"

# ─── Плагины ──────────────────────────────────────────────
plugins=(
  git
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# ─── Подключение Oh My Zsh ────────────────────────────────
source $ZSH/oh-my-zsh.sh

# ─── Powerlevel10k ────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ─── Курсор: блок и мигание ───────────────────────────────
# Делает курсор квадратным (в kitty и других терминалах)
echo -ne "\e[2 q"

# ─── Настройки пользователя ───────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'
alias yy='yazi'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# ─── История ──────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Делиться историей между сессиями
setopt HIST_EXPIRE_DUPS_FIRST # Удалять дубликаты в первую очередь
setopt HIST_IGNORE_DUPS       # Не записывать дубликаты
setopt HIST_IGNORE_ALL_DUPS   # Удалять старые дубликаты
setopt HIST_FIND_NO_DUPS      # Не показывать дубликаты при поиске
setopt HIST_IGNORE_SPACE      # Не записывать команды, начинающиеся с пробела
setopt HIST_SAVE_NO_DUPS      # Не сохранять дубликаты
setopt HIST_VERIFY            # Показывать команду перед выполнением при подстановке истории

# ─── Автодополнение ───────────────────────────────────────
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # Игнорировать регистр
setopt AUTO_CD              # Автоматически cd при вводе только пути
setopt CORRECT              # Предлагать исправления для команд
setopt GLOBDOTS             # Включать скрытые файлы в глобинг

# ─── Дополнительно (раскомментируй при необходимости) ─────
# export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL=nvim

# ─── Горячие клавиши ───────────────────────────────────────

# Ctrl+e — запуск nvim в текущей директории
bindkey -s '^e' 'nvim .\n'

# Ctrl+g — запуск lazygit
bindkey -s '^g' 'lazygit\n'

alias sudonvim='sudo -E nvim'