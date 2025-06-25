//
//  CMPCustomActionSheet.h
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/30.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPCustomAlertViewProtocol.h"

@interface CMPCustomActionSheet : UIView <CMPAlertActionSheetViewProtocol>

@property (nonatomic, weak) _Nullable id delegate;

- (instancetype _Nullable )initWithTitle:(nullable NSString *)title
                                 message:(nullable NSString *)message
                                delegate:(id _Nullable )delegate
                               footStyle:(CMPAlertPublicFootStyle)footStyle
                               bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                       cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                       otherButtonTitles:(nullable NSArray <NSString *> *)otherButtonTitles
                                 handler:(nullable void(^)(NSInteger buttonIndex,
                                                           id _Nullable value))handler;
@end

@interface CMPCustomActionSheetButtion : UIView
- (instancetype)initWithTitle:(NSString *_Nullable)title;
@end
