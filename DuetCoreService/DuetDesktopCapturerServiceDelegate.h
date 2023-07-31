//
//  DuetDesktopCaptureServiceDelegate.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopCapturerService.h"

NS_ASSUME_NONNULL_BEGIN

@interface DuetDesktopCapturerServiceDelegate : NSObject <NSXPCListenerDelegate>

@property (nonatomic, strong) DuetDesktopCapturerService *sharedService;

@end


NS_ASSUME_NONNULL_END
