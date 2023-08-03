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
@class DuetCoreGUIClient;

NS_ASSUME_NONNULL_BEGIN

@protocol DuetCoreGUIClientDelegate

- (void)clientConnectionStateDidChange:(DuetCoreGUIClient *)client;

@end

@interface DuetCoreGUIClient : NSObject <DuetGUIClientProtocol>

@property (nonatomic, weak) id<DuetCoreGUIClientDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, readonly) id<DuetGUIDaemonProtocol> remoteProxy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppModel:(DuetAppModel *)model;

- (void)connect;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
