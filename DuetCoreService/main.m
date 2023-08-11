//
//  main.m
//  DuetService
//
//  Created by Peter Huszak on 2023. 07. 28..
//

#import <Foundation/Foundation.h>
#import "DuetCoreModel.h"

int main(int argc, const char *argv[])
{
	@autoreleasepool {
		NSLog(@"Launching DuetCoreService Daemon");
		DuetCoreModel *model = [DuetCoreModel new];
		[model start];
		[[NSRunLoop mainRunLoop] run];
	}
	return 0;
}
