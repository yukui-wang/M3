//
//  CMPServerListHeader.m
//  M3
//
//  Created by MacBook on 2019/12/25.
//

#import "CMPServerListHeader.h"

#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPServerListHeader()
@property(nonatomic,retain)UIView *bgColorView;
@property(nonatomic,retain)CAShapeLayer *shapeLayer;

@end
@implementation CMPServerListHeader

- (void)setup {
    if (!_bgColorView) {
        _bgColorView = [[UIView alloc] init];
        [self addSubview:_bgColorView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [_bgColorView addSubview:_titleLabel];
    }
}

- (void)setupTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)customLayoutSubviews {
    _bgColorView.frame = CGRectMake(0, 14.f, self.width, self.height - 14.f);
    [_titleLabel setFrame:CGRectMake(10, 0, _bgColorView.width-20, _bgColorView.height)];
    if (self.shapeLayer) {
        //移除之前的
        [self.shapeLayer removeFromSuperlayer];
    }
    self.shapeLayer = [_bgColorView cmp_setTopCornerWithRadius:6.f bgColor:[UIColor cmp_colorWithName:@"input-bg"]];
}

@end
