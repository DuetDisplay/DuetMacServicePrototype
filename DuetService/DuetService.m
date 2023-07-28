//
//  DuetService.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import "DuetService.h"

@implementation DuetService

- (void)sendScreenData:(NSData *)data {
	// Process the received screen data from the LaunchAgent
	// Send the data to the remote desktop client or perform other tasks
	NSLog(@"DuetService data received %lu", data.length);
}

- (void)sendDataToAgent:(NSData *)data {
	// Process the received data from the LaunchAgent
	// You can send data back to the Agent or perform other tasks
}

@end
