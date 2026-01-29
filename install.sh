#!/bin/bash

# Copilot CLI Updater Installer
# This script installs the daily Copilot CLI update checker automation

set -e

echo "🚀 Installing Copilot CLI Update Checker..."

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

# Create necessary directories
print_status "Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/Library/LaunchAgents

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install the AppleScript
print_status "Installing AppleScript..."
if [[ -f "$SCRIPT_DIR/copilot_update_checker.scpt" ]]; then
    cp "$SCRIPT_DIR/copilot_update_checker.scpt" ~/.local/bin/
    chmod +x ~/.local/bin/copilot_update_checker.scpt
    print_success "AppleScript installed to ~/.local/bin/"
else
    print_error "copilot_update_checker.scpt not found in $SCRIPT_DIR"
    exit 1
fi

# Install the LaunchAgent plist
print_status "Installing LaunchAgent..."
if [[ -f "$SCRIPT_DIR/com.user.copilot-update-checker.plist" ]]; then
    # Replace $HOME placeholder with actual home directory
    sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/com.user.copilot-update-checker.plist" > ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
    print_success "LaunchAgent installed to ~/Library/LaunchAgents/"
else
    print_error "com.user.copilot-update-checker.plist not found in $SCRIPT_DIR"
    exit 1
fi

# Check if Homebrew is installed
print_status "Checking for Homebrew..."
if command -v brew &> /dev/null; then
    print_success "Homebrew found: $(which brew)"
else
    print_warning "Homebrew not found. Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
fi

# Check if copilot-cli is installed
print_status "Checking for Copilot CLI..."
if brew list --cask | grep -q copilot-cli || brew list | grep -q copilot-cli; then
    print_success "Copilot CLI is installed"
else
    print_warning "Copilot CLI not found. Installing now..."
    if brew install --cask copilot-cli; then
        print_success "Copilot CLI installed successfully"
    else
        print_error "Failed to install Copilot CLI"
        print_warning "You can install it manually with: brew install --cask copilot-cli"
    fi
fi

# Unload existing LaunchAgent (if any)
print_status "Unloading any existing LaunchAgent..."
launchctl unload ~/Library/LaunchAgents/com.user.copilot-update-checker.plist 2>/dev/null || true

# Load the LaunchAgent
print_status "Loading LaunchAgent..."
if launchctl load ~/Library/LaunchAgents/com.user.copilot-update-checker.plist; then
    print_success "LaunchAgent loaded successfully"
else
    print_error "Failed to load LaunchAgent"
    exit 1
fi

# Test the installation
print_status "Testing installation..."
echo ""
echo "🧪 Running test check..."

# Run the AppleScript manually to test
if osascript ~/.local/bin/copilot_update_checker.scpt; then
    print_success "Test completed successfully!"
else
    print_error "Test failed. Check the logs at /tmp/copilot-update-checker.log"
fi

# Show log file if it exists
if [[ -f "/tmp/copilot-update-checker.log" ]]; then
    echo ""
    echo "📋 Recent log entries:"
    tail -n 10 /tmp/copilot-update-checker.log
fi

echo ""
print_success "Installation completed!"
echo ""
echo "📅 The automation will now run daily at 9:00 AM"
echo "🔍 To manually test: osascript ~/.local/bin/copilot_update_checker.scpt"
echo "📋 View logs: tail -f /tmp/copilot-update-checker.log"
echo "🛑 To uninstall: ./uninstall.sh"
echo ""
echo "🎉 You'll receive macOS notifications about Copilot CLI updates!"