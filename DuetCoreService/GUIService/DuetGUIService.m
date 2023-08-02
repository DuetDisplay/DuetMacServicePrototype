//
//  DuetGUIService.m
//  DuetCoreService
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetGUIService.h"
#import "DuetGUIServiceXPCListenerDelegate.h"
#import "DuetCoreModel.h"

@interface DuetGUIService ()

@property (nonatomic, strong) NSXPCListener *guiListener;
@property (nonatomic, strong) DuetGUIServiceXPCListenerDelegate *guiDelegate;
@property (nonatomic, weak) DuetCoreModel *coreModel;

@end

@implementation DuetGUIService

#pragma mark - DuetServiceProtocol

- (instancetype)initWithCoreModel:(DuetCoreModel *)model {
	self = [super init];
	if (self != nil) {
		self.coreModel = model;
		
		self.guiDelegate = [[DuetGUIServiceXPCListenerDelegate alloc] initWithService:self];
		// Set up the one NSXPCListener for this service. It will handle all incoming connections.
		self.guiListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetGUIService"];
		self.guiListener.delegate = self.guiDelegate;
		if (@available(macOS 13.0, *)) {
			[self.guiListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetGUI\""];
		} else {
			// Fallback on earlier versions
		}
	}
	return self;
}

- (void)startListening {
	[self.guiListener resume];
}

- (void)stopListening {
	[self.guiListener suspend];
}

#pragma mark - DuetGUIDaemonProtocol

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
