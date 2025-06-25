//
//  CMPMediator+ShortcutMenuActions.h
//  CMPMediator
//
//  Created by CRMO on 2019/3/29.
//  Copyright © 2019 crmo. All rights reserved.
//

#import "CMPMediator.h"

NS_ASSUME_NONNULL_BEGIN

/** 点击Item回调 **/
typedef void(^CMPMediatorShortcutSelectAction)(NSUInteger index);
/** 点击关闭按钮回调 **/
typedef void(^CMPMediatorShortcutCloseAction)(void);

@interface CMPMediator (ShortcutActions)

/**
 在指定父View上展示快捷菜单，通过Items指定展示的内容
 
 Items是NSDictionary数组，数据格式
 {@"icon": UIImage,
 @"title": NSString}

 @param view 展示快捷菜单的父View
 @param items 定义快捷菜单的Items
 @param selectAction 选中某个Item回调
 @param closeAction 点击关闭回调
 */
- (void)CMPMediator_showShortcutInView:(UIView *)view
                                 items:(NSArray *)items
                          selectAction:(CMPMediatorShortcutSelectAction)selectAction
                           closeAction:(_Nullable CMPMediatorShortcutCloseAction)closeAction;

/**
 隐藏快捷菜单
 */
- (void)CMPMediator_hideShortcut;

@end

NS_ASSUME_NONNULL_END
