//
//  DuetCaptureManagerModel.h
//  DuetDesktopCaptureManager
//
//  Created by Peter Huszak on 2023. 08. 06..
//

#import <Foundation/Foundation.h>
#import "FramePanel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetDesktopCaptureManagerModel : NSObject

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;

- (void)startScreenCapture;
- (void)stopScreenCapture;

- (void)connect;
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
