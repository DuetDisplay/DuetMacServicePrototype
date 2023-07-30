# DuetServicePrototype

The goal of this project is to demonstrate the new proposed architecture to use in the macOS app that enables remote access to Duet even if there is no logged in user. 

## Overview
In order to achieve this, the app had to be restructured into multiple processes.

Some parts of Duet had to be moved into a separate process running as a Launch Daemon. This process is launched during system boot; no active user session is needed. This component will implement Duet connectivity, serving as a listener that manages the network communication with the remote client.

Since Launch Daemons interaction with the GUI is very limited, another new component is introduced: a hybrid Launch Agent that can run both in root and user context. This component's responsibility is capturing the screen, synthesizing user events, and sending screen data to the network component/receiving user event data from the network component.

There will be a purely GUI component too, that will implement the actual user interface of the app, and also the Remote Desktop client/viewer functionality. 

## Installation
1. Copy the app to /Applications.
2. Starting and stopping the daemon and launch agent components of the application are managed by macOS, using launchd. To let the system know we need these processes up and running, we need to copy plist descriptors of these processes:

```
$ sudo cp /Applications/DuetDesktopCaptureManager.app/Contents/Resources/com.kairos.duet.DesktopCaptureManager.plist /Library/LaunchAgents

$ sudo cp /Applications/DuetDesktopCaptureManager.app/Contents/Resources/com.kairos.DuetCoreService.plist /Library/LaunchDaemons
```

3. Make sure the plists are owned by root:wheel:

```
$ sudo chown root:wheel /Library/LaunchDaemons/com.kairos.DuetCoreService.plist 
$ sudo chown root:wheel /Library/LaunchAgents/com.kairos.duet.DesktopCaptureManager.plist

```

4. Launch the services:

```
$ sudo launchctl load /Library/LaunchDaemons/com.kairos.DuetCoreService.plist
$ sudo launchctl load /Library/LaunchAgents/com.kairos.duet.DesktopCaptureManager.plist

```