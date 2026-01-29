#!/bin/bash

# Copilot CLI Updater Uninstaller
# This script removes the daily Copilot CLI update checker automation

set -e

echo "🗑️  Uninstalling Copilot CLI Update Checker..."

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

# Unload the LaunchAgent
print_status "Unloading LaunchAgent..."
if launchctl unload ~/Library/LaunchAgents/com.user.copilot-update-checker.plist 2>/dev/null; then
    print_success "LaunchAgent unloaded"
else
    print_warning "LaunchAgent was not loaded or already unloaded"
fi

# Remove the LaunchAgent plist
print_status "Removing LaunchAgent plist..."
if [[ -f ~/Library/LaunchAgents/com.user.copilot-update-checker.plist ]]; then
    rm ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
    print_success "LaunchAgent plist removed"
else
    print_warning "LaunchAgent plist not found"
fi

# Remove the AppleScript
print_status "Removing AppleScript..."
if [[ -f ~/.local/bin/copilot_update_checker.scpt ]]; then
    rm ~/.local/bin/copilot_update_checker.scpt
    print_success "AppleScript removed"
else
    print_warning "AppleScript not found"
fi

# Remove log files (optional)
read -p "Do you want to remove log files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Removing log files..."
    rm -f /tmp/copilot-update-checker.log
    rm -f /tmp/copilot-update-checker.error.log
    print_success "Log files removed"
else
    print_status "Log files preserved at /tmp/copilot-update-checker*.log"
fi

echo ""
print_success "Uninstallation completed!"
echo ""
echo "ℹ️  Note: Copilot CLI itself was not removed. To remove it:"
echo "   brew uninstall --cask copilot-cli"