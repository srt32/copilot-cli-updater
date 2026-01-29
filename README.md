# Copilot CLI Updater

A daily automation for macOS that checks for updates to the GitHub Copilot CLI (installed via Homebrew) and automatically updates it when available. Provides desktop notifications about the update status.

## 🚀 Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/srt32/copilot-cli-updater.git
   cd copilot-cli-updater
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

That's it! The automation will now run daily at 9:00 AM and check for Copilot CLI updates.

## 📋 How It Works

### Architecture

The automation consists of three main components:

1. **AppleScript** (`copilot_update_checker.scpt`) - The core logic
2. **LaunchAgent** (`com.user.copilot-update-checker.plist`) - Schedules daily execution
3. **Install Script** (`install.sh`) - Sets everything up automatically

### Workflow

```mermaid
flowchart TD
    A[Daily at 9:00 AM] --> B[LaunchAgent triggers]
    B --> C[AppleScript runs]
    C --> D{Homebrew installed?}
    D -->|No| E[Show error notification]
    D -->|Yes| F{Copilot CLI installed?}
    F -->|No| G[Show install notification]
    F -->|Yes| H[Update Homebrew cache]
    H --> I{Updates available?}
    I -->|No| J[Show "up to date" notification]
    I -->|Yes| K[Show "updating" notification]
    K --> L[Run brew upgrade]
    L --> M{Update successful?}
    M -->|Yes| N[Show "success" notification]
    M -->|No| O[Show "failed" notification]
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

### What the installer does:

1. **Creates directories**: `~/.local/bin` and `~/Library/LaunchAgents`
2. **Installs AppleScript**: Copies script to `~/.local/bin/copilot_update_checker.scpt`
3. **Installs LaunchAgent**: Copies plist to `~/Library/LaunchAgents/`
4. **Checks dependencies**: Verifies Homebrew and Copilot CLI are installed
5. **Tests installation**: Runs the script once to ensure it works
6. **Loads LaunchAgent**: Activates the daily schedule

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

### View Logs
```bash
# View recent log entries
tail -f /tmp/copilot-update-checker.log

# View error logs
tail -f /tmp/copilot-update-checker.error.log
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
If you see permission errors, ensure the AppleScript has execute permissions:
```bash
chmod +x ~/.local/bin/copilot_update_checker.scpt
```

### Logs show errors
Check the detailed logs for specific error messages:
```bash
# Main log
cat /tmp/copilot-update-checker.log

# Error log
cat /tmp/copilot-update-checker.error.log
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

- **Local execution**: All scripts run locally on your machine
- **No external connections**: Only connects to Homebrew repositories (same as manual `brew` commands)
- **Minimal permissions**: Only requires access to run Homebrew commands
- **Open source**: All code is visible and auditable

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