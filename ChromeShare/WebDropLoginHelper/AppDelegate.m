//
//  AppDelegate.m
//  WebDropLoginHelper
//
//  Created by Justin Fincher on 2017/6/6.
//  Copyright © 2017年 JustZht. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	BOOL alreadyRunning = NO;
	NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
	for (NSRunningApplication *app in running) {
		if ([[app bundleIdentifier] isEqualToString:@"com.JustZht.ChromeShare"]) {
			alreadyRunning = YES;
			break;
		}
	}
	if (!alreadyRunning)
	{
		NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
		pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
		NSString *path = [NSString pathWithComponents:pathComponents];
		[[NSWorkspace sharedWorkspace] launchApplication:path];
		[NSApp terminate:nil];
	}
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
