//
//  CMPCustomAlertView.h
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPCustomAlertViewProtocol.h"
#import "CMPAddressModel.h"
#import "CMPSingleGeneralModel.h"
#import "CMPTheme.h"

typedef NS_ENUM(NSInteger, CMPCustomAlertViewStyle){
    CMPCustomAlertViewStyleAlert = 0,
    CMPCustomAlertViewStyleActionSheet = 1,
    CMPCustomAlertViewStyleDatePicker = 2,//datePicker默认在中间显示
    CMPCustomAlertViewStyleDatePicker2 = 3,//datePicke显示在底部
    CMPCustomAlertViewStyleAddressPicker = 4,
    CMPCustomAlertViewStyleSingleGeneralPicker = 5,
    
};

@interface CMPCustomAlertView : NSObject

/**
 创建并弹出使用代理监听点击事件的
 
 @param title 标题
 @param message 提示内容
 @param delegate 委托代理
 @param preferredStyle 弹框的样式
 @param footStyle footView的样式
 @param bodyStyle messageView的样式
 @param cancelButtonTitle 取消按钮的标题
 @param otherButtonTitles 其他按钮的标题
 @return 弹框的对象
 */
+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                             delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                    otherButtonTitles:(nullable NSArray *)otherButtonTitles;

/**
 创建并弹出使用block监听点击事件的
 
 @param title 标题
 @param message 提示内容
 @param preferredStyle 弹框的样式
 @param footStyle footView的样式
 @param bodyStyle messageView的样式
 @param cancelButtonTitle 取消按钮的标题
 @param otherButtonTitles 其他按钮的标题
 @param handler blcok
 @return 弹框的对象
 */
+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                    otherButtonTitles:(nullable NSArray *)otherButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;

/**
 添加显示在哪个view上的参数 nnd
 */
+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                           otherButtonTitles:(nullable NSArray *)otherButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler onView:(nullable UIView *)onView;

//可以传入initialTime:(NSTimeInterval)initialTime
//只能10位，不能13位
+ (nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                                  initialTime:(NSTimeInterval)initialTime
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                             sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;

/**
 快速调用datePicker使用block回调
 
 @param title 标题（可选）
 @param preferredStyle dataPicker的显示位置，默认CMPCustomAlertViewStyleDatePicker（中间）
 @param footStyle footView的样式
 @param bodyStyle 日历格式的样式
 @param cancelButtonTitle  取消按钮的标题
 @param sureButtonTitles 其他按钮的标题
 @param handler blcok
 @return 弹框的对象
 */
+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;

/**
 快速调用signleGeneral使用blcok回调
 
 @param title 标题（可选）
 @param dataSource 数据源
 @param cancelButtonTitle 取消按钮的标题
 @param sureButtonTitles 其他按钮的标题
 @param handler blcok
 @return 弹框的对象
 */
+(nullable id<CMPAlertSingleGeneralPickerViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                           dataSource:(NSArray <CMPSingleGeneralModel *> *_Nonnull)dataSource
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler;




/**
 快速调用signleGeneral使用delegate回调
 
 @param title 标题（可选）
 @param delegate 委托代理
 @param dataSource 数据源
 @param cancelButtonTitle 取消按钮的标题
 @param sureButtonTitles 其他按钮的标题
 @return 弹框的对象
 */
+(nullable id<CMPAlertSingleGeneralPickerViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                             delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                           dataSource:(NSArray <CMPSingleGeneralModel *> *_Nonnull)dataSource
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles;

/**
 当前版本号
 
 @return 版本号
 */
+ (NSString *_Nonnull)version;
@end
