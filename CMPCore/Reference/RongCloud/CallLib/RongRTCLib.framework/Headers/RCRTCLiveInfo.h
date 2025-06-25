//
//  RCRTCLiveInfo.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/8/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRTCMixConfig.h"
#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCLiveInfo : NSObject

/**
 当前的直播地址
 @discussion 新版观众加房间,直接可以拿到直播合流, 单个主播流,使用常规方式订阅即可
 */
@property (nonatomic, copy, readonly) NSString *liveUrl;

/*!
 设置混流布局配置
 
 @param config 混流布局配置
 @param completion 动作的回调
 @discussion
 设置混流布局配置
 
 @remarks 资源管理
 */
- (void)setMixStreamConfig:(RCRTCMixConfig *)config
                completion:(void (^) (BOOL isSuccess, RCRTCCode code))completion DEPRECATED_MSG_ATTRIBUTE("use setMixConfig:completion: API instead");

/*!
 设置混流布局配置
 
 @param config 混流布局配置
 @param completion 动作的回调
 @discussion
 设置混流布局配置
 
 @remarks 资源管理
 */
- (void)setMixConfig:(RCRTCMixConfig *)config
                completion:(void (^) (BOOL isSuccess, RCRTCCode code))completion;

/*!
 添加一个 CDN 直播推流地址
 
 @param url 推流地址
 @param completion 回调
 */
- (void)addPublishStreamUrl:(NSString *)url
                 completion:(void (^)(BOOL isSuccess, RCRTCCode code, NSArray *array))completion;

/*!
 删除一个 CDN 直播推流地址
 
 @param url 要删除的推流地址
 @param completion 回调
 */
- (void)removePublishStreamUrl:(NSString *)url
                    completion:(void (^)(BOOL isSuccess, RCRTCCode code, NSArray *array))completion;

@end

NS_ASSUME_NONNULL_END
