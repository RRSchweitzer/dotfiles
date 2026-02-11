#!/bin/bash
# Export current system packages to config files
# Run this to capture your current setup

set -e

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

echo "Exporting packages to $DOTFILES_DIR..."

# Homebrew
if command -v brew &> /dev/null; then
    echo "  - Homebrew packages -> Brewfile"
    brew bundle dump --force --file="$DOTFILES_DIR/Brewfile"
else
    echo "  - Homebrew not found, skipping"
fi

# npm global packages
if command -v npm &> /dev/null; then
    echo "  - npm global packages -> npm-packages.txt"
    npm list -g --depth=0 2>/dev/null | \
        tail -n +2 | \
        sed 's/.*[├└]── //' | \
        sed 's/@[0-9].*//' | \
        grep -v "^npm$" | grep -v "^corepack$" \
        > "$DOTFILES_DIR/npm-packages.txt"
else
    echo "  - npm not found, skipping"
fi

# pip packages
if command -v pip3 &> /dev/null; then
    echo "  - pip packages -> requirements.txt"
    pip3 freeze | grep -v "^pip==" | grep -v "^wheel==" > "$DOTFILES_DIR/requirements.txt"
else
    echo "  - pip3 not found, skipping"
fi

echo ""
echo "Done! Files created:"
ls -la "$DOTFILES_DIR"/*.txt "$DOTFILES_DIR"/Brewfile 2>/dev/null || true
echo ""
echo "Next steps:"
echo "  1. Review the files and remove any packages you don't want"
echo "  2. Push to GitHub:"
echo "     cd ~/.dotfiles"
echo "     git init && git add -A && git commit -m 'Initial dotfiles'"
echo "     git remote add origin https://github.com/RRSchweitzer/dotfiles.git"
echo "     git push -u origin main"
