//
//  CMPTopScreenModel.m
//  M3
//
//  Created by Shoujian Rao on 2023/12/28.
//

#import "CMPTopScreenModel.h"

#define kPrefixRule @"#CMP:"

@implementation CMPTopScreenModel

//处理iconUrl值为#CMP:xxx名称的图标
- (NSString *)iconUrlParsed{
    if (_iconUrlParsed) {
        return _iconUrlParsed;
    }
    
    if (!_iconUrl) {
        return nil;
    }
    if ([_iconUrl hasPrefix:kPrefixRule]) {
        _iconUrlParsed = [_iconUrl stringByReplacingOccurrencesOfString:kPrefixRule withString:@""];
    }
    return _iconUrlParsed;
}
@end
