//
//  XZQABottomCoverView.m
//  Xiaozhi
//
//  Created by Kaku Songu on 3/23/21.
//  Copyright © 2021 wujiansheng. All rights reserved.
//

#import "XZQABottomCoverView.h"
#import <CMPLib/Masonry.h>
#import "XZCore.h"

@implementation XZQABottomCoverView

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *iconImgV = [[UIImageView alloc] init];
    iconImgV.backgroundColor = UIColorFromRGB(0x297FFB);
    iconImgV.image = XZ_IMAGE(@"xz_input_icon");
    iconImgV.layer.cornerRadius = 15;
    iconImgV.layer.masksToBounds = YES;
    [self addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(14);
        make.top.greaterThanOrEqualTo(13).priorityHigh();
        make.bottom.lessThanOrEqualTo(-13).priorityHigh();
        make.size.mas_equalTo(CGSizeMake(30, 30)).priorityHigh();
    }];
    
    UIButton *askBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [askBtn setBackgroundColor:UIColorFromRGB(0x297FFB)];
    [askBtn setTitle:SY_STRING(@"我要提问") forState:UIControlStateNormal];
    askBtn.titleLabel.font = FONTSYS(14);
    [askBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    askBtn.layer.cornerRadius = 14;
    askBtn.layer.masksToBounds = YES;
//    [askBtn sizeToFit];
    [self addSubview:askBtn];
    [askBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerY.offset(0);
       make.right.offset(-14);
       make.top.greaterThanOrEqualTo(13).priorityHigh();
       make.bottom.lessThanOrEqualTo(-13).priorityHigh();
        make.width.greaterThanOrEqualTo(@84);
        make.height.greaterThanOrEqualTo(@30);
    }];
    
    UILabel *tipLb = [[UILabel alloc] init];
    tipLb.text = SY_STRING(@"再多问题一问便知");
    tipLb.font = FONTBOLDSYS(16);
    [self addSubview:tipLb];
    [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(iconImgV.mas_right).offset(10);
    }];
    
    [askBtn addTarget:self action:@selector(_startAskAct:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)_startAskAct:(UIButton *)sender
{
    if (_startAskBlock) {
        _startAskBlock();
    }
}

@end
