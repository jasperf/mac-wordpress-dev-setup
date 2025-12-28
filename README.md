# Mac WordPress Development Setup

Automated development environment setup for macOS, optimized for WordPress development with modern tooling and the Roots.io ecosystem (Trellis, Bedrock, Sage).

## What This Does

This repository contains shell scripts that automate the installation and configuration of a complete WordPress development environment on macOS. It's specifically optimized for Apple Silicon (M-series) Macs but works on Intel Macs too.

## Who This Is For

- WordPress developers using modern workflows (Trellis, Bedrock, Sage)
- Developers setting up a new Mac for web development
- Anyone wanting a batteries-included local WordPress development environment
- Teams standardizing their development setup

## What Gets Installed

### Core Development Tools
- **Xcode Command Line Tools** - Required for compilation and Git
- **Homebrew** - macOS package manager
- **Git** - Version control (via Xcode)
- **GitHub CLI (gh)** - GitHub integration from terminal

### WordPress Stack
- **PHP** (latest) - WordPress runtime
- **Composer** - PHP dependency manager
- **MariaDB** - MySQL-compatible database
- **Laravel Valet** - Local development server (.test domains)
- **WP-CLI** - WordPress command-line tools
- **WP-CLI Valet Command** - Quick WordPress site creation

### Roots.io Ecosystem
- **Lima** - Lightweight Linux VM manager
- **Ansible** - Server automation tool
- **Trellis CLI** - WordPress deployment and provisioning

### JavaScript/Node.js
- **fnm** - Fast Node Manager (nvm alternative, optimized for M-series)
- **Node.js LTS** - JavaScript runtime
- **pnpm** - Fast, efficient package manager

### Applications
- **Visual Studio Code** - Code editor with CLI integration
- **Docker Desktop** - Container platform
- **Warp** - Modern terminal emulator
- **Claude Code** - AI coding assistant CLI
- **Sequel Ace** - Database management GUI

## Prerequisites

- macOS (tested on Apple Silicon, works on Intel)
- Administrator access (for some installations)
- Internet connection
- About 30-45 minutes for complete installation

## Quick Start

### 1. Clone or Download

```bash
# Clone the repository
git clone https://github.com/jasperf/mac-wordpress-dev-setup.git
cd mac-wordpress-dev-setup

# Or download and extract ZIP from GitHub
```

### 2. Make Scripts Executable

```bash
chmod +x mac-wp-dev-setup.sh setup-github-ssh.sh
```

### 3. Run Main Setup

```bash
./mac-wp-dev-setup.sh
```

The script will guide you through the installation. Some steps require user interaction:
- Xcode Command Line Tools installation (popup window)
- Homebrew installation (password prompt)
- Various confirmations

### 4. Setup GitHub SSH (Optional)

If you plan to use Git with SSH:

```bash
./setup-github-ssh.sh
```

This will:
- Generate an ed25519 SSH key
- Add it to macOS keychain
- Guide you through adding it to GitHub
- Test the connection

### 5. Restart Terminal

After installation completes:

```bash
# Restart your terminal or run:
source ~/.zshrc
```

## Post-Installation Setup

### Secure MariaDB

```bash
sudo mysql_secure_installation
```

Follow prompts to set root password and secure the installation.

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Authenticate GitHub CLI

```bash
gh auth login
```

### Launch Docker Desktop

Open Docker Desktop from Applications for first-time setup.

## Common Workflows

### Quick WordPress Site with Valet

```bash
# Navigate to your sites directory
mkdir -p ~/Sites && cd ~/Sites

# Option 1: Use WP-CLI Valet command (fastest)
wp valet new my-site
# Creates complete WordPress install at https://my-site.test

# Option 2: Manual setup
mkdir my-site && cd my-site
valet link my-site
wp core download
wp core config --dbname=my_site --dbuser=root --dbpass=root
wp db create
wp core install --url=my-site.test --title='My Site' \
  --admin_user=admin --admin_email=admin@example.com
```

### Roots Trellis Project

```bash
# Create new project with Trellis + Bedrock + Sage
trellis new my-project
cd my-project/trellis

# Start local development environment
trellis up

# Open site in browser
trellis open

# SSH into the VM
trellis ssh development
```

### Roots Sage Theme

```bash
# In your theme directory
composer create-project roots/sage my-theme
cd my-theme
composer install
pnpm install
pnpm dev
```

### Managing Node.js Versions

```bash
# List installed versions
fnm list

# Install specific version
fnm install 20
fnm install 18

# Switch version
fnm use 20

# Set default
fnm default 20
```

### Valet Directory Parking

```bash
# Park a directory so all subdirectories become .test sites
cd ~/Sites
valet park

# Now any directory becomes sitename.test
# ~/Sites/wordpress -> https://wordpress.test
# ~/Sites/my-app -> https://my-app.test
```

## Useful Commands Reference

```bash
# Valet
valet start              # Start Valet services
valet stop               # Stop Valet services
valet restart            # Restart Valet
valet links              # List all linked sites
valet unlink             # Remove link from current directory
valet secure my-site     # Enable HTTPS for site
valet paths              # List parked paths

# WP-CLI
wp --info                # Show WP-CLI info
wp plugin list           # List installed plugins
wp theme list            # List installed themes
wp db export             # Export database
wp search-replace        # Search and replace in database

# Trellis
trellis --help           # Show all commands
trellis provision        # Provision environment
trellis deploy           # Deploy to environment
trellis logs             # View server logs

# Database
mysql -u root            # Connect to MariaDB
# Or use Sequel Ace GUI

# Node/pnpm
pnpm install             # Install dependencies
pnpm add <package>       # Add dependency
pnpm dev                 # Run dev script
pnpm build               # Run build script
```

## Troubleshooting

### Xcode Command Line Tools Failed

If Xcode tools installation fails:
```bash
xcode-select --install
# Complete installation, then re-run the setup script
```

### Homebrew Permission Issues

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew
```

### Valet Not Working

```bash
# Reinstall Valet
valet uninstall
valet install
```

### Port Conflicts

Valet uses port 80 and 443. If you have conflicts:
```bash
# Check what's using port 80
sudo lsof -i :80

# Stop conflicting services or reconfigure Valet
```

### fnm Command Not Found

```bash
# Ensure fnm is in your shell config
echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
source ~/.zshrc
```

### MariaDB Connection Issues

```bash
# Check if MariaDB is running
brew services list

# Start MariaDB
brew services start mariadb

# Restart MariaDB
brew services restart mariadb
```

## Architecture

This setup creates a hybrid local development environment:

1. **Valet** for simple, lightweight WordPress sites (no VM required)
2. **Trellis/Lima** for production-like environments with Vagrant-style VMs
3. **Docker** as an alternative containerized option

You can use whichever approach fits your project:
- **Valet**: Quick sites, theme development, simple projects
- **Trellis**: Full-stack projects matching production, team deployments
- **Docker**: Containerized environments, microservices

## Updating Installed Tools

```bash
# Update Homebrew and all packages
brew update && brew upgrade

# Update Composer global packages
composer global update

# Update npm global packages
pnpm update -g

# Update WP-CLI packages
wp package update
```

## Uninstallation

To remove components:

```bash
# Uninstall Valet
valet uninstall

# Remove Homebrew packages
brew uninstall <package-name>

# Uninstall Homebrew entirely
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests for:
- Bug fixes
- Additional tools or configurations
- Platform compatibility improvements
- Documentation enhancements

## License

This project is open source and available under the MIT License.

## Resources

### Official Documentation
- [Roots Trellis](https://roots.io/trellis/)
- [Roots Bedrock](https://roots.io/bedrock/)
- [Roots Sage](https://roots.io/sage/)
- [Laravel Valet](https://laravel.com/docs/valet)
- [WP-CLI](https://wp-cli.org/)
- [Homebrew](https://brew.sh/)
- [fnm](https://github.com/Schniz/fnm)

### Community
- [Roots Discourse](https://discourse.roots.io/)
- [WordPress Stack Exchange](https://wordpress.stackexchange.com/)
- [WP-CLI GitHub](https://github.com/wp-cli/wp-cli)

---

Made with care for the WordPress development community.
