//
//  CMPRCMissionHelper.h
//  M3
//
//  Created by CRMO on 2018/10/17.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

@class RCMessageModel;
@interface CMPRCMissionHelper : CMPObject

/**
 构造IM文本消息转任务新建任务所需参数

 @param message IM消息
 @return 新建任务参数
 */
+ (NSString *)paramForCovertMission:(RCMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
