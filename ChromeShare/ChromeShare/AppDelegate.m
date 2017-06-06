//
//  AppDelegate.m
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "JZShareManager.h"
#import "PFMoveApplication.h"

@interface AppDelegate ()<NSOpenSavePanelDelegate>

@property (strong,nonatomic) JZShareManager *shareManager;
@property (strong,nonatomic) NSOpenPanel *openPanel;

@end

@implementation AppDelegate
@synthesize openPanel;

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	PFMoveToApplicationsFolderIfNecessary();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _shareManager = [JZShareManager sharedManager];
    [Fabric with:@[[Crashlytics class]]];
}

#pragma mark - Delegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSString *givenPath = [url path];
    
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [directoryURL path];
    
    return [givenPath isEqualToString:path];
}

- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url {
    NSString *givenPath = [url path];
    
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [directoryURL path];

    
    if (![givenPath isEqualToString:path])
    {
        NSOpenPanel *panel = (NSOpenPanel *)sender;
        [panel setDirectoryURL:directoryURL];
    }
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    NSString *givenPath = [url path];
    
    
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSString *path = [directoryURL path];
    
    return [givenPath isEqualToString:path];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication
                    hasVisibleWindows:(BOOL)flag
{
    [self.window makeKeyAndOrderFront:self];
    return YES;
}

@end
