//
//  CMPNotificationSettingObjct.h
//  M3
//
//  Created by CRMO on 2017/9/20.
//

#import "CMPBaseResponse.h"

@interface CMPPushConfigResponse : CMPBaseResponse

/** 提醒时间段（开始时间） **/
@property (nonatomic, strong) NSString *startDate;
/** 提醒时间段（结束时间） **/
@property (nonatomic, strong) NSString *endDate;
/** 设置详情,老板本接口 **/
@property (nonatomic, strong) NSString *settingContent;
@property (strong, nonatomic) NSString *main;
@property (strong, nonatomic) NSString *ring;
@property (strong, nonatomic) NSString *shake;
/** v8.0新增参数,是否静音 **/
@property (copy, nonatomic) NSString *mute;


/** 总开关 **/
@property (nonatomic, assign) BOOL mainSwitch;
/** 铃声开关 **/
@property (nonatomic, assign) BOOL ringSwitch;
/** 震动开关 **/
@property (nonatomic, assign) BOOL shakeSwitch;

/** 多端登录静音开关是否接收消息,默认为No,不接收消息 **/
@property (nonatomic, assign) BOOL multiLoginReceivesMessageState;

@end
