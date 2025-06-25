//
//  CMPStartPageHelper.h
//  M3
//
//  Created by youlin on 2017/11/21.
//

#import <CMPLib/CMPObject.h>

@interface CMPStartPageViewHelper : CMPObject

// 是否需要显示启动页
+ (BOOL)needShowStartPageView;
// 是否是默认启动页,只有当设置了服务器地址后
- (BOOL)isDefaultStartPage;
// 显示启动页
- (void)showStartPageView;
// 隐藏启动页
- (void)hideStartPageView;
- (void)bringToFront;

@end
