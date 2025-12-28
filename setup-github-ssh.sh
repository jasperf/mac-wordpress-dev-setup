#!/bin/bash

# GitHub SSH Key Setup Script
# Generates an SSH key and guides you through adding it to GitHub

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

echo "🔑 GitHub SSH Key Setup"
echo "================================================"
echo ""

# Ask for email
read -p "Enter your GitHub email address: " github_email

if [ -z "$github_email" ]; then
    echo "Error: Email address is required"
    exit 1
fi

print_status "Generating SSH key..."

# Generate SSH key
ssh-keygen -t ed25519 -C "$github_email" -f ~/.ssh/id_ed25519 -N ""

print_success "SSH key generated!"

# Start ssh-agent
print_status "Starting ssh-agent..."
eval "$(ssh-agent -s)"

# Add SSH key to ssh-agent and macOS keychain
print_status "Adding SSH key to ssh-agent and macOS keychain..."
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

print_success "SSH key added to keychain!"

# Create/update SSH config for automatic key loading on macOS
print_status "Configuring SSH for macOS..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat > ~/.ssh/config << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

Host *
  AddKeysToAgent yes
  UseKeychain yes
EOF

chmod 600 ~/.ssh/config

print_success "SSH configured!"

echo ""
echo "================================================"
print_success "SSH Key Generated Successfully!"
echo "================================================"
echo ""
echo "📋 Your public SSH key (copy this):"
echo "================================================"
cat ~/.ssh/id_ed25519.pub
echo "================================================"
echo ""

# Try to copy to clipboard
if command -v pbcopy &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | pbcopy
    print_success "✓ SSH key copied to clipboard!"
else
    print_warning "Could not copy to clipboard automatically"
fi

echo ""
print_warning "IMPORTANT: You MUST add this key to GitHub before continuing!"
echo ""
echo "Steps to add the key to GitHub:"
echo "1. Open this URL in your browser: https://github.com/settings/ssh/new"
echo "2. In the 'Title' field, enter: Mac M4 Pro (or any name you prefer)"
echo "3. In the 'Key' field, paste the key (Cmd+V - it's already copied)"
echo "4. Click the green 'Add SSH key' button"
echo "5. Confirm with your GitHub password if prompted"
echo ""

# Open GitHub in browser automatically
if command -v open &> /dev/null; then
    print_status "Opening GitHub SSH settings in your browser..."
    open "https://github.com/settings/ssh/new"
    echo ""
fi

read -p "Press ENTER after you've added the key to GitHub and clicked 'Add SSH key'..."

# Test the connection with better error handling
echo ""
print_status "Testing GitHub connection..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo ""
    print_success "🎉 Successfully connected to GitHub!"
    print_success "Your SSH key is working correctly!"
else
    echo ""
    print_warning "⚠️  Connection test failed."
    echo ""
    echo "Please verify:"
    echo "1. Did you add the key to GitHub? https://github.com/settings/keys"
    echo "2. Did you click 'Add SSH key' button?"
    echo "3. Try running this command to see the error:"
    echo "   ssh -T git@github.com"
    echo ""
    echo "If you see 'Permission denied (publickey)', the key wasn't added to GitHub yet."
    echo "If you see 'successfully authenticated', it's working!"
    exit 1
fi

echo ""
print_success "Setup complete! You can now clone repositories with SSH."
echo ""
echo "Try again:"
echo "  git clone git@github.com:jasperf/mac-wordpress-dev-setup.git"
