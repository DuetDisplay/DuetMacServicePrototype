//
//  DuetAppModel.h
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import <Foundation/Foundation.h>
#import "DuetGUIClientProtocol.h"
#import "DuetCoreGUIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetAppModel : NSObject <DuetCoreGUIClientDelegate>

@property (nonatomic, assign, readonly) BOOL connected;

+ (instancetype)shared;

- (void)connectToDaemon;
- (void)disconnectFromDaemon;

- (void)startScreenCapture;

@end

NS_ASSUME_NONNULL_END
