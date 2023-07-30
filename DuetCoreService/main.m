//
//  main.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
#import "DuetService.h"
#import "DuetDesktopClientProtocol.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>

@property (nonatomic, strong) DuetService *sharedService;

@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
	NSLog(@"DuetService incoming connection %@", newConnection);

	// Configure the connection.
	// First, set the interface that the exported object implements.
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopServiceProtocol)];
	newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopClientProtocol)];
	// Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
	DuetService *exportedObject = [DuetService new];
	newConnection.exportedObject = exportedObject;
	
	// Resuming the connection allows the system to deliver more incoming messages.
	[newConnection resume];
	[newConnection.remoteObjectProxy sendDataToAgent:[@"data" dataUsingEncoding:NSUTF8StringEncoding] withReply:^(NSString *message) {
		NSLog(@"Got reply from xpc client: %@", message);
	}];
	// Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
	return YES;
}

@end

int main(int argc, const char *argv[])
{
	// Create the delegate for the service.
	ServiceDelegate *delegate = [ServiceDelegate new];
	
	// Set up the one NSXPCListener for this service. It will handle all incoming connections.
	NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetService"];
	listener.delegate = delegate;
	
	// Resuming the serviceListener starts this service. This method does not return.
	[listener resume];
	[[NSRunLoop mainRunLoop] run];

	return 0;
}