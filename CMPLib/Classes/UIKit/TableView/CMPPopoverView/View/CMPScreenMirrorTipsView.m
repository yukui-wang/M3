//
//  CMPScreenMirrorTipsView.m
//  CMPLib
//
//  Created by MacBook on 2019/11/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPScreenMirrorTipsView.h"
#import <CMPLib/UIView+CMPView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/CMPThemeManager.h>



@interface CMPScreenMirrorTipsView()


@end

@implementation CMPScreenMirrorTipsView

#pragma mark 外部工厂方法
+ (instancetype)viewWithFrame:(CGRect)frame {
    CMPScreenMirrorTipsView *view = [CMPScreenMirrorTipsView.alloc initWithFrame:frame];
    return view;
}

///初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configViews];
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    }
    return self;
}

///配置subviews
- (void)configViews {
    [self cmp_setCornerRadius:6.f];
    
    //标题label
    UILabel *titleLabel = [UILabel.alloc initWithFrame:CGRectMake(0, 14.f, self.width, 20.f)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    titleLabel.cmp_centerX = self.width/2.f;
    titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    titleLabel.text = SY_STRING(@"screen_mirror_tips_title");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    //提示label
    UILabel *tipsLabel = [UILabel.alloc initWithFrame:CGRectMake(20.f, CGRectGetMaxY(titleLabel.frame) + 14.f, self.width - 40.f, 52.f)];
    tipsLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont boldSystemFontOfSize:14.f];
    tipsLabel.text = SY_STRING(@"screen_mirror_tips");
    tipsLabel.numberOfLines = 0;
    [self addSubview:tipsLabel];
    
    //提示图
    UIImageView *imgView = [UIImageView.alloc initWithFrame:CGRectMake(CGRectGetMinX(tipsLabel.frame), CGRectGetMaxY(tipsLabel.frame) + 10.f, tipsLabel.width, 172.f)];
    [imgView cmp_setCornerRadius:6.f];
    imgView.image = [UIImage imageNamed:@"screen_mirroring_tips"];
    
    [self addSubview:imgView];
    
    UIView *horizonalLine = [UIView.alloc initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame) + 20.f, self.width, 1.f)];
    horizonalLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
    [self addSubview:horizonalLine];
    
    //按钮容器view
    UIView *btnsView = [UIView.alloc initWithFrame:CGRectMake(0, CGRectGetMaxY(horizonalLine.frame), self.width, self.height - CGRectGetMaxY(horizonalLine.frame))];
    btnsView.backgroundColor = UIColor.clearColor;
    [self addSubview:btnsView];
    
    //上分割线
    UIView *verticalLine = [UIView.alloc initWithFrame:CGRectMake(0, 0, 1.f, 16.f)];
    verticalLine.backgroundColor = horizonalLine.backgroundColor;
    verticalLine.center = CGPointMake(btnsView.width/2.f, btnsView.height/2.f);
    [btnsView addSubview:verticalLine];
    
    //查看教程btn
    CGFloat btnW = (btnsView.width - 1.f)/2.f;
    CGFloat btnH = btnsView.height;
    UIButton *checkBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, btnW, btnH)];
    [checkBtn setTitleColor: [UIColor cmp_colorWithName:@"theme-bdc"] forState:UIControlStateNormal];
    [checkBtn setTitle:SY_STRING(@"screen_mirror_checkout_btn") forState:UIControlStateNormal];
    checkBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    checkBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [checkBtn addTarget:self action:@selector(checkBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:checkBtn];
    
    //确定btn
    UIButton *sureBtn = [UIButton.alloc initWithFrame:CGRectMake(btnW + 0.5f, 0, btnW, btnH)];
    [sureBtn setTitleColor: [UIColor cmp_colorWithName:@"theme-bdc"] forState:UIControlStateNormal];
    [sureBtn setTitle:SY_STRING(@"common_ok") forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    sureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    sureBtn.userInteractionEnabled = NO;
    [btnsView addSubview:sureBtn];
    
    //遮罩
    UIButton *coverBtn = [UIButton.alloc initWithFrame:CGRectMake(0, 0, self.width, self.height - btnsView.height)];
    coverBtn.backgroundColor = UIColor.clearColor;
    [self addSubview:coverBtn];
}

#pragma mark 按钮点击

- (void)checkBtnClicked {
    if (_checkClicked) {
        _checkClicked();
    }
}


@end
