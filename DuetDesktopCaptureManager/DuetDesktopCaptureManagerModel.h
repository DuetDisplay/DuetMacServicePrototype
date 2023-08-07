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

@property (nonatomic, assign, readwrite) IBOutlet FramePanel *panel;

- (void)startScreenCapture;

@end

NS_ASSUME_NONNULL_END
