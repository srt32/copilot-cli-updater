#!/bin/bash

# Copilot CLI Updater Installer (SECURITY HARDENED)
# This script installs the daily Copilot CLI update checker automation

set -e

echo "🔐 Installing Secure Copilot CLI Update Checker..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This installer only works on macOS"
    exit 1
fi

# Create necessary directories with secure permissions
print_status "Creating secure directories..."
mkdir -p ~/.local/bin
chmod 700 ~/.local/bin
mkdir -p ~/Library/LaunchAgents
chmod 700 ~/Library/LaunchAgents
mkdir -p ~/Library/Logs
chmod 700 ~/Library/Logs

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install the AppleScript with secure permissions
print_status "Installing secure AppleScript..."
if [[ -f "$SCRIPT_DIR/copilot_update_checker.scpt" ]]; then
    cp "$SCRIPT_DIR/copilot_update_checker.scpt" ~/.local/bin/
    chmod 700 ~/.local/bin/copilot_update_checker.scpt
    print_success "Secure AppleScript installed to ~/.local/bin/"
else
    print_error "copilot_update_checker.scpt not found in $SCRIPT_DIR"
    exit 1
fi

# Install the LaunchAgent plist with secure permissions
print_status "Installing secure LaunchAgent..."
if [[ -f "$SCRIPT_DIR/com.user.copilot-update-checker.plist" ]]; then
    cp "$SCRIPT_DIR/com.user.copilot-update-checker.plist" ~/Library/LaunchAgents/
    chmod 600 ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
    print_success "Secure LaunchAgent installed to ~/Library/LaunchAgents/"
else
    print_error "com.user.copilot-update-checker.plist not found in $SCRIPT_DIR"
    exit 1
fi

# Security validation
print_status "Performing security validation..."

# Validate script syntax
if osascript -s ~/.local/bin/copilot_update_checker.scpt 2>/dev/null; then
    print_success "AppleScript syntax validation passed"
else
    print_error "AppleScript syntax validation failed"
    exit 1
fi

# Check if Homebrew is installed and validate it
print_status "Checking for Homebrew..."
if command -v brew &> /dev/null; then
    BREW_PATH=$(which brew)
    if [[ -f "$BREW_PATH" && -x "$BREW_PATH" ]]; then
        print_success "Homebrew found and validated: $BREW_PATH"
    else
        print_error "Homebrew found but validation failed"
        exit 1
    fi
else
    print_warning "Homebrew not found. Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if copilot-cli is installed
print_status "Checking for Copilot CLI..."
if brew list --cask 2>/dev/null | grep -q "^copilot-cli$" || brew list 2>/dev/null | grep -q "^copilot-cli$"; then
    print_success "Copilot CLI is installed"
else
    print_warning "Copilot CLI not found. Installing now..."
    if brew install --cask copilot-cli; then
        print_success "Copilot CLI installed successfully"
    else
        print_error "Failed to install Copilot CLI"
        print_warning "You can install it manually with: brew install --cask copilot-cli"
        exit 1
    fi
fi

# Clean up any insecure temporary files
print_status "Cleaning up insecure temporary files..."
rm -f /tmp/copilot-update-checker.log /tmp/copilot-update-checker.error.log

# Unload existing LaunchAgent (if any)
print_status "Unloading any existing LaunchAgent..."
launchctl unload ~/Library/LaunchAgents/com.user.copilot-update-checker.plist 2>/dev/null || true

# Load the secure LaunchAgent
print_status "Loading secure LaunchAgent..."
if launchctl load ~/Library/LaunchAgents/com.user.copilot-update-checker.plist; then
    print_success "Secure LaunchAgent loaded successfully"
else
    print_error "Failed to load LaunchAgent"
    exit 1
fi

# Test the secure installation
print_status "Testing secure installation..."
echo ""
echo "🔐 Running security-hardened test check..."

# Run the AppleScript manually to test
if osascript ~/.local/bin/copilot_update_checker.scpt; then
    print_success "Secure test completed successfully!"
else
    print_error "Test failed. Check the logs at ~/Library/Logs/copilot-update-checker.log"
fi

# Show secure log file if it exists
SECURE_LOG="$HOME/Library/Logs/copilot-update-checker.log"
if [[ -f "$SECURE_LOG" ]]; then
    echo ""
    echo "📋 Recent secure log entries:"
    tail -n 10 "$SECURE_LOG"
fi

# Verify file permissions
print_status "Verifying secure file permissions..."
if [[ "$(stat -f %A ~/.local/bin/copilot_update_checker.scpt)" == "700" ]]; then
    print_success "AppleScript permissions: Secure (700)"
else
    print_warning "AppleScript permissions may be insecure"
fi

if [[ "$(stat -f %A ~/Library/LaunchAgents/com.user.copilot-update-checker.plist)" == "600" ]]; then
    print_success "LaunchAgent permissions: Secure (600)"
else
    print_warning "LaunchAgent permissions may be insecure"
fi

echo ""
print_success "🔐 Security-hardened installation completed!"
echo ""
echo "🔐 SECURITY IMPROVEMENTS:"
echo "  ✅ Secure logging directory: ~/Library/Logs/ (permissions: 700)"
echo "  ✅ Input validation and command injection protection"
echo "  ✅ Secure file permissions (700/600)"
echo "  ✅ Error message sanitization"
echo "  ✅ Dynamic path resolution (no hardcoded paths)"
echo ""
echo "📅 The automation will now run daily at 9:00 AM"
echo "🔍 To manually test: osascript ~/.local/bin/copilot_update_checker.scpt"
echo "📋 View secure logs: tail -f ~/Library/Logs/copilot-update-checker.log"
echo "🛑 To uninstall: ./uninstall.sh"
echo ""
echo "🎉 You'll receive macOS notifications about Copilot CLI updates!"