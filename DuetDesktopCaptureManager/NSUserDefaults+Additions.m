//
//  NSUserDefaults+Additions.m
//  DuetMac
//
//  Created by Cedric Pansky on 9/7/17.
//  Copyright © 2017 Duet, Inc. All rights reserved.
//

#import "DuetConstants.h"
#import "NSUserDefaults+Additions.h"

// Temporarily cache these here. Will optimize further soon. - Cedric
NSDictionary *gMacSettingsCache = nil;
NSDictionary *gMacDeviceSettingsCache = nil;
NSRecursiveLock *generalLock = nil;
NSMutableDictionary *gGeneralUserDefaultsLoaded = nil;

@implementation NSUserDefaults (DuetDefaultAdditions)

- (void)safeSetObject:(id)object forKey:(NSString *)key
{
	[generalLock lock];
	if (object == nil)
	{
		[gGeneralUserDefaultsLoaded removeObjectForKey:key];
	}
	else
	{
		[gGeneralUserDefaultsLoaded setObject:object forKey:key];
		[NSNotificationCenter.defaultCenter postNotificationName:@"SettingsDidChange" object:nil];
	}
	[generalLock unlock];

	dispatch_async(dispatch_get_main_queue(), ^{
	  [generalLock lock];
	  [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
	  [[NSUserDefaults standardUserDefaults] synchronize];
	  [generalLock unlock];
	});
}

- (id)safeReadObjectForKey:(NSString *)key
{
	if (gGeneralUserDefaultsLoaded == nil)
	{
		if (NSThread.isMainThread)
		{
			generalLock = [[NSRecursiveLock alloc] init];
			gGeneralUserDefaultsLoaded = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] mutableCopy];
			[NSNotificationCenter.defaultCenter postNotificationName:@"SettingsDidChange" object:nil];
		}
		else
		{
			dispatch_sync(dispatch_get_main_queue(), ^{
			  generalLock = [[NSRecursiveLock alloc] init];
			  gGeneralUserDefaultsLoaded = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] mutableCopy];
				[NSNotificationCenter.defaultCenter postNotificationName:@"SettingsDidChange" object:nil];
			});
		}
	}

	@try
	{
		[generalLock lock];
		return [gGeneralUserDefaultsLoaded objectForKey:key];
	}
	@finally
	{
		[generalLock unlock];
	}
}

- (NSString *)lastConnectediPad
{
	return [[self safeReadObjectForKey:DuetLastConnectediPadKey] copy];
}

- (void)setLastConnectediPad:(NSString *)serial
{
	[self safeSetObject:serial forKey:DuetLastConnectediPadKey];
}

- (NSString *)lastConnectediPhone
{
	return [[self safeReadObjectForKey:DuetLastConnectediPhoneKey] copy];
}

- (void)setLastConnectediPhone:(NSString *)serial
{
	[self safeSetObject:serial forKey:DuetLastConnectediPhoneKey];
}

- (BOOL)retinaEnabled
{
	return [[self safeReadObjectForKey:DuetRetinaEnabledKey] boolValue];
}

- (void)setRetinaEnabled:(BOOL)retinaEnabled
{
	[self safeSetObject:@(retinaEnabled) forKey:DuetRetinaEnabledKey];
}

- (BOOL)retinaDesired
{
	return [[self safeReadObjectForKey:@"RDPRetinaDesired"] boolValue];
}

- (void)setRetinaDesired:(BOOL)retinaDesired
{
	[self safeSetObject:@(retinaDesired) forKey:@"RDPRetinaDesired"];
}

- (BOOL)isReduceMotionOpen
{
	return [[self safeReadObjectForKey:DuetIsReduceMotionOpenKey] boolValue];
}

- (void)setIsReduceMotionOpen:(BOOL)isReduceMotionOpen
{
	[self safeSetObject:@(isReduceMotionOpen) forKey:DuetIsReduceMotionOpenKey];
}

- (NSString *)reduceMotionRestore
{
	return [[self safeReadObjectForKey:DuetReduceMotionRestoreKey] copy];
}

- (void)setReduceMotionRestore:(NSString *)reduceMotionRestore
{
	[self safeSetObject:reduceMotionRestore forKey:DuetReduceMotionRestoreKey];
}

- (BOOL)controlStripCacheOpen
{
	return [[self safeReadObjectForKey:DuetControlStripCacheOpenKey] boolValue];
}

- (void)setControlStripCacheOpen:(BOOL)controlStripCacheOpen
{
	[self safeSetObject:@(controlStripCacheOpen) forKey:DuetControlStripCacheOpenKey];
}

- (NSString *)controlStripCache
{
	return [[self safeReadObjectForKey:DuetControlStripCacheKey] copy];
}

- (void)setControlStripCache:(NSString *)controlStripCache
{
	[self safeSetObject:controlStripCache forKey:DuetControlStripCacheKey];
}

- (NSDictionary *)macSettings
{
	if (gMacSettingsCache != nil)
	{
		return gMacSettingsCache;
	}

	NSDictionary *value = [self safeReadObjectForKey:DuetMacSettingsKey];

	if (value)
	{
		gMacSettingsCache = value;
		return [value copy];
	}

	// Return a new empty dictionary, this one should always seem valid
	return @{};
}

- (void)setMacSettings:(NSDictionary *)macSettings
{
	gMacSettingsCache = macSettings;
	[self safeSetObject:macSettings forKey:DuetMacSettingsKey];
}

- (NSDictionary *)macDeviceSettings
{
	if (gMacDeviceSettingsCache)
	{
		return gMacDeviceSettingsCache;
	}

	gMacDeviceSettingsCache = [[self safeReadObjectForKey:DuetMacDeviceSettingsKey] copy];
	return gMacDeviceSettingsCache;
}

- (void)setMacDeviceSettings:(NSDictionary *)macDeviceSettings
{
	gMacDeviceSettingsCache = macDeviceSettings;

	[self safeSetObject:macDeviceSettings forKey:DuetMacDeviceSettingsKey];
}

- (NSNumber *)successfullyConnectedToAir
{
	return [[self safeReadObjectForKey:DuetSuccessfullyConnectedToAirKey] copy];
}

- (void)setSuccessfullyConnectedToAir:(NSNumber *)successfullyConnectedToAir
{
	[self safeSetObject:successfullyConnectedToAir forKey:DuetSuccessfullyConnectedToAirKey];
}

- (NSNumber *)forceHighPerformanceGPU
{
	return [[self safeReadObjectForKey:DuetForceHighPerformanceGPUKey] copy];
}

- (void)setForceHighPerformanceGPU:(NSNumber *)forceHighPerformanceGPU
{
	[self safeSetObject:forceHighPerformanceGPU forKey:DuetForceHighPerformanceGPUKey];
}

- (NSNumber *)launchAtLogin
{
	return [[self safeReadObjectForKey:DuetLaunchAtLoginKey] copy];
}

- (void)setLaunchAtLogin:(NSNumber *)launchAtLogin
{
	[self safeSetObject:launchAtLogin forKey:DuetLaunchAtLoginKey];
}

- (NSNumber *)legacyDisableAWDL
{
	return [[self safeReadObjectForKey:DuetLegacyDisableAWDLKey] copy];
}

- (void)setLegacyDisableAWDL:(NSNumber *)disableAWDL
{
	[self safeSetObject:disableAWDL forKey:DuetLegacyDisableAWDLKey];
}

- (NSNumber *)disableAWDL
{
	return [[self safeReadObjectForKey:DuetDisableAWDLKey] copy];
}

- (void)setDisableAWDL:(NSNumber *)disableAWDL
{
	[self safeSetObject:disableAWDL forKey:DuetDisableAWDLKey];
}

- (NSNumber *)hoverKey
{
	return [[self objectForKey:DuetHoverKey] copy];
}

- (void)setHoverKey:(NSNumber *)hoverKey
{
	[self safeSetObject:hoverKey forKey:DuetHoverKey];
}

//┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃ Automatic Updates
//┃    Sparkle and Duet have two separate keys for controlling automatic updates, and clashes between these have caused some
//┃ problems.  This sets both to match, favoring the result from Sparkle in the case of a mismatch.
//┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- (NSNumber *)updateAppAutomatically
{
   NSNumber *sparkle = [NSUserDefaults.standardUserDefaults objectForKey:@"SUEnableAutomaticChecks"];
   NSNumber *duet    = [[self safeReadObjectForKey:DuetUpdateAppAutomaticallyKey] copy];
   
   if(sparkle.boolValue != duet.boolValue)
   {
      NSLog(@"SUEnableAutomaticChecks != UpdateAppAutomatically");
      [self safeSetObject:sparkle forKey:DuetUpdateAppAutomaticallyKey];
   }
   
   return sparkle;
}

- (void)setUpdateAppAutomatically:(NSNumber *)updateAppAutomatically
{
	[NSUserDefaults.standardUserDefaults setObject:updateAppAutomatically forKey:@"SUEnableAutomaticChecks"];
	[self safeSetObject:updateAppAutomatically forKey:DuetUpdateAppAutomaticallyKey];
}

- (NSNumber *)highResolutionEnabled
{
	return [[self safeReadObjectForKey:DuetHighResolutionEnabledKey] copy];
}

- (void)setHighResolutionEnabled:(NSNumber *)highResolutionEnabled
{
	[self safeSetObject:highResolutionEnabled forKey:DuetHighResolutionEnabledKey];
}

- (NSNumber *)disabledMirrorInitially
{
	return [[self safeReadObjectForKey:DuetDisabledMirrorInitiallyKey] copy];
}

- (void)setDisabledMirrorInitially:(NSNumber *)disabledMirrorInitially
{
	[self safeSetObject:disabledMirrorInitially forKey:DuetDisabledMirrorInitiallyKey];
}

- (NSDate *)lastMoreSpaceReset
{
	return [[self safeReadObjectForKey:DuetLastMoreSpaceResetKey] copy];
}

- (void)setLastMoreSpaceReset:(NSDate *)lastMoreSpaceReset
{
	[self safeSetObject:lastMoreSpaceReset forKey:DuetLastMoreSpaceResetKey];
}

- (NSDate *)didShowMissionControl
{
	return [[self safeReadObjectForKey:DuetDidShowMissionControlKey] copy];
}

- (void)setDidShowMissionControl:(NSDate *)didShowMissionControl
{
	[self safeSetObject:didShowMissionControl forKey:DuetDidShowMissionControlKey];
}

- (NSNumber *)proEnabled
{
	return [[self safeReadObjectForKey:DuetProEnabledKey] copy];
}

- (void)setProEnabled:(NSNumber *)proEnabled
{
	[self safeSetObject:proEnabled forKey:DuetProEnabledKey];
}

- (NSNumber *)enableAir
{
	return [[self safeReadObjectForKey:DuetEnableAirKey] copy];
}

- (void)setEnableAir:(NSNumber *)enableAir
{
	[self safeSetObject:enableAir forKey:DuetEnableAirKey];
}

- (NSNumber *)lastConnectTime
{
	return [[self safeReadObjectForKey:DuetLastConnectTimeKey] copy];
}

- (void)setLastConnectTime:(NSNumber *)lastConnectTime
{
	[self safeSetObject:lastConnectTime forKey:DuetLastConnectTimeKey];
}

- (NSNumber *)lastConnectionReminder
{
	return [[self safeReadObjectForKey:DuetLastConnectionReminderKey] copy];
}

- (void)setLastConnectionReminder:(NSNumber *)lastConnectionReminder
{
	[self safeSetObject:lastConnectionReminder forKey:DuetLastConnectionReminderKey];
}

- (NSNumber *)notificationGroup
{
	return [[self safeReadObjectForKey:DuetNotificationGroupKey] copy];
}

- (void)setNotificationGroup:(NSNumber *)notificationGroup
{
	[self safeSetObject:notificationGroup forKey:DuetNotificationGroupKey];
}

- (NSDate *)didShowPremiereTutorial
{
	return [[self safeReadObjectForKey:DuetDidShowPremiereTutorialKey] copy];
}

- (void)setDidShowPremiereTutorial:(NSDate *)didShowPremiereTutorial
{
	[self safeSetObject:didShowPremiereTutorial forKey:DuetDidShowPremiereTutorialKey];
}

- (NSDate *)didShowLightroomTutorial
{
	return [[self safeReadObjectForKey:DuetDidShowLightroomTutorialKey] copy];
}

- (void)setDidShowLightroomTutorial:(NSDate *)didShowLightroomTutorial
{
	[self safeSetObject:didShowLightroomTutorial forKey:DuetDidShowLightroomTutorialKey];
}

- (NSDate *)didShowPhotoshopTutorial
{
	return [[self safeReadObjectForKey:DuetDidShowPhotoshopTutorialKey] copy];
}

- (void)setDidShowPhotoshopTutorial:(NSDate *)didShowPhotoshopTutorial
{
	[self safeSetObject:didShowPhotoshopTutorial forKey:DuetDidShowPhotoshopTutorialKey];
}

- (NSNumber *)installDate
{
	return [[self safeReadObjectForKey:DuetInstallDateKey] copy];
}

- (void)setInstallDate:(NSNumber *)installDate
{
	[self safeSetObject:installDate forKey:DuetInstallDateKey];
}

- (NSDate *)lastProfileSubmissionDate
{
	return [[self safeReadObjectForKey:SULastProfileSubmissionDateKey] copy];
}

- (void)setLastProfileSubmissionDate:(NSDate *)lastProfileSubmissionDate
{
	[self safeSetObject:lastProfileSubmissionDate forKey:SULastProfileSubmissionDateKey];
}

- (NSString *)installedDuetVersion
{
	return [[self safeReadObjectForKey:DuetInstalledDuetVersionKey] copy];
}

- (void)setInstalledDuetVersion:(NSNumber *)installedDuetVersion
{
	[self safeSetObject:installedDuetVersion forKey:DuetInstalledDuetVersionKey];
}

- (BOOL)skipAccessibilityCheck
{
	return [[self safeReadObjectForKey:DuetSkipAccessibilityKey] boolValue];
}

- (void)setSkipAccessibilityCheck:(BOOL)skip
{
	[self safeSetObject:@(skip) forKey:DuetSkipAccessibilityKey];
}

- (NSNumber *)lastUpdate
{
	return [[self safeReadObjectForKey:DuetLastUpdateKey] copy];
}

- (void)setLastUpdate:(NSNumber *)lastUpdate
{
	[self safeSetObject:lastUpdate forKey:DuetLastUpdateKey];
}

- (NSNumber *)resolutionQuality
{
	return [[self safeReadObjectForKey:DuetResolutionQualityKey] copy];
}

- (void)setResolutionQuality:(NSNumber *)resolutionQuality
{
	[self safeSetObject:resolutionQuality forKey:DuetResolutionQualityKey];
}

- (NSNumber *)firstLaunch
{
	return [[self safeReadObjectForKey:DuetFirstLaunchKey] copy];
}

- (void)setFirstLaunch:(NSNumber *)firstLaunch
{
	[self safeSetObject:firstLaunch forKey:DuetFirstLaunchKey];
}

- (NSDate *)lastRetinaVerifyDate
{
	return [[self safeReadObjectForKey:DuetLastRetinaVerifyDate] copy];
}

- (void)setLastRetinaVerifyDate:(NSDate *)date
{
	[self safeSetObject:date forKey:DuetLastRetinaVerifyDate];
}

- (NSArray<NSArray<NSNumber *> *> *)explicitlyAllowedAndroidDevices
{
	return [[self safeReadObjectForKey:DuetExplicitlyAllowedAndroidDevices] copy];
}

- (void)setExplicitlyAllowedAndroidDevices:(NSArray<NSArray<NSNumber *> *> *)devices
{
	[self safeSetObject:devices forKey:DuetExplicitlyAllowedAndroidDevices];
}

- (BOOL)acceleratedDisplayPossible
{
	return [[self safeReadObjectForKey:DuetAcceleratedDisplayPossible] boolValue];
}

- (void)setAcceleratedDisplayPossible:(BOOL)possible
{
	[self safeSetObject:@(possible) forKey:DuetAcceleratedDisplayPossible];
}

- (BOOL)forceReflectorRequired
{
	static dispatch_once_t onceToken;
	static BOOL value;

	dispatch_once(&onceToken, ^{
	  value = [[self safeReadObjectForKey:DuetForceReflectorRequired] boolValue];
	});

	return value;
}

- (BOOL)remoteDesktopEnabled
{
	id resultObject = [self safeReadObjectForKey:DuetRemoteDesktopEnabled];

	// Normally [nil boolValue] will return a 'false', but we want to default to 'true' so that
	// the user has screen sharing enabled set to true initially. After that we will persist
	// the value of this setting across logon/logoff

	if (resultObject == nil)
	{
		NSLog(@"Setting initial value of screen sharing enabled to true");
		[self setRemoteDesktopEnabled:TRUE]; // set it so we don't keep hitting this logic
		return TRUE;
	}
    else
    {
		return [resultObject boolValue];
    }
    
}

- (void)setRemoteDesktopEnabled:(BOOL)enabled
{
	[self safeSetObject:@(enabled) forKey:DuetRemoteDesktopEnabled];
}

- (BOOL)alreadyInstalledDriver
{
	return [[self safeReadObjectForKey:DuetDriverAlreadyInstalled] boolValue];
}

- (void)setAlreadyInstalledDriver:(BOOL)alreadyInstalledDriver
{
	[self safeSetObject:@(alreadyInstalledDriver) forKey:DuetDriverAlreadyInstalled];
}

- (DuetPanelLastSelected)lastOpenViewForSettingsWindow
{
	NSNumber *lastOpen = [self safeReadObjectForKey:LastOpenViewForSettingsWindow];
	if (lastOpen != nil && [lastOpen isKindOfClass:[NSNumber class]])
	{
		return [lastOpen unsignedIntegerValue];
	}

	return kDuetPaneliOSView;
}

- (void)setLastOpenViewForSettingsWindow:(DuetPanelLastSelected)lastOpenView
{
	[self safeSetObject:@(lastOpenView) forKey:LastOpenViewForSettingsWindow];
}

- (NSUInteger)lastOpenedTab
{
	NSNumber *lastOpen = [self safeReadObjectForKey:LastOpenTabForMainWindow];
	if (lastOpen != nil && [lastOpen isKindOfClass:[NSNumber class]])
	{
		return [lastOpen unsignedIntegerValue];
	}

	return 0;
}

- (void)setLastOpenedTab:(NSUInteger)lastOpenView
{
	[self safeSetObject:@(lastOpenView) forKey:LastOpenTabForMainWindow];
}

@end
