-- Copilot CLI Update Checker AppleScript (SECURITY HARDENED)
-- Checks for updates to copilot-cli via Homebrew and updates if available
-- Sends notifications with results

on run
	-- Use secure logging directory with proper permissions
	set userHome to (path to home folder as string)
	set logDir to userHome & "Library:Logs:"
	set logFile to (logDir & "copilot-update-checker.log") as string
	
	-- Ensure log directory exists with secure permissions
	try
		do shell script "mkdir -p " & quoted form of (POSIX path of logDir) & " && chmod 700 " & quoted form of (POSIX path of logDir)
	on error
		display notification "Failed to create secure log directory" with title "Copilot CLI Updater" subtitle "Security Error"
		return
	end try
	
	try
		-- Log start time
		secureLogMessage("Starting Copilot CLI update check", logFile)
		
		-- Check if Homebrew is installed with validation
		set brewPath to getSecureBrewPath()
		if brewPath is "" then
			set errorMsg to "Homebrew not found"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Error"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("Found Homebrew installation", logFile)
		
		-- Validate brew path before use
		if not isValidBrewPath(brewPath) then
			set errorMsg to "Invalid Homebrew installation detected"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Security Error"
			secureLogMessage("SECURITY ERROR: Invalid brew path", logFile)
			return
		end if
		
		-- Check if copilot-cli is installed
		if not isCopilotInstalledSecure(brewPath) then
			set errorMsg to "Copilot CLI not found"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Not Installed"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("Copilot CLI is installed", logFile)
		
		-- Update Homebrew with secure command execution
		secureLogMessage("Updating Homebrew...", logFile)
		set updateCmd to quoted form of brewPath & " update"
		do shell script updateCmd
		
		-- Check for copilot-cli updates with secure execution
		set outdatedCmd to quoted form of brewPath & " outdated --cask copilot-cli 2>/dev/null || true"
		set updateCheck to do shell script outdatedCmd
		
		if updateCheck contains "copilot-cli" then
			-- Update available
			display notification "Update available! Updating now..." with title "Copilot CLI Updater" subtitle "Updating"
			secureLogMessage("Update available, updating copilot-cli...", logFile)
			
			try
				set upgradeCmd to quoted form of brewPath & " upgrade --cask copilot-cli"
				do shell script upgradeCmd
				display notification "Updated successfully!" with title "Copilot CLI Updater" subtitle "Success"
				secureLogMessage("Successfully updated copilot-cli", logFile)
			on error
				set errorMsg to "Update failed"
				display notification errorMsg with title "Copilot CLI Updater" subtitle "Update Failed"
				secureLogMessage("ERROR: " & errorMsg, logFile)
			end try
		else
			-- No updates available
			display notification "Copilot CLI is up to date!" with title "Copilot CLI Updater" subtitle "No Updates"
			secureLogMessage("Copilot CLI is already up to date", logFile)
		end if
		
	on error
		set errorMsg to "Script execution failed"
		display notification errorMsg with title "Copilot CLI Updater" subtitle "Error"
		secureLogMessage("ERROR: " & errorMsg, logFile)
	end try
end run

-- Function to get Homebrew path with security validation
on getSecureBrewPath()
	set brewPaths to {"/opt/homebrew/bin/brew", "/usr/local/bin/brew"}
	repeat with brewPath in brewPaths
		try
			-- Validate path exists and is executable
			do shell script "test -f " & quoted form of brewPath & " && test -x " & quoted form of brewPath
			return brewPath
		end try
	end repeat
	return ""
end getSecureBrewPath

-- Function to validate brew path for security
on isValidBrewPath(brewPath)
	try
		-- Ensure it's an actual brew binary and not something else
		set brewVersion to do shell script quoted form of brewPath & " --version 2>/dev/null | head -1"
		if brewVersion contains "Homebrew" then
			return true
		end if
	on error
		return false
	end try
	return false
end isValidBrewPath

-- Function to check if copilot-cli is installed (secure version)
on isCopilotInstalledSecure(brewPath)
	try
		-- Use secure command execution with proper quoting
		set caskListCmd to quoted form of brewPath & " list --cask 2>/dev/null"
		set caskList to do shell script caskListCmd
		if caskList contains "copilot-cli" then
			return true
		end if
		
		-- Also check formula installations
		set formulaListCmd to quoted form of brewPath & " list 2>/dev/null"
		set formulaList to do shell script formulaListCmd
		if formulaList contains "copilot-cli" then
			return true
		end if
		
		return false
	on error
		return false
	end try
end isCopilotInstalledSecure

-- Function to log messages with timestamp and secure file handling
on secureLogMessage(message, logFile)
	try
		set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
		set logEntry to "[" & timestamp & "] " & message
		set logFilePath to quoted form of (POSIX path of logFile)
		
		-- Create log file with secure permissions if it doesn't exist
		do shell script "touch " & logFilePath & " && chmod 600 " & logFilePath
		
		-- Append log entry securely
		do shell script "echo " & quoted form of logEntry & " >> " & logFilePath
	on error
		-- Fail silently for logging errors to prevent recursive issues
	end try
end secureLogMessage