-- Copilot CLI Update Checker AppleScript (Secure Version)
-- Checks for updates to copilot-cli via Homebrew and updates if available
-- Sends notifications with results
-- Security hardened with input validation and secure file handling

on run
	-- Use secure log location with proper permissions
	set logDir to (POSIX path of (path to home folder)) & "Library/Logs"
	set logFile to logDir & "/copilot-update-checker.log"
	
	-- Ensure log directory exists with secure permissions
	try
		do shell script "mkdir -p " & quoted form of logDir & " && chmod 700 " & quoted form of logDir
	end try
	
	try
		-- Log start time with secure logging
		secureLogMessage("Starting Copilot CLI update check", logFile)
		
		-- Check if Homebrew is installed with validation
		set brewPath to getSecureBrewPath()
		if brewPath is "" then
			set errorMsg to "Homebrew not found"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Configuration Error"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("Found Homebrew at validated path", logFile)
		
		-- Check if copilot-cli is installed with secure validation
		if not isSecureCopilotInstalled(brewPath) then
			set errorMsg to "Copilot CLI not found"
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Not Installed"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("Copilot CLI is installed", logFile)
		
		-- Update Homebrew with secure command execution
		secureLogMessage("Updating Homebrew...", logFile)
		do shell script quoted form of brewPath & " update 2>&1"
		
		-- Check for copilot-cli updates with secure command
		set updateCheck to do shell script quoted form of brewPath & " outdated --cask copilot-cli 2>/dev/null || true"
		
		if updateCheck contains "copilot-cli" then
			-- Update available
			display notification "Copilot CLI update available! Updating now..." with title "Copilot CLI Updater" subtitle "Updating"
			secureLogMessage("Update available, updating copilot-cli...", logFile)
			
			try
				do shell script quoted form of brewPath & " upgrade --cask copilot-cli 2>&1"
				display notification "Copilot CLI updated successfully!" with title "Copilot CLI Updater" subtitle "Success"
				secureLogMessage("Successfully updated copilot-cli", logFile)
			on error updateError
				-- Sanitize error message to prevent information disclosure
				set errorMsg to "Update failed"
				display notification errorMsg with title "Copilot CLI Updater" subtitle "Update Failed"
				secureLogMessage("ERROR: Update failed with error", logFile)
			end try
		else
			-- No updates available
			display notification "Copilot CLI is up to date!" with title "Copilot CLI Updater" subtitle "No Updates"
			secureLogMessage("Copilot CLI is already up to date", logFile)
		end if
		
	on error scriptError
		-- Sanitize error message to prevent information disclosure
		set errorMsg to "Script error occurred"
		display notification errorMsg with title "Copilot CLI Updater" subtitle "Script Error"
		secureLogMessage("ERROR: Script error occurred", logFile)
	end try
end run

-- Secure function to get Homebrew path with validation
on getSecureBrewPath()
	set brewPaths to {"/opt/homebrew/bin/brew", "/usr/local/bin/brew"}
	repeat with brewPath in brewPaths
		try
			-- Validate brew binary exists and is executable
			do shell script "test -f " & quoted form of brewPath & " && test -x " & quoted form of brewPath
			-- Additional validation that it's actually brew
			set brewVersion to do shell script quoted form of brewPath & " --version 2>/dev/null | head -1"
			if brewVersion contains "Homebrew" then
				return brewPath
			end if
		end try
	end repeat
	return ""
end getSecureBrewPath

-- Secure function to check if copilot-cli is installed with input validation
on isSecureCopilotInstalled(brewPath)
	try
		-- Validate brewPath parameter
		if brewPath is "" then return false
		
		-- Secure command execution with proper quoting
		set caskList to do shell script quoted form of brewPath & " list --cask 2>/dev/null | grep -w copilot-cli || true"
		if caskList contains "copilot-cli" then
			return true
		end if
		
		-- Also check formula installations with secure quoting
		set formulaList to do shell script quoted form of brewPath & " list 2>/dev/null | grep -w copilot-cli || true"
		if formulaList contains "copilot-cli" then
			return true
		end if
		
		return false
	on error
		return false
	end try
end isSecureCopilotInstalled

-- Secure function to log messages with timestamp and proper file permissions
on secureLogMessage(message, logFile)
	try
		-- Sanitize message to prevent log injection
		set sanitizedMessage to my sanitizeLogMessage(message)
		set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
		set logEntry to "[" & timestamp & "] " & sanitizedMessage
		
		-- Write to log with secure permissions
		do shell script "echo " & quoted form of logEntry & " >> " & quoted form of logFile & " && chmod 600 " & quoted form of logFile
	end try
end secureLogMessage

-- Function to sanitize log messages
on sanitizeLogMessage(message)
	-- Remove potential log injection characters
	set sanitized to my replaceText(message, "\n", " ")
	set sanitized to my replaceText(sanitized, "\r", " ")
	return sanitized
end sanitizeLogMessage

-- Helper function to replace text safely
on replaceText(originalText, searchText, replacementText)
	set AppleScript's text item delimiters to searchText
	set textItems to text items of originalText
	set AppleScript's text item delimiters to replacementText
	set resultText to textItems as string
	set AppleScript's text item delimiters to ""
	return resultText
end replaceText