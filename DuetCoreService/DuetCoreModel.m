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

#pragma mark - session handling

- (void)refreshSessionWithCompletion:(void (^_Nullable)(NSError *))completion {
//	DDLogInfo(@"[APP] Checking keychain, if there is a valid duet session persisted");
	UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithServer:[NSURL URLWithString:@"https://duetdisplay.com/auth"] protocolType:UICKeyChainStoreProtocolTypeHTTPS];
	NSData *data = [store dataForKey:@"duetServicesAccount"];
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
@end
