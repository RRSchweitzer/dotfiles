#!/bin/bash
# Bootstrap a new Mac with all your packages
# Run: curl -fsSL https://raw.githubusercontent.com/RRSchweitzer/dotfiles/main/install.sh | bash

DOTFILES_DIR="$HOME/.dotfiles"

echo "======================================"
echo "  Mac Setup Script"
echo "======================================"
echo ""

# Clone dotfiles if running via curl (not already in the repo)
if [ ! -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Cloning dotfiles repository..."
    if [ -d "$DOTFILES_DIR" ]; then
        echo "  ~/.dotfiles exists but has no Brewfile. Please check your repo."
        exit 1
    fi
    git clone https://github.com/RRSchweitzer/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed"
fi

# Install NVM
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
else
    echo "NVM already installed"
fi

# Symlink config files
echo "Symlinking config files..."
if [ -f "$DOTFILES_DIR/zshrc" ]; then
    ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
    echo "  - ~/.zshrc -> ~/.dotfiles/zshrc"
fi
if [ -f "$DOTFILES_DIR/gitconfig" ]; then
    ln -sf "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
    echo "  - ~/.gitconfig -> ~/.dotfiles/gitconfig"
fi

# Claude Code config
if [ -d "$DOTFILES_DIR/claude" ]; then
    mkdir -p "$HOME/.claude/hooks"
    ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
    echo "  - ~/.claude/settings.json -> ~/.dotfiles/claude/settings.json"
    if [ -f "$DOTFILES_DIR/claude/hooks/announce.sh" ]; then
        ln -sf "$DOTFILES_DIR/claude/hooks/announce.sh" "$HOME/.claude/hooks/announce.sh"
        echo "  - ~/.claude/hooks/announce.sh -> ~/.dotfiles/claude/hooks/announce.sh"
    fi
fi

# Sleepwatcher wakeup script (auto-upgrade Claude Code on wake)
if [ -f "$DOTFILES_DIR/wakeup" ]; then
    ln -sf "$DOTFILES_DIR/wakeup" "$HOME/.wakeup"
    echo "  - ~/.wakeup -> ~/.dotfiles/wakeup"
    if command -v brew &> /dev/null; then
        brew services start sleepwatcher 2>/dev/null
    fi
fi

# Custom scripts (~/bin and ~/scripts)
if [ -d "$DOTFILES_DIR/bin" ]; then
    mkdir -p "$HOME/bin"
    for script in "$DOTFILES_DIR/bin"/*; do
        name=$(basename "$script")
        ln -sf "$script" "$HOME/bin/$name"
        echo "  - ~/bin/$name -> ~/.dotfiles/bin/$name"
    done
fi
if [ -d "$DOTFILES_DIR/scripts" ]; then
    mkdir -p "$HOME/scripts"
    for script in "$DOTFILES_DIR/scripts"/*; do
        name=$(basename "$script")
        ln -sf "$script" "$HOME/scripts/$name"
        echo "  - ~/scripts/$name -> ~/.dotfiles/scripts/$name"
    done
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to path for this session (Apple Silicon)
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

# Install Homebrew packages
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo ""
    echo "Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" || echo "Some packages failed to install (continuing anyway)"
else
    echo "No Brewfile found, skipping Homebrew packages"
fi

# Install npm global packages
if [ -f "$DOTFILES_DIR/npm-packages.txt" ]; then
    echo ""
    echo "Installing npm global packages..."
    if command -v npm &> /dev/null; then
        while IFS= read -r package; do
            [ -z "$package" ] && continue
            echo "  - $package"
            npm install -g "$package" 2>/dev/null || echo "    (already installed or failed)"
        done < "$DOTFILES_DIR/npm-packages.txt"
    else
        echo "  npm not found. Install Node.js first (should be in Brewfile)"
    fi
else
    echo "No npm-packages.txt found, skipping npm packages"
fi

# Install pip packages
if [ -f "$DOTFILES_DIR/requirements.txt" ]; then
    echo ""
    echo "Installing pip packages..."
    if command -v pip3 &> /dev/null; then
        pip3 install -r "$DOTFILES_DIR/requirements.txt" || echo "Some pip packages failed (continuing anyway)"
    else
        echo "  pip3 not found. Install Python first (should be in Brewfile)"
    fi
else
    echo "No requirements.txt found, skipping pip packages"
fi

# Restore Dock configuration
if [ -f "$DOTFILES_DIR/dock.plist" ]; then
    current_dock=$(defaults export com.apple.dock - 2>/dev/null)
    saved_dock=$(cat "$DOTFILES_DIR/dock.plist")
    if [ "$current_dock" = "$saved_dock" ]; then
        echo "Dock configuration already up to date"
    else
        echo ""
        echo "Restoring Dock configuration..."
        defaults import com.apple.dock "$DOTFILES_DIR/dock.plist"
        killall Dock
    fi
else
    echo "No dock.plist found, skipping Dock configuration"
fi

# Set up GitHub authentication
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "GitHub CLI already authenticated"
    else
        echo ""
        echo "Setting up GitHub authentication..."
        gh auth login
        gh auth setup-git
    fi
else
    echo "gh CLI not found, skipping GitHub authentication setup"
fi

echo ""
echo "======================================"
echo "  Setup complete!"
echo "======================================"
echo ""
echo "You may need to restart your terminal for all changes to take effect."
