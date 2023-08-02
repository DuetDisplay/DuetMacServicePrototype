//
//  DuetDesktopCaptureServiceDelegate.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerClientProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetDesktopCapturerServiceXPCListenerDelegate : NSObject <NSXPCListenerDelegate>

@property (nonatomic, assign, readonly) BOOL connected;
@property (nonatomic, assign, readonly) id<DuetDesktopCapturerClientProtocol> remoteProxy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithService:(DuetDesktopCapturerService *)service;

@end


NS_ASSUME_NONNULL_END
