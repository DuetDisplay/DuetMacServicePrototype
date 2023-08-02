//
//  DuetGUIServiceDelegate.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetGUIServiceXPCListenerDelegate.h"
#import "DuetGUIClientProtocol.h"
#import "DuetGUIDaemonProtocol.h"

@interface DuetGUIServiceXPCListenerDelegate ()

@property (nonatomic, weak) DuetGUIService *service;
@property (readwrite) BOOL connected;
@property (nonatomic, weak) NSXPCConnection *connection;

@end

@implementation DuetGUIServiceXPCListenerDelegate

- (nonnull instancetype)initWithService:(nonnull DuetGUIService *)service {
	self = [super init];
	if (self != nil) {
		self.service = service;
	}
	return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
	NSLog(@"DuetService incoming connection %@", newConnection);
	if (self.connected) {
		NSLog(@"Refusing incoming connection: %@", newConnection);
		return NO;
	}
	// Configure the connection.
	// First, set the interface that the exported object implements.
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIDaemonProtocol)];
	newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIClientProtocol)];
	// Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
	DuetGUIService *exportedObject = self.service;
	newConnection.exportedObject = exportedObject;
	typeof(self) __weak weakSelf = self;

	newConnection.invalidationHandler = ^{
		typeof(self) self = weakSelf;
		self.connected = NO;
		NSLog(@"Connection to the GUI Client was invalidated");
	};
	newConnection.interruptionHandler = ^{
		typeof(self) self = weakSelf;
		self.connected = NO;
		NSLog(@"Connection to the GUI Client was interrupted");
	};

	// Resuming the connection allows the system to deliver more incoming messages.
	[newConnection resume];
	
	// Validate the connection
	[self.remoteProxy getVersionWithCompletion:^(NSString *version, NSError *error) {
		NSLog(@"GUI responded to getVersion: %@ error: %@", version, error);
	}];

	self.connected = YES;
	self.connection = newConnection;
	// Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
	return YES;
}

- (id<DuetGUIClientProtocol>)remoteProxy {
	typeof(self) __weak weakSelf = self;
	id<DuetGUIClientProtocol> remoteProxy = [self.connection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		typeof(self) self = weakSelf;
		self.connected = NO;
		// This block will be called if the connection is interrupted or disconnected.
		NSLog(@"Connection to the GUI Client was terminated with error %@", error);
	}];
	return remoteProxy;
}

@end
