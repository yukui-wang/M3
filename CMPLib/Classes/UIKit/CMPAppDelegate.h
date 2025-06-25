//
//  CMPAppDelegate.h
//  CMPLib
//
//  Created by youlin on 2017/5/14.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#import "CMPObject.h"
#import "UIDevice+TFDevice.h"
#import "CMPScreenShotView.h"


@interface CMPAppDelegate : CMPObject<UIApplicationDelegate>

@property (nonatomic, strong) CMPScreenShotView *screenshotView;

/**
 * 是否允许转向
 */
@property(nonatomic,assign)BOOL allowRotation;
/* 是否允许转屏 */
@property (copy, nonatomic) NSString *rotationAllowed;
/**
 * 标注某个页面只允许竖屏 iPad也竖屏
 */
@property(nonatomic,assign)BOOL onlyPortrait;


+ (CMPAppDelegate *)shareAppDelegate;

//返回：是否要跳转到登陆页面  //统一处理原生弹出提示
- (BOOL)handleError:(NSError *)error;

@end
