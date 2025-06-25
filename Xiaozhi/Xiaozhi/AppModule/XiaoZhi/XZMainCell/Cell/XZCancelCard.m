//
//  XZCancelCard.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/29.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZCancelCard.h"

@interface XZCancelCard () {
    UILabel *_label;
}
@end

@implementation XZCancelCard

- (void)setup {
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    if (!_label) {
        _label = [[UILabel alloc] init];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setFont:FONTSYS(26)];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setTextColor:UIColorFromRGB(0x7F8EB4)];
        _label.text = @"已取消";
        [self addSubview:_label];
    }
}

- (void)customLayoutSubviews {
    [_label setFrame:self.bounds];
}

+ (CGFloat)viewHeight {
    return 100;
}

@end
