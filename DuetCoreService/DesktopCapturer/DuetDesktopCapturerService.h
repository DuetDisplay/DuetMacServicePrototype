//
//  DuetService.h
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopCapturerDaemonProtocol.h"
#import "DuetServiceProtocol.h"
#import "DuetDesktopCapturerClientProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface DuetDesktopCapturerService : NSObject <DuetServiceProtocol, DuetDesktopCapturerDaemonProtocol>

@property (nonatomic, strong, readonly) id<DuetDesktopCapturerClientProtocol> remoteProxy;

@end
