#!/usr/bin/env bash
# macdots installer — idempotent.
#   Symlinks every tracked dotfile into $HOME, backs up any existing real file,
#   installs brew deps, and ensures oh-my-zsh + plugins are present.
#
# Usage:   ./install.sh
# Re-run any time — already-correct symlinks are skipped.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'; c_dim=$'\e[2m'; c_reset=$'\e[0m'
say()  { printf '%s%s%s\n' "$c_green" "$1" "$c_reset"; }
warn() { printf '%s%s%s\n' "$c_yellow" "$1" "$c_reset"; }
fail() { printf '%s%s%s\n' "$c_red"    "$1" "$c_reset" >&2; }
note() { printf '%s%s%s\n' "$c_dim"    "$1" "$c_reset"; }

# ── 1. Homebrew + Brewfile ──────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  say "[1/4] installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # apple silicon shell init
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
else
  say "[1/4] Homebrew present"
fi

if [ -f "$DOTFILES/Brewfile" ]; then
  say "[2/4] running brew bundle…"
  brew bundle --file="$DOTFILES/Brewfile"
else
  warn "[2/4] no Brewfile — skipping deps"
fi

# ── 2. oh-my-zsh + custom plugins ──────────────────────────────────────────
say "[3/4] ensuring oh-my-zsh + plugins"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for entry in \
  "zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions" \
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git" ; do
  name="${entry%% *}"
  url="${entry##* }"
  dest="$ZSH_CUSTOM/plugins/$name"
  if [ ! -d "$dest" ]; then
    git clone --depth=1 "$url" "$dest"
  else
    note "  plugin already present: $name"
  fi
done

# ── 3. Symlinks ─────────────────────────────────────────────────────────────
say "[4/4] linking dotfiles → \$HOME"

link() {
  local rel="$1"
  local src="$DOTFILES/$rel"
  local dest="$HOME/$rel"
  if [ ! -e "$src" ]; then
    note "  miss in repo: $rel"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    note "  already linked: ~/$rel"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$TS"
    warn "  backed up: ~/$rel → ~/$rel.bak-$TS"
  fi
  ln -sfn "$src" "$dest"
  echo "  linked: ~/$rel"
}

link .zshrc
link .tmux.conf
link .hushlogin
link .config/tmux
link .config/ghostty
link .config/alacritty
link .claude/settings.json
link .claude/statusline.js
link .claude/statusline.sh
link .claude/statusline-command.sh

# Alacritty не умеет save-window-state сам — пусть macOS делает это за него.
defaults write org.alacritty NSQuitAlwaysKeepsWindows -bool true 2>/dev/null || true

# ── 4. Manual reminders ─────────────────────────────────────────────────────
cat <<EOF

${c_green}done.${c_reset}

${c_yellow}manual steps that can't be automated:${c_reset}
  1. System Settings → Privacy & Security → Full Disk Access → add Ghostty.app
     (otherwise Claude Code triggers a TCC popup on every launch)
  2. Launch Ghostty once so fonts register, then start a new shell
  3. tmux prefix is ${c_green}C-a${c_reset} (not the default C-b)
  4. If you keep using oh-my-zsh and \$HOME/.zshrc was overwritten, your
     previous version was saved as ~/.zshrc.bak-$TS
EOF
