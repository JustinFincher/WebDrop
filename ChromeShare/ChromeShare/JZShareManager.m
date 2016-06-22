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
    
    NSMenuItem *shareWebKitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current WebKit Tab", nil) action:@selector(shareWebKitTab) keyEquivalent:@"w"];
    shareWebKitMenuItem.target = self;
    [statusBarMenu addItem:shareWebKitMenuItem];
    
    NSMenuItem *shareSafariTechnologyPreviewMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Share Current Safari Technology Preview Tab", nil) action:@selector(shareSafariTechnologyPreviewTab) keyEquivalent:@"p"];
    shareSafariTechnologyPreviewMenuItem.target = self;
    [statusBarMenu addItem:shareSafariTechnologyPreviewMenuItem];
    
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
    [self getURLWithScript:@"tell application \"Google Chrome\" to get URL of active tab of front window as string"];
}
- (void)shareChromeCanaryTab
{
    [self getURLWithScript:@"tell application \"Google Chrome Canary\" to get URL of active tab of front window as string"];
}
- (void)shareSafariTab
{
    [self getURLWithScript:@"tell application \"Safari\" to return URL of front document as string"];
}
- (void)shareSafariTechnologyPreviewTab
{
    [self getURLWithScript:@"tell application \"Safari Technology Preview\" to return URL of front document as string"];
}
- (void)shareVivaldiTab
{
    [self getURLWithScript:@"tell application \"Vivaldi\" to get URL of active tab of front window as string"];
}
- (void)shareWebKitTab
{
    [self getURLWithScript:@"tell application \"WebKit\" to return URL of front document as string"];
}

- (void)getURLWithScript:(NSString *)scriptString
{
    NSAppleScript *script= [[NSAppleScript alloc] initWithSource:scriptString];
    NSDictionary *scriptError = nil;
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&scriptError];
    if(scriptError) {
        NSLog(@"Error: %@",scriptError);
    } else {
        NSAppleEventDescriptor *unicode = [descriptor coerceToDescriptorType:typeUnicodeText];
        NSData *data = [unicode data];
        NSString *result = [[NSString alloc] initWithCharacters:(unichar*)[data bytes] length:[data length] / sizeof(unichar)];
        //NSLog(@"Result: %@",result);
        [self shareString:[NSURL URLWithString:result]];
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
