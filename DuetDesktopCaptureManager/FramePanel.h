//
//  FramePanel.h
//  DuetDesktopCaptureManager
//
//  Created by Peter Huszak on 2023. 07. 26..
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FramePanel : NSPanel


@property (nonatomic, weak) IBOutlet NSTextView *logView;

- (void)logMessage:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
