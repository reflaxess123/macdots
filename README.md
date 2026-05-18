# macdots

Personal macOS dotfiles. One command to restore on a fresh Mac.

## Restore

```bash
git clone git@github.com:reflaxess123/macdots.git ~/repos/macdots
cd ~/repos/macdots && ./install.sh
```

The installer is idempotent — re-run it any time. Existing real files are
backed up as `*.bak-<timestamp>` before being replaced by symlinks.

## What's tracked

| Path | What |
|---|---|
| `.config/ghostty/` | Ghostty terminal config + custom themes (LightWhite / GrayBlack / XDRBlack) |
| `.config/alacritty/` | Alacritty terminal config + Catppuccin Mocha theme (parallel to Ghostty) |
| `.config/tmux/` | Random window/session name pool + picker script |
| `.tmux.conf` | Tmux: Catppuccin Mocha, rounded segments on transparent bar, prefix=C-a |
| `.claude/settings.json` | Claude Code config (effortLevel, statusLine, terminalProgressBar=off) |
| `.claude/statusline.{js,sh}` | Status-line scripts referenced from settings.json |
| `.zshrc` | Zsh + oh-my-zsh: tool aliases (bat/eza/fd/fzf), helper functions |
| `.hushlogin` | Suppresses macOS "Last login:" banner on every shell |
| `Brewfile` | Brew deps installed by `brew bundle` |

## Manual one-time steps

These can't be automated:

1. **Full Disk Access for Ghostty** — System Settings → Privacy & Security
   → Full Disk Access → add `/Applications/Ghostty.app`. Without this Claude
   Code triggers a `"Ghostty would like to access data from other apps"`
   popup on every launch (it reads Claude Desktop's config from Application
   Support to detect MCP servers).
2. **Sign into Claude Code** — `claude` then follow the auth flow.

## Key bindings

- `tmux` prefix: `C-a` (not `C-b`)
- New window: `C-a c` — gets a random server name (thor, athena, kraken…)
- New session: `C-a :new` — same random naming via session-created hook
- Kill pane/window: `C-a x` / `C-a &` — no confirmation prompt
- F1–F10 (no prefix): switch to window 1–10
- Shift+Left/Right (no prefix): prev/next window

When prefix `C-a` is held, a red `⌃A` badge appears in the right side of
the status bar.

## Re-syncing the working machine

If you edit one of the tracked configs in `$HOME` instead of inside the repo,
re-run `./install.sh` — it'll back up the divergent local file and reinstate
the symlink. Or just edit inside `~/repos/macdots/` since `$HOME/` is
symlinked there anyway.
