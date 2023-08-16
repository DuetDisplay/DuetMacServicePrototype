//
//  DuetServiceProtocol.h
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
@import DuetScreenCapture;
@import DuetRemoteDisplay;

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol DuetDesktopCapturerClientProtocol

- (void)getVersionWithCompletion:(void (^)(NSString *version, NSError *error))completion;
- (void)startScreenCaptureWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)getScreenList:(void (^)(NSArray *))completion;
- (void)setRemoteFeatures:(DuetRemoteFeatures *)features;
//- (void)getScreenList:(void (^)(NSArray<DSCScreen *> *))completion;
// Methods for communication from Daemon to Agent
- (void)sendDataToAgent:(NSData *)data withReply:(void (^)(NSString *message))reply;

- (void)setupWithResolutions:(nonnull NSArray<id<DuetRDSExtendedDisplayResolution>> *)resolutions retina:(BOOL)retina portrait:(BOOL)portrait completion:(nonnull DuetRDSExtendedDisplaySetupCompletion)completion;

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
