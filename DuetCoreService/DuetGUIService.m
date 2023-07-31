//
//  DuetGUIService.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetGUIService.h"

@implementation DuetGUIService

- (void)getVersionWithCompletion:(void (^)(NSString *version, NSError *error))completion {
	//TODO: version handling
	completion(@"1.0", nil);
}

- (void)setScreenSharingStateTo:(BOOL)enabled withCompletion:(void (^)(BOOL success, NSError *error))completion {
	//TODO: screen sharing enable/disable
	completion(YES, nil);
}

- (void)startSessionWithCompletion:(void (^)(BOOL success, NSError *error))completion {
	//TODO: start capture session
	completion(YES, nil);
}

@end
