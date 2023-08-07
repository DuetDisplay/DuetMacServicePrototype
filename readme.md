# DuetServicePrototype

The goal of this project is to demonstrate the new proposed architecture to use in the macOS app that enables remote access to Duet even if there is no logged in user. 

## Overview
In order to achieve this, the app had to be restructured into multiple processes.

Some parts of Duet had to be moved into a separate process running as a Launch Daemon. This process is launched during system boot; no active user session is needed. This component will implement Duet connectivity, serving as a listener that manages the network communication with the remote client.

Since Launch Daemons interaction with the GUI is very limited, another new component is introduced: a hybrid Launch Agent that can run both in root and user context. This component's responsibility is capturing the screen, synthesizing user events, and sending screen data to the network component/receiving user event data from the network component.

There will be a purely GUI component too, that will implement the actual user interface of the app, and also the Remote Desktop client/viewer functionality. 

``` mermaid
graph LR
  S[Services] -- REST, Websocket <--> Dd[Duet Core Service <BR>Daemon]
  Dd -- Video frames, UI events <--> Ddp[Duet Desktop Capture Manager<BR>hybrid launch agent]
  Dd -- Virtual display <--> Ddp
  Dd -- User actions, App state <--> Dg[Duet GUI<BR>user-space process]
```

## Installation - debugging in Xcode
1. Archive the Duet scheme, the resulting xcarchive will contain the product bundle in Products/Applications/DuetGUI.app
2. Copy this DuetGUI.app into /Applications
3. To start the Duet Core Service component in debug mode (breakpoints, but no logs in Xcode console), Run the Duet Core Service scheme.
4. Xcode will ask for the admin credentials because installing the service component needs root privileges. 
5. Once the Run finishes, Xcode will be in Waiting for executable to start state.
6. Select "Launch daemon" scheme, and cmd+b. 
7. Launchd will start the daemon in the background, and xcode lldb will automatically connect to it.
8. Now you can start separately the DuetDesktopCaptureManager component running the scheme with the same name.
9. Finally start the Duet scheme to debug the Duet app gui component.

### Internals
The Daemon process is installed by Xcode by copying plists to /Library/LaunchDaemons or LaunchAgents. You don't have to do this manually now.

```
$ sudo cp /Applications/DuetDesktopCaptureManager.app/Contents/Resources/com.kairos.DuetDesktopCaptureManager.plist /Library/LaunchAgents

$ sudo cp /Applications/DuetDesktopCaptureManager.app/Contents/Resources/com.kairos.DuetCoreService.plist /Library/LaunchDaemons
```
Then chown everything

```
$ sudo chown root:wheel /Library/LaunchDaemons/com.kairos.DuetCoreService.plist 
$ sudo chown root:wheel /Library/LaunchAgents/com.kairos.DuetDesktopCaptureManager.plist

```

And finally launching the components:

```
$ sudo launchctl load /Library/LaunchDaemons/com.kairos.DuetCoreService.plist
$ sudo launchctl load /Library/LaunchAgents/com.kairos.DuetDesktopCaptureManager.plist

```