//
//  AppDelegate.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "AppDelegate.h"
#import "DuetGUIClientProtocol.h"
#import "DuetGUIServiceProtocol.h"

@interface AppDelegate () <NSApplicationDelegate, DuetGUIClientProtocol>

@property (nonatomic, strong) NSXPCConnection *connectionToService;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}


- (void)serviceDidChangeScreenSharingState:(DuetServiceScreenSharingState)state {
	
}

- (void)connectToDaemon {
	_connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetGUIService" options:NSXPCConnectionPrivileged];
//	_connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetService" options:0];
	_connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIServiceProtocol)];
	_connectionToService.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetGUIClientProtocol)];
	_connectionToService.exportedObject = self;
	[_connectionToService resume];
	
	typeof(self) __weak weakSelf = self;

	// Validate the connection
	id<DuetGUIServiceProtocol> remoteProxy = [_connectionToService remoteObjectProxyWithErrorHandler:^(NSError *error) {
		typeof(self) self = weakSelf;
		NSLog(@"%@", error);
		// This block will be called if the connection is interrupted or disconnected.
	}];
	
	[remoteProxy getVersionWithCompletion:^(NSString *version, NSError *error) {
		NSLog(@"Daemon responded to getVersion: %@ error: %@", version, error);
	}];
//	[remoteProxy  sendScreenData:[@"screendata" dataUsingEncoding:NSUTF8StringEncoding] withReply:^(NSString *message) {
//		typeof(self) self = weakSelf;
//		NSLog(@"Daemon responded to sendScreenData: %@", message);
//		[self logMessage:[NSString stringWithFormat:@"Daemon responded to sendScreenData: %@", message]];
//
//	}];
}

- (void)getVersionWithCompletion:(void (^)(NSString *, NSError *))completion {
	//TODO: version handling
	completion(@"1.0", nil);
}

@end
