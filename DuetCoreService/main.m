//
//  main.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
#import "DuetDesktopCapturerService.h"
#import "DuetDesktopCapturerClientProtocol.h"
#import "DuetDesktopCapturerServiceDelegate.h"

#import "DuetGUIService.h"
#import "DuetGUIServiceDelegate.h"
#import "DuetGUIServiceProtocol.h"
#import "DuetGUIClientProtocol.h"

int main(int argc, const char *argv[])
{
	DuetGUIServiceDelegate *guiDelegate = [DuetGUIServiceDelegate new];
	// Set up the one NSXPCListener for this service. It will handle all incoming connections.
	NSXPCListener *guiListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetGUIService"];
	guiListener.delegate = guiDelegate;
	if (@available(macOS 13.0, *)) {
		[guiListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetGUI\""];
	} else {
		// Fallback on earlier versions
	}

	// Resuming the serviceListener starts this service. This method does not return.
	[guiListener resume];
	
	// Create the delegate for the service.
	DuetDesktopCapturerServiceDelegate *desktopCapturerDelegate = [DuetDesktopCapturerServiceDelegate new];
	
	// Set up the one NSXPCListener for this service. It will handle all incoming connections.
	NSXPCListener *capturerListener = [[NSXPCListener alloc] initWithMachServiceName:@"com.kairos.DuetDesktopCapturerService"];
	capturerListener.delegate = desktopCapturerDelegate;
	if (@available(macOS 13.0, *)) {
		[capturerListener setConnectionCodeSigningRequirement:@"identifier \"com.kairos.DuetDesktopCaptureManager\""];
	} else {
		// Fallback on earlier versions
	}
	// Resuming the serviceListener starts this service. This method does not return.
	[capturerListener resume];
	


	[[NSRunLoop mainRunLoop] run];

	return 0;
}
