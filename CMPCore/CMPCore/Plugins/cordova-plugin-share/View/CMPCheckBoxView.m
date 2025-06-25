//
//  CMPCheckBoxView.m
//  M3
//
//  Created by MacBook on 2019/12/2.
//

#import "CMPCheckBoxView.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>

@implementation CMPCheckBoxView

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
        [self setImage:[UIImage imageNamed:@"share_btn_unselected_circle"] forState:UIControlStateNormal];
        [self setImage:[[CMPThemeManager sharedManager] skinColorImageWithName:@"share_btn_selected_circle"] forState:UIControlStateSelected];
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.cmp_x = 0;
    self.titleLabel.cmp_x = CGRectGetMaxX(self.imageView.frame) + 3.f;
}

@end
