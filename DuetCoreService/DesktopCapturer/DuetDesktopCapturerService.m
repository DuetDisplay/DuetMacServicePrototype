//
//  DuetService.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerServiceXPCListenerDelegate.h"
#import "DuetCoreModel.h"

@interface DuetDesktopCapturerService ()

@property (nonatomic, strong) NSXPCListener *capturerListener;
@property (nonatomic, strong) DuetDesktopCapturerServiceXPCListenerDelegate *capturerDelegate;
@property (nonatomic, weak) DuetCoreModel *coreModel;

@end

@implementation DuetDesktopCapturerService

#pragma mark - DuetServiceProtocol

- (instancetype)initWithCoreModel:(DuetCoreModel *)model {
	self = [super init];
	if (self != nil) {
		self.coreModel = model;
		
		// Create the delegate for the service.
		self.capturerDelegate = [[DuetDesktopCapturerServiceXPCListenerDelegate alloc] initWithService:self];
		
		// Set up the one NSXPCListener for this service. It will handle all incoming connections.
		self.capturerListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetDesktopCapturerService"];
		self.capturerListener.delegate = self.capturerDelegate;
		if (@available(macOS 13.0, *)) {
			[self.capturerListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetDesktopCaptureManager\""];
		} else {
			// Fallback on earlier versions
		}
	}
	return self;
}

- (void)startListening {
	[self.capturerListener resume];
}

- (void)stopListening {
	[self.capturerListener suspend];
}

- (id<DuetDesktopCapturerClientProtocol>)remoteProxy {
	return self.capturerDelegate.remoteProxy;
}

#pragma mark - DuetDesktopCapturerDaemonProtocol

- (void)sendScreenData:(NSData *)data withReply:(void (^)(NSString *message))reply {
	// Process the received screen data from the LaunchAgent
	// Send the data to the remote desktop client or perform other tasks
	reply(@"sendScreenData called");
	NSLog(@"DuetService data received %lu", data.length);
}

- (void)getVersionWithCompletion:(void (^)(NSString *, NSError *))completion {
	//TODO: add version handling
	completion(@"1.0", nil);
}

@end
