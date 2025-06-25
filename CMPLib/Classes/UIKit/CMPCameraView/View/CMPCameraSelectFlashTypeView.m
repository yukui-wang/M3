//
//  CMPCameraSelectFlashTypeView.m
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPCameraSelectFlashTypeView.h"

#import <CMPLib/UIView+CMPView.h>


@implementation CMPCameraSelectFlashTypeView
#pragma mark - initialise views
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *titles = @[SY_STRING(@"pic_automatic"),SY_STRING(@"pic_open"),SY_STRING(@"pic_close")];
        NSArray *imgs = @[@"camera_turn_auto_flash",@"camera_turn_on_flash",@"camera_turn_off_flash"];
        NSInteger count = titles.count;
        CGFloat btnY = 0;
        CGFloat btnW = self.width/count;
        CGFloat btnH = self.height;
        for (NSInteger i = 0; i < count; i++) {
            UIButton *btn = [UIButton.alloc initWithFrame:CGRectMake(btnW*i, btnY, btnW, btnH)];
            [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateSelected];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            btn.tag = i;
            btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
    return self;
}


- (void)btnClicked:(UIButton *)btn {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.45f animations:^{
        weakSelf.alpha = 0;
    }];
    if (_flashClicked) {
        _flashClicked(btn.tag,[btn imageForState:UIControlStateSelected]);
    }
}

@end
