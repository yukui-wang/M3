//
//  CMPTabBarAttribute.m
//  CMPCore
//
//  Created by yang on 2017/2/15.
//
//

#import "CMPTabBarAttribute.h"
#import <CMPLib/CMPConstant.h>

@implementation CMPTabBarAttribute

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CMPTabBarAttribute *aObject = (CMPTabBarAttribute *)object;
    aObject.theme = [NSString isNotNull:aObject.theme] ? aObject.theme : @"";
    aObject.bgColor = [NSString isNotNull:aObject.bgColor] ? aObject.bgColor : @"";
    aObject.bgImg = [NSString isNotNull:aObject.bgImg] ? aObject.bgImg : @"";
    
    self.theme = [NSString isNotNull:self.theme] ? self.theme : @"";
    self.bgColor = [NSString isNotNull:self.bgColor] ? self.bgColor : @"";
    self.bgImg = [NSString isNotNull:self.bgImg] ? self.bgImg : @"";
    
    if ([self.titleColor isEqualToString:aObject.titleColor] &&
        [self.titleSelectedColor isEqualToString:aObject.titleSelectedColor] &&
        self.titleFontSize == aObject.titleFontSize &&
        [self.theme isEqualToString:aObject.theme] &&
        [self.bgColor isEqualToString:aObject.bgColor] &&
        [self.bgImg isEqualToString:aObject.bgImg] ) {
        return YES;
    }    
    return NO;
}
@end

