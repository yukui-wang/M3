//
//  CMPCustomAlertView.m
//  CMPCustomAlertViewDemo
//
//  Created by yaowei on 2018/8/28.
//  Copyright © 2018年 yaowei. All rights reserved.
//

#import "CMPCustomAlertView.h"
#import "CMPAlert.h"
#import "CMPCustomActionSheet.h"
#import "CMPDatePicker.h"
#import "CMPAddressPicker.h"
#import "CMPSingleGeneralPicker.h"

@implementation CMPCustomAlertView

+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                             delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                             footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                    otherButtonTitles:(nullable NSArray *)otherButtonTitles{
    id<CMPCustomAlertViewProtocol>alertView = nil;
    switch (preferredStyle) {
        case CMPCustomAlertViewStyleAlert:
            alertView = [CMPCustomAlertView CMPAlertTitle:title message:message delegate:delegate footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:nil onView:nil];
            break;
        case CMPCustomAlertViewStyleActionSheet:
            alertView = [CMPCustomAlertView CMPSheetTitle:title message:message delegate:delegate footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:nil];
            break;
        case CMPCustomAlertViewStyleDatePicker:
            @throw [NSException exceptionWithName:@"调用提示" reason:@"请使用dataPicker快速调用方法" userInfo:nil];
            break;
        case CMPCustomAlertViewStyleDatePicker2:
            @throw [NSException exceptionWithName:@"调用提示" reason:@"请使用dataPicker快速调用方法" userInfo:nil];
            break;

        case CMPCustomAlertViewStyleAddressPicker:
            alertView = [CMPCustomAlertView CMPAddressTitle:title message:nil delegate:delegate bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:nil];
            break;

        default:
            break;
    }
    return alertView;
}

+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                           otherButtonTitles:(nullable NSArray *)otherButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    return [CMPCustomAlertView alertViewWithTitle:title message:message preferredStyle:preferredStyle footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler onView:nil];
}

+(nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                           otherButtonTitles:(nullable NSArray *)otherButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler onView:(nullable UIView *)onView{
    
    id<CMPCustomAlertViewProtocol>alertView = nil;
    
    switch (preferredStyle) {
        case CMPCustomAlertViewStyleAlert:
            alertView = [CMPCustomAlertView CMPAlertTitle:title message:message delegate:nil footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler onView:onView];
            break;
        case CMPCustomAlertViewStyleActionSheet:
            alertView = [CMPCustomAlertView CMPSheetTitle:title message:message delegate:nil footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler];
            break;
        case CMPCustomAlertViewStyleDatePicker:
            @throw [NSException exceptionWithName:@"调用提示" reason:@"请使用dataPicker快速调用方法" userInfo:nil];
            break;
        case CMPCustomAlertViewStyleDatePicker2:
            @throw [NSException exceptionWithName:@"调用提示" reason:@"请使用dataPicker快速调用方法" userInfo:nil];
            break;
        case CMPCustomAlertViewStyleAddressPicker:
            alertView = [CMPCustomAlertView CMPAddressTitle:title message:nil delegate:nil bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler];
            break;
        default:
            break;
    }
    return alertView;
}
//MARK: --- CMPCustomAlertViewStyleAddressPicker
+ (nullable id<CMPCustomAlertViewProtocol>)CMPAddressTitle:(nullable NSString *)title
                                           message:(nullable NSString *)message
                                          delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                         bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                 cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                 otherButtonTitles:(nullable NSArray *)otherButtonTitles
                                           handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    
    return [[CMPAddressPicker alloc] initWithTitle:title delegate:delegate bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle okButtonTitles:otherButtonTitles.firstObject handler:handler];
}


//MARK: --- CMPCustomAlertViewStyleActionSheet
+ (nullable id<CMPCustomAlertViewProtocol>)CMPSheetTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message
                                        delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                       footStyle:(CMPAlertPublicFootStyle)footStyle
                                       bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                               cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                               otherButtonTitles:(nullable NSArray *)otherButtonTitles
                                         handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
   return [[CMPCustomActionSheet alloc] initWithTitle:title message:message delegate:delegate footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler];
}



//MARK: --- CMPCustomAlertViewStyleAlert
+ (nullable id<CMPCustomAlertViewProtocol>)CMPAlertTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message
                                        delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                        footStyle:(CMPAlertPublicFootStyle)footStyle
                                       bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                               cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                               otherButtonTitles:(nullable NSArray *)otherButtonTitles
                                         handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler onView:(nullable UIView *)onView{
    
   return [[CMPAlert alloc] initWithTitle:title message:message delegate:delegate footStyle:footStyle bodyStyle:bodyStyle cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler onView:onView];
    
}




//MARK: --- 日期的快速调用方法
+ (nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    if (preferredStyle == CMPCustomAlertViewStyleDatePicker) {
        return [[CMPDatePicker alloc] initWithTitle:title delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:0 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
    }else if (preferredStyle == CMPCustomAlertViewStyleDatePicker2){
        return [[CMPDatePicker alloc] initWithTitle:title delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:1 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
    }else{
        @throw [NSException exceptionWithName:@"提示" reason:@"请检查preferredStyle是否正确" userInfo:nil];
        return nil;
    }
}
+ (nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                                  initialTime:(NSTimeInterval)initialTime
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    if (preferredStyle == CMPCustomAlertViewStyleDatePicker) {
        return [[CMPDatePicker alloc] initWithTitle:title initialTime:initialTime delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:0 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
//        return [[CMPDatePicker alloc] initWithTitle:title delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:0 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
    }else if (preferredStyle == CMPCustomAlertViewStyleDatePicker2){
        return [[CMPDatePicker alloc] initWithTitle:title initialTime:initialTime delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:1 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
//        return [[CMPDatePicker alloc] initWithTitle:title delegate:nil footStyle:footStyle bodyStyle:bodyStyle mode:1 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
    }else{
        @throw [NSException exceptionWithName:@"提示" reason:@"请检查preferredStyle是否正确" userInfo:nil];
        return nil;
    }
}

+ (nullable id<CMPCustomAlertViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                       preferredStyle:(CMPCustomAlertViewStyle)preferredStyle
                                             delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                            footStyle:(CMPAlertPublicFootStyle)footStyle
                                            bodyStyle:(CMPAlertPublicBodyStyle)bodyStyle
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles{
    
    if (preferredStyle == CMPCustomAlertViewStyleDatePicker) {
        return [[CMPDatePicker alloc] initWithTitle:title delegate:delegate footStyle:footStyle bodyStyle:bodyStyle mode:0 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:nil];
    }else if (preferredStyle == CMPCustomAlertViewStyleDatePicker2){
        return [[CMPDatePicker alloc] initWithTitle:title delegate:delegate footStyle:footStyle bodyStyle:bodyStyle mode:1 cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:nil];
    }else{
        @throw [NSException exceptionWithName:@"提示" reason:@"请检查preferredStyle是否正确" userInfo:nil];
        return nil;
    }
    
}


+(nullable id<CMPAlertSingleGeneralPickerViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                           dataSource:(NSArray <CMPSingleGeneralModel *> *_Nonnull)dataSource
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles handler:(nullable void(^)(NSInteger buttonIndex,id _Nullable value))handler{
    
    return [[CMPSingleGeneralPicker alloc] initWithTitle:title delegate:nil dataSource:dataSource cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:handler];
}



+(nullable id<CMPAlertSingleGeneralPickerViewProtocol>)alertViewWithTitle:(nullable NSString *)title
                                             delegate:(nullable id<CMPCustomAlertViewDelegate>)delegate
                                           dataSource:(NSArray <CMPSingleGeneralModel *> *_Nonnull)dataSource
                                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                                     sureButtonTitles:(nullable NSString *)sureButtonTitles{
    return [[CMPSingleGeneralPicker alloc] initWithTitle:title delegate:delegate dataSource:dataSource cancelButtonTitle:cancelButtonTitle okButtonTitles:sureButtonTitles handler:nil];

}

+ (NSString *)version{
    return @"1.3.3";
}
@end
