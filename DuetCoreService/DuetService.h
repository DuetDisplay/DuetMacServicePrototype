//
//  DuetService.h
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface DuetService : NSObject <DuetDesktopServiceProtocol>
@end
