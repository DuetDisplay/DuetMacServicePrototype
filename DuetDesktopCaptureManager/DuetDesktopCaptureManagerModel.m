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
#import "AppDelegate.h"

@interface DuetDesktopCaptureManagerModel () <DuetCoreDesktopCaptureManagerClientDelegate>

@property (nonatomic, strong) DSCScreen *mainScreen;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) DuetCoreDesktopCaptureManagerClient *captureManagerClient;

@end

@implementation DuetDesktopCaptureManagerModel

+ (instancetype)shared {
	static dispatch_once_t onceToken;
	static DuetDesktopCaptureManagerModel *shared;
	
	dispatch_once(&onceToken, ^{
		shared = [[DuetDesktopCaptureManagerModel alloc] init];
	});
	
	return shared;
}

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		self.mainScreen = [DSCScreen screenWithDisplayID:CGMainDisplayID()];
		self.captureManagerClient = [[DuetCoreDesktopCaptureManagerClient alloc] initWithAppModel:self];
		self.captureManagerClient.delegate = self;
		[self.captureManagerClient connect];
		
	}
	return self;
}

- (NSData *)dataFromEvent:(DSCScreenEvent * _Nonnull)event {
	CVImageBufferRef pixelBuffer = event.frame.imageBuffer;;
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
//	CFRelease(pixelBuffer);
	return data;
}

- (void)startScreenCapture {
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
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(screen.displayBounds.origin.x, screen.displayBounds.origin.y, 1, 1) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
					[window orderFront:nil];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
						[window orderOut:nil];
					});
				});
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
				dispatch_async(dispatch_get_main_queue(), ^{
					CVPixelBufferRef buffer = event.frame.imageBuffer;//CMSampleBufferGetImageBuffer(sampleBuffer);
					CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:buffer];
					NSCIImageRep *rep = [[NSCIImageRep alloc] initWithCIImage:image];
					NSImage *nsimage = [[NSImage alloc] init];//WithSize:rep.size];
					[nsimage addRepresentation:rep];
					((AppDelegate *)([NSApplication sharedApplication].delegate)).panel.imageView.image = nsimage;

				});
				NSData * data = [self dataFromEvent:event];
				[self.captureManagerClient.remoteProxy sendScreenData:data withReply:^(NSString *message) {
					typeof(self) self = weakSelf;
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

- (void)stopScreenCapture {
	[self.mainScreen stopCapturingScreen];
}

- (void)connect {
	[self.captureManagerClient connect];

}

- (void)disconnect {
	[self.captureManagerClient disconnect];
}

- (void)logMessage:(NSString *)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		[((AppDelegate *)([NSApplication sharedApplication].delegate)).panel logMessage:message];
	});
}

#pragma mark - DuetCoreDesktopCaptureManagerClientDelegate

- (void)clientConnectionStateDidChange:(DuetCoreDesktopCaptureManagerClient *)client {
	if (client.isConnected) {
		[self logMessage:@"Connected to Duet Core Service"];
	} else {
		[self logMessage:@"Disconnected from Duet Core Service"];
	}
}


@end
