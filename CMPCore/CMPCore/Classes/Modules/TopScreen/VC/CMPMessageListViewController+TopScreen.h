//
//  CMPMessageListViewController+TopScreen.h
//  M3
//
//  Created by Shoujian Rao on 2023/12/27.
//

#import "CMPMessageListViewController.h"

@interface CMPMessageListViewController (TopScreen)
//添加下拉手势-只针对CMPMessageListViewController->CMPMessageListView
- (void)addPanGuestureToView:(UIView *)view;
//恢复初始状态
- (void)resumeViewAnimate:(BOOL)animate;
@end

