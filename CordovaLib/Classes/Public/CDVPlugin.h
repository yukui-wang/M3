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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CDVPluginResult.h"
#import "NSMutableArray+QueueAdditions.h"
#import "CDVCommandDelegate.h"
#import "CDVWebViewEngineProtocol.h"

@interface UIView (org_apache_cordova_UIView_Extension)

@property (nonatomic, weak) UIScrollView* scrollView;

@end

extern NSString* const CDVPageDidLoadNotification;
extern NSString* const CDVPageLoadErrorNotification;
extern NSString* const CDVPluginHandleOpenURLNotification;
extern NSString* const CDVPluginResetNotification;
extern NSString* const CDVLocalNotification;
extern NSString* const CDVRemoteNotification;
extern NSString* const CDVRemoteNotificationError;

@interface CDVPlugin : NSObject {}

@property (nonatomic, readonly, weak) UIView* webView;
@property (nonatomic, readonly, weak) id <CDVWebViewEngineProtocol> webViewEngine;

@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;

@property (readonly, assign) BOOL hasPendingOperation;

- (void)pluginInitialize;

- (void)handleOpenURL:(NSNotification*)notification;
- (void)onAppTerminate;
- (void)onMemoryWarning;
- (void)onReset;
- (void)dispose;

/*
 // see initWithWebView implementation
 - (void) onPause {}
 - (void) onResume {}
 - (void) onOrientationWillChange {}
 - (void) onOrientationDidChange {}
 - (void)didReceiveLocalNotification:(NSNotification *)notification;
 */

- (id)appDelegate;

@end
