//
//  NSUserDefaults+Additions.h
//  DuetMac
//
//  Created by Cedric Pansky on 9/7/17.
//  Copyright © 2017 Duet, Inc. All rights reserved.
//

#import "DuetConstants.h"
#import <Foundation/Foundation.h>
/**
 Convienience properties for accessing NSUserDefault's in a more type safe and consistent manner.
*/
@interface NSUserDefaults (DuetDefaultAdditions)

/// A safe way to set an object from any thread
- (void)safeSetObject:(id _Nullable)object forKey:(NSString *_Nonnull)key;

/// A safe way to read an object from any thread
- (id _Nullable)safeReadObjectForKey:(NSString *_Nonnull)key;

/// Whether to perform further control strip checks or not before altering controlStripCache
@property (nonatomic, assign) BOOL controlStripCacheOpen;

/// Whether the check for reduced motion is looking for a "1" (isReduceMotionOpen == NO), or a "0" (isReduceMotionOpen == YES)
@property (nonatomic, assign) BOOL isReduceMotionOpen;

/// Read inside shouldBeRetinaWithDevice, otherwise unused, and never set.  Superceeded it looks like by a macDeviceSetting entry.
@property (nonatomic, assign) BOOL retinaEnabled;

/// Retina desired (checked) in Panel Controller
@property (nonatomic, assign) BOOL retinaDesired;

/// Should we skip the accessibility checks on Mojave and beyond
@property (nonatomic, assign) BOOL skipAccessibilityCheck;

/// When did the lightroom tutorial show
@property (nonatomic, copy, nullable) NSDate *didShowLightroomTutorial;

/// Date of last time mission control window was shown
@property (nonatomic, copy, nullable) NSDate *didShowMissionControl;

/// When did the photoshop tutorial show
@property (nonatomic, copy, nullable) NSDate *didShowPhotoshopTutorial;

/// When did the premiere tutorial show
@property (nonatomic, copy, nullable) NSDate *didShowPremiereTutorial;

/// Read in shouldForceRestartDisplay, never set
@property (nonatomic, copy, nullable) NSDate *lastMoreSpaceReset;

/// SULastProfileSubmissionDate - This is set by Sparkle
@property (nonatomic, copy, nullable) NSDate *lastProfileSubmissionDate;

/// When did the last update check run
@property (nonatomic, copy, nullable) NSDate *lastUpdate;

/// Additional dictionary of settings manipulated in PanelController and Utils
@property (nonatomic, copy, nullable) NSDictionary *macDeviceSettings;

/// Additional dictionary of settings manipulated in Utils
@property (nonatomic, copy, nullable) NSDictionary *macSettings;

/// Set to @YES when shouldUnmirror is called, never changed after, TODO: See if this has anything to do with the mirroring bug
@property (nonatomic, copy, nullable) NSNumber *disabledMirrorInitially;

/// Is WiFi screens enabled, @YES by default
@property (nonatomic, copy, nullable) NSNumber *enableAir;

/// Has the app been launched before or not?
@property (nonatomic, copy, nullable) NSNumber *firstLaunch;

/// High performance GPU setting, defalts to @YES
@property (nonatomic, copy, nullable) NSNumber *forceHighPerformanceGPU;

/// Presumably if retina is enabled or something, this setting is defaulted to false and never set anyplace, though it is tested in DuetDisplayController
@property (nonatomic, copy, nullable) NSNumber *highResolutionEnabled;

/// The currently chosen key mask for the hover key, defaults to NSFunctionKeyMask
@property (nonatomic, copy, nullable) NSNumber *hoverKey;

/// The date of the first launch
@property (nonatomic, copy, nullable) NSNumber *installDate;

/// Last time we spoke to a device over USB
@property (nonatomic, copy, nullable) NSNumber *lastConnectTime;

/// The last time we reminded the user of something. Currently disabled.
@property (nonatomic, copy, nullable) NSNumber *lastConnectionReminder;

/// If the app is set to launch on login
@property (nonatomic, copy, nullable) NSNumber *launchAtLogin;

/// If the app should disable awdl0
@property (nonatomic, copy, nullable) NSNumber *disableAWDL;

@property (nonatomic, copy, nullable) NSNumber *legacyDisableAWDL;

///
@property (nonatomic, copy, nullable) NSNumber *notificationGroup;

/// If the last device connected to told us pro was enabled.
@property (nonatomic, copy, nullable) NSNumber *proEnabled;

/// Always 1 at the moment from what I can cell - Cedric
@property (nonatomic, copy, nullable) NSNumber *resolutionQuality;

/// If we've ever connected over wiFi, once true, always true.
@property (nonatomic, copy, nullable) NSNumber *successfullyConnectedToAir;

/// If we're updating the app automatically as updates are available or not, default is true
@property (nonatomic, copy, nullable) NSNumber *updateAppAutomatically;

/// The saved output from the NSTask call reading the com.apple.controlstrip defaults for the MiniCustomized setting
@property (nonatomic, copy, nullable) NSString *controlStripCache;

/// The last CFBundleShortVersionString seen on launch basically, with "Version " prefixed.
@property (nonatomic, copy, nullable) NSString *installedDuetVersion;

/// Serial number of the last connected iPad, "DefaultiPad", or nil
@property (nonatomic, copy, nullable) NSString *lastConnectediPad;

/// Serial number of the last connected iPhone, "DefaultiPhone", or nil
@property (nonatomic, copy, nullable) NSString *lastConnectediPhone;

/// The saved output from the NSTask call reading the com.apple.dock defaults for the mcx-expose-disabled setting
@property (nonatomic, copy, nullable) NSString *reduceMotionRestore;

/// When did we last "verify" the retina setting
@property (nonatomic, copy, nullable) NSDate *lastRetinaVerifyDate;

@property (nonatomic, copy, nullable) NSArray<NSArray<NSNumber *> *> *explicitlyAllowedAndroidDevices;

/// Whether the driver could even begin to support acceleration!
@property (nonatomic, assign) BOOL acceleratedDisplayPossible;

/// Whether remote display sharing is enabled
@property (nonatomic, assign) BOOL remoteDesktopEnabled;

/// Whether to force the reflector support on despite OS version or not
@property (nonatomic, readonly) BOOL forceReflectorRequired;

/// Whether the driver has ever been installed before
@property (nonatomic, assign) BOOL alreadyInstalledDriver;

/// save last open view to restore on re-open
@property (nonatomic, assign) DuetPanelLastSelected lastOpenViewForSettingsWindow;

/// save last open tab in main menu.
@property (nonatomic, assign) NSUInteger lastOpenedTab;

@end
