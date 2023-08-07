//
//  DuetCaptureManagerModel.m
//  DuetDesktopCaptureManager
//
//  Created by Peter Huszak on 2023. 08. 06..
//

#import "DuetDesktopCaptureManagerModel.h"
#import "FramePanel.h"
#import "DuetCoreDesktopCaptureManagerClient.h"
@import DuetCommon;
@import DuetScreenCapture;

@interface DuetDesktopCaptureManagerModel () <DuetCoreDesktopCaptureManagerClientDelegate>

@property (nonatomic, strong) DSCScreen *mainScreen;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) DuetCoreDesktopCaptureManagerClient *captureManagerClient;

@end

@implementation DuetDesktopCaptureManagerModel

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		self.captureManagerClient = [[DuetCoreDesktopCaptureManagerClient alloc] initWithAppModel:self];
		self.captureManagerClient.delegate = self;
		[self.captureManagerClient connect];
		
	}
	return self;
}

- (NSData *)dataFromEvent:(DSCScreenEvent * _Nonnull)event {
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(event.frame.sampleBuffer);
	CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	size_t planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
	size_t totalSize = 0;
	void *rawFrame;
	if (planeCount == 0) {
		size_t height = CVPixelBufferGetHeight(pixelBuffer);
		size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
		totalSize = height * bytesPerRow;
		rawFrame = malloc(totalSize);
		if (rawFrame == nil) {
			exit(1);
		}
		void *source = CVPixelBufferGetBaseAddress(pixelBuffer);
		memcpy(rawFrame, source, totalSize);
	} else {
		for (size_t i = 0; i < planeCount; i++) {
			size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i);
			size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i);
			size_t planeSize = height * bytesPerRow;
			totalSize += planeSize;
		}
		rawFrame = malloc(totalSize);
		if (rawFrame == nil) {
			exit(1);
		}
		void *dest = rawFrame;
		for (size_t i = 0; i < planeCount; i++) {
			void *source = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, i);
			size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i);
			size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i);
			size_t planeSize = height * bytesPerRow;
			
			memcpy(dest, source, planeSize);
			dest += planeSize;
		}
	}
	CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
	NSData *data = [[NSData alloc] initWithBytesNoCopy:rawFrame length:totalSize freeWhenDone:YES];
	return data;
}

- (void)startScreenCapture {
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

				NSData * data = [self dataFromEvent:event];
				
				[self.captureManagerClient.remoteProxy sendScreenData:data withReply:^(NSString *message) {
					typeof(self) self = weakSelf;
					NSLog(@"Daemon responded to sendScreenData: %@", message);
					[self logMessage:[NSString stringWithFormat:@"Daemon responded to sendScreenData: %@", message]];
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

- (IBAction)startCaptureButtonAction:(id)sender {
	[self startScreenCapture];
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
	[self logMessage:@"connectToDaemon"];
	[self.captureManagerClient connect];
}

- (IBAction)disconnectFromDaemon:(id)sender {
	//	 And, when you are finished with the service, clean up the connection like this:
	[self logMessage:@"disconnectFromDaemon"];
	
	[self.captureManagerClient disconnect];
}

- (IBAction)closeAppButtonAction:(id)sender {
	[[NSApplication sharedApplication] terminate:self];
}

- (void)logMessage:(NSString *)string {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.panel.logView.string = [self.panel.logView.string stringByAppendingFormat:@"\n%@: %@", [NSDate date], string];
	});
}

- (void)startScreenCaptureWithCompletion:(void (^)(BOOL, NSError *))completion {
	[self startScreenCapture];
	//TODO: error handling here
	completion(YES, nil);
}

- (void)clientConnectionStateDidChange:(DuetCoreDesktopCaptureManagerClient *)client {
	if (client.isConnected) {
		[self logMessage:@"Connected to Duet Core Service"];
	} else {
		[self logMessage:@"Disconnected from Duet Core Service"];
	}
}

@end
