//
//  CMPSpeechRobotConfig.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/20.
//
//

#import <Foundation/Foundation.h>

@interface CMPSpeechRobotConfig : NSObject <NSCoding>

@property(nonatomic,assign) BOOL isOnOff;//机器人是否开启
@property(nonatomic,assign) BOOL isOnShow;//机器人快捷图标是否打开
@property(nonatomic,assign) BOOL isAutoAwake;//是否自动唤醒
@property(nonatomic,strong) NSString *startTime;//开启时间 HH:mm
@property(nonatomic,strong) NSString *endTime;//关闭时间 HH:mm

@end
