//
//  DuetGUIServiceDelegate.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetGUIService.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetGUIServiceDelegate : NSObject <NSXPCListenerDelegate>
@property (nonatomic, strong) DuetGUIService *sharedService;

@end

NS_ASSUME_NONNULL_END
