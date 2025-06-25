//
//  XZSmartMsgManager.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/4/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZSmartMsgView.h"

typedef void(^SmartMsgRobotSpeakBlock)(NSString *word,NSString *speakContent);
typedef void(^SmartMsgCustomBlock)(void);
typedef void(^SmartMsgEnterSleepBlock)(BOOL sleep);
typedef void(^SmartMsgHandleErrorBlock)(NSError *error);

@interface XZSmartMsgManager : NSObject
@property(nonatomic, assign)BOOL canShowMsgView;
@property(nonatomic, assign)BOOL isLogout;
@property(nonatomic, strong)XZSmartMsgView *msgView;
@property(nonatomic, strong)NSTimer *msgTimer;
@property(nonatomic, assign)UIViewController *viewController;
@property(nonatomic, copy)SmartMsgRobotSpeakBlock robotSpeakBlock;
@property(nonatomic, copy)SmartMsgCustomBlock stopSpeakBlock;
@property(nonatomic, copy)SmartMsgCustomBlock showSpeechRobotBlock;
@property(nonatomic, copy)SmartMsgCustomBlock handleBeforeRequestBlock;
@property(nonatomic, copy)SmartMsgCustomBlock willShowMsgViewBlock;
@property(nonatomic, copy)SmartMsgEnterSleepBlock enterSleepBlock;
@property(nonatomic, copy)SmartMsgHandleErrorBlock handleErrorBlock;

+ (instancetype)sharedInstance;
- (void)startShowSmartMsg;
- (void)needSearchSmartMsg:(NSString *)date inController:(UIViewController *)viewController;
- (void)userLogout;
- (void)addListenToTabbarControllerShow;

@end
