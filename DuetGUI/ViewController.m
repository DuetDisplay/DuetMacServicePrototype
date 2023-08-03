//
//  ViewController.m
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import "ViewController.h"
#import "DuetAppModel.h"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	//TODO: implement listener instead of notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStateChanged:) name:@"clientConnectionStateChanged" object:nil];
	[self updateUI];
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

- (IBAction)screenSharingSwitchAction:(id)sender {
	
}

- (IBAction)screenCapturerSwitchAction:(id)sender {
	
}

- (void)connectionStateChanged:(NSNotification *)notification {
	[self updateUI];
}

- (void)updateUI {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.coreServiceConnectionStateLabel.stringValue = [DuetAppModel shared].connected ? @"Connected" : @"Disconnected";
	});
}

@end
