//
//  JZShareManager.m
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import "JZShareManager.h"
#import "JZSettingsController.h"
static NSString *const MASOpenMenuShortcutKey = @"openMenuShortcutKey";

@interface JZShareManager()<NSSharingServiceDelegate>

@property (nonatomic,strong) NSPopover *settingsPopover;

@end

@implementation JZShareManager
@synthesize statusItem,statusBarMenu,settingsPopover;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static JZShareManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        [self initStatusBar];
    }
    return self;
}

- (void) initStatusBar
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    statusItem.button.image = [NSImage imageNamed:@"StatusBarButtonImage"];
    statusItem.button.action = @selector(statusBarButtonPressed);
    
    statusBarMenu = [[NSMenu alloc] init];
    statusItem.menu = statusBarMenu;
    NSMenuItem *shareChromeMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current Chrome Tab", nil) action:@selector(shareChromeTab) keyEquivalent:@"c"];
    shareChromeMenuItem.target = self;
    [statusBarMenu addItem:shareChromeMenuItem];
    
    NSMenuItem *shareChromeCanaryMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current Chrome Canary Tab", nil) action:@selector(shareChromeCanaryTab) keyEquivalent:@"C"];
    shareChromeCanaryMenuItem.target = self;
    [statusBarMenu addItem:shareChromeCanaryMenuItem];
    
    NSMenuItem *shareSafariMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current Safari Tab", nil) action:@selector(shareSafariTab) keyEquivalent:@"s"];
    shareSafariMenuItem.target = self;
    [statusBarMenu addItem:shareSafariMenuItem];
    
    NSMenuItem *shareOperaMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current Vivaldi Tab", nil) action:@selector(shareVivaldiTab) keyEquivalent:@"v"];
    shareOperaMenuItem.target = self;
    [statusBarMenu addItem:shareOperaMenuItem];
    
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) action:@selector(goSettings) keyEquivalent:@"S"];
    settingsItem.target = self;
    [statusBarMenu addItem:settingsItem];

    
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    [statusBarMenu addItem:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit App", nil) action:@selector(terminate:) keyEquivalent:@"q"]];

    settingsPopover = [[NSPopover alloc] init];
    JZSettingsController *vc = [[JZSettingsController alloc] initWithNibName:@"JZSettingsController" bundle:nil];
    vc.popover = settingsPopover;
    settingsPopover.contentViewController = vc;
    
    // Associate the preference key with an action
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:MASOpenMenuShortcutKey
     toAction:^
     {
         int height = statusItem.button.bounds.size.height + 8;
         [statusBarMenu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, height) inView:statusItem.button];
     }];

}
- (void)goSettings
{
    if (settingsPopover.isShown)
    {
        [settingsPopover performClose:self];
    }
    else
    {
        NSStatusBarButton *btn = statusItem.button;
        [settingsPopover showRelativeToRect:btn.bounds ofView:btn preferredEdge:NSMinYEdge];
    }
}
- (void)statusBarButtonPressed
{

}

- (void)shareChromeTab
{
    [self getURLWithScript:@"chromeURL"];
}
- (void)shareChromeCanaryTab
{
    [self getURLWithScript:@"chromeCanaryURL"];
}
- (void)shareSafariTab
{
    [self getURLWithScript:@"safariURL"];
}
- (void)shareVivaldiTab
{
    [self getURLWithScript:@"vivaldiURL"];
}

- (NSUserAppleScriptTask *)automationScriptTask
{
    NSUserAppleScriptTask *result = nil;
    
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (directoryURL) {
        NSURL *scriptURL = [directoryURL URLByAppendingPathComponent:@"Automation.scpt"];
        result = [[NSUserAppleScriptTask alloc] initWithURL:scriptURL error:&error];
        if (! result) {
            NSLog(@"%s no AppleScript task error = %@", __PRETTY_FUNCTION__, error);
        }
    }
    else {
        // NOTE: if you're not running in a sandbox, the directory URL will always be nil
        NSLog(@"%s no Application Scripts folder error = %@", __PRETTY_FUNCTION__, error);
    }
    
    return result;
}

- (NSAppleEventDescriptor *)eventDescriptorbyName:(NSString *)string
{
    // target
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
    
    // function
    NSAppleEventDescriptor *function = [NSAppleEventDescriptor descriptorWithString:string];
    
    // event
    NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite eventID:kASSubroutineEvent targetDescriptor:target returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
    [event setParamDescriptor:function forKeyword:keyASSubroutineName];
    
    return event;
}
- (NSURL *)URLForResultEventDescriptor:(NSAppleEventDescriptor *)resultEventDescriptor
{
    NSURL *result = nil;
    
    NSString *URLString = nil;
    if (resultEventDescriptor) {
        if ([resultEventDescriptor descriptorType] != kAENullEvent) {
            if ([resultEventDescriptor descriptorType] == kTXNUnicodeTextData) {
                URLString = [resultEventDescriptor stringValue];
            }
        }
    }
    
    result = [NSURL URLWithString:URLString];
    
    return result;
}

- (void)getURLWithScript:(NSString *)scriptString
{
    NSUserAppleScriptTask *automationScriptTask = [self automationScriptTask];
    if (automationScriptTask) {
        NSAppleEventDescriptor *event = [self eventDescriptorbyName:scriptString];
        [automationScriptTask executeWithAppleEvent:event completionHandler:^(NSAppleEventDescriptor *resultEventDescriptor, NSError *error) {
            if (! resultEventDescriptor) {
                NSLog(@"%s AppleScript task error = %@", __PRETTY_FUNCTION__, error);
            }
            else {
                
                
                NSURL *URL = [self URLForResultEventDescriptor:resultEventDescriptor];
                // NOTE: The completion handler for the script is not run on the main thread. Before you update any UI, you'll need to get
                // on that thread by using libdispatch or performing a selector.
                
                
                [self performSelectorOnMainThread:@selector(shareString:) withObject:URL waitUntilDone:NO];
            }
        }];
    }
}
-(void)shareString:(NSURL *)url
{
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNameSendViaAirDrop];
    NSArray * shareItems = [NSArray arrayWithObjects:url, nil];
    service.delegate = self;
    [service performWithItems:shareItems];
}

@end
