-- Secure Copilot CLI Update Checker with Enhanced Notifications
-- Enhanced version with both notifications and dialog boxes for visibility

on run
	try
		-- Create secure log directory with proper permissions
		set homeDir to (path to home folder as string)
		set logDir to homeDir & "Library:Logs:"
		set logFile to logDir & "copilot-update-checker.log"
		
		-- Ensure log directory exists with secure permissions
		try
			do shell script "mkdir -p " & quoted form of POSIX path of logDir
			do shell script "chmod 700 " & quoted form of POSIX path of logDir
		on error
			display dialog "❌ Failed to create secure log directory" buttons {"OK"} default button 1
			display notification "Failed to create secure log directory" with title "Copilot CLI Updater" subtitle "Security Error"
			return
		end try
		
		-- Show start notification AND dialog
		display notification "🔍 Starting Copilot CLI update check..." with title "Copilot CLI Updater" subtitle "Checking"
		display dialog "🔍 Starting Copilot CLI update check..." buttons {"Continue"} default button 1 giving up after 3
		
		secureLogMessage("=== Starting Copilot CLI update check ===", logFile)
		
		-- Get and validate Homebrew installation
		set brewPath to getSecureBrewPath()
		if brewPath is "" then
			set errorMsg to "Homebrew not found or not secure"
			display dialog "❌ " & errorMsg buttons {"OK"} default button 1
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Error"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("✅ Found secure Homebrew at: " & brewPath, logFile)
		
		-- Validate Homebrew binary for security
		if not isValidBrewPath(brewPath) then
			set errorMsg to "Homebrew binary validation failed"
			display dialog "❌ " & errorMsg buttons {"OK"} default button 1
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Security Error"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		-- Check if copilot-cli is installed
		if not isCopilotInstalledSecure(brewPath) then
			set errorMsg to "Copilot CLI not installed via Homebrew"
			display dialog "📦 " & errorMsg & ". Please install first." buttons {"OK"} default button 1
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Not Installed"
			secureLogMessage("ERROR: " & errorMsg, logFile)
			return
		end if
		
		secureLogMessage("✅ Copilot CLI is installed", logFile)
		
		-- Update Homebrew with progress indication
		display notification "🔄 Updating Homebrew..." with title "Copilot CLI Updater" subtitle "Progress"
		display dialog "🔄 Updating Homebrew package database..." buttons {"Continue"} default button 1 giving up after 2
		
		secureLogMessage("🔄 Updating Homebrew...", logFile)
		try
			do shell script quoted form of brewPath & " update 2>/dev/null"
			secureLogMessage("✅ Homebrew updated successfully", logFile)
		on error updateError
			secureLogMessage("⚠️ Homebrew update warning: " & updateError, logFile)
		end try
		
		-- Check for updates with proper security validation
		display notification "🔍 Checking for Copilot updates..." with title "Copilot CLI Updater" subtitle "Scanning"
		display dialog "🔍 Checking for Copilot CLI updates..." buttons {"Continue"} default button 1 giving up after 2
		
		secureLogMessage("🔍 Checking for Copilot CLI updates...", logFile)
		
		try
			-- Use secure command to check for outdated packages
			set outdatedCmd to quoted form of brewPath & " outdated --cask 2>/dev/null"
			set outdatedOutput to do shell script outdatedCmd
			
			-- Secure check if copilot-cli needs updating
			if outdatedOutput contains "copilot-cli" then
				secureLogMessage("📦 Update available for Copilot CLI", logFile)
				
				-- Show update notification AND dialog
				display notification "📦 Update available! Updating now..." with title "Copilot CLI Updater" subtitle "Updating"
				display dialog "📦 Copilot CLI update available! Starting update..." buttons {"Continue"} default button 1 giving up after 3
				
				-- Perform the update with progress indication
				display dialog "⏳ Installing Copilot CLI update..." buttons {"Please Wait"} default button 1 giving up after 2
				
				secureLogMessage("🔄 Starting Copilot CLI update...", logFile)
				set updateCmd to quoted form of brewPath & " upgrade --cask copilot-cli 2>/dev/null"
				do shell script updateCmd
				
				-- Success notifications
				set successMsg to "✅ Copilot CLI updated successfully!"
				display dialog successMsg buttons {"Great!"} default button 1
				display notification "Updated successfully!" with title "Copilot CLI Updater" subtitle "Success"
				secureLogMessage("✅ " & successMsg, logFile)
			else
				-- No updates needed
				set upToDateMsg to "✅ Copilot CLI is up to date!"
				display dialog upToDateMsg buttons {"Perfect!"} default button 1
				display notification "Copilot CLI is up to date!" with title "Copilot CLI Updater" subtitle "No Updates"
				secureLogMessage("✅ " & upToDateMsg, logFile)
			end if
			
		on error updateError
			set errorMsg to "Update check failed"
			display dialog "❌ " & errorMsg buttons {"OK"} default button 1
			display notification errorMsg with title "Copilot CLI Updater" subtitle "Update Failed"
			secureLogMessage("ERROR: " & errorMsg & " - " & updateError, logFile)
		end try
		
		secureLogMessage("=== Update check completed ===", logFile)
		
	on error
		set errorMsg to "Script execution failed"
		display dialog "❌ " & errorMsg buttons {"OK"} default button 1
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
		
		-- Check if copilot-cli cask is in the list
		if caskList contains "copilot-cli" then
			return true
		end if
	on error
		return false
	end try
	return false
end isCopilotInstalledSecure

-- Secure logging function with proper file permissions
on secureLogMessage(message, logFile)
	try
		set timeStamp to (do shell script "date '+%Y-%m-%d %H:%M:%S'")
		set logEntry to "[" & timeStamp & "] " & message
		
		-- Write to log with secure permissions
		do shell script "echo " & quoted form of logEntry & " >> " & quoted form of POSIX path of logFile
		do shell script "chmod 600 " & quoted form of POSIX path of logFile
	on error
		-- Fail silently for logging errors to avoid exposing internals
	end try
end secureLogMessage