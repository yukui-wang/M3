//
//  CMPMeetingDataProvider.h
//  M3
//
//  Created by Kaku Songu on 11/26/22.
//

#import <CMPLib/CMPBaseDataProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPMeetingDataProvider : CMPBaseDataProvider

/**
 8.2 即时会议
 获取后台管理配置是否开启
 */
-(void)fetchQuickMeetingEnableStateWithResult:(CommonResultBlk)result;

/**
 8.2即时会议
 获取个人会议号是否配置
 */
-(void)checkQuickMeetingConfigWithResult:(CommonResultBlk)result;

/**
 8.2即时会议
 获取个人会议号的配置信息
 */
-(void)fetchPersonalQuickMeetingConfigInfoWithResult:(CommonResultBlk)result;

/**
 8.2即时会议
 创建即时会议，人员id数组
 */
-(void)createOnTimeMeetingByMids:(NSArray *)mids result:(CommonResultBlk)result;

/**
 8.2即时会议
 校验会议是否有效
 */
-(void)verifyOnTimeMeetingValidWithInfo:(NSDictionary *)meetInfo result:(CommonResultBlk)result;

/**
 8.2即时会议
 致信创建即时会议，会发送人员卡片
 */
-(void)zxCreateOnTimeMeetingBySenderId:(NSString *)sid receiverIds:(NSArray *)receiverIds type:(NSString *)type link:(NSString *)link password:(NSString *)pwd result:(CommonResultBlk)result;

@end

NS_ASSUME_NONNULL_END
