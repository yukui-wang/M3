//
//  CMPBannerBackButton.m
//  CMPLib
//
//  Created by MacBook on 2020/2/15.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPBannerBackButton.h"

#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPCore.h>


@implementation CMPBannerBackButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        self.imageView.cmp_x = 16.f;
    }
    
}

@end
