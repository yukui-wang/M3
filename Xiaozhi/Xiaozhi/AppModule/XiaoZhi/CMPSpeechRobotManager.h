//
//  CMPSpeechRobotManager.h
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/21.
//
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CMPSpeechRobotManager : NSObject
@property(nonatomic,weak)UIViewController *xzIconInViewController;//缓存小致要显示的界面
+ (instancetype)sharedInstance;
//开启语音机器人
- (void)openSpeechRobot;
- (void)reloadSpeechRobot;
- (void)showQAWithIntentId:(NSString *)intentId;
@end
