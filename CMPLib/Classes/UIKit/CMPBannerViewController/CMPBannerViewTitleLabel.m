//
//  CMPBannerViewTitleLabel.m
//  CMPLib
//
//  Created by MacBook on 2020/1/13.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPBannerViewTitleLabel.h"
#import "CMPConstant.h"


@implementation CMPBannerViewTitleLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CMPFuncLog;
    if (_viewClicked) {
        _viewClicked();
    }
}

@end
