//
//  CMPFontProvider.m
//  CMPLib
//
//  Created by 程昆 on 2018/12/25.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "CMPFontProvider.h"
#import "EGOCache.h"
#import "CMPFontModel.h"

NSString * const MinStandardFontKey = @"minStandardFontKey";

NSNotificationName const MinStandardFontChanged = @"setMinStandardFont";

@implementation CMPFontProvider

+(void)setMinStandardFont:(CGFloat)size{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    [[CMPCore sharedInstance].currentFont setMinStandardFontSize:size];
    [[EGOCache globalCache]setObject:@(size) forKey:fontKey];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MinStandardFontChanged object:nil];
    
}

+(void)deleteFontSettingWithServerID:(NSString *)serverID userID:(NSString *)userID{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",serverID,userID,MinStandardFontKey];
    
    [[EGOCache globalCache]removeCacheForKey:fontKey];
}

+(CGFloat)currentMinStandardFont{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue];
    
    if (!fontSize) {
        
        fontSize = KMinStandardFontSize;
        
    }
    
    return fontSize;
    
}

+(CGFloat)currentStandardFont{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue] + 2.0f;
    
    if (!fontSize) {
        
        fontSize = KMinStandardFontSize + 2.0f;
        
    }
    
    return fontSize;
    
}

+(CGFloat)currentStandardOneFont{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue] + 4.0f;
    
    if (!fontSize) {
        
        fontSize = KMinStandardFontSize + 4.0f;
        
    }
    
    return fontSize;
    
}

+(CGFloat)currentStandardTwoFont{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue] + 6.0f;
    
    if (!fontSize) {
        
        fontSize = KMinStandardFontSize + 6.0f;
        
    }
    
    return fontSize;
    
}

+(CGFloat)currentStandardThreeFont{
    
    NSString *fontKey = [NSString stringWithFormat:@"%@_%@_%@",[CMPCore sharedInstance].serverID,[CMPCore sharedInstance].userID,MinStandardFontKey];
    
    CGFloat fontSize = [(NSNumber *)[[EGOCache globalCache]objectForKey:fontKey] floatValue] + 8.0f;
    
    if (!fontSize) {
        
        fontSize = KMinStandardFontSize + 8.0f;
        
    }
    
    return fontSize;
    
}

@end
