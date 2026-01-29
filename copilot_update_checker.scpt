-- Copilot CLI Update Checker AppleScript
-- Checks for updates to copilot-cli via Homebrew and updates if available
-- Sends notifications with results

on run
	set logFile to "/tmp/copilot-update-checker.log"
	
	try
		-- Log start time
		logMessage("Starting Copilot CLI update check", logFile)
		
		-- Check if Homebrew is installed
		set brewPath to getBrewPath()
		if brewPath is "" then
			set errorMsg to "Homebrew not found. Please install Homebrew first."
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Error"
			logMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		logMessage("Found Homebrew at: " & brewPath, logFile)
		
		-- Check if copilot-cli is installed
		if not isCopilotInstalled(brewPath) then
			set errorMsg to "Copilot CLI not found. Install with: brew install --cask copilot-cli"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Not Installed"
			logMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		logMessage("Copilot CLI is installed", logFile)
		
		-- Update Homebrew
		logMessage("Updating Homebrew...", logFile)
		do shell script brewPath & " update 2>&1"
		
		-- Check for copilot-cli updates
		set updateCheck to do shell script brewPath & " outdated --cask copilot-cli 2>/dev/null || true"
		
		if updateCheck contains "copilot-cli" then
			-- Update available
			display notification "Copilot CLI update available! Updating now..." with title "Copilot CLI Updater" subtitle "Updating"
			logMessage("Update available, updating copilot-cli...", logFile)
			
			try
				do shell script brewPath & " upgrade --cask copilot-cli 2>&1"
				display notification "Copilot CLI updated successfully!" with title "Copilot CLI Updater" subtitle "Success"
				logMessage("Successfully updated copilot-cli", logFile)
			on error updateError
				set errorMsg to "Failed to update copilot-cli: " & updateError
				display notification errorMsg with title "Copilot CLI Updater" subtitle "Update Failed"
				logMessage("ERROR: " & errorMsg, logFile)
			end try
		else
			-- No updates available
			display notification "Copilot CLI is up to date!" with title "Copilot CLI Updater" subtitle "No Updates"
			logMessage("Copilot CLI is already up to date", logFile)
		end if
		
	on error scriptError
		set errorMsg to "Script error: " & scriptError
		display notification errorMsg with title "Copilot CLI Updater" subtitle "Script Error"
		logMessage("ERROR: " & errorMsg, logFile)
	end try
end run

-- Function to get Homebrew path (supports both Intel and Apple Silicon)
on getBrewPath()
	set brewPaths to {"/opt/homebrew/bin/brew", "/usr/local/bin/brew"}
	repeat with brewPath in brewPaths
		try
			do shell script "test -f " & brewPath
			return brewPath
		end try
	end repeat
	return ""
end getBrewPath

-- Function to check if copilot-cli is installed
on isCopilotInstalled(brewPath)
	try
		set caskList to do shell script brewPath & " list --cask 2>/dev/null | grep copilot-cli || true"
		if caskList contains "copilot-cli" then
			return true
		end if
		
		-- Also check formula installations
		set formulaList to do shell script brewPath & " list 2>/dev/null | grep copilot-cli || true"
		if formulaList contains "copilot-cli" then
			return true
		end if
		
		return false
	on error
		return false
	end try
end isCopilotInstalled

-- Function to log messages with timestamp
on logMessage(message, logFile)
	set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
	set logEntry to "[" & timestamp & "] " & message
	try
		do shell script "echo " & quoted form of logEntry & " >> " & quoted form of logFile
	end try
end logMessage