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
#import <UICKeyChainStore/UICKeyChainStore.h>

@import CocoaLumberjack;
@import DuetServiceSessions;

@interface DuetCoreModel ()

@property (nonatomic, strong) DuetGUIService *guiService;
@property (nonatomic, strong) DuetDesktopCapturerService *desktopCapturerService;
@property (nonatomic, strong) DuetRemoteDisplayServer *rdpServer;

@property (nonatomic) DuetServiceSession *session;

@property (nonatomic, assign) BOOL started;

@end

@implementation DuetCoreModel

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		[self setupServiceListeners];
		[self refreshSessionWithCompletion:^(NSError *) {
			NSLog(@"Refresh session completed");
		}];
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
		self.rdpServer = [DuetRemoteDisplayServer remoteDisplayServer:[[NSHost currentHost] localizedName] allowUDP:NO embeddedCursor:YES asService:NO];
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

- (void)capturerDidSendFrame:(NSData *)data {
	[self.guiService.remoteProxy serviceDidReceiveFrame];
}

#pragma mark - session handling

- (void)refreshSessionWithCompletion:(void (^_Nullable)(NSError *))completion {
//	DDLogInfo(@"[APP] Checking keychain, if there is a valid duet session persisted");
	UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
	NSData *data = [store dataForKey:@"duetServicesAccount"];
	[store setString:@"something" forKey:@"duetASD"];
	completion(nil);
	return;
	//BOOL shouldEnable = GeneralSettingsManager.shared.remoteDesktopEnabled;
	
	//	DDLogVerbose(@"%s: Acquired login data: %@", __PRETTY_FUNCTION__, data);
	if (data)
	{
		NSData *passwordHashEncodedData, *passwordHashData;
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		NSString *email = json[@"email"];
		NSString *password = json[@"password"];
		NSString *existingToken = json[@"token"];
		BOOL emailVerified = json[@"emailVerified"];
		NSString *passwordHashEncodedString = json[@"passwordHash"];
		
		if (passwordHashEncodedString != nil) {
			passwordHashEncodedData = [passwordHashEncodedString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
			passwordHashData = [[NSData alloc] initWithBase64EncodedData:passwordHashEncodedData options:NSDataBase64DecodingIgnoreUnknownCharacters];
		}
		
		if (json && email) // we may not have a password if signed in via browser
		{
			if (password != nil) {
//				DDLogWarn(@"[APP] Warning! Password based credentials in keychain. Don't login the user, and delete credentials.");

//				[AnalyticManager.shared trackEvent:@"Password based credentials detected"];

				// persisted password detected. It means the user has logged in with, don't even try to log in, delete old credentials
				UICKeyChainStore *store = [[UICKeyChainStore alloc] initWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
				[store removeItemForKey:@"duetServicesAccount"];
				if (completion != nil) {
					completion(nil);
				}
				return;
			}
//			[[DuetServicesManager shared] signInForEmail:email
//											passwordHash:passwordHashData
//												   token:existingToken
//										  emailValidated:emailVerified
//											  completion:^(DuetServicesManager *_Nonnull manager, NSError *_Nullable error) {
//				if (error != nil)
//				{
//					if (error.code == 423)
//					{ // Account was locked
//						DDLogWarn(@"[APP] Login failed - Duet session 423 - account is locked");
//
//						UICKeyChainStore *store = [[UICKeyChainStore alloc] initWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
//						[store removeItemForKey:@"duetServicesAccount"];
//					}
//					else if (error.code == 401)
//					{ // Password was wrong
//						DDLogWarn(@"[APP] Login failed - Duet Session has received 401 (invalid credentials)");
//
//						UICKeyChainStore *store = [[UICKeyChainStore alloc] initWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
//						[store removeItemForKey:@"duetServicesAccount"];
//					}
//				}
//				DDLogInfo(@"[APP] User is logged in");
//				if (completion != nil) {
//					completion(error);
//				}
//
//				//				if (shouldEnable && manager.emailVerified) {
//				//					[[DuetServicesManager shared] enableDisplays];
//				//				}
//			}];
		} else {
//			DDLogInfo(@"[APP] No Duet Session is detected (JSON decode error, or missing email)");
			if (completion != nil) {
				completion(nil);
			}
		}
	} else {
//		DDLogInfo(@"[APP] No Duet Session is detected (nothing is persisted in keychain)");
//		[AnalyticManager.shared trackEvent:@"No duet credentials"];
		if (completion != nil) {
			completion(nil);
		}
	}
}


- (void)refreshSession {
	typeof(self) __weak weakSelf = self;
	[self refreshSessionWithCompletion:^(NSError * error) {
//		if ([DuetServicesManager shared].session.authToken == nil || [DuetServicesManager shared].emailVerified == NO) {
//			if ([DuetServicesManager shared].session.authToken == nil) {
//				DDLogInfo(@"[APP] No valid Duet session is detected");
//			} else {
//				DDLogInfo(@"[APP] Waiting for email confirmation");
//			}
//
//			dispatch_async(dispatch_get_main_queue(), ^{
//				typeof(self) self = weakSelf;
//				[self openAppAndBringToForeground];
//			});
//		}
	}];
}

//- (void)validateSession:(DuetServicesManagerCompletion _Nonnull)completion
//{
//	DuetServiceSession *session = self.session;
//
//	if (session == nil || session.authToken == nil)
//	{
//		//		[[NSException exceptionWithName:@"DuetServicesManagerException" reason:@"Session is Missing" userInfo:nil] raise];
//		completion(self, [NSError errorWithDomain:@"session.error" code:404 userInfo:nil]);
//		return;
//	}
//
//	if (session.authToken != nil)
//	{
//		[self validateSessionWithExistingLogin:completion session:session];
//	}
//}
//
//- (void)signInForEmail:(NSString *_Nonnull)email passwordHash:(NSData *_Nonnull)passwordHash token:(NSString *_Nullable)token emailValidated:(BOOL)emailValidated completion:(DuetServicesManagerCompletion _Nonnull)completion
//{
////	DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
//
//	typeof(self) __weak weakSelf = self;
//
////	[self clearRelogTimer];
////	self.emailVerified = emailValidated;
//	DuetServicesManagerCompletion completionCopy = [completion copy];
//	DuetServiceSession *session = [DuetServiceSession sessionWithBaseURL:@"https://rdp.duetdisplay.com" environment:@"Production" email:email existingToken:token passwordHash:passwordHash emailValidated:emailValidated];
//	session.deviceListHandler = self.session.deviceListHandler;
//	session.proxyJoinHandler = self.session.proxyJoinHandler;
//	session.deviceListWithProxyHandler = self.session.deviceListWithProxyHandler;
//
//	[self.session cancelUrlSession];
//
//	WebSocketDevicesClient *devicesClient = self.session.devicesClient;
//	session.devicesClient = devicesClient;
//	devicesClient.delegate = session;
//
//	self.session = session;
//
//	[session refreshLocalCertificateCacheWithCompletion:^(NSURLResponse *_Nullable response, NSData *_Nullable responseData, NSError *_Nullable error) {
//	  typeof(self) strongSelf = weakSelf;
//
//	  if (strongSelf == nil)
//	  {
//		  //			[[NSException exceptionWithName:@"DuetServicesManagerException" reason:@"Service Manager is Missing" userInfo:nil] raise];
//		  return;
//	  }
//
////	  DDLogVerbose(@"%s: %@", __PRETTY_FUNCTION__, error);
//	  if (error == nil)
//	  {
//		  [strongSelf validateSession:^(DuetCoreModel *_Nonnull manager, NSError *_Nullable error) {
//			if (error == nil)
//			{
//				UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
//
//				// when doing quick logon/logoff, sometimes we see a race condition
//				// where one of these is nil, leading to a crash, so double check here
//				// and throw an error instead of crashing
//
//				// TODO: we should find the origin of this race condition and eventually make a proper fix
//
//				// NOTE: when we do web auth outside of the app, we no longer have a password, so don't check for that
//
//				if ((email == nil) || (strongSelf.session.authToken == nil))
//				{
//					NSInteger errorCode = 1000;
//
//					if (email == nil)
//						errorCode = 1000;
//					else if (strongSelf.session.authToken == nil)
//						errorCode = 1002;
//
//					NSError *sysError = [NSError errorWithDomain:@"duet.timingError"
//															code:errorCode
//														userInfo:@{
//															NSLocalizedDescriptionKey : @"System Error, please try again."
//														}];
//
//					completionCopy(strongSelf, sysError);
//					return;
//				}
//
//				NSData *data;
//
//				if (passwordHash)
//				{
//					NSData *passwordHashEncodedData = [passwordHash base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength];
//
//					NSString *passwordHashEncodedDataString = [[NSString alloc] initWithData:passwordHashEncodedData encoding:NSUTF8StringEncoding];
//
//					data = [NSJSONSerialization dataWithJSONObject:@{@"email" : email, @"passwordHash" : passwordHashEncodedDataString, @"token" : strongSelf.session.authToken, @"emailVerified": @(strongSelf.session.emailVerified)} options:0 error:nil];
//				}
//				else
//				{
//					data = [NSJSONSerialization dataWithJSONObject:@{@"email" : email, @"token" : strongSelf.session.authToken, @"emailVerified": @(strongSelf.session.emailVerified)} options:0 error:nil];
//				}
//
//				if (data)
//				{
//					[store setData:data forKey:@"duetServicesAccount"];
//				}
////				[[AnalyticManager shared] setUserId:email];
//			}
//			else if (error.code == 423 || error.code == 401)
//			{
//				UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
//				[store removeItemForKey:@"duetServicesAccount"];
//			}
//
////			[[DuetServicesManager.shared session] postLogs];  // Dead code TODO: fix it or delete it
//			//				[[DuetServicesManager.shared session] clearLogs];
//
//			if (error.code != 504 && error.code != 502)
//			{
//				if (error == nil || (error.code != 423 && error.code != 401))
//				{
////					[strongSelf startReSignTimerForEmail:email passwordHash:passwordHash token:token completion:completionCopy];
//				}
//
//				if (error.code == 423 || error.code == 401)
//				{
//					[strongSelf.session cancelUrlSession];
//					[strongSelf.session stopDevicesClient];
//					strongSelf.session = nil;
//				}
//				completionCopy(manager, error);
//			}
//			else if (error.code == 404)
//			{
//				completionCopy(manager, error);
//			}
//			else
//			{
////				[strongSelf startReSignTimerForEmail:email passwordHash:passwordHash token:token completion:completionCopy];
//			}
//		  }];
//	  }
//	  else
//	  {
//		  if (error.code != 504 && error.code != 502)
//		  {
//			  completionCopy(strongSelf, error);
//		  }
//		  else
//		  {
////			  [strongSelf startReSignTimerForEmail:email passwordHash:passwordHash token:token completion:completionCopy];
//		  }
//	  }
//	}];
//}

@end
