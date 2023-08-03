#!/bin/sh

PROJECT_DIR=$1
BUILT_PRODUCTS_DIR=$2

# Copy the daemon's launchd.plist into /Library/LaunchDaemons
for plist in com.kairos.DuetCoreService.plist
do
  trg=/Library/LaunchDaemons/com.kairos.DuetCoreService.plist
  cp ${PROJECT_DIR}/${plist} ${trg}
  chown root:wheel ${trg}
  chmod 644 ${trg}
done

# Copy the daemon's executable into /Library/PrivilegedHelperTools
for executable in DuetCoreService
do
  trgdir=/Applications/DuetGUI.app/Contents/SharedSupport
  trg=${trgdir}/${executable}
  if [ ! -f ${trgdir} ]; then
	mkdir -p ${trgdir}
  fi
  cp ${BUILT_PRODUCTS_DIR}/${executable} ${trg}
  chown -R root:admin ${trg}
done

# Load the new daemon
#launchctl load /Library/LaunchDaemons/com.kairos.DuetCoreService.plist

