/*
     File: AppDelegate.m
 Abstract: Main app controller..
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"
#import "FramePanel.h"
@import DuetCommon;
@import DuetScreenCapture;
#import "DuetDesktopServiceProtocol.h"
#import "DuetDesktopClientProtocol.h"

#import "LogManager.h"

@interface AppDelegate () <NSApplicationDelegate, DuetDesktopClientProtocol>

@property (nonatomic, assign, readwrite) IBOutlet FramePanel *     panel;
@property (nonatomic, strong) DSCScreen *mainScreen;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) NSXPCConnection *connectionToService;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    #pragma unused(note)
	
    [[LogManager sharedManager] logWithFormat:@"Did finish launching begin"];

    assert(self.panel != nil);

    // We have to call -[NSWindow setCanBecomeVisibleWithoutLogin:] to let the 
    // system know that we're not accidentally trying to display a window 
    // pre-login.
    
    [self.panel setCanBecomeVisibleWithoutLogin:YES];
    
    // Our application is a UI element which never activates, so we want our 
    // panel to show regardless.
    
    [self.panel setHidesOnDeactivate:NO];

    // Due to a problem with the relationship between the UI frameworks and the 
    // window server <rdar://problem/5136400>, -[NSWindow orderFront:] is not 
    // sufficient to show the window.  We have to use -[NSWindow orderFrontRegardless].

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ForceOrderFront"]) {
        [[LogManager sharedManager] logWithFormat:@"Showing window with extreme prejudice"];
        [self.panel orderFrontRegardless];
    } else {
        [[LogManager sharedManager] logWithFormat:@"Showing window normally"];
        [self.panel orderFront:self];
    }

    [[LogManager sharedManager] logWithFormat:@"Did finish launching end"];
}

- (void)applicationWillTerminate:(NSNotification *)note
{
    #pragma unused(note)
    [[LogManager sharedManager] logWithFormat:@"Will terminate"];
}

- (IBAction)startCaptureButtonAction:(id)sender {
	self.mainScreen = [DSCScreen screenWithDisplayID:CGMainDisplayID()];
	typeof(self) __weak weakSelf = self;
	if ([self.mainScreen isStreaming]) {
		[self logMessage:@"Already capturing"];
		return;
	}
	[self logMessage:@"Starting capture"];
	dispatch_async(dispatch_get_main_queue(), ^{
		self.frameCount = 0;
	});

	[self.mainScreen startCapturingResolution:kDSCCaptureFullResolution fullResolutionEnabled:YES intoErrorCapable:^(DSCScreen * _Nonnull screen, DSCScreenEvent * _Nonnull event, NSError * _Nullable error) {
		typeof(self) self = weakSelf;
		if (self == nil) {
			return;
		}
		switch(event.type) {
			case DSCScreenEventHandlerSet: {
				[self logMessage:@"DSCScreenEventHandlerSet"];
				break;
			}
			case DSCScreenEventStartingStream: {
				[self logMessage:@"DSCScreenEventStartingStream"];
				break;
			}
			case DSCScreenEventStartedStream: {
				[self logMessage:@"DSCScreenEventStartedStream"];
				break;
			}
			case DSCScreenEventStoppingStream: {
				[self logMessage:@"DSCScreenEventStoppingStream"];
				break;
			}
			case DSCScreenEventStoppedStream: {
				[self logMessage:@"DSCScreenEventStoppedStream"];
				break;
			}
			case DSCScreenEventSizeModified: {
				[self logMessage:@"DSCScreenEventSizeModified"];
				break;
			}
			case DSCScreenEventFrame: {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.frameCount++;
				});
				[self logMessage:[NSString stringWithFormat:@"DSCScreenEventFrame: %lu %@", self.frameCount, event.frame]];
				//TODO: encoding frames. For now, we don't send the actual data in the prototype.
				[[self->_connectionToService remoteObjectProxy] sendScreenData:[@"screendata" dataUsingEncoding:NSUTF8StringEncoding] withReply:^(NSString *message) {
					NSLog(@"Daemon responded to sendScreenData: %@", message);
				}];
				break;
			}
			case DSCScreenEventError: {
				[self logMessage:[NSString stringWithFormat:@"DSCScreenEventError: %@", error]];
				break;
			}
			case DSCScreenEventFlush: {
				[self logMessage:@"DSCScreenEventFlush"];
				break;
			}
			default:
				[self logMessage:[NSString stringWithFormat:@"Unknown event: %lu", event.type]];
				break;
		}
	}];
}

- (IBAction)stopCaptureButtonAction:(id)sender {
	[self logMessage:@"Stopping capture"];
	[self.mainScreen stopCapturingScreen];
}

- (IBAction)clearLogsButtonAction:(id)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.panel.logView.string = @"";
	});
	
}

- (IBAction)connectToDaemon:(id)sender {
	/*
	 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:
	 */
	
	_connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetService" options:NSXPCConnectionPrivileged]; //0];//
//	_connectionToService = [[NSXPCConnection alloc] initWithMachServiceName:@"com.kairos.DuetService" options:0];
	_connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopServiceProtocol)];
	_connectionToService.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DuetDesktopClientProtocol)];
	_connectionToService.exportedObject = self;
	[_connectionToService resume];
	
	[[_connectionToService remoteObjectProxy] sendScreenData:[@"screendata" dataUsingEncoding:NSUTF8StringEncoding] withReply:^(NSString *message) {
		NSLog(@"Daemon responded to sendScreenData: %@", message);
	}];
}

- (IBAction)disconnectFromDaemon:(id)sender {
	//	 And, when you are finished with the service, clean up the connection like this:

	[_connectionToService invalidate];
}

- (IBAction)closeAppButtonAction:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)logMessage:(NSString *)string {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.panel.logView.string = [self.panel.logView.string stringByAppendingFormat:@"\n%@: %@", [NSDate date], string];
	});
}

- (void)sendDataToAgent:(NSData *)data withReply:(void (^)(NSString *))reply {
	// TODO: process data coming from the daemon
	NSLog(@"Daemon called sendDataToAgent: %@", data);
	reply(@"xpc client received sendDataToAgent");
}

@end
