# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains automated setup scripts for configuring a macOS development environment optimized for WordPress development with modern tooling. The setup is specifically tailored for Apple Silicon (M-series) Macs and focuses on a Roots.io workflow (Trellis, Bedrock, Sage).

## Architecture

### Two Main Scripts

1. **mac-wp-dev-setup.sh** - Primary setup script that orchestrates the entire development environment installation
2. **setup-github-ssh.sh** - Standalone script for GitHub SSH key generation and configuration

### Installation Flow (mac-wp-dev-setup.sh)

The script follows a sequential installation pattern with 12 main steps:

1. Xcode Command Line Tools (prerequisite for all development)
2. Homebrew (package manager)
3. Git verification (installed with Xcode)
4. GitHub CLI (gh)
5. Lima (VM manager for Trellis)
6. Ansible + Trellis CLI (WordPress deployment automation)
7. PHP + Composer (PHP runtime and dependency management)
8. MariaDB (database server)
9. Laravel Valet (local development server)
10. WP-CLI + Valet command package (WordPress CLI tools)
11. Node.js via fnm + pnpm (JavaScript runtime and package manager)
12. GUI applications (VS Code, Docker, Warp, Sequel Ace, Claude Code)

### Key Design Patterns

**Idempotency**: Each installation step checks if the tool is already installed before attempting installation. This allows the script to be run multiple times safely.

**Interactive Prompts**: The script pauses at critical points (Xcode installation, GitHub SSH setup) requiring user interaction before proceeding.

**Path Management**: Adds necessary paths to `~/.zshrc` for persistent shell configuration:
- Homebrew bin directory
- Composer global bin directory
- fnm environment
- VS Code CLI tools

**Error Handling**: Uses `set -e` to exit on any error, preventing cascading failures.

### Shell Configuration Files Modified

The scripts modify `~/.zshrc` and `~/.zprofile` to add:
- Homebrew environment variables
- Composer global bin directory
- fnm Node.js version manager
- VS Code CLI command

## Development Stack

### WordPress-Specific Tools

- **Trellis**: Server provisioning and deployment (uses Ansible)
- **Bedrock**: WordPress boilerplate with modern development tools
- **Sage**: WordPress starter theme with build process
- **Laravel Valet**: Local development server (serves .test domains)
- **WP-CLI**: WordPress command-line interface

### Infrastructure

- **Lima**: Lightweight VM manager (used by Trellis for local development)
- **Docker Desktop**: Container runtime (alternative to Trellis/Lima)
- **MariaDB**: Drop-in MySQL replacement

### Runtime Environments

- **PHP**: Latest version via Homebrew
- **Node.js**: Managed by fnm (Fast Node Manager) - preferred over nvm for Apple Silicon
- **pnpm**: Package manager (faster alternative to npm/yarn)

## Common Commands

### Running the Setup

```bash
# Make scripts executable
chmod +x mac-wp-dev-setup.sh setup-github-ssh.sh

# Run main setup
./mac-wp-dev-setup.sh

# Setup GitHub SSH (optional, standalone)
./setup-github-ssh.sh
```

### Trellis Workflow

```bash
# Create new Trellis + Bedrock + Sage project
trellis new mysite
cd mysite/trellis

# Start local development environment
trellis up

# Open site in browser
trellis open

# SSH into VM
trellis ssh

# Deploy to staging/production
trellis deploy staging
```

### Valet Workflow

```bash
# Park a directory (all subdirs become .test sites)
cd ~/Sites
valet park

# Link individual site
cd my-project
valet link my-site  # Creates my-site.test

# Quick WordPress setup with WP-CLI
wp valet new my-site  # Complete WordPress installation at my-site.test
```

### Node.js Version Management

```bash
# fnm is used instead of nvm (optimized for M-series chips)
fnm list                    # Show installed versions
fnm install --lts           # Install latest LTS
fnm install 18              # Install specific version
fnm use 18                  # Switch version
fnm default 18              # Set default version
```

## Platform-Specific Considerations

### Apple Silicon (M-series) Optimizations

- Homebrew installs to `/opt/homebrew` (not `/usr/local`)
- fnm is preferred over nvm for better ARM64 performance
- All tools installed are Apple Silicon native builds where available
- Script warns if run on non-ARM64 architecture but continues

### Shell Environment

- Assumes zsh shell (macOS default since Catalina)
- Configuration added to `~/.zshrc` and `~/.zprofile`
- Requires terminal restart or `source ~/.zshrc` after installation

## SSH Configuration (setup-github-ssh.sh)

### What It Does

1. Generates ed25519 SSH key pair (modern, secure algorithm)
2. Starts ssh-agent and adds key to macOS keychain
3. Creates `~/.ssh/config` with automatic key loading
4. Copies public key to clipboard
5. Opens GitHub SSH settings in browser
6. Tests GitHub connection after user adds key

### SSH Config Structure

The script creates `~/.ssh/config` with:
- GitHub-specific configuration (host github.com)
- Automatic keychain integration (UseKeychain yes)
- Agent forwarding (AddKeysToAgent yes)
- Default identity file (~/.ssh/id_ed25519)

## Post-Installation Steps

After running mac-wp-dev-setup.sh, users typically need to:

1. Restart terminal or source shell config
2. Launch Docker Desktop (first-time setup)
3. Secure MariaDB: `sudo mysql_secure_installation`
4. Configure Git identity
5. Authenticate GitHub CLI: `gh auth login`
6. Setup SSH keys if using Git via SSH

## Script Modification Guidelines

- Maintain idempotency - always check before installing
- Use color-coded output functions: `print_status`, `print_success`, `print_warning`
- Update step counters in output messages if adding/removing steps
- Test on both fresh and partially-configured systems
- Preserve interactive prompts for critical steps (Xcode, SSH)
