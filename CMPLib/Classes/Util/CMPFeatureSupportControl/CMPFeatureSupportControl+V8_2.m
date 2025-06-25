//
//  CMPFeatureSupportControl+V8_2.m
//  CMPLib
//
//  Created by Kaku Songu on 11/25/22.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPFeatureSupportControl+V8_2.h"
#import "CMPServerVersionUtils.h"

@implementation CMPFeatureSupportControl (V8_2)

+ (BOOL)serverSupportInstantMeeting
{
    return [CMPServerVersionUtils serverIsLaterV8_2];
}

+ (NSString *)instantMeetingQuickName
{
    if ([self serverSupportInstantMeeting]) {
        return @"quick_ontimemeet";
    }
    return nil;
}

@end
