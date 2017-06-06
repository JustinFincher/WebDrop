//
//  JZLaunchOnLoginManager.h
//  ArtWall
//
//  Created by Justin Fincher on 2016/11/19.
//  Copyright © 2016年 Justin Fincher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JZLaunchOnLoginManager : NSObject

+ (id)sharedManager;
@property (nonatomic,strong) NSString * helperId;

- (BOOL)isLaunchOnLogin;
- (void)setLaunchOnLogin:(BOOL)boolValue
         completeHandler:(void (^)(void))completion
                   error:(void (^)(void))error;

@end
