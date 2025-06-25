//
//  RDVTabBarShortcutItem.h
//  RDVTabBarController
//
//  Created by CRMO on 2019/4/28.
//  Copyright © 2019 Robert Dimitrov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RDVTabBarShortcutItemDidClick)(void);
typedef NS_ENUM(NSUInteger, RDVTabBarShortcutType) {
    RDVTabBarShortcutType_Common  = 0,
    RDVTabBarShortcutType_AllSearch//全文检索
};

@interface RDVTabBarShortcutItem : UIControl

- (instancetype)initWithUnselectImage:(UIImage *)unselectImage
                        selectedImage:(UIImage *)selectedImage
                            canSelect:(BOOL)canSelect
                             didClick:(RDVTabBarShortcutItemDidClick)didClick;

/**
 未选中按钮图标
 */
@property (strong, nonatomic) UIImage *unselectImage;

/**
 选中按钮图标
 */
@property (strong, nonatomic) UIImage *selectedImage;

/**
 是否可以选中
 为YES，点击按钮，图标变为selectedImagem，展示viewController，调用didClick
 为NO，点击按钮，图标不变，不展示viewController，调用didClick
 */
@property (assign, nonatomic) BOOL canSelect;

/**
 点击事件
 */
@property (copy, nonatomic) RDVTabBarShortcutItemDidClick didClick;

//类型，目前小致要用到全文检索，如果其他模块要用可增加type
@property (assign, nonatomic) RDVTabBarShortcutType shortcutType;


@end

NS_ASSUME_NONNULL_END
