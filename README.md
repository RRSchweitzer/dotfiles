# dotfiles

Mac setup scripts to bootstrap a new machine with all my tools and apps.

## Quick Start (New Mac)

```bash
curl -fsSL https://raw.githubusercontent.com/RRSchweitzer/dotfiles/main/install.sh | bash
```

Or clone first to review:
```bash
git clone https://github.com/RRSchweitzer/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

## What Gets Installed

### CLI Tools (Homebrew)
- awscli, gh, git, go, mkcert
- postgis, postgresql@16, redis, mongodb
- tmux, titlecase, bash-completion

### GUI Apps (Homebrew Casks)
- 1Password, Brave, Chrome, Cursor, Discord
- Docker, Slack, Spotify, Signal, VLC
- Tailscale, Zoom, WhatsApp, and more

### Dev Packages
- **npm**: mermaid-cli, codex, shopify-cli, nodemon, yarn
- **pip**: GDAL, numpy

### Dock
Your Dock layout is saved and restored automatically.

## Updating Your Config

After installing new packages on your current Mac:

```bash
~/.dotfiles/export.sh
git add -A && git commit -m "Update packages"
git push
```

## Files

| File | Purpose |
|------|---------|
| `install.sh` | Run on new Mac to install everything |
| `export.sh` | Run to capture current packages |
| `Brewfile` | Homebrew packages and casks |
| `npm-packages.txt` | Global npm packages |
| `requirements.txt` | Python packages |
| `dock.plist` | Dock configuration |
