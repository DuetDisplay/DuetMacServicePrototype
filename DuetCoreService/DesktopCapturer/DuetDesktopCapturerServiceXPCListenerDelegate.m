//
//  DuetDesktopCaptureServiceDelegate.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetDesktopCapturerServiceXPCListenerDelegate.h"
#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerClientProtocol.h"

@interface DuetDesktopCapturerServiceXPCListenerDelegate ()

@property (nonatomic, weak) DuetDesktopCapturerService *service;

@property (readwrite) BOOL connected;
@property (nonatomic, weak) NSXPCConnection *connection;

@end

@implementation DuetDesktopCapturerServiceXPCListenerDelegate

- (nonnull instancetype)initWithService:(nonnull DuetDesktopCapturerService *)service {
	self = [super init];
	if (self != nil) {
		self.service = service;
	}
	return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
	NSLog(@"DuetService incoming connection %@", newConnection);

	// Configure the connection.
	// First, set the interface that the exported object implements.
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopCapturerDaemonProtocol)];
	newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopCapturerClientProtocol)];
	// Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
	DuetDesktopCapturerService *exportedObject = self.service;
	newConnection.exportedObject = exportedObject;
	typeof(self) __weak weakSelf = self;

	newConnection.invalidationHandler = ^{
		typeof(self) self = weakSelf;
		NSLog(@"Connection to the DesktopCaptureManager Client was invalidated");
	};
	newConnection.interruptionHandler = ^{
		typeof(self) self = weakSelf;
		self.connected = NO;
		NSLog(@"Connection to the DesktopCaptureManager Client was interrupted");
	};
	
	// Resuming the connection allows the system to deliver more incoming messages.
	[newConnection resume];
	
	// Validate the connection

	[self.remoteProxy getVersionWithCompletion:^(NSString *version, NSError *error) {
		NSLog(@"Desktop Capture Manager responded to getVersion: %@ error: %@", version, error);
	}];

	[self.remoteProxy startScreenCaptureWithCompletion:^(BOOL success, NSError *error) {
		NSLog(@"Start screencapture success: %d, error: %@", success, error);
	}];
	
	self.connection = newConnection;
	// Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
	return YES;
}

- (id<DuetDesktopCapturerClientProtocol>)remoteProxy {
	typeof(self) __weak weakSelf = self;
	id<DuetDesktopCapturerClientProtocol> remoteProxy = [self.connection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		typeof(self) self = weakSelf;
		self.connected = NO;
		// This block will be called if the connection is interrupted or disconnected.
		NSLog(@"Connection to the DesktopCapturer Client was terminated with error %@", error);
	}];
	return remoteProxy;
}
@end
