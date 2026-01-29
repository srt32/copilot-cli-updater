# Copilot CLI Updater 🔐

A **security-hardened** daily automation for macOS that checks for updates to the GitHub Copilot CLI (installed via Homebrew) and automatically updates it when available. Provides desktop notifications about the update status.

> **🔐 Security Note**: This project has been hardened against common security vulnerabilities including command injection, insecure file storage, and information disclosure. All operations use secure coding practices.

## 🚀 Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/srt32/copilot-cli-updater.git
   cd copilot-cli-updater
   ```

2. **Run the secure installer:**
   ```bash
   ./install.sh
   ```

That's it! The automation will now run daily at 9:00 AM and securely check for Copilot CLI updates.

## 📋 How It Works

### Architecture

The automation consists of three main components:

1. **AppleScript** (`copilot_update_checker.scpt`) - The core logic
2. **LaunchAgent** (`com.user.copilot-update-checker.plist`) - Schedules daily execution
3. **Install Script** (`install.sh`) - Sets everything up automatically

### Workflow

```
┌─────────────────┐
│ Daily at 9:00 AM│
└────────┬────────┘
         ▼
┌─────────────────┐
│LaunchAgent runs │
└────────┬────────┘
         ▼
┌─────────────────┐     ┌──────────────────┐
│Homebrew installed?├──No─►│Show error notice │
└────────┬────────┘     └──────────────────┘
        Yes
         ▼
┌─────────────────┐     ┌──────────────────┐
│Copilot CLI found?├──No─►│Show install notice│
└────────┬────────┘     └──────────────────┘
        Yes
         ▼
┌─────────────────┐
│  brew update    │
└────────┬────────┘
         ▼
┌─────────────────┐     ┌──────────────────┐
│Updates available?├──No─►│"Up to date" notice│
└────────┬────────┘     └──────────────────┘
        Yes
         ▼
┌─────────────────┐
│  brew upgrade   │
└────────┬────────┘
         ▼
┌─────────────────┐
│ Show result     │
│ notification    │
└─────────────────┘
```

### What Happens Each Morning

1. **9:00 AM**: macOS LaunchAgent triggers the AppleScript
2. **Environment Check**: Verifies Homebrew and Copilot CLI are installed
3. **Update Check**: Runs `brew update` and checks for Copilot CLI updates
4. **Automatic Update**: If updates are available, runs `brew upgrade --cask copilot-cli`
5. **Notification**: Shows macOS notification with the result

### Notifications You'll See

- ✅ **"Copilot CLI is up to date!"** - No updates needed
- 🔄 **"Copilot CLI update available! Updating now..."** - Update in progress
- ✅ **"Copilot CLI updated successfully!"** - Update completed
- ❌ **Error messages** - If Homebrew/Copilot CLI not found or update fails

## 🛠 Installation Details

### What the secure installer does:

1. **Creates secure directories**: `~/.local/bin`, `~/Library/LaunchAgents`, and `~/Library/Logs` with proper permissions
2. **Installs AppleScript**: Copies hardened script to `~/.local/bin/copilot_update_checker.scpt` (600 permissions)
3. **Installs LaunchAgent**: Copies secure plist to `~/Library/LaunchAgents/` (600 permissions)
4. **Security validation**: Verifies script syntax and Homebrew installation
5. **Checks dependencies**: Validates Homebrew and Copilot CLI installations
6. **Cleans up**: Removes any insecure temporary files from previous installations
7. **Tests installation**: Runs the script once to ensure secure operation
8. **Loads LaunchAgent**: Activates the daily schedule with security validations

### Security Improvements in Installation

- ✅ **Secure permissions**: All files created with restrictive permissions (600/700)
- ✅ **Syntax validation**: AppleScript syntax is validated before installation
- ✅ **Path validation**: Homebrew installation is verified and validated
- ✅ **Cleanup operations**: Removes insecure temporary files from previous versions
- ✅ **Security testing**: Installation includes security-focused validation tests

### Prerequisites

- **macOS**: This automation only works on macOS
- **Homebrew**: Install from [brew.sh](https://brew.sh)
- **Copilot CLI**: The installer will attempt to install it automatically

## 🔧 Management

### Manual Testing
```bash
# Run the update check manually
osascript ~/.local/bin/copilot_update_checker.scpt
```

### View Secure Logs
```bash
# View recent secure log entries
tail -f ~/Library/Logs/copilot-update-checker.log

# View error logs
tail -f ~/Library/Logs/copilot-update-checker.error.log
```

### Check LaunchAgent Status
```bash
# List all LaunchAgents
launchctl list | grep copilot

# Check if our agent is loaded
launchctl list com.user.copilot-update-checker
```

### Modify Schedule
Edit the plist file to change when the automation runs:
```bash
nano ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
```

Then reload the LaunchAgent:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
launchctl load ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
```

## 🗑 Uninstallation

```bash
./uninstall.sh
```

This will:
- Unload and remove the LaunchAgent
- Remove the AppleScript
- Optionally remove log files
- Keep Copilot CLI installed (removes only the automation)

## 🐛 Troubleshooting

### The automation isn't running
1. Check if the LaunchAgent is loaded:
   ```bash
   launchctl list com.user.copilot-update-checker
   ```

2. If not loaded, reload it:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.user.copilot-update-checker.plist
   ```

### No notifications appearing
1. Check macOS notification settings for "Script Editor" or "osascript"
2. Run the script manually to test notifications:
   ```bash
   osascript ~/.local/bin/copilot_update_checker.scpt
   ```

### Homebrew not found
The script supports both Intel and Apple Silicon Mac Homebrew paths:
- Intel Macs: `/usr/local/bin/brew`
- Apple Silicon Macs: `/opt/homebrew/bin/brew`

### Copilot CLI not detected
The script checks for both formula and cask installations:
```bash
# Check if installed as cask (recommended)
brew list --cask | grep copilot-cli

# Check if installed as formula
brew list | grep copilot-cli
```

### Permission issues
If you see permission errors, run the installer again to ensure proper permissions are set:
```bash
./install.sh
```

### Logs show errors
Check the detailed secure logs for specific error messages:
```bash
# Main secure log
cat ~/Library/Logs/copilot-update-checker.log

# Error log
cat ~/Library/Logs/copilot-update-checker.error.log
```

## 📁 File Structure

```
copilot-cli-updater/
├── copilot_update_checker.scpt      # Main AppleScript automation
├── com.user.copilot-update-checker.plist  # LaunchAgent configuration
├── install.sh                       # Installation script
├── uninstall.sh                     # Uninstallation script
└── README.md                        # This documentation
```

## 🔐 Security & Privacy

### Security Hardening Implemented

This automation has been **security-hardened** to protect against common vulnerabilities:

#### ✅ **Command Injection Protection**
- All shell commands use proper quoting with `quoted form of`
- Input validation for all external data (brew paths, command output)
- No direct string concatenation in shell commands

#### ✅ **Secure File Storage**
- Logs stored in `~/Library/Logs/` with `600` permissions (user-only access)
- No world-readable files in `/tmp/` directory
- Secure directory creation with `700` permissions

#### ✅ **Information Disclosure Prevention**
- Error messages sanitized to prevent sensitive information leakage
- No detailed system paths or internal details in notifications
- Fail-safe error handling without exposing internals

#### ✅ **Dynamic Path Resolution**
- No hardcoded user paths in configuration files
- Runtime detection of user home directory
- Supports multiple system configurations

#### ✅ **File Permission Security**
- AppleScript: `600` permissions (owner read/write only)
- LaunchAgent plist: `600` permissions (owner read/write only)
- Log directory: `700` permissions (owner access only)
- Log files: `600` permissions (owner read/write only)

#### ✅ **Validation & Verification**
- Homebrew binary validation before execution
- Script syntax validation during installation
- File existence and permission verification

### Privacy Protection

- **Local execution**: All scripts run locally on your machine
- **No external connections**: Only connects to Homebrew repositories (same as manual `brew` commands)
- **Minimal permissions**: Only requires access to run Homebrew commands
- **Open source**: All code is visible and auditable
- **No data collection**: No telemetry or usage data transmitted

### Security Best Practices Followed

1. **Principle of Least Privilege**: Scripts run with minimal necessary permissions
2. **Input Validation**: All external input is validated and sanitized
3. **Secure Defaults**: All file operations use secure permissions by default
4. **Error Handling**: Graceful error handling without information disclosure
5. **Code Auditing**: Clear, readable code structure for security review

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test them
4. Commit your changes: `git commit -m "Description"`
5. Push to the branch: `git push origin feature-name`
6. Create a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## ❓ FAQ

**Q: Will this work with other Homebrew packages?**  
A: The script is specifically designed for Copilot CLI, but could be adapted for other packages.

**Q: Can I change the update time?**  
A: Yes, edit the plist file and change the Hour/Minute values, then reload the LaunchAgent.

**Q: Will this interfere with manual Homebrew usage?**  
A: No, it only runs `brew update` and `brew upgrade --cask copilot-cli`, which are safe operations.

**Q: What if my Mac is asleep at 9 AM?**  
A: The LaunchAgent will run the next time your Mac wakes up.

**Q: Can I run this on multiple Macs?**  
A: Yes, install it on each Mac independently. Each installation is local to that machine.