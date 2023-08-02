//
//  DuetGUIService.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetGUIDaemonProtocol.h"
#import "DuetServiceProtocol.h"
#import "DuetGUIClientProtocol.h"

@class DuetCoreModel;

NS_ASSUME_NONNULL_BEGIN

@interface DuetGUIService : NSObject <DuetServiceProtocol, DuetGUIDaemonProtocol>

@property (nonatomic, strong, readonly) id<DuetGUIClientProtocol> remoteProxy;

@end

NS_ASSUME_NONNULL_END
