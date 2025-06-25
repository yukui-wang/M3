//
//  NSURL+CMPURL.m
//  CMPLib
//
//  Created by 程昆 on 2019/8/2.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "NSURL+CMPURL.h"
#import <CMPLib/NSString+CMPString.h>

@implementation NSURL (CMPURL)

+ (instancetype)URLWithPathString:(NSString *)pathString {
    if (!pathString || ![pathString isKindOfClass:NSString.class]) {
        return [NSURL URLWithString:@""];
    }
    if ([pathString hasPrefix:@"file://"]) {
        pathString = [pathString replaceCharacter:@"file://" withString:@""];
    }
    if ([pathString hasPrefix:@"http://"] ||
        [pathString hasPrefix:@"https://"] ) {
        return [self URLWithString:pathString];
    } else {
        return [self fileURLWithPath:pathString];
    }
}

@end
