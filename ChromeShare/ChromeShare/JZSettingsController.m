//
//  JZSettingsController.m
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZSettingsController.h"
#import <MASShortcut/Shortcut.h>
#import "JZLaunchOnLoginManager.h"

static NSString *const MASOpenMenuShortcutKey = @"openMenuShortcutKey";
static NSString *const MASCustomShortcutEnabledKey = @"customShortcutEnabled";
static NSString *const MASHardcodedShortcutEnabledKey = @"hardcodedShortcutEnabled";
//static NSString *const MASOpenOnStartupEnabledKey = @"openOnStartupEnabled";
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
                                 }];
    [self.shortcutView setAssociatedUserDefaultsKey:MASOpenMenuShortcutKey];
    [_shortcutView setAssociatedUserDefaultsKey:MASOpenMenuShortcutKey];
    [_shortcutView bind:@"enabled" toObject:defaults
            withKeyPath:MASCustomShortcutEnabledKey options:nil];
	
	[self.openOnStartupCheck setState:[[JZLaunchOnLoginManager sharedManager] isLaunchOnLogin] ? NSOnState : NSOffState];
    
}
- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
    if (context != MASObservingContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
}
- (IBAction)launchOnLoginChanged:(NSButton *)sender
{
	BOOL isOn = (sender.state == NSOnState);
	[[JZLaunchOnLoginManager sharedManager] setLaunchOnLogin:isOn completeHandler:nil error:nil];
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

- (IBAction)closeButtonPressed:(id)sender
{
    [_popover performClose:self];
}

@end
