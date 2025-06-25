//
//  CMPExpandTabBarCollectionCell.m
//  CMPLib
//
//  Created by Shoujian Rao on 2022/5/27.
//  Copyright © 2022 crmo. All rights reserved.
//

#import "CMPExpandTabBarCollectionCell.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import "UIColor+Hex.h"
@interface CMPExpandTabBarCollectionCell()



@end

@implementation CMPExpandTabBarCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _iconIgv = [[UIImageView alloc]init];
//        _iconIgv.contentMode = UIViewContentModeScaleToFill;
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"cont-fc"];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        
        
        [self addSubview:_iconIgv];
        [self addSubview:_titleLabel];
        [_iconIgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
//            make.centerY.mas_equalTo(self.mas_centerY).offset(-5);
            make.top.mas_equalTo(12);
            make.width.height.mas_equalTo(22);
        }];
        
        _redPointView = [UIView new];
        _redPointView.hidden = YES;
        _redPointView.backgroundColor = [UIColor colorWithHexString:@"0xff5c5c"];
        _redPointView.layer.cornerRadius = 4.5f;
        [self addSubview:_redPointView];
        [_redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconIgv.mas_right).offset(-5);
            make.bottom.mas_equalTo(self.iconIgv.mas_top).offset(5);
            make.width.height.mas_equalTo(9);
        }];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconIgv.mas_bottom).offset(6);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.left.offset(6);
            make.right.offset(-6);
        }];
    }
    return self;
}
@end
