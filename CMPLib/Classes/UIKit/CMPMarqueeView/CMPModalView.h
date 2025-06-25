//
//  SyModalView.h
//  M1Core
//
//  Created by guoyl on 13-1-28.
//  Copyright (c) 2013年 北京致远协创软件有限公司. All rights reserved.
//

#import "CMPBaseView.h"

@interface CMPModalView : CMPBaseView

@property (nonatomic, assign)UIView *contentView;
@property (nonatomic, assign)BOOL autoHide;

- (void)popWithContentView:(UIView *)aContentView;
- (void)popWithContentView:(UIView *)aContentView autoHide:(BOOL)autoHide;
- (void)presentView:(UIView *)aView fromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated autoHide:(BOOL)autoHide;

@end
