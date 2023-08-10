//
//  DuetAppModel.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 08. 02..
//

#import "DuetAppModel.h"
#import "DuetGUIDaemonProtocol.h"
@import DuetScreenCapture;


@interface DuetAppModel ()

@property (nonatomic, strong) DuetCoreGUIClient *guiClient;

@property (nonatomic, strong) DSCScreen *mainScreen;
@property (nonatomic, assign) NSInteger frameCount;

@end

@implementation DuetAppModel

- (void)startScreenCapture {
	[self.guiClient.remoteProxy startSessionWithCompletion:^(BOOL success, NSError *error) {
		NSLog(@"Start capture: %d %@", success, error);
	}];
}

- (void)logMessage:(NSString *)message {
	NSLog(@"%@",message);
}

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
		self.guiClient.delegate = self;
		DSCScreen *screen = [DSCScreen screenWithDisplayID:CGMainDisplayID()];
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

- (void)clientConnectionStateDidChange:(nonnull DuetCoreGUIClient *)client {
	//TODO: implement listener instead of notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:@"clientConnectionStateChanged" object:nil];
}

@end
