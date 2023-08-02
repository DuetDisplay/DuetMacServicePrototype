//
//  DuetCoreGUIClient.h
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import <Foundation/Foundation.h>
#import "DuetGUIClientProtocol.h"
#import "DuetGUIDaemonProtocol.h"

@class DuetAppModel;

NS_ASSUME_NONNULL_BEGIN

@interface DuetCoreGUIClient : NSObject <DuetGUIClientProtocol>

@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, readonly) id<DuetGUIDaemonProtocol> remoteProxy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppModel:(DuetAppModel *)model;

- (void)connect;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
