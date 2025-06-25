//
//  CMPLocalAuthenticationHelper.h
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPLocalAuthenticationHelper : CMPObject

@property (copy, nonatomic) void(^tapGestureView)(void);

/**
 展示面容解锁页面

 @param completion 面容解锁结果回调
 */
- (void)authWithCompletion:(void(^)(BOOL result, NSError *error))completion;

/**
 隐藏界面
 */
- (void)hide;

/**
 指纹解锁界面是否展示
 */
+ (BOOL)isLocalAuthenticationShow;

@end

NS_ASSUME_NONNULL_END
