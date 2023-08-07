//
//  AppUserNotificationProtocol.h
//  duet
//
//  Created by Cedric Pansky on 11/10/17.
//  Copyright © 2017 Duet, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@class DuetInstance;

@protocol AppUserNotificationProtocol

- (void)showConnectNotification;
- (void)showMirroringNotification;
- (void)showSingleDisplayNotification;
- (void)showRetinaEnableNotificationForWidth:(int)width height:(int)height retinaEnabled:(BOOL)retinaEnabled displayId:(CGDirectDisplayID)displayId;
- (void)showRetinaDisableNotificationForInstance:(DuetInstance *)instance;

@end
