//
//  UtilsReplacement.h
//  duet
//
//  Created by Cedric Pansky on 7/5/18.
//  Copyright © 2018 Duet, Inc. All rights reserved.
//

#import <CoreGraphics/CGDirectDisplay.h>
#import <Foundation/Foundation.h>

@class NSScreen;

typedef NS_ENUM(NSInteger, DuetAutoConnectOption) {
	kDuetAutoConnectNotSet = -1,
	kDuetAutoConnectOff,
	kDuetAutoConnectOn
};

typedef NS_ENUM(NSInteger, DuetOrientationSetting) {
	kDuetDisplayLandscape = 0,
	kDuetDisplayPortrait,
};

typedef NS_ENUM(NSInteger, DuetResolutionKeys) {
	kDuetiPadResolutionKey,
	kDuetiPadProResolutionKey,
	kDuetiPadExtremeResolutionKey,
	kDuetiPadRetinaResolutionKey,
	kDuetiPadHighResolutionKey,
	kDuetiPadProRetinaResolutionKey,
	kDuetiPadProHighResolutionKey,

	kDuetDeviceiPadRetinaLandscape = 1,
	kDuetDeviceiPadRetinaPortrait = 2,
	kDuetDeviceiPadLandscape = 3,
	kDuetDeviceiPadPortrait = 4,
	kDuetDeviceiPhoneSixPlusLandscape = 5,
	kDuetDeviceiPhoneSixPlusPortrait = 6,
	kDuetDeviceiPhoneSixLandscape = 7,
	kDuetDeviceiPhoneSixPortrait = 8,
	kDuetDeviceiPhoneFiveLandscape = 9,
	kDuetDeviceiPhoneFivePortrait = 10,
	kDuetDeviceiPadMiniLandscape = 11,
	kDuetDeviceiPadMiniPortrait = 12,
	kDuetDeviceiPadMiniRetinaLandscape = 13,
	kDuetDeviceiPadMiniRetinaPortrait = 14,
	kDuetDeviceiPhoneSixPlusRetinaLandscape = 15,
	kDuetDeviceiPhoneSixPlusRetinaPortrait = 16,
	kDuetDeviceiPhoneSixRetinaLandscape = 17,
	kDuetDeviceiPhoneSixRetinaPortrait = 18,
	kDuetDeviceiPhoneFiveRetinaLandscape = 19,
	kDuetDeviceiPhoneFiveRetinaPortrait = 20,
	kDuetDeviceMirror = 21,
	kDuetDevicePlaceholder = 22,
	kDuetDeviceiPhoneFourRetinaLandscape = 23,
	kDuetDeviceiPhoneFourRetinaPortrait = 24,
	kDuetDeviceiPhoneThreeRetinaLandscape = 25,
	kDuetDeviceiPhoneThreeRetinaPortrait = 26,
	kDuetDeviceiPadThreeRetinaLandscape = 27,
	kDuetDeviceiPadThreeRetinaPortrait = 28,
	kDuetDeviceiPadMiniTwoRetinaLandscape = 29,
	kDuetDeviceiPadMiniTwoRetinaPortrait = 30,
	kDuetDeviceiPadProLandscape = 31,
	kDuetDeviceiPadProPortrait = 32,
	kDuetDeviceiPad11ProLandscape = 33,
	kDuetDeviceiPad11ProPortrait = 34,
};

@interface UtilsReplacement : NSObject

+ (NSString *)edidStringForDisplay:(CGDirectDisplayID)displayID;

+ (double)framesPerSecondForPixels:(unsigned long)numberOfPixels iPadProductID:(int)productID andDuetDeviceCode:(int)duetDevice andSerialNumber:(NSString *)serialNumber;

+ (NSScreen *)screenForDisplayID:(CGDirectDisplayID)displayID;

+ (BOOL)setResolutionWithWidth:(int)desiredWidth andHeight:(int)desiredHeight andRetinaEnabled:(bool)retinaEnabled forDisplay:(CGDirectDisplayID)display;

+ (BOOL)setResolutionWithWidth:(int)desiredWidth andHeight:(int)desiredHeight andRetinaEnabled:(BOOL)retinaEnabled forDisplay:(CGDirectDisplayID)display skipVerify:(BOOL)skipVerify;

+ (BOOL)setDisplayMode:(int)duetDevice forDisplay:(CGDirectDisplayID)display;

+ (DuetOrientationSetting)orientationForDuetDevice:(int)device;

+ (BOOL)isSettingsMirrored:(int)duetDevice;

+ (NSString *)settingsIDForDeviceType:(int)deviceType;

+ (void)forceNoResolution;
+ (BOOL)portraitTag:(int)duetDevice;
@end
