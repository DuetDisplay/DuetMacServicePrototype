//
//  DuetCoreModel.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 08. 01..
//

#import "DuetCoreModel.h"
#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerClientProtocol.h"
#import "DuetDesktopCapturerServiceXPCListenerDelegate.h"

#import "DuetGUIService.h"
#import "DuetDesktopCapturerService.h"

@interface DuetCoreModel ()

@property (nonatomic, strong) DuetGUIService *guiService;
@property (nonatomic, strong) DuetDesktopCapturerService *desktopCapturerService;

@property (nonatomic, assign) BOOL started;

@end

@implementation DuetCoreModel

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		[self setupServiceListeners];
	}
	return self;
}

- (void)setupServiceListeners {
	self.guiService = [[DuetGUIService alloc] initWithCoreModel:self];
	self.desktopCapturerService = [[DuetDesktopCapturerService alloc] initWithCoreModel:self];

}

- (void)start {
	if (!self.started) {
		self.started = YES;
		[self.guiService startListening];
		[self.desktopCapturerService startListening];
	}
}

- (void)stop {
	[self.guiService stopListening];
	[self.desktopCapturerService stopListening];
	self.started = NO;
}

- (void)startScreenCaptureWithCompletion:(void (^)(BOOL, NSError * _Nonnull))completion {
	if (self.desktopCapturerService.remoteProxy == nil) {
		completion(NO, [NSError errorWithDomain:@"" code:404 userInfo:nil]);
		return;
	}
	[self.desktopCapturerService.remoteProxy startScreenCaptureWithCompletion:^(BOOL success, NSError *error) {
		completion(success, error);
	}];
}

@end
