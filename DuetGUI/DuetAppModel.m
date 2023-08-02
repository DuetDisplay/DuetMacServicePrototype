//
//  DuetAppModel.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import "DuetAppModel.h"
#import "DuetGUIDaemonProtocol.h"
#import "DuetCoreGUIClient.h"

@interface DuetAppModel ()

@property (nonatomic, strong) DuetCoreGUIClient *guiClient;

@end

@implementation DuetAppModel

+ (instancetype)shared {
	static dispatch_once_t onceToken;
	static DuetAppModel *shared;
	
	dispatch_once(&onceToken, ^{
		shared = [[DuetAppModel alloc] init];
	});
	
	return shared;
}

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		self.guiClient = [[DuetCoreGUIClient alloc] initWithAppModel:self];
	}
	return self;
}

- (void)connectToDaemon {
	[self.guiClient connect];
}

- (void)disconnectFromDaemon {
	[self.guiClient disconnect];
}

- (BOOL)connected {
	return self.guiClient.isConnected;
}

@end
