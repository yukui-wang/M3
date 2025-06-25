//
//  CMPSingleGeneralPicker.h
//  CMPCustomAlertViewDemo
//
//  Created by Mr.Yao on 2020/2/23.
//  Copyright © 2020 yaowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPCustomAlertViewProtocol.h"
@class CMPSingleGeneralModel;

NS_ASSUME_NONNULL_BEGIN

@interface CMPSingleGeneralPicker : UIView <CMPAlertSingleGeneralPickerViewProtocol>
@property (nonatomic, weak) _Nullable id delegate;
- (instancetype _Nullable)initWithTitle:(nullable NSString *)title
                               delegate:(id _Nullable)delegate
                            dataSource:(NSArray <CMPSingleGeneralModel*> *)dataSource
                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                         okButtonTitles:(nullable NSString *)sureButtonTitles
                                handler:(nullable void(^)(NSInteger buttonIndex,
                                                          id _Nullable value))handler;
@end
NS_ASSUME_NONNULL_END
