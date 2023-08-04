//
// Created by Cedric Pansky on 2019-02-07.
// Copyright (c) 2019 Duet, Inc. All rights reserved.
//

#import "DVDIMap.h"
//#import <duet-Swift.h>
#import <DuetDesktopCaptureManager-Swift.h>

@implementation DVDIVirtualDisplaySettings

- (id)init
{
	id vdiClass = NSClassFromString([[DVDI ecn] stringByAppendingString:@"Settings"]);

	if (vdiClass != nil)
	{
		return [[vdiClass alloc] init];
	}

	return nil;
}

@end

@implementation DVDIVirtualDisplayDescriptor

- (id)init
{
	id vdiClass = NSClassFromString([[DVDI ecn] stringByAppendingString:@"Descriptor"]);

	if (vdiClass != nil)
	{
		return [[vdiClass alloc] init];
	}

	return nil;
}

@end

@implementation DVDIVirtualDisplayMode

- (DVDIVirtualDisplayMode *)initWithWidth:(uint32_t)width height:(uint32_t)height refreshRate:(double)refreshRate
{
	id vdiClass = NSClassFromString([[DVDI ecn] stringByAppendingString:@"Mode"]);

	if (vdiClass != nil)
	{
		return [[vdiClass alloc] initWithWidth:width height:height refreshRate:refreshRate];
	}

	return nil;
}

@end

@implementation DVDIVirtualDisplay

- (DVDIVirtualDisplay *)initWithDescriptor:(DVDIVirtualDisplayDescriptor *)descriptor
{
	id vdiClass = NSClassFromString([DVDI ecn]);

	if (vdiClass != nil)
	{
		return [[vdiClass alloc] initWithDescriptor:descriptor];
	}

	return nil;
}

- (BOOL)applySettings:(DVDIVirtualDisplaySettings *)settings
{
	return NO;
}

@end
