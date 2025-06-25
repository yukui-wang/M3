//
//  CMPPersonInfoUtils.h
//  CMPLib
//
//  Created by youlin on 2016/9/28.
//  Copyright © 2016年 CMPCore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMPPersonInfoUtils : NSObject

// 打开人员信息view
+ (BOOL)showPersonInfoView:(NSString *)memberId
                      from:(NSString *)aFrom
                enableChat:(BOOL)enableChat
      parentViewController:(UIViewController *)parentViewController
             allowRotation:(BOOL)alllowRotation;

// 跳转到设置页面
+ (void)jumpUserSettingFrom:(UIViewController *)viewController;

/**
 获取我的设置页面
 */
+ (UIViewController *)userSettingViewController;

@end
