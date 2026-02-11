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
    echo ""
    echo "Restoring Dock configuration..."
    defaults import com.apple.dock "$DOTFILES_DIR/dock.plist"
    killall Dock
else
    echo "No dock.plist found, skipping Dock configuration"
fi

echo ""
echo "======================================"
echo "  Setup complete!"
echo "======================================"
echo ""
echo "You may need to restart your terminal for all changes to take effect."
