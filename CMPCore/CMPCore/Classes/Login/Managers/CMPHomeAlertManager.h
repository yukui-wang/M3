//
//  CMPHomeAlertManager.h
//  M3
//
//  Created by CRMO on 2019/1/23.
//

#import <CMPLib/CMPObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CMPHomeAlertPriority) {
    CMPHomeAlertPrioritywLowSystemBlankTip = 90,  // 低版本系统可能出现空白页面的提示
    CMPHomeAlertPrioritywNotOpenUserNotification = 100,  // 未打开系统消息推送开关
    CMPHomeAlertPriorityMsgQuickAlert = 900, // 消息页的快捷操作弹框
    CMPHomeAlertPriorityImportMsg = 950, // 重要消息提醒（如生日等）
    CMPHomeAlertPrioritySmartMsg = 1000, // 智能提醒
    CMPHomeAlertPriorityWiFiClockIn = 2000, // WiFi打卡
    CMPHomeAlertPriorityXZ = 3000,  // 小致
    CMPHomeAlertPriorityTip = 3500,  // 新版本指引
    CMPHomeAlertPriorityWeakPwd = 4000,  // 弱口令
    CMPHomeAlertPriorityTabBar = 5000,  // 底导航刷新
    CMPHomeAlertPriorityRemoteNotifi = 6000,  // 离线消息推送
    CMPHomeAlertPriorityDeviceBinding = 6100,  // 硬件绑定
    CMPHomeAlertPrioritySessionInvalid = 6200,  // 失效下线
    CMPHomeAlertPriorityNotHaveAvailableLanguage = 6300,  // 没有可用的语言
    CMPHomeAlertPriorityPopUpPrivacyProtocolPage = 6400,  // 弹出隐私协议
    CMPHomeAlertPriorityShowBeforeLogin = 7000,  //此级别为分割值，大于它，可在登录前显示，小于需要在登录后才能显示
    CMPHomeAlertPriorityGuidePage = 8000,  // 引导页
    CMPHomeAlertPriorityUpdate = 9000,  // 壳更新
    CMPHomeAlertPrioritySinglePopUpPrivacyProtocolPage = 10000 // 隐私协议
};

typedef void(^CMPHomeAlertShowBlock)(void);

/** 所有任务执行完成通知 **/
extern NSString * const CMPHomeAlertTaskManagerAllTaskDidFinish;

@interface CMPHomeAlertManager : CMPObject

@property (assign, nonatomic) BOOL hasPushedNewVersionTip;//是否已经push过新引导页的标记

/**
 获取Manager单例
 */
+ (instancetype)sharedInstance;

/**
 将弹窗任务加入队列，如果当前没有ready，不会马上执行任务，调用ready后开始执行
 CMPHomeAlertManager维护一个优先级队列，每次取出优先级最高的任务执行，任务执行完毕后需主动调用taskDone。
 上一个任务执行完毕后，自动取下一个任务执行。

 @param showBlock 展示弹窗逻辑
 @param priority 任务优先级
 @return TaskID 任务ID，类型是字符串
 */
- (NSString *)pushTaskWithShowBlock:(CMPHomeAlertShowBlock)showBlock
                           priority:(NSUInteger)priority;

/**
 任务完成后需主动调用改方法，如果任务队列还有任务，会触发下一个任务
 */
- (void)taskDone;

/**
 移除队列中的所有任务，将ready状态置为NO
 */
- (void)removeAllTask;

/**
 开始执行任务队列，轮询执行任务队列中的任务。
 需要注意的是：如果任务队列为空，直接结束执行。
 */
- (void)ready;

@end

NS_ASSUME_NONNULL_END
