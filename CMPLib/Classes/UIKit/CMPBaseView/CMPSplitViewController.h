//
//  CMPSplitViewController.h
//  CMPLib
//
//  Created by CRMO on 2019/5/6.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPScreenshotControlProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class CMPNavigationController;
@interface CMPSplitViewController : UISplitViewController<CMPScreenshotControlProtocol>

/**
 操作区
 */
@property (nonatomic, weak) CMPNavigationController *masterNavigation;

/**
 内容区
 */
@property (nonatomic, weak) CMPNavigationController *detailNavigation;

/**
 横屏切换竖屏时，记录操作区栈大小
 */
@property (assign, nonatomic) NSInteger masterStackSize;

/**
 初始化函数

 @param vc 操作区初始化vc
 @param delegate 代理
 @return 初始化对象
 */
+ (instancetype)splitWithMasterVc:(UIViewController *)vc delegate:(__nullable id)delegate;

#pragma mark-
#pragma mark 路由管理

/**
 在内容区跳转页面

 @param vc 需要跳转的ViewController
 */
- (void)showDetailViewController:(UIViewController *)vc;

/**
 清空内容区页面，展示暂无内容
 */
- (void)clearDetailViewController;

/**
 根据displaymode重建栈
 */
- (void)updateStackWithDisplayMode:(UIInterfaceOrientation)orientation;

- (void)didSeleted;

/**
 根据当前displaymode重建栈
 */
- (void)updateStackAnimation:(BOOL)animation;

- (void)updateSeperateLineHidden:(BOOL)hidden;

@end

@interface UIViewController (CMPSplitViewController)

@property (nullable, nonatomic, readonly, strong) CMPSplitViewController *cmp_splitViewController;

/**
 在内容区跳转页面
 
 @param vc 需要跳转的ViewController
 */
- (void)cmp_showDetailViewController:(UIViewController *)vc;

- (void)cmp_pushPageInMasterView:(UIViewController *)vc navigation:(UINavigationController *)nav;

/**
 清空内容区页面，展示暂无内容
 */
- (void)cmp_clearDetailViewController;

/**
 是否可以在内容区跳转，需满足两个条件
 1. 横屏模式
 2. 当前页面在操作区
 */
- (BOOL)cmp_canPushInDetail;

/**
 当前页面是否在操作区
 */
- (BOOL)cmp_inMasterStack;

/**
 当前页面是否在内容区
 */
- (BOOL)cmp_inDetailStack;

/**
 返回是否是全屏模式
 */
- (BOOL)cmp_isFullScreen;

/**
 切换到全屏模式
 */
- (void)cmp_switchFullScreen;

/**
 切换到分屏模式
 */
- (void)cmp_switchSplitScreen;

@end

NS_ASSUME_NONNULL_END
