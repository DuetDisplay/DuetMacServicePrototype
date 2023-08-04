//
//  DuetCoreModel.h
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 08. 01..
//

#import <Foundation/Foundation.h>
@import DuetServiceSessions;

@class DuetCoreModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^DuetServicesManagerCompletion)(DuetCoreModel *_Nonnull manager, NSError *_Nullable error);

@interface DuetCoreModel : NSObject

@property (nonatomic, readonly, nullable) DuetServiceSession *session;

- (void)start;
- (void)stop;

- (void)startScreenCaptureWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
