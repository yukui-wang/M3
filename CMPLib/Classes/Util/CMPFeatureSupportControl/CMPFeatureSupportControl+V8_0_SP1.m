//
//  CMPFeatureSupportControl+V8_0.m
//  CMPLib
//
//  Created by 程昆 on 2020/3/4.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPFeatureSupportControl+V8_0.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import <CMPLib/CMPAppListModel.h>

@implementation CMPFeatureSupportControl (V8_0_SP1)

#pragma mark - 版本兼容控制

+ (BOOL)isNeedUpdateRCMessageSetting
{
    if ([CMPServerVersionUtils serverIsLaterV8_0_SP1]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNeedUploadRCMessageSetting
{
    if ([CMPServerVersionUtils serverIsLaterV8_0_SP1]) {
        return YES;
    }
    return NO;
}

@end
