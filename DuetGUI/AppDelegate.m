//
//  AppDelegate.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "AppDelegate.h"
#import "DuetGUIClientProtocol.h"
#import "DuetGUIDaemonProtocol.h"
#import "DuetAppModel.h"

@interface AppDelegate () <NSApplicationDelegate>

@property (nonatomic, strong) DuetAppModel *appModel;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.appModel = [DuetAppModel shared];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}




@end
