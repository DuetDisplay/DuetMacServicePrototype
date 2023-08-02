//
//  DuetGUIServiceDelegate.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetGUIService.h"
#import "DuetGUIClientProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetGUIServiceXPCListenerDelegate : NSObject <NSXPCListenerDelegate>

@property (nonatomic, assign, readonly) BOOL connected;
@property (nonatomic, assign, readonly) id<DuetGUIClientProtocol> remoteProxy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithService:(DuetGUIService *)service;

@end

NS_ASSUME_NONNULL_END
