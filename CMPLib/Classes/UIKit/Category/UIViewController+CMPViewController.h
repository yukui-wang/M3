//
//  UIViewController+SyViewController.h
//  M1Core
//
//  Created by admin on 12-10-30.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CMPViewController)

//@property (nonatomic, readonly) UIApplication *appDelegate;
@property (assign, nonatomic, getter = isInPopoverController) BOOL isInPopoverController;
@property (assign, nonatomic, getter = isRoot) BOOL isRoot;

- (UIInterfaceOrientation)statusBarOrientation;

/**
 当前显示的ViewController
 */
+ (UIViewController*)currentViewController;

/**
 ViewController是否在显示
 */
- (BOOL)isVisible;

/**
 在当前显示的Viewcontroller展示alertview
 */
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cacelTitle;

/**
 在当前显示的Viewcontroller展示alertview，没有标题，只有提示内容，只有确定按钮
 */
- (void)showAlertMessage:(NSString *)message;
/**
 判断当前控制器是否可见
 */
- (BOOL)isViewControllerVisable;


/// 原来的present方法。因为我们交换了原始的present方法，将原始的方法默认present的模式设为了全屏的，如果想使用原始的并且可以自定义模式的就用这个方法
- (void)cmp_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

@end
