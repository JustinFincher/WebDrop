//
//  JZSettingsController.m
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZSettingsController.h"
#import <MASShortcut/Shortcut.h>

static NSString *const MASOpenMenuShortcutKey = @"openMenuShortcutKey";
static NSString *const MASCustomShortcutEnabledKey = @"customShortcutEnabled";
static NSString *const MASHardcodedShortcutEnabledKey = @"hardcodedShortcutEnabled";
static NSString *const MASOpenOnStartupEnabledKey = @"openOnStartupEnabled";
static void *MASObservingContext = &MASObservingContext;

@interface JZSettingsController ()
@property (weak) IBOutlet MASShortcutView *shortcutView;
@property (weak) IBOutlet NSButton *openOnStartupCheck;

@end

@implementation JZSettingsController

- (void) awakeFromNib
{
    [super awakeFromNib];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Register default values to be used for the first app start
    [defaults registerDefaults:@{
                                 MASHardcodedShortcutEnabledKey : @YES,
                                 MASCustomShortcutEnabledKey : @YES,
                                 MASOpenOnStartupEnabledKey : @NO
                                 }];
    [self.shortcutView setAssociatedUserDefaultsKey:MASOpenMenuShortcutKey];
    [_shortcutView setAssociatedUserDefaultsKey:MASOpenMenuShortcutKey];
    [_shortcutView bind:@"enabled" toObject:defaults
            withKeyPath:MASCustomShortcutEnabledKey options:nil];
    
    [defaults addObserver:self forKeyPath:MASOpenOnStartupEnabledKey
                  options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                  context:MASObservingContext];
    
}
- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
    if (context != MASObservingContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    BOOL newValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    if ([keyPath isEqualToString:MASOpenOnStartupEnabledKey]) {
        [self setOpenOnStartupEnabled:newValue];
    }
}
- (void) setOpenOnStartupEnabled: (BOOL) enabled
{
    if (enabled)
    {
        
    }
    else
    {
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)contactAuthorButtonPressed:(id)sender
{
    NSURL *     url;
    
    // Create the URL.
    
    url = [NSURL URLWithString:@"mailto:zhtsu47@me.com"
           "?subject=WebDrop%20Questions"
           ];
    assert(url != nil);
    
    // Open the URL.
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)deleteScriptsButtonPressed:(id)sender
{
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *destinationURL = [directoryURL URLByAppendingPathComponent:@"Automation.scpt"];
    NSString *path = [destinationURL path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
    {
        
        BOOL success = [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];
        if (!success)
        {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }else
        {
            [self performSelector:@selector(terminate:)];
        }
    }
    
    
}

- (IBAction)closeButtonPressed:(id)sender
{
    [_popover performClose:self];
}

@end
