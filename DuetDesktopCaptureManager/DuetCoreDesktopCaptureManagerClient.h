//
//  DuetCoreDesktopCaptureManagerClient.h
//  DuetDesktopCaptureManager
//
//  Created by Peter Huszak on 2023. 08. 06..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopCapturerClientProtocol.h"
#import "DuetDesktopCapturerDaemonProtocol.h"
#import "DuetDesktopCaptureManagerModel.h"

NS_ASSUME_NONNULL_BEGIN
@class DuetCoreDesktopCaptureManagerClient;

@protocol DuetCoreDesktopCaptureManagerClientDelegate

- (void)clientConnectionStateDidChange:(DuetCoreDesktopCaptureManagerClient *)client;

@end

@interface DuetCoreDesktopCaptureManagerClient : NSObject <DuetDesktopCapturerClientProtocol>

@property (nonatomic, weak) id<DuetCoreDesktopCaptureManagerClientDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, readonly) id<DuetDesktopCapturerDaemonProtocol> remoteProxy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppModel:(DuetDesktopCaptureManagerModel *)model;

- (void)connect;
- (void)disconnect;


@end

NS_ASSUME_NONNULL_END
