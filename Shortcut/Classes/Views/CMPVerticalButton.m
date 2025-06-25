//
//  CMPVerticalButton.m
//
//  Created by MacTsin on 16/3/19.
//  Copyright © 2016年 MacTsin. All rights reserved.
//

#import "CMPVerticalButton.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPThemeManager.h>


@implementation CMPVerticalButton

- (void)setupViews
{
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:13.0];
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupViews];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imgViewSize.width != 0) {
        self.imageView.cmp_size = self.imgViewSize;
    }
    
    self.imageView.cmp_centerX = self.width/2.f;
    self.imageView.cmp_y = 0;
    
    NSString *title = [self titleForState:UIControlStateNormal];
    self.titleLabel.cmp_width = [title sizeWithFontSize:self.titleLabel.font defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
    self.titleLabel.cmp_height = 16;
    self.titleLabel.cmp_centerX = self.width/2.f;
    self.titleLabel.cmp_centerY = self.height - 18.f;
    if (CMPThemeManager.sharedManager.isDisplayDrak) {
        self.titleLabel.cmp_centerY = self.height - 8.f;
    }
    
    
}
@end
