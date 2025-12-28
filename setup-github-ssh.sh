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

# Add SSH key to ssh-agent
print_status "Adding SSH key to ssh-agent..."
ssh-add ~/.ssh/id_ed25519

# Create/update SSH config for automatic key loading
print_status "Configuring SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat > ~/.ssh/config << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
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
echo "Next steps:"
echo "1. Copy the SSH key above (it's already in your clipboard if pbcopy worked)"
echo "2. Go to: https://github.com/settings/ssh/new"
echo "3. Paste the key and give it a title (e.g., 'Mac M4 Pro')"
echo "4. Click 'Add SSH key'"
echo ""

# Try to copy to clipboard
if command -v pbcopy &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | pbcopy
    print_success "✓ SSH key copied to clipboard!"
else
    print_warning "Could not copy to clipboard automatically"
fi

echo ""
read -p "Press ENTER after you've added the key to GitHub..."

# Test the connection
echo ""
print_status "Testing GitHub connection..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "✓ Successfully connected to GitHub!"
else
    print_warning "Connection test unclear - try running: ssh -T git@github.com"
fi

echo ""
print_success "Setup complete! You can now clone repositories with SSH."
echo ""
echo "Try again:"
echo "  git clone git@github.com:jasperf/mac-wordpress-dev-setup.git"
