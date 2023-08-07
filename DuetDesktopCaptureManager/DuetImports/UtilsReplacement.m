//
//  UtilsReplacement.m
//  duet
//
//  Created by Cedric Pansky on 7/5/18.
//  Copyright © 2018 Duet, Inc. All rights reserved.
//

#import "UtilsReplacement.h"
#import "AppUserNotificationProtocol.h"
#import "CGDisplayDefines.h"
//#import "DuetConstants.h"
//#import "GBDeviceInfo.h"
//#import "NSNotificationCenter+Additions.h"
//#import "Utils.h"
#import "DuetDesktopCaptureManager-Swift.h"
#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <IOKit/graphics/IOGraphicsLib.h>

@import CocoaLumberjack;

static NSDate *forceNoResolutionSet;

@implementation UtilsReplacement

// Not sure if we actually even need the edid anymore under the modern API, but what we can't do is stop using
// CGDisplayIOServicePort() while we do need it.
+ (NSString *)edidStringForDisplay:(CGDirectDisplayID)displayID
{
//	DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	io_service_t displayPort = CGDisplayIOServicePort(displayID);

	if (displayPort == MACH_PORT_NULL)
		return nil; // No physical device to get a name from.

	CFDictionaryRef infoDict = IODisplayCreateInfoDictionary(displayPort, kIODisplayOnlyPreferredName);

	CFDataRef cfData = (CFDataRef)CFDictionaryGetValue(infoDict, CFSTR(kIODisplayEDIDKey));
	NSData *edidData = (__bridge NSData *)cfData;
	// EDID *edid = (EDID *) CFDataGetBytePtr( data );;
	NSMutableString *edidString = [NSMutableString stringWithCapacity:64];
	const unsigned char *buf = (const unsigned char *)edidData.bytes;
	NSInteger i;
	for (i = 0; i < edidData.length; ++i)
	{
		[edidString appendFormat:@"%02lX", (unsigned long)buf[i]];
	}

	// Added in case this ever happens on a real screen.  Within VMWare the edid ends up a empty string - Cedric
	if (edidString.length >= 36)
	{
		edidString = [[edidString substringToIndex:36] copy];
	}

	// Make sure the dictionary gets cleaned up
	if (infoDict)
	{
		CFRelease(infoDict);
	}

	return edidString;
}

+ (double)framesPerSecondForPixels:(unsigned long)numberOfPixels iPadProductID:(int)productID andDuetDeviceCode:(int)duetDevice andSerialNumber:(NSString *)serialNumber
{
//	DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	// NSNumber *fps = [Utils propertyForKey:@"DuetHighFrameRate" forDevice:serialNumber];
	NSString *deviceTypeForSetting = [UtilsReplacement settingsIDForDeviceType:duetDevice];
	DeviceTypeSettings *settings = [DeviceTypeSettings settingsForName:deviceTypeForSetting];

	if (settings.framerate == DuetFrameratesRate60)
	{
		return 60.0;

		//        //use some heuristics to drop frame rate
		//
		//        //lower end iPads have a max of 50 fps
		//        double maxFps = 60.0;
		//        if (productID == 4770 || //iPad 2 CDMA
		//            productID == 4771 || //iPad 2 GSM
		//            productID == 4767 || //iPad 2
		//            productID == 4777 || //iPad 3
		//            productID == 4772 || //iPad 3 Wifi
		//            productID == 4773 || //iPad 3 CDMA
		//            productID == 4774 || //iPad 3 GSM
		//            duetDevice == DuetDeviceiPadMiniLandscape || //iPad non-Retina
		//            duetDevice == DuetDeviceiPadMiniPortrait ||
		//            duetDevice == DuetDeviceiPadPortrait ||
		//            duetDevice == DuetDeviceiPadLandscape
		//            ) {
		//            maxFps = MIN(maxFps, 50.0);
		//            if (numberOfPixels >= iPadRetinaResolution)
		//                maxFps = MIN(maxFps, 40.0); //iPad simply can't handle retina iPad at such a high rate, spare the CPU on the Mac
		//        }
		//
		//        if (numberOfPixels >= iPadProRetinaResolution) {
		//            maxFps = MIN(maxFps, 30.0); //right now, cap for iPad Pro Retina
		//        }
		//
		//        GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
		//        if (deviceInfo.cpuInfo.frequency <= 1.4) { //kind of macbook
		//            maxFps = MIN(maxFps, 50.0);//should we only do this for low res
		//            if (numberOfPixels > iPadProResolution) {
		//                maxFps = MIN(maxFps, 45.0);
		//            }
		//            if (numberOfPixels >= iPadProRetinaResolution) {
		//                maxFps = MIN(maxFps, 30.0);
		//            }
		//        }
		//        if (deviceInfo.family == GBDeviceFamilyMacBookAir) {
		//            NSUInteger majorID = deviceInfo.deviceVersion.major;
		//            if (majorID <= 3) {
		//                maxFps = MIN(maxFps, 35.0);
		//                if (numberOfPixels >= iPadProRetinaResolution) {
		//                    maxFps = MIN(maxFps, 30.0);
		//                }
		//            }
		//            else if (majorID <= 5) {
		//                maxFps = MIN(maxFps, 45.0);
		//                if (numberOfPixels >= iPadRetinaResolution) {
		//                    maxFps = MIN(maxFps, 40.0);
		//                }
		//            }
		//            else if (majorID > 5) {
		//                if (numberOfPixels >= iPadProResolution) {
		//                    maxFps = MIN(maxFps, 55.0);
		//                }
		//                if (numberOfPixels >= iPadRetinaResolution) {
		//                    maxFps = MIN(maxFps, 50.0);
		//                }
		//            }
		//        }
		//        if (deviceInfo.family == GBDeviceFamilyMacBookPro) {
		//            NSUInteger majorID = deviceInfo.deviceVersion.major;
		//            if (majorID <= 7) {
		//                maxFps = 55;
		//                if (numberOfPixels >= iPadProResolution) {
		//                    maxFps = MIN(maxFps, 50.0);
		//                }
		//                if (numberOfPixels >= iPadRetinaResolution) {
		//                    maxFps = MIN(maxFps, 40.0);
		//                }
		//            }
		//            else if (majorID <= 9) {
		//                maxFps = MIN(maxFps, 60.0);
		//                if (numberOfPixels >= iPadRetinaResolution) {
		//                    maxFps = MIN(maxFps, 50.0);
		//                }
		//            }
		//            else if (majorID <= 9) {
		//                maxFps = MIN(maxFps, 60.0);
		//                if (numberOfPixels >= iPadRetinaResolution) {
		//                    maxFps = MIN(maxFps, 55.0);
		//                }
		//            }
		//            else if (majorID >= 10) {
		//                maxFps = MIN(maxFps, 60.0);
		//            }
		//        }
		//
		//        return maxFps;
	}
	else
	{
		// always return 30 as that is the minimum desired frame rate
		return 30.0f;
	}
}

+ (NSScreen *)screenForDisplayID:(CGDirectDisplayID)displayID
{
//	DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	NSScreen *screen = nil;
	for (NSScreen *s in [NSScreen screens])
	{
		NSDictionary *screenDictionary = [s deviceDescription];
		NSNumber *screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
		if ([screenID unsignedIntValue] == displayID)
		{
			screen = s;
		}
	}

	return screen;
}

+ (BOOL)setResolutionWithWidth:(int)desiredWidth andHeight:(int)desiredHeight andRetinaEnabled:(bool)retinaEnabled forDisplay:(CGDirectDisplayID)display
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	return [self setResolutionWithWidth:desiredWidth andHeight:desiredHeight andRetinaEnabled:retinaEnabled forDisplay:display skipVerify:NO];
}

+ (int)setCGSDisplayMode:(CGSDisplayMode)mode forDisplay:(CGDirectDisplayID)display{
	CGDisplayConfigRef config;
	CGBeginDisplayConfiguration(&config);
	CGSConfigureDisplayMode(config, display, mode.modeNumber);
	
	int error = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
	int outputMode;
	CGSGetCurrentDisplayMode(display, &outputMode);

	// CGSConfigureDisplayMode sometimes silently fails. It emits noErr but the display mode does not change. So we need to add cgsMode.modeNumber == outputMode to the success conditions too.
	if (error == noErr && mode.modeNumber == outputMode)
	{
//		DDLogInfo(@"[Display] Display mode was set successfully. (w: %d h: %d px: %f)", mode.width, mode.height, mode.density);
		return noErr;
	} else if (mode.modeNumber != outputMode) {
//		DDLogError(@"[Display] Setting display mode has failed (current mode(%d) != set mode(%d))", outputMode, mode.modeNumber);
		return -1;
	} else {
//		DDLogError(@"[Display] Setting display mode has failed (error %d)", error);
		return error;
	}
}

+ (BOOL)setResolutionWithWidth:(int)desiredWidth andHeight:(int)desiredHeight andRetinaEnabled:(BOOL)retinaEnabled forDisplay:(CGDirectDisplayID)display skipVerify:(BOOL)skipVerify
{
	int notDone = 10;

	while (notDone--)
	{
//		DDLogInfo(@"[Display] Start setting resolution. Desired resolution (%dpt x %dpt) (retina %i) - display ID = %d", desiredWidth, desiredHeight, retinaEnabled, display);

		CGDisplayModeRef currentMode = CGDisplayCopyDisplayMode(display);
		if (currentMode == nil)
		{
//			DDLogInfo(@"[Display] Error setting resolution. Display mode for displayID = %d is nil.", display);
			return NO;
		}

		size_t width = CGDisplayModeGetPixelWidth(currentMode);
		size_t height = CGDisplayModeGetPixelHeight(currentMode);
		size_t fullWidth = CGDisplayModeGetWidth(currentMode);
		size_t fullHeight = CGDisplayModeGetHeight(currentMode);
//		DDLogInfo(@"[Display] Setting resolution. current resolution in px = (%zupx x %zupx) in pt = (%zupt x %zupt).", width, height, fullWidth, fullHeight);

		// Cleanup
		if (currentMode)
		{
			CFRelease(currentMode);
		}
		
		int numberOfDisplayModes;
		CGSGetNumberOfDisplayModes(display, &numberOfDisplayModes);
		
		if (numberOfDisplayModes == 1)
		{
			// notify the installer so that we can walk them through a reinstall
//			NSLog(@"[Display] failed early 2");
			return NO;
		}

		BOOL triedAll = NO;
		
		while (!triedAll)
		{
			CGSDisplayMode cgsMode = {};

			for (int i = 0; i < numberOfDisplayModes; i++)
			{
				CGSGetDisplayModeDescriptionOfLength(display, i, &cgsMode, sizeof(CGSDisplayMode));
//				DDLogDebug(@"[Display] Testing CGSDisplayMode %d: w: %d h: %d px: %f",i, cgsMode.width, cgsMode.height, cgsMode.density);

				BOOL retinaMode = cgsMode.density > 1.5;
				if (cgsMode.width == desiredWidth && cgsMode.height == desiredHeight && retinaEnabled == retinaMode)
				{
//					DDLogDebug(@"[Display] Found display mode to be set %d! Trying to configure display mode w: %d h: %d px: %f", cgsMode.modeNumber, cgsMode.width, cgsMode.height, cgsMode.density);
					int result = [self setCGSDisplayMode:cgsMode forDisplay:display];
					if (result == noErr) {
						return YES;
					} else if (result == -1) { // this indicates that the underlying display mode change was executed with noErr, but the display mode was not set actually.
						//WORKAROUND: In MacOS 13 Ventura display mode setting seems to be broken. First try to set the display mode to 0, then transition to the requested display mode
						if (@available(macOS 13.0, *)) {
//							DDLogDebug(@"[Display] MacOS 13 resolution change bug workaround START.");
							CGDisplayConfigRef config;
							CGBeginDisplayConfiguration(&config);
							// It seems it doesn't really matter if setting the new mode actually works. After this, we can set the display mode we originally wanted.
							CGSConfigureDisplayMode(config, display, 0);
//							DDLogDebug(@"[Display] Configuring display %d to mode %d.", display, i);
							CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
//							DDLogDebug(@"[Display] MacOS 13 resolution change bug workaround END.");
						}
						// now retry setting the display mode
						int result = [self setCGSDisplayMode:cgsMode forDisplay:display];
						if (result == noErr) {
							return YES;
						}
					} else {
//						DDLogError(@"[Display] Setting display mode has failed (error %d)", result);
					}
					CGDisplayConfigRef config;
					CGBeginDisplayConfiguration(&config);
					CGSConfigureDisplayMode(config, display, cgsMode.modeNumber);

					int error = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
					int outputMode;
					CGSGetCurrentDisplayMode(display, &outputMode);

					// CGSConfigureDisplayMode sometimes silently fails. It emits noErr but the display mode does not change. So we need to add cgsMode.modeNumber == outputMode to the success conditions too.
					if (error == noErr && cgsMode.modeNumber == outputMode)
					{
//						DDLogInfo(@"[Display] Display mode was set successfully. (w: %d h: %d px: %f)", cgsMode.width, cgsMode.height, cgsMode.density);
						return YES;
					} else if (cgsMode.modeNumber != outputMode) {
//						DDLogError(@"[Display] Setting display mode has failed (current mode(%d) != set mode(%d))", outputMode, cgsMode.modeNumber);
					} else {
//						DDLogError(@"[Display] Setting display mode has failed (error %d)", error);
					}
				}
			}

			if (retinaEnabled && !triedAll)
			{
				retinaEnabled = NO;
			}
			else
			{
				triedAll = YES;
			}
		}

//		DDLogError(@"[Display] resolution not found");
        
//		[[AnalyticManager shared] trackEvent:@"Resolution not found" properties:@{@"desiredWidth": @(desiredWidth), @"desiredHeight": @(desiredHeight)}];

        
		[NSThread sleepForTimeInterval:0.5];
		CFRunLoopRunInMode(kCFRunLoopCommonModes, 0, YES);
	}

	// We need an analytic for these cases
//	DDLogError(@"[Display] resolution never found");

	return NO;
}



+ (BOOL)setDisplayMode:(int)duetDevice forDisplay:(CGDirectDisplayID)display
{
//	DDLogVerbose(@"[Display] %s, %i %i", __DUET_PRETTY_FUNCTION__, duetDevice, display);

	if (duetDevice >= 2048)
	{
		duetDevice -= 2048;
	}

	if (display == 0 || duetDevice > 10000 || display == kCGNullDirectDisplay /*|| display == kCGDirectMainDisplay*/)
	{
		DDLogVerbose(@"[Display] %s could not find display or bad device", __DUET_PRETTY_FUNCTION__);
		return NO;
	}

	if (duetDevice == 0)
	{ // don't set for devices before getting the resolution
		DDLogVerbose(@"[Display] %s could not find duetDevice", __DUET_PRETTY_FUNCTION__);
		return NO;
	}

	if (forceNoResolutionSet != nil && fabs([forceNoResolutionSet timeIntervalSinceNow]) < 5)
	{
		[NSThread sleepForTimeInterval:2]; // wait to make sure it's not mirrored
	}

	if (CGDisplayIsInMirrorSet(display))
	{
		DDLogVerbose(@"Is in mirroring set");
		return YES;
	}

	BOOL portrait = [self portraitTag:duetDevice];

	NSString *deviceTypeForSetting = [UtilsReplacement settingsIDForDeviceType:duetDevice];
	DeviceTypeSettings *settings = [DeviceTypeSettings settingsForName:deviceTypeForSetting];

	DuetResolution *intendedResolution = [DuetResolutionManager.shared resolutionForOption:settings.modernResolution portrait:portrait];
	BOOL retinaEnabled = settings.retinaEnabled;

	if (!intendedResolution.retina && retinaEnabled)
	{
		retinaEnabled = NO;
	}

	DDLogVerbose(@"[Display] Calling set resolution for %ix%i", intendedResolution.width, intendedResolution.height);
	return [self setResolutionWithWidth:(int)intendedResolution.width andHeight:(int)intendedResolution.height andRetinaEnabled:retinaEnabled forDisplay:display];
}

+ (void)setDisplay:(CGDirectDisplayID)displayID toMode:(CGDisplayModeRef)mode
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	CGDisplayConfigRef config;
	CGBeginDisplayConfiguration(&config);
	CGConfigureDisplayWithDisplayMode(config, displayID, mode, NULL);
	CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
}

+ (DuetOrientationSetting)orientationForDuetDevice:(int)device
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	if (device >= 2048)
	{
		device -= 2048;
	}

	if (device % 2 == 1)
	{
		return kDuetDisplayLandscape;
	}

	return kDuetDisplayPortrait;
}

+ (BOOL)isSettingsMirrored:(int)duetDevice
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	NSString *deviceTypeForSetting = [UtilsReplacement settingsIDForDeviceType:duetDevice];
	DeviceTypeSettings *settings = [DeviceTypeSettings settingsForName:deviceTypeForSetting];

	return settings.mirroring;
}

+ (NSString *)settingsIDForDeviceType:(int)deviceType
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	NSString *result = nil;

	if (deviceType == DuetDeviceiPadLandscape || deviceType == DuetDeviceiPadPortrait)
	{
		result = iPadSetting;
	}
	if (deviceType == DuetDeviceiPadRetinaLandscape || deviceType == DuetDeviceiPadRetinaPortrait || deviceType == DuetDeviceiPadThreeRetinaLandscape || deviceType == DuetDeviceiPadThreeRetinaPortrait)
	{
		result = iPadRetinaSetting;
	}
	if (deviceType == DuetDeviceiPadMiniLandscape || deviceType == DuetDeviceiPadMiniPortrait)
	{
		result = iPadMiniSetting;
	}
	if (deviceType == DuetDeviceiPadMiniRetinaLandscape || deviceType == DuetDeviceiPadMiniRetinaPortrait || deviceType == DuetDeviceiPadMiniTwoRetinaLandscape || deviceType == DuetDeviceiPadMiniTwoRetinaPortrait)
	{
		result = iPadMiniRetinaSetting;
	}
	if (deviceType == DuetDeviceiPadMiniRetinaLandscape || deviceType == DuetDeviceiPadMiniRetinaPortrait)
	{
		result = iPadMiniRetinaSetting;
	}
	if (deviceType == DuetDeviceiPadProLandscape || deviceType == DuetDeviceiPadProPortrait)
	{
		result = iPadPro129Setting;
	}
	if (deviceType == DuetDeviceiPad11ProLandscape || deviceType == DuetDeviceiPad11ProPortrait)
	{
		result = iPadPro11Setting;
	}

//	if ([Utils isDeviceIPhone:deviceType])
//	{
//		result = iPhoneSetting;
//	}

	if (result == nil)
	{
		result = iPadRetinaSetting;
	}

	//if (Utils.isAirPlaySupportRequired)
	//{
	//	result = [result stringByAppendingString:@"-AirPlay"];
	//}

	return result;
}

+ (void)forceNoResolution
{
	//    DDLogVerbose(@"%s", __DUET_PRETTY_FUNCTION__);

	forceNoResolutionSet = [NSDate date];
}

+ (BOOL)portraitTag:(int)duetDevice
{
	BOOL portrait = NO;
	switch (duetDevice)
	{
	case DuetDeviceiPadRetinaPortrait:
	case DuetDeviceiPadPortrait:
	case DuetDeviceiPhoneSixPlusPortrait:
	case DuetDeviceiPhoneSixPortrait:
	case DuetDeviceiPhoneFivePortrait:
	case DuetDeviceiPadMiniPortrait:
	case DuetDeviceiPadMiniRetinaPortrait:
	case DuetDeviceiPhoneSixPlusRetinaPortrait:
	case DuetDeviceiPhoneSixRetinaPortrait:
	case DuetDeviceiPhoneFiveRetinaPortrait:
	case DuetDeviceiPhoneFourRetinaPortrait:
	case DuetDeviceiPhoneThreeRetinaPortrait:
	case DuetDeviceiPadThreeRetinaPortrait:
	case DuetDeviceiPadMiniTwoRetinaPortrait:
	case DuetDeviceiPadProPortrait:
	case DuetDeviceiPad11ProPortrait:
		portrait = YES;
		break;
	default:
		break;
	}

	return portrait;
}

@end
