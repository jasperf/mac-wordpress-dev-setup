#!/bin/bash

# Mac M4 Pro Web Developer Setup Script
# This script installs: Xcode CLI Tools, Homebrew, Git, GitHub CLI, Lima, PHP, Composer, MariaDB, Laravel Valet, WP-CLI, Node.js (with fnm), pnpm, VS Code, Docker, Warp, Claude, and Sequel Ace
# Optimized for Apple Silicon (M4 Pro)

set -e  # Exit on any error

echo "🚀 Starting Mac M4 Pro Developer Setup..."
echo "================================================"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is designed for macOS only"
    exit 1
fi

# Check for Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    print_warning "This script is optimized for Apple Silicon. Detected: $(uname -m)"
fi

echo ""
print_status "Step 1/9: Checking for Xcode Command Line Tools..."
# Install Xcode Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    print_status "Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    
    print_warning "================================================"
    print_warning "IMPORTANT: Complete the Xcode Command Line Tools"
    print_warning "installation in the popup window that appeared."
    print_warning "================================================"
    echo ""
    echo "Once the installation is complete, press ENTER to continue..."
    read -r
    
    # Verify installation completed
    if xcode-select -p &> /dev/null; then
        print_success "Xcode Command Line Tools installed successfully"
    else
        echo "Error: Xcode Command Line Tools installation failed or was cancelled."
        echo "Please run this script again after installing the tools."
        exit 1
    fi
else
    print_success "Xcode Command Line Tools already installed at $(xcode-select -p)"
fi

echo ""
print_status "Step 2/9: Installing Homebrew..."
# Install Homebrew
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
    brew update
fi

echo ""
print_status "Step 3/9: Verifying Git installation..."
# Git comes with Xcode Command Line Tools
if command -v git &> /dev/null; then
    print_success "Git already installed with Xcode Command Line Tools"
    print_status "Git version: $(git --version)"
else
    print_warning "Git not found - this is unusual after Xcode tools install"
fi

echo ""
print_status "Step 4/9: Installing GitHub CLI (gh)..."
# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    brew install gh
    print_success "GitHub CLI installed"
    echo "Configure GitHub CLI later with: gh auth login"
else
    print_success "GitHub CLI already installed"
fi

echo ""
print_status "Step 5/9: Installing Lima (limactl) for Roots Trellis..."
# Install Lima for running Linux VMs (needed for Trellis)
if ! command -v limactl &> /dev/null; then
    brew install lima
    print_success "Lima installed"
    print_status "Lima is used by Trellis for local development VMs"
else
    print_success "Lima already installed"
fi

echo ""
print_status "Step 6/9: Installing PHP and Composer..."
# Install PHP (latest version)
if ! command -v php &> /dev/null; then
    brew install php
    print_success "PHP installed"
else
    print_success "PHP already installed"
fi

# Install Composer
if ! command -v composer &> /dev/null; then
    brew install composer
    print_success "Composer installed"
else
    print_success "Composer already installed"
fi

print_status "PHP version: $(php --version | head -n 1)"
print_status "Composer version: $(composer --version 2>&1 | head -n 1)"

echo ""
print_status "Step 7/11: Installing MariaDB..."
# Install MariaDB
if ! brew list mariadb &> /dev/null; then
    brew install mariadb
    print_success "MariaDB installed"
    
    # Start MariaDB service
    brew services start mariadb
    print_success "MariaDB service started"
    print_status "Secure your MariaDB installation later with: sudo mysql_secure_installation"
else
    print_success "MariaDB already installed"
fi

echo ""
print_status "Step 8/11: Installing Laravel Valet..."
# Install Laravel Valet globally via Composer
if ! command -v valet &> /dev/null; then
    composer global require laravel/valet
    
    # Add Composer global bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.composer/vendor/bin:"* ]]; then
        echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.zshrc
        export PATH="$HOME/.composer/vendor/bin:$PATH"
    fi
    
    # Install Valet
    valet install
    print_success "Laravel Valet installed and configured"
    print_status "Use 'valet park' in your projects directory to serve sites"
else
    print_success "Laravel Valet already installed"
fi

echo ""
print_status "Step 9/12: Installing WP-CLI..."
# Install WP-CLI
if ! command -v wp &> /dev/null; then
    brew install wp-cli
    print_success "WP-CLI installed"
else
    print_success "WP-CLI already installed"
fi

# Install WP-CLI Valet command package
print_status "Installing WP-CLI Valet command package..."
if ! wp package list 2>/dev/null | grep -q "aaemnnosttv/wp-cli-valet-command"; then
    wp package install aaemnnosttv/wp-cli-valet-command:@stable
    print_success "WP-CLI Valet command installed"
    print_status "You can now use: wp valet new <site-name>"
else
    print_success "WP-CLI Valet command already installed"
fi

echo ""
print_status "You may want to configure Git with your details:"
echo "  git config --global user.name \"Your Name\""
echo "  git config --global user.email \"your.email@example.com\""

echo ""
print_status "Step 10/12: Installing Node.js via fnm (Fast Node Manager)..."
print_status "Note: fnm is faster than nvm on Apple Silicon, but works the same way"
# Install fnm (Fast Node Manager) - better than nvm for M-series Macs
if ! command -v fnm &> /dev/null; then
    brew install fnm
    
    # Add fnm to shell configuration
    echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
    eval "$(fnm env --use-on-cd)"
    
    # Install latest LTS version of Node.js
    fnm install --lts
    fnm use lts-latest
    fnm default lts-latest
    
    print_success "Node.js (LTS) installed via fnm"
else
    print_success "fnm already installed"
fi

print_status "Node.js version: $(node --version)"
print_status "npm version: $(npm --version)"

echo ""
print_status "Step 11/12: Installing pnpm (recommended package manager)..."
# Install pnpm - faster and more efficient than npm/yarn
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
    print_success "pnpm installed globally"
else
    print_success "pnpm already installed"
fi

print_status "pnpm version: $(pnpm --version)"

echo ""
print_status "Step 12/12: Installing Visual Studio Code, Docker Desktop, Warp Terminal, and Sequel Ace..."
# Install VS Code
if ! brew list --cask visual-studio-code &> /dev/null; then
    brew install --cask visual-studio-code
    print_success "VS Code installed"
else
    print_success "VS Code already installed"
fi

# Install VS Code command line tools
if ! command -v code &> /dev/null; then
    print_status "Setting up 'code' command..."
    cat << 'EOF' >> ~/.zshrc

# VS Code command line
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi


# Install Docker Desktop
if ! brew list --cask docker &> /dev/null; then
    brew install --cask docker
    print_success "Docker Desktop installed"
    print_warning "Docker Desktop needs to be launched manually the first time"
else
    print_success "Docker Desktop already installed"
fi

# Install Warp Terminal
if ! brew list --cask warp &> /dev/null; then
    brew install --cask warp
    print_success "Warp Terminal installed"
else
    print_success "Warp Terminal already installed"
fi

# Install Sequel Ace (Apple Silicon compatible fork of Sequel Pro)
print_status "Installing database management tool..."
if ! brew list --cask sequel-ace &> /dev/null; then
    brew install --cask sequel-ace
    print_success "Sequel Ace installed (Apple Silicon compatible fork of Sequel Pro)"
else
    print_success "Sequel Ace already installed"
fi

# Install Claude Code (CLI tool for agentic coding)
print_status "Installing Claude Code..."
if ! brew list --cask claude-code &> /dev/null; then
    brew install --cask claude-code
    print_success "Claude Code installed"
else
    print_success "Claude Code already installed"
fi

echo ""
echo "================================================"
print_success "🎉 Setup Complete!"
echo "================================================"
echo ""
echo "Installed tools:"
echo "  ✓ Homebrew (package manager)"
echo "  ✓ Git $(git --version | cut -d' ' -f3)"
echo "  ✓ GitHub CLI (gh)"
echo "  ✓ Lima (limactl) - for Trellis VMs"
echo "  ✓ PHP $(php --version | head -n 1 | cut -d' ' -f2)"
echo "  ✓ Composer"
echo "  ✓ MariaDB - database server"
echo "  ✓ Laravel Valet - local development environment"
echo "  ✓ WP-CLI - WordPress command line tool"
echo "  ✓ WP-CLI Valet command - for easy WordPress setup"
echo "  ✓ Node.js $(node --version) (managed by fnm)"
echo "  ✓ pnpm $(pnpm --version)"
echo "  ✓ Visual Studio Code"
echo "  ✓ Docker Desktop"
echo "  ✓ Warp Terminal"
echo "  ✓ Claude Code - AI coding assistant CLI"
echo "  ✓ Sequel Ace - database management GUI"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Launch Docker Desktop from Applications"
echo "  3. Secure MariaDB: sudo mysql_secure_installation"
echo "  4. Configure Git with your details:"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your.email@example.com\""
echo "  5. Authenticate with GitHub: gh auth login"
echo "  6. Open Warp Terminal for an enhanced terminal experience"
echo "  7. Optional: Install VS Code extensions for WordPress/React development"
echo ""
echo "Useful commands:"
echo "  fnm list                    # Show installed Node versions"
echo "  fnm install <version>       # Install specific Node version"
echo "  fnm use <version>           # Switch Node version"
echo "  pnpm install                # Install dependencies (faster than npm)"
echo "  composer install            # Install PHP dependencies"
echo "  code .                      # Open current directory in VS Code"
echo "  claude                      # Start Claude Code for AI-assisted coding"
echo "  gh repo clone <repo>        # Clone GitHub repository"
echo "  limactl start               # Start Lima VM for Trellis"
echo "  valet park                  # Serve all sites in current directory"
echo "  valet link <name>           # Create a symbolic link to serve site"
echo "  mysql -u root               # Connect to MariaDB"
echo "  wp --info                   # Check WP-CLI installation"
echo ""
echo "For Roots Sage projects:"
echo "  composer create-project roots/sage <project-name>"
echo "  cd <project-name> && composer install"
echo "  pnpm install && pnpm dev"
echo ""
echo "For Laravel Valet projects:"
echo "  cd ~/Sites"
echo "  valet park                  # All directories become .test sites"
echo ""
echo "For quick WordPress setup with Valet:"
echo "  cd ~/Sites"
echo "  wp valet new my-site        # Creates WP install at my-site.test"
echo "  # Or manually:"
echo "  mkdir my-site && cd my-site"
echo "  valet link my-site          # Creates my-site.test domain"
echo "  wp core download            # Download WordPress"
echo "  wp core config --dbname=my_site --dbuser=root --dbpass=root"
echo "  wp db create                # Create database"
echo "  wp core install --url=my-site.test --title='My Site' --admin_user=admin --admin_email=admin@example.com"
echo ""
print_success "Happy coding! 🚀"
