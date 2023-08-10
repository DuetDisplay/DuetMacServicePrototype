//
//  DuetGUIWindowController.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "DuetGUIWindowController.h"
#import "DuetAppModel.h"

@interface DuetGUIWindowController ()

@end

@implementation DuetGUIWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)startCaptureAction:(id)sender {
	[[DuetAppModel shared] startScreenCapture];
}

- (IBAction)stopCaptureAction:(id)sender {
	
}

- (IBAction)connectToDaemon:(id)sender {
	[[DuetAppModel shared] connectToDaemon];
}

- (IBAction)disconnectFromDaemon:(id)sender {
	[[DuetAppModel shared] disconnectFromDaemon];

}

@end
