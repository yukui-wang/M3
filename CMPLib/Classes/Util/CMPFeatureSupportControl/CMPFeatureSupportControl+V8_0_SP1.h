//
//  CMPFeatureSupportControl+V8_0.h
//  CMPLib
//
//  Created by 程昆 on 2020/3/4.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <CMPLib/CMPFeatureSupportControl.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPFeatureSupportControl (V8_0_SP1)

/// V8.0SP1需要从服务器获取融云消息设置
+ (BOOL)isNeedUpdateRCMessageSetting;

/// V8.0SP1融云消息设置需提交服务器
+ (BOOL)isNeedUploadRCMessageSetting;

@end

NS_ASSUME_NONNULL_END
