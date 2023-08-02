//
//  DuetAppModel.h
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import <Foundation/Foundation.h>
#import "DuetGUIClientProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetAppModel : NSObject

+ (instancetype)shared;

- (void)connectToDaemon;
- (void)disconnectFromDaemon;

@end

NS_ASSUME_NONNULL_END
