//
//  DuetGUIServiceDelegate.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetGUIServiceDelegate.h"
#import "DuetGUIClientProtocol.h"
#import "DuetGUIServiceProtocol.h"

@implementation DuetGUIServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
	NSLog(@"DuetService incoming connection %@", newConnection);

	// Configure the connection.
	// First, set the interface that the exported object implements.
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIServiceProtocol)];
	newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIClientProtocol)];
	// Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
	DuetGUIService *exportedObject = [DuetGUIService new];
	newConnection.exportedObject = exportedObject;
	
	// Resuming the connection allows the system to deliver more incoming messages.
	[newConnection resume];
	
	typeof(self) __weak weakSelf = self;

	// Validate the connection
	id<DuetGUIClientProtocol> remoteProxy = [newConnection remoteObjectProxyWithErrorHandler:^(NSError *error) {
		typeof(self) self = weakSelf;
		// This block will be called if the connection is interrupted or disconnected.
	}];
	[remoteProxy getVersionWithCompletion:^(NSString *version, NSError *error) {
		NSLog(@"GUI responded to getVersion: %@ error: %@", version, error);
	}];


	// Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
	return YES;
}

@end
