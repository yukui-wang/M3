//
//  CMPAlert.h
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/27.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPCustomAlertViewProtocol.h"

@interface CMPAlert : UIView <CMPAlertAlertViewProtocol>

@property (nonatomic, weak) _Nullable id delegate;

@property (nonatomic, assign, readonly) CMPAlertPublicFootStyle footStyle;
@property (nonatomic, assign, readonly) CMPAlertPublicBodyStyle bodyStyle;


- (instancetype _Nullable )initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(id _Nullable )delegate
                    footStyle:(CMPAlertPublicFootStyle)footStyle
                    bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
                      handler:(nullable void(^)(NSInteger buttonIndex,
                                                id _Nullable value))handler;

- (instancetype _Nullable )initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                     delegate:(id _Nullable )delegate
                    footStyle:(CMPAlertPublicFootStyle)footStyle
                    bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
                      handler:(nullable void(^)(NSInteger buttonIndex,
                                                id _Nullable value))handler onView:(UIView *_Nullable)onView;
@end
