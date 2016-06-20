//
//  JZShareManager.h
//  ChromeShare
//
//  Created by Fincher Justin on 16/6/20.
//  Copyright © 2016年 JustZht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>
@import AppKit;

@interface JZShareManager : NSObject

@property (strong,nonatomic) NSStatusItem *statusItem;
@property (strong,nonatomic) NSMenu *statusBarMenu;

+ (id)sharedManager;

@end
