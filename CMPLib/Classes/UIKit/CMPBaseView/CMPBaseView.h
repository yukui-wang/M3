//
//  CMPBaseView.h
//  M1Core
//
//  Created by admin on 12-10-26.
//  Copyright (c) 2012年 北京致远协创软件有限公司. All rights reserved.
//

#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#import <UIKit/UIKit.h>
#import "CMPCore.h"
#import "CMPThemeManager.h"
#import <CMPLib/Masonry.h>

@interface CMPBaseView : UIView {
    UIViewController *_viewController; // 所在viewcontroller
    CMPBaseView      *_modalView;        //弹出的modalview
}

@property (nonatomic, assign) UIViewController *viewController;
@property (nonatomic, retain) CMPBaseView            *modalParentView;//modal 父view
@property(nonatomic, assign) CGSize contentSize; // 内部大小
@property (nonatomic,copy) void(^actBlk)(NSInteger act,id ext,UIViewController *controller);

- (void)setup; // pad、 phone共同调用
// 用于pad、phone公共View
- (void)setupForPhone; // phone
- (void)setupForPad; // pad 

- (void)customLayoutSubviews; // 自定义布局子views, 不能与layoutSubviews一起写
- (void)layoutSubviewsForPortrait;  // 横向布局子views （默认调用）
- (void)layoutSubviewsForLandscape; // 纵向布局子views

// pad、 phone common view
- (void)layoutSubviewsForPhone;
- (void)layoutSubviewsForPhonePortrait;  
- (void)layoutSubviewsForPhoneLandscape;
- (void)layoutSubviewsForPad;
- (void)layoutSubviewsForPadPortrait;  
- (void)layoutSubviewsForPadLandscape;


// 模态窗体
- (void)showLoadingView;
- (void)hideLoadingView;

@end
