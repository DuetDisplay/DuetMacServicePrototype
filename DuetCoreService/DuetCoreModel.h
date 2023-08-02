//
//  DuetCoreModel.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 08. 01..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DuetCoreModel : NSObject

- (void)start;
- (void)stop;

- (void)startScreenCaptureWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
