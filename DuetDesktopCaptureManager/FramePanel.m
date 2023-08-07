//
//  FramePanel.m
//  DuetDesktopCaptureManager
//
//  Created by Peter Huszak on 2023. 07. 26..
//

#import "FramePanel.h"
#import "DuetDesktopCaptureManagerModel.h"

@implementation FramePanel

- (IBAction)startCaptureButtonAction:(id)sender {
	[[DuetDesktopCaptureManagerModel shared] startScreenCapture];
}

- (IBAction)stopCaptureButtonAction:(id)sender {
	[self logMessage:@"Stopping capture"];
	[[DuetDesktopCaptureManagerModel shared] stopScreenCapture];

}

- (IBAction)clearLogsButtonAction:(id)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.logView.string = @"";
	});
	
}

- (IBAction)connectToDaemon:(id)sender {
	/*
	 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:
	 */
	[self logMessage:@"connectToDaemon"];
	[[DuetDesktopCaptureManagerModel shared] connect];
}

- (IBAction)disconnectFromDaemon:(id)sender {
	//	 And, when you are finished with the service, clean up the connection like this:
	[self logMessage:@"disconnectFromDaemon"];
	[[DuetDesktopCaptureManagerModel shared] disconnect];
	
}

- (IBAction)closeAppButtonAction:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)logMessage:(NSString *)string {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@"%@", string);
		self.logView.string = [self.logView.string stringByAppendingFormat:@"\n%@: %@", [NSDate date], string];
	});
}
@end
