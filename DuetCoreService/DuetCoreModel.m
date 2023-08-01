//
//  DuetCoreModel.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 08. 01..
//

#import "DuetCoreModel.h"
#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerClientProtocol.h"
#import "DuetDesktopCapturerServiceDelegate.h"

#import "DuetGUIService.h"
#import "DuetGUIServiceDelegate.h"
#import "DuetGUIServiceProtocol.h"
#import "DuetGUIClientProtocol.h"

@interface DuetCoreModel ()

@property (nonatomic, strong) NSXPCListener *guiListener;
@property (nonatomic, strong) DuetGUIServiceDelegate *guiDelegate;
@property (nonatomic, strong) NSXPCListener *capturerListener;
@property (nonatomic, strong) DuetDesktopCapturerServiceDelegate *desktopCapturerDelegate;
@property (nonatomic, assign) BOOL started;

@end

@implementation DuetCoreModel

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		[self setupServiceListeners];
	}
	return self;
}

- (void)setupServiceListeners {
	self.guiDelegate = [DuetGUIServiceDelegate new];
	// Set up the one NSXPCListener for this service. It will handle all incoming connections.
	self.guiListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetGUIService"];
	self.guiListener.delegate = self.guiDelegate;
	if (@available(macOS 13.0, *)) {
//		[self.guiListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetGUI\""];
	} else {
		// Fallback on earlier versions
	}

	// Create the delegate for the service.
	self.desktopCapturerDelegate = [DuetDesktopCapturerServiceDelegate new];
	
	// Set up the one NSXPCListener for this service. It will handle all incoming connections.
	self.capturerListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetDesktopCapturerService"];
	self.capturerListener.delegate = self.desktopCapturerDelegate;
	if (@available(macOS 13.0, *)) {
		[self.capturerListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetDesktopCaptureManager\""];
	} else {
		// Fallback on earlier versions
	}
}

- (void)start {
	if (!self.started) {
		self.started = YES;
		[self.guiListener resume];
		[self.capturerListener resume];
	}
}

- (void)stop {
	[self.guiListener suspend];
	[self.capturerListener suspend];
	self.started = NO;
}

@end
