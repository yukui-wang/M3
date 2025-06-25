//
//  CMPLoginSwitchButton.m
//  M3
//
//  Created by MacBook on 2019/12/4.
//

#import "CMPLoginSwitchButton.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>

@implementation CMPLoginSwitchButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [self setTitleColor:[UIColor cmp_colorWithName:@"sup-fc2"] forState:UIControlStateNormal];
    }
    return self;
}

@end
