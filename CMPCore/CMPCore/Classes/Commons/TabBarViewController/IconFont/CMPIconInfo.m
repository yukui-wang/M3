//
//  CMPIconInfo.m
//  iconfont
//
//  Created by yang on 2017/2/13.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "CMPIconInfo.h"

@implementation CMPIconInfo
- (void)dealloc
{
    [_text release];
    _text = nil;
    [_color release];
    _color = nil;
    [super dealloc];
}
- (instancetype)initWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    if (self = [super init]) {
        self.text = text;
        self.size = size;
        self.color = color;
    }
    return self;
}

+ (instancetype)iconInfoWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color {
    return [[[CMPIconInfo alloc] initWithText:text size:size color:color] autorelease];
}

@end
