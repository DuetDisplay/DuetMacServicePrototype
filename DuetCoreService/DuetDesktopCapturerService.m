//
//  DuetService.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import "DuetDesktopCapturerService.h"

@implementation DuetDesktopCapturerService

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
