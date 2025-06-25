//
//  CMPPreferenceManager.m
//  M3
//
//  Created by Kaku Songu on 8/6/21.
//

#import "CMPPreferenceManager.h"
#import <CMPLib/CMPCore.h>

@implementation CMPPreferenceManager

+(BOOL)setMapTypeInUse:(MapTypeInUse)mapType
{
    NSString *curUserId = [CMPCore sharedInstance].currentUser.userID;
    if (!curUserId || curUserId.length == 0) {
        return NO;
    }
    NSString *key = [NSString stringWithFormat:@"%@_mapInUse",curUserId];
    [[NSUserDefaults standardUserDefaults] setObject:@(mapType) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+(MapTypeInUse)getMapTypeInUse
{
    NSString *curUserId = [CMPCore sharedInstance].currentUser.userID;
    if (!curUserId || curUserId.length == 0) {
        return MapTypeInUse_Gaode;
    }
    NSString *key = [NSString stringWithFormat:@"%@_mapInUse",curUserId];
    NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (val) {
        return val.integerValue;
    }
    return MapTypeInUse_Gaode;
}

@end
