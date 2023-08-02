//
//  DuetGUIServiceDelegate.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetGUIService.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetGUIServiceXPCListenerDelegate : NSObject <NSXPCListenerDelegate>
@property (nonatomic, strong) DuetGUIService *sharedService;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithService:(DuetGUIService *)service;

@end

NS_ASSUME_NONNULL_END
