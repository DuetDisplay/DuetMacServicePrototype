//  DuetConstants.h
//  DuetMac
//
//  Created by Rahul Dewan on 6/28/15.
//  Copyright (c) 2015 Rahul Dewan. All rights reserved.
//

#ifndef DUET_CONSTANTS_H
#define DUET_CONSTANTS_H

#import <Foundation/Foundation.h>
#include <stdint.h>

#if DEBUG
#define __DUET_PRETTY_FUNCTION__ __PRETTY_FUNCTION__
#else
#define __DUET_PRETTY_FUNCTION__ ""
#endif

// This clashes with a similar define in DuetServiceConstants.h
//#undef LOG_LEVEL_DEF
//#define LOG_LEVEL_DEF ddLogLevel

@import DuetCommon;

#define kDuetInitializing @"DuetInitializing"
#define kDuetClosing @"DuetClosing"
#define kDuetRestartConnection @"DuetRestartConnection"
#define kDuetInitialized @"DuetInitialized"
#define kDuetOrientationChanged @"OrientationChanged"
#define kDuetConfigurationChanged @"DuetConfigurationChanged"
#define kDuetChangeResolution @"DuetChangeResolution"
#define kDuetEnableTouchbar @"DuetEnableTouchbar"
#define kDuetDisableTouchbar @"DuetDisableTouchbar"
#define kDuetResetEngine @"DuetResetEngine"
#define kDuetChangeResolutionAndRestartDisplay @"kDuetChangeResolutionAndRestartDisplay"
#define kDuetRestartDisplay @"RestartDuetDisplay"
#define kDuetMoreSpaceRestartDisplay @"MoreSpaceRestartVirtualDisplay"
#define kDuetFramerateChanged @"FrameRateChanged"
#define kDuetPerformanceChanged @"PerformanceSettingChanged"
#define kDuetRDPQualityChanged @"RDPQualityChanged"
#define kDuetSetupEngine @"SetupEngine"
#define kDuetDisplayServiceName "com_kairos_driver_DuetDisplayDriver"
#define kDuetDisplaySameServiceIsOpen @"SameVersionIsOpened"
#define kDuetDisplayCloseIfOpen @"DuetDisplayCloseIfOpen"
#define kDuetDisplayAirDevicesChanged @"DuetUpdateStatusMenu"
#define kDuetLeftClickNotification @"LeftClick"
#define kDuetRightClickNotification @"RightClick"
#define kDuetScrollBeganNotification @"ScrollBegan"
#define kDuetDidScrollNotification @"DidScroll"
#define kDuetDidDragNotification @"DidDrag"
#define kDuetDragBeganNotification @"DragBegan"
#define kDuetDragEndedNotification @"DragEnded"
#define kDuetRequestHighPerformanceGraphicsNotification @"RequestHighPerformanceGraphics"
#define kDisableHighPerformanceGraphicsNotification @"DisableHighPerformanceGraphics"
#define kCheckForAppUpdatesNotification @"CheckForAppUpdates"
#define kDuetResolutionHoverNotification @"ResolutionHover"
#define kDuetResolutionExitNotification @"ResolutionExit"
#define kDuetShowAccessibilityPermissionsWarning @"AccessibilityPermissionsWarning"
#define kDuetHideAccessibilityPermissionsWarning @"AccessibilityPermissionsResolved"
#define kDuetHighWindowServerCPUNotification @"HighWindowServerCPUNotice"
#define kDuetAirEnableToggled @"AirEnabledToggled"
#define kDuetReflectorReset @"DuetReflectorReset"
#define kDuetPortInUseNotification @"DuetPortInUseNotification"
#define kSettingsChangedNotification @"SettingsChangedNotification"
#define kConfigV1RefreshedNotification @"ConfigV1Refreshed"

//#define kDuetiPadResolutionKey 0 //1024 x 768
//#define kDuetiPadProResolutionKey 1 //1366 x 1024
//#define kDuetiPadExtremeResolutionKey 2 //something in between
//#define kDuetiPadRetinaResolutionKey 3 //2048 x 1536
//#define kDuetiPadHighResolutionKey 4 // 2048 x 1536 @ 2x
//#define kDuetiPadProRetinaResolutionKey 5 //2732 x 2048
//#define kDuetiPadProHighResolutionKey 6 //not even sure if this will ever be used

typedef NSString *DuetResolutionNameKey NS_EXTENSIBLE_STRING_ENUM;
extern const DuetResolutionNameKey kDuetiPadResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPadTenFiveResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPadProResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPadExtremeResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPadHighResolutionV2Key;

extern const DuetResolutionNameKey kDuetiPhoneResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPhoneTwoResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPhoneThreeResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPhoneFourResolutionV2Key;
extern const DuetResolutionNameKey kDuetiPhoneFiveResolutionV2Key;

// settings
#define iPhoneSetting @"iPhone"
#define iPadSetting @"iPad"
#define iPadMiniSetting @"iPad Mini"
#define iPadMiniRetinaSetting @"iPad Mini Retina"
#define iPadRetinaSetting @"iPad Retina"
#define iPadPro105Setting @"iPad Pro 10.5-inch"
#define iPadPro129Setting @"iPad Pro 12.9-inch"
#define iPadPro11Setting @"iPad Pro 11-inch"

#define iPadRegularResolution 786432
#define iPadRetinaResolution 3145728
#define iPadProResolution 1398784
#define iPadProRetinaResolution 5595136

#define iPhone6PlusResolution 2073600
#define iPhone6Resolution 1000500

#define ALLOW_RETINA_PRO 1

#define SHOULD_USE_ENCRYPTION true
#define FORCE_DUET_AIR NO

#define DuetHoverKey @"DuetHoverKey"
#define DuetHighResolutionEnabledKey @"DuetHighResolutionEnabled"
#define DuetDidShowMissionControlKey @"DidShowMissionControl"
#define DuetDisabledMirrorInitiallyKey @"DisabledMirrorInitially"
#define DuetForceHighPerformanceGPUKey @"ForceHighPerformanceGPU"
#define DuetLastMoreSpaceResetKey @"LastMoreSpaceReset"

#define DuetLastConnectediPadKey @"LastConnectediPad"
#define DuetLastConnectediPhoneKey @"LastConnectediPhone"
#define DuetLastConnectTimeKey @"DuetLastConnectTime"
#define DuetDidShowPhotoshopTutorialKey @"DidShowPhotoshopTutorial"
#define DuetDidShowLightroomTutorialKey @"DidShowLightroomTutorial"
#define DuetDidShowPremiereTutorialKey @"DidShowPremiereTutorial"
#define DuetLastConnectionReminderKey @"DuetLastConnectionReminder"
#define DuetInstallDateKey @"DuetInstallDate"
#define DuetNotificationGroupKey @"DuetNotificationGroup"

#define DuetRetinaEnabledKey @"DuetRetinaEnabled"
#define DuetIsReduceMotionOpenKey @"IsReduceMotionOpen"
#define DuetReduceMotionRestoreKey @"ReduceMotionRestore"
#define DuetControlStripCacheOpenKey @"DuetControlStripCacheOpen"
#define DuetControlStripCacheKey @"DuetControlStripCache"
#define DuetReduceTransparencyKey @"DuetReduceTransparency"
#define DuetReducedTransparencyEnabledKey @"ReducedTransparencyEnabled"

#define DuetLaunchAtLoginKey @"LaunchAtLogin"
#define DuetLegacyDisableAWDLKey @"DisableAWDL"
#define DuetDisableAWDLKey @"AWDLToolEnabled"
#define DuetUpdateAppAutomaticallyKey @"UpdateAppAutomatically"

#define SULastProfileSubmissionDateKey @"SULastProfileSubmissionDate"
#define DuetInstalledDuetVersionKey @"InstalledDuetVersion"
#define DuetSkipAccessibilityKey @"SkipAccCheck"
#define DuetLastUpdateKey @"DuetLastUpdate"
#define DuetResolutionQualityKey @"DuetResolutionQuality"
#define DuetFirstLaunchKey @"FirstRun" // Changed from "FirstLaunch" to avoid stale keys from old uninstalls.

#define DuetMacDeviceSettingsKey @"Duet Mac Device Settings"
#define DuetMacSettingsKey @"Duet Mac Settings"
#define DuetSuccessfullyConnectedToAirKey @"Successfully Connected To Air"
#define DuetEnableAirKey @"Enable Air"
#define DuetAirAutoConnectKey @"Air Auto-Connect"

#define DuetProEnabledKey @"Pro Enabled"

#define DuetLastRetinaVerifyDate @"Last Retina Verify"
#define DuetAcceleratedDisplayPossible @"Accelerated Display Possible"
#define DuetForceReflectorRequired @"dfrr"
#define DuetRemoteDesktopEnabled @"Remote Desktop Enabled"
#define DuetDriverAlreadyInstalled @"DuetDriverAlreadyInstalled"
#define LastOpenViewForSettingsWindow @"LastOpenViewForSettingsWindow"
#define LastOpenTabForMainWindow @"LastOpenTabForMainWindow"
#define DuetExplicitlyAllowedAndroidDevices @"ExplicitlyAllowedAndroidDevices"

static uint32_t DuetManagerVersion = 1;
typedef uint32_t DuetPayloadType;

static inline void DEBUG_LOG_DATA_PACKET(int fd, const char *from, DuetDisplayData packet)
{
	//	DDLogVerbose(@"DuetDisplayData Size on (%d) (%s) (%d) (%d) %d", fd, from, ntohl(packet.tag), ntohl(packet.type), ntohl(packet.size));
}

typedef NS_ENUM(NSUInteger, DuetPanelLastSelected) {
	kDuetPaneliOSView,
	kDuetPanelAndroidView,
	kDuetPanelProfileView,
	kDuetPanelSettingsView,
	kDuetPanelDesktopView,
};

#endif
