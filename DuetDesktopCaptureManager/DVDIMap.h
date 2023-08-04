//
// Created by Cedric Pansky on 2019-02-07.
// Copyright (c) 2019 Duet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

#define DVDIVirtualDisplay DuetX__vdi__
#define DVDIVirtualDisplayDescriptor DuetX__vdi_d__
#define DVDIVirtualDisplayMode DuetX__vdi_m__
#define DVDIVirtualDisplaySettings DuetX__vdi_s__
#define DVDIVirtualDisplayHiDPI_t DuetX__vdi_m_t
#define kDVDIVirtualDisplayHIDPI DuetX__vdi_m_k

@class DVDIVirtualDisplay;

// Prototype for client-supplied handler/block to intercept VirtualDisplay terminations
typedef void (^DVDIVirtualDisplayTerminationHandler_t)(DVDIVirtualDisplay *display);

/*!
 @enum CGVirtualDisplayRotationMode
 @brief Display rotation policies a virtual display can adopt.
 */
typedef NS_ENUM(uint32_t, DVDIVirtualDisplayRotationMode) {
	/*!
	 @brief
	 Opt out of rotation support.
	 In this mode Displays Preferences won't show users a UI to change the orientation.
	 */
	DVDIVirtualDisplayRotationModeDisable = 0,
	/*!
	 @brief
	 Opt in of rotation support.
	 In this mode Displays Preferences will show users a UI to change the orientation.
	 */
	DVDIVirtualDisplayRotationModeEnable = 1,
};

/*
 * This object contains the immutable properties of a Virtual Display.
 * All of this information is client provided.
 * - vendorID  (32bit value - unique to vendor)
 * - productID (32bit value - unique to product per vendor)
 * - serialNum (32bit value - unique instance per vendor's product)
 * - name NSString * (name of CGVirtualDisplay instance)
 * - size (physical CGSize in inches)
 * - redPrimary (CGPoint on color triangle corresponding to RED     - defaults to sRGB)
 * - greenPrimary (CGPoint on color triangle corresponding to GREEN - defaults to sRGB)
 * - bluePrimary (CGPoint on color triangle corresponding to BLUE   - defaults to sRGB)
 * - whitePoint (CGPoint on color triangle corresponding to WHITE   - defaults to sRGB)
 * - queue (dispatch_queue on which to invoke callbacks)
 * - terminationHandler (callback block indicating termination of frameBuffer being displayed)
 *
 * Use this descriptor to init the VirtualDisplay object (InitWithDescriptor).
 */
@interface DVDIVirtualDisplayDescriptor : NSObject
@property (readwrite, nonatomic) uint32_t vendorID;
@property (readwrite, nonatomic) uint32_t productID;
@property (readwrite, nonatomic) uint32_t serialNum;
@property (readwrite, nonatomic) uint32_t serialNumber;
@property (readwrite, nonatomic, strong) NSString *name;
@property (readwrite, nonatomic) CGSize sizeInMillimeters;
@property (readwrite, nonatomic) uint32_t maxPixelsWide;
@property (readwrite, nonatomic) uint32_t maxPixelsHigh;
@property (readwrite, nonatomic) CGPoint redPrimary;
@property (readwrite, nonatomic) CGPoint greenPrimary;
@property (readwrite, nonatomic) CGPoint bluePrimary;
@property (readwrite, nonatomic) CGPoint whitePoint;
@property (readwrite, nonatomic, strong) dispatch_queue_t queue;
@property (readwrite, nonatomic, copy) DVDIVirtualDisplayTerminationHandler_t terminationHandler;
@end

/*
 * This object describes a single supported VirtualDisplay mode, containing:
 * - width (in pixels)
 * - height (in pixels)
 * - refreshRate (in seconds)
 */
@interface DVDIVirtualDisplayMode : NSObject
@property (readonly, nonatomic) uint32_t width;
@property (readonly, nonatomic) uint32_t height;
@property (readonly, nonatomic) double refreshRate;
- (DVDIVirtualDisplayMode *)initWithWidth:(uint32_t)width
								   height:(uint32_t)height
							  refreshRate:(double)refreshRate;
@end

typedef NS_ENUM(uint32_t, DVDIVirtualDisplayHiDPI_t) {
	kHIDPIDisable = 0, // opt out of hiDPI mode
	kHIDPIEnable = 1,  // opt in to hiDPI mode
	kHIDPIAuto = 2,	   // automatically opt in/out of hiDPI mode based on pixel density
};

/*
 * This object contains the mutable properties of a VirtualDisplay:
 * - modes: NSArray of CGVirtualDisplayMode objects (defaults to nil)
 * - hiDPI: specify hiDPI modes (defaults to kCGVirtualDisplayHIDPIAuto)
 */
@interface DVDIVirtualDisplaySettings : NSObject
@property (strong, readwrite, nonatomic) NSArray<DVDIVirtualDisplayMode *> *modes;
@property (readwrite, nonatomic) DVDIVirtualDisplayHiDPI_t hiDPI;

/*!
 @property rotation
 @brief Rotation policy to be used by a virtual display. Defaults to @em CGVirtualDisplayRotationModeDisable.
 */
@property (readwrite, assign, nonatomic) DVDIVirtualDisplayRotationMode rotation API_AVAILABLE(macos(10.16));

@end

/*
 * This object serves as the underyling implementation of
 * CoreGraphic's VirtualDisplay.
 *
 * All properties are read-only and derived from descriptor it was
 * created against as well as any settings requested since then.
 * The only derived property is displayID, and it conveys the
 * CGDirectDisplayID to CGDisplayStream from in order to access
 * the VirtualDisplay's content.
 */
@interface DVDIVirtualDisplay : NSObject
@property (readonly, nonatomic) uint32_t vendorID;
@property (readonly, nonatomic) uint32_t productID;
@property (readonly, nonatomic) uint32_t serialNum;
@property (readonly, nonatomic) uint32_t serialNumber;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) CGSize sizeInMillimeters;
@property (readonly, nonatomic) uint32_t maxPixelsWide;
@property (readonly, nonatomic) uint32_t maxPixelsHigh;
@property (readonly, nonatomic) CGPoint redPrimary;
@property (readonly, nonatomic) CGPoint greenPrimary;
@property (readonly, nonatomic) CGPoint bluePrimary;
@property (readonly, nonatomic) CGPoint whitePoint;
@property (readonly, nonatomic) dispatch_queue_t queue;
@property (readonly, nonatomic) DVDIVirtualDisplayTerminationHandler_t terminationHandler;
@property (readonly, nonatomic) CGDirectDisplayID displayID;
@property (readonly, nonatomic) DVDIVirtualDisplayHiDPI_t hiDPI;
@property (readonly, nonatomic) NSArray<DVDIVirtualDisplayMode *> *modes;
/*!
 @property rotation
 @brief Rotation mode used by the virtual display.
 */
@property (readonly, assign, nonatomic) DVDIVirtualDisplayRotationMode rotation;

- (DVDIVirtualDisplay *)initWithDescriptor:(DVDIVirtualDisplayDescriptor *)descriptor;
- (BOOL)applySettings:(DVDIVirtualDisplaySettings *)settings;
@end
