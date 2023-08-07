
#pragma once
#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#import <QuartzCore/QuartzCore.h>

typedef struct
{
	uint32_t modeNumber;
	uint32_t flags;
	uint32_t width;
	uint32_t height;
	uint32_t depth;
	uint8_t unknown[170];
	uint16_t freq;
	uint8_t more_unknown[16];
	float density;
} CGSDisplayMode;

// void _CGXPC_RegisterCallbackAndBringAirDisplayOnline;
int CGXDisplayDriverInitialize(int arg0, int arg1);
// int CGXExtendedDisplayStart();
// void CGSBringAirDisplayOnline();
// void CGXPC_RegisterCallbackAndBringAirDisplayOnline();
void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int *modeNum);
void CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int *nModes);
void CGSGetDisplayModeDescriptionOfLength(CGDirectDisplayID display, int idx, CGSDisplayMode *mode, int length);
