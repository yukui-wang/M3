//
//  CMPShareToUCFinishedTipsView.m
//  CMPLib
//
//  Created by MacBook on 2020/2/13.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPShareToUCFinishedTipsView.h"

#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/UIView+CMPView.h>

@implementation CMPShareToUCFinishedTipsView

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
        self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
        [self cmp_setCornerRadius:6.f];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    //已发送label
    UIButton *tips = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, 109.f)];
    [tips setTitleColor:[UIColor cmp_colorWithName:@"main-fc"] forState:UIControlStateNormal];
    tips.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [tips setTitle:SY_STRING(@"share_component_share_finished_tips") forState:UIControlStateNormal];;
    [self addSubview:tips];
    
    //分割线1
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tips.frame), self.width, 0.5f)];
    separator1.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    [self addSubview:separator1];
    
    //返回上一页 按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separator1.frame), self.width, 53.f)];
    [backBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    [backBtn setTitle:SY_STRING(@"share_component_share_finished_back_former_view") forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
    
    //分割线2
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backBtn.frame), self.width, 0.5f)];
    separator2.backgroundColor = [UIColor cmp_colorWithName:@"cmp-line"];
    [self addSubview:separator2];
    
    //留在当前页 按钮
    UIButton *stayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separator2.frame), self.width, 53.f)];
    [stayBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    [stayBtn setTitle:SY_STRING(@"share_component_share_finished_stay_curr_view") forState:UIControlStateNormal];
    stayBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    stayBtn.userInteractionEnabled = NO;
    [self addSubview:stayBtn];
}

#pragma mark - 按钮点击事件

/// 返回上一页 按钮点击事件
- (void)backClicked {
    CMPFuncLog;
    if (self.backToFormerClicked) {
        self.backToFormerClicked();
    }
}


@end
