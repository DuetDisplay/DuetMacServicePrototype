//
//  DuetCoreGUIClient.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import "DuetCoreGUIClient.h"
#import "DuetGUIDaemonProtocol.h"
#import "DuetGUIClientProtocol.h"
#import "DuetAppModel.h"

@interface DuetCoreGUIClient ()

@property (nonatomic, strong) NSXPCConnection *connectionToService;
@property (nonatomic, weak) DuetAppModel *appModel;

@end

@implementation DuetCoreGUIClient

- (instancetype)initWithAppModel:(DuetAppModel *)model {
	self = [super self];
	if (self != nil) {
		self.appModel = model;
	}
	return self;
}
- (id<DuetGUIDaemonProtocol>)remoteProxy {
	typeof(self) __weak weakSelf = self;
	id<DuetGUIDaemonProtocol> remoteProxy = [self.connectionToService remoteObjectProxyWithErrorHandler:^(NSError *error) {
		typeof(self) self = weakSelf;
		NSLog(@"Connection to the Daemon is terminated. Error: %@.", error);
		self.connectionToService = nil;
	}];
	return remoteProxy;
}

- (BOOL)isConnected {
	return (self.connectionToService != nil);
}

- (void)connect {
	if (self.isConnected) {
		NSLog(@"Already connected to DuetCoreService.");
		return;
	}
	self.connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetGUIService" options:NSXPCConnectionPrivileged];
//	_connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetGUIService" options:0];
	self.connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIDaemonProtocol)];
	self.connectionToService.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIClientProtocol)];
	self.connectionToService.exportedObject = self;
	typeof(self) __weak weakSelf = self;
	self.connectionToService.interruptionHandler = ^{
		typeof(self) self = weakSelf;
		NSLog(@"Connection to the Daemon is interrupted.");
		self.connectionToService = nil;
	};
	self.connectionToService.invalidationHandler = ^{
		typeof(self) self = weakSelf;
		NSLog(@"Connection to the Daemon is invalidated.");
		self.connectionToService = nil;
	};
	
	[self.connectionToService resume];
	
	// Validate the connection
	[self.remoteProxy getVersionWithCompletion:^(NSString *version, NSError *error) {
		NSLog(@"Daemon responded to getVersion: %@ error: %@", version, error);
	}];
	[self.remoteProxy startSessionWithCompletion:^(BOOL success, NSError *error) {
		NSLog(@"Daemon responded to startSession: %d %@", success, error);
	}];
}

- (void)disconnect {
	[self.connectionToService invalidate];
	self.connectionToService = nil;
}

- (void)setConnectionToService:(NSXPCConnection *)connectionToService {
	if (_connectionToService == connectionToService) {
		return;
	}
	_connectionToService = connectionToService;
	[self.delegate clientConnectionStateDidChange:self];
	
}

#pragma mark - DuetGUIClientProtocol
- (void)serviceDidChangeScreenSharingState:(DuetServiceScreenSharingState)state {
	
}

- (void)serviceDidReceiveFrame {
	NSLog(@"Daemon received a video frame from the capturer");
}

- (void)getVersionWithCompletion:(void (^)(NSString *, NSError *))completion {
	//TODO: version handling
	completion(@"1.0", nil);
}

@end
