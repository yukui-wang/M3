//
//  SPWakeuper.h
//  CMPCore
//
//  Created by zeb on 2017/2/25.
//
//

#import <Foundation/Foundation.h>
#import "SPConstant.h"
@interface SPWakeuper : NSObject

@property (nonatomic) BOOL isInit;
@property (nonatomic) SPSpeechEngineType type;//语音使用的sdk


+ (instancetype)sharedInstance;
- (void)startWakeupWithAction:(void (^)(void))wakeupAction;
- (void)stopWakeup;
@end
