//
//  ViewController.h
//  DuetGUI
//
//  Created by Peter Huszak on 2023. 07. 31..
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSSwitch *screenSharingSwitch;
@property (weak) IBOutlet NSSwitch *screenCapturerSwitch;
@property (weak) IBOutlet NSTextField *coreServiceConnectionStateLabel;

@end

