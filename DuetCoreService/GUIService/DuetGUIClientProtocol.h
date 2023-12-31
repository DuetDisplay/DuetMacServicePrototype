//
//  DuetServiceProtocol.h
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DuetServiceState) {
	DuetServiceStateConnected,
	DuetServiceStateDisconnected
};

typedef NS_ENUM(NSUInteger, DuetServiceScreenSharingState) {
	DuetServiceScreenSharingStateEnabled,
	DuetServiceScreenSharingStateDisabled
};


// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol DuetGUIClientProtocol

// Methods for communication from Daemon to GUI
- (void)getVersionWithCompletion:(void (^)(NSString *version, NSError *error))completion;
- (void)serviceDidChangeScreenSharingState:(DuetServiceScreenSharingState)state;
- (void)serviceDidReceiveFrame;
@end

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"com.kairos.DuetService"];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetServiceProtocol)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         NSLog(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/
