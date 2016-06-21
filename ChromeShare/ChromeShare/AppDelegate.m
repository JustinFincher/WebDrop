//
//  AppDelegate.m
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "AppDelegate.h"
#import "JZShareManager.h"

@interface AppDelegate ()<NSOpenSavePanelDelegate>

@property (strong,nonatomic) JZShareManager *shareManager;
@property (strong,nonatomic) NSOpenPanel *openPanel;

@end

@implementation AppDelegate
@synthesize openPanel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _shareManager = [JZShareManager sharedManager];
    [self checkScriptExists];
    
    
}
- (void)checkScriptExists
{
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *destinationURL = [directoryURL URLByAppendingPathComponent:@"Automation.scpt"];
    NSString *path = [destinationURL path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
    {
    }else
    {
        [self installScripts];
    }
    
}

- (void)installScripts
{
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    openPanel = [NSOpenPanel openPanel];
    [openPanel setLevel:CGShieldingWindowLevel()];
    [openPanel setDirectoryURL:directoryURL];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setDelegate:self];
    [openPanel setCanChooseFiles:NO];
    [openPanel setPrompt:NSLocalizedString(@"Select Script Folder", nil)];
    [openPanel setMessage:NSLocalizedString(@"Please select the Current User > Library > Application Scripts > com.JustZht.ChromeShare folder to install WebDrop Scripts", nil)];
    [openPanel beginWithCompletionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *selectedURL = [openPanel URL];
            if ([selectedURL isEqual:directoryURL]) {
                NSURL *destinationURL = [selectedURL URLByAppendingPathComponent:@"Automation.scpt"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:@"Automation" withExtension:@"scpt"];
                NSError *error;
                BOOL success = [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:&error];
                if (success) {
                    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Script Installed", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The Automation script was installed succcessfully.", nil)];
                    [alert runModal];
                }
                else {
                    NSLog(@"%s error = %@", __PRETTY_FUNCTION__, error);
                    if ([error code] == NSFileWriteFileExistsError) {
                        // this is where you could update the script, by removing the old one and copying in a new one
                    }
                    else {
                        // the item couldn't be copied, try again
                        [self performSelector:@selector(installScripts) withObject:self afterDelay:0.0];
                    }
                }
            }
            else {
                // try again because the user changed the folder path
                [self performSelector:@selector(installScripts) withObject:self afterDelay:0.0];
            }
        }
    }];
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
