#!/bin/bash

# Oh My Zsh Setup Script
# Installs Oh My Zsh while preserving existing shell configuration
# Safe to run on systems with existing .zshrc customizations

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo "🎨 Oh My Zsh Installation"
echo "================================================"
echo ""

# Check if Oh My Zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Oh My Zsh is already installed at ~/.oh-my-zsh"
    echo ""
    read -p "Do you want to reinstall? This will backup your current .zshrc (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Check if .zshrc exists and has content
if [ -f "$HOME/.zshrc" ] && [ -s "$HOME/.zshrc" ]; then
    print_status "Found existing .zshrc with configuration"

    # Create a backup with timestamp
    BACKUP_FILE="$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_FILE"
    print_success "Backed up current .zshrc to: $BACKUP_FILE"

    # Extract important configurations
    print_status "Extracting important PATH configurations..."

    TEMP_CONFIG=$(mktemp)

    # Extract Homebrew configuration
    if grep -q "brew shellenv" "$HOME/.zshrc"; then
        echo -e "\n# Homebrew" >> "$TEMP_CONFIG"
        grep "brew shellenv" "$HOME/.zshrc" >> "$TEMP_CONFIG"
        print_status "  ✓ Found Homebrew configuration"
    fi

    # Extract Composer global bin
    if grep -q "\.composer/vendor/bin" "$HOME/.zshrc"; then
        echo -e "\n# Composer" >> "$TEMP_CONFIG"
        grep "\.composer/vendor/bin" "$HOME/.zshrc" >> "$TEMP_CONFIG"
        print_status "  ✓ Found Composer configuration"
    fi

    # Extract fnm configuration
    if grep -q "fnm env" "$HOME/.zshrc"; then
        echo -e "\n# fnm (Fast Node Manager)" >> "$TEMP_CONFIG"
        grep "fnm env" "$HOME/.zshrc" >> "$TEMP_CONFIG"
        print_status "  ✓ Found fnm configuration"
    fi

    # Extract VS Code CLI
    if grep -q "Visual Studio Code" "$HOME/.zshrc"; then
        echo -e "\n# VS Code CLI" >> "$TEMP_CONFIG"
        grep -A 1 "Visual Studio Code" "$HOME/.zshrc" | tail -n 1 >> "$TEMP_CONFIG"
        print_status "  ✓ Found VS Code configuration"
    fi

    HAS_CUSTOM_CONFIG=true
else
    print_status "No existing .zshrc found or file is empty"
    HAS_CUSTOM_CONFIG=false
fi

echo ""
print_status "Installing Oh My Zsh..."
echo ""

# Install Oh My Zsh (unattended mode)
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

print_success "Oh My Zsh installed successfully!"

# Set theme to af-magic (shows full path and git branch)
print_status "Setting theme to af-magic..."
sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="af-magic"/' "$HOME/.zshrc"
print_success "Theme set to af-magic (shows path + git branch)"
echo ""

# Restore important configurations if we extracted them
if [ "$HAS_CUSTOM_CONFIG" = true ] && [ -f "$TEMP_CONFIG" ] && [ -s "$TEMP_CONFIG" ]; then
    print_status "Restoring important PATH configurations to new .zshrc..."

    # Append the extracted config to the new .zshrc
    cat "$TEMP_CONFIG" >> "$HOME/.zshrc"

    print_success "Configuration restored!"
    echo ""
    print_status "Restored configurations:"
    cat "$TEMP_CONFIG"

    # Clean up temp file
    rm "$TEMP_CONFIG"
fi

echo ""
echo "================================================"
print_success "🎉 Oh My Zsh Setup Complete!"
echo "================================================"
echo ""
echo "What's installed:"
echo "  ✓ Oh My Zsh framework"
echo "  ✓ Theme: af-magic (shows full path + git branch)"
echo "  ✓ Your previous PATH configurations (preserved)"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Customize your theme by editing ~/.zshrc"
echo "  3. Install plugins by adding them to the plugins=() array"
echo ""
echo "Popular themes to try:"
echo "  - agnoster (requires Powerline fonts)"
echo "  - powerlevel10k (install separately: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k)"
echo "  - spaceship (install separately)"
echo ""
echo "Popular plugins (already included):"
echo "  - git (enabled by default)"
echo "  - Add more: plugins=(git brew composer npm docker)"
echo ""
echo "Documentation: https://github.com/ohmyzsh/ohmyzsh"
echo ""

if [ "$HAS_CUSTOM_CONFIG" = true ]; then
    print_warning "Your original .zshrc was backed up to: $BACKUP_FILE"
    echo "You can compare it with: diff ~/.zshrc $BACKUP_FILE"
fi

echo ""
print_success "Enjoy Oh My Zsh! 🚀"
