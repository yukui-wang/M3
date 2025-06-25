/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.h
//  CMPCore
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPAppDelegate.h>
#import <CMPLib/AFNetworkReachabilityManager.h>
#import "CMPTabBarViewController.h"
extern double StartTime;
@interface AppDelegate : CMPAppDelegate

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CMPTabBarViewController *tabBarViewController;
@property (nonatomic, assign) BOOL launchFromNotification;
@property (nonatomic, strong) NSDate *launchFromNotificationStartTime;
@property (nonatomic, strong) dispatch_group_t alertGroup;//弹窗同步group

@property (nonatomic, assign) BOOL aNeedShowGuidePagesView;
@property (nonatomic, assign) BOOL hasCalledUpdateOnlineLngLat; //判断是否调用过updateOnlineLngLat接口

+ (AppDelegate *)shareAppDelegate;
- (void)_autoLoginWithStart:(void(^)(void))start success:(void(^)(void))success fail:(void(^)(NSError *))fail ext:(__nullable id)ext;
- (void)showTabBarWithHideAppIds:(NSString *)appIDs didFinished:(void(^)(void))didFinished;

- (CMPTabBarViewController *)tabBar;

//统一处理原生弹出提示
- (BOOL)handleError:(NSError *)error;

// 显示设置手势密码界面
- (void)showSetGesturePwdView;
// 显示验证手势密码界面
- (void)showGestureVerifyView:(CMPLoginAccountModel *)aM3User ext:(__nullable id)ext;
// 刷新底导航
- (void)reloadTabBar;
// 刷新 APP
- (void)reloadApp;
// 展示指纹面容解锁页面
- (void)showLocalAuthViewWithExt:(id __nullable)ext;

- (void)showStartPageView;
- (void)hideStartPageView;
- (void)hideGuidePagesView;
- (void)clearViews:(void(^)(void))block;
//处理seesion失效
- (void)handleSessionInvalid;
- (void)delayHandleSessionInvalid;

@end
