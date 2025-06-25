//
//  CMPSeparateImgButton.m
//  M3
//
//  Created by MacBook on 2020/2/27.
//

#import "CMPSeparateImgButton.h"
#import <CMPLib/UIView+CMPView.h>

@implementation CMPSeparateImgButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.cmp_x = CGRectGetMaxX(self.imageView.frame) + 4.f;
}

@end
