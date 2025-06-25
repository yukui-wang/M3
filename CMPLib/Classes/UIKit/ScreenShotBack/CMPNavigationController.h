//
//  CMPNavigationController
//  ScreenShotBack
//
//  Created by 郑文明 on 16/5/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPConstant.h"

typedef void(^CMPNavigationCallBack)(void);

@protocol CMPNavigationControllerProtocol <NSObject>
@required
- (BOOL)enablePanGesture;

@end

@interface CMPNavigationController : UINavigationController

@property (nonatomic, strong) NSMutableArray *arrayScreenshot;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, copy) CMPNavigationCallBack willShowViewControllerAlwaysCallBack;
@property (nonatomic, strong)NSMutableArray <CMPNavigationCallBack> *willShowViewControllerAlwaysCallBackArr;
@property (nonatomic, assign) BOOL showTabBarInRootVC;//根视图是否能显示底(侧)导航。默认YES

/**
 设置是否允许手势返回
 默认打开

 @param panGestureEnable 当前页面是否允许手势返回
 */
- (void)updateEnablePanGesture:(BOOL)panGestureEnable;

//强制禁止右滑返回，这个影响全局，如果针对某个vc使用，需要注意
@property (nonatomic, assign) BOOL forceDisablePanGestureBack;
@end
