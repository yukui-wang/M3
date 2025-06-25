//
//  CMPShortcutView.h
//  CMPCore
//
//  Created by wujiansheng on 2017/7/5.
//
//

#import <CMPLib/CMPBaseView.h>
#import "CMPShortcutItem.h"
#import <CMPLib/CMPCore.h>

@protocol CMPShortcutViewDelegate <NSObject>

/**
 点击关闭按钮
 */
- (void)shortcutDidClose:(id)shortcut;

/**
 点击某个item

 @param shortcut 实例
 @param index 选中index
 */
- (void)shortcut:(id)shortcut selectedIndex:(NSUInteger)index;

@end

@interface CMPShortcutView : CMPBaseView

/**
 在指定View展示快捷菜单

 @param view 展示快捷菜单的父view
 @param shortcuts 快捷菜单列表，数据类型为：CMPShortcutItemModel
 @param delegate 事件代理
 @return 快捷菜单实例
 */
+ (instancetype)showInView:(UIView *)view
                 shortcuts:(NSArray<CMPShortcutItemModel*> *)shortcuts
                  delegate:(id<CMPShortcutViewDelegate>) delegate;

- (void)dismissWithoutAnimation;

@end

