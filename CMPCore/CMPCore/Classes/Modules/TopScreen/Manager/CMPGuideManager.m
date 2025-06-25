//
//  CMPGuideManager.m
//  M3
//
//  Created by Shoujian Rao on 2024/3/5.
//

#import "CMPGuideManager.h"
#import "CMPTopScreenGuideView.h"
#import <CMPLib/CMPCore.h>
@interface CMPGuideManager()

@end
@implementation CMPGuideManager
+ (instancetype)sharedInstance {
    static CMPGuideManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}
+ (BOOL)commonGuidePageShown{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultName_showNewCommonGuideTipFlag];
}

@end
