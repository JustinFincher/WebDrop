//
//  JZLaunchOnLoginManager.m
//  ArtWall
//
//  Created by Justin Fincher on 2016/11/19.
//  Copyright © 2016年 Justin Fincher. All rights reserved.
//

#import "JZLaunchOnLoginManager.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation JZLaunchOnLoginManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static JZLaunchOnLoginManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        self.helperId = @"com.JustZht.WebDropLoginHelper";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (BOOL)isLaunchOnLogin
{
    
    BOOL isEnabled  = NO;
    
    // the easy and sane method (SMJobCopyDictionary) can pose problems when sandboxed. -_-
    CFArrayRef cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([self.helperId isEqualToString:[job objectForKey:@"Label"]]) {
                isEnabled = [[job objectForKey:@"OnDemand"] boolValue];
                break;
            }
        }
    }
    
    return isEnabled;
}
- (void)setLaunchOnLogin:(BOOL)boolValue
         completeHandler:(void (^)(void))completion
                   error:(void (^)(void))error
{
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.JustZht.WebDropLoginHelper", boolValue))
    {
        NSLog(@"Shit");
        error();
    }else
    {
        completion();
    }

}

@end
