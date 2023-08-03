#!/bin/sh

if [ -f /Library/LaunchDaemons/com.kairos.DuetCoreService.plist ]; then
	# Unload the daemon
	launchctl unload /Library/LaunchDaemons/com.kairos.DuetCoreService.plist

	# Remove the daemon's launchd.plist
	rm /Library/LaunchDaemons/com.kairos.DuetCoreService.plist
fi

#if [ -f /Library/PrivilegedHelperTools/DuetCoreService ]; then
#	# Remove the daemon's executable
#	rm /Library/PrivilegedHelperTools/DuetCoreService
#fi
