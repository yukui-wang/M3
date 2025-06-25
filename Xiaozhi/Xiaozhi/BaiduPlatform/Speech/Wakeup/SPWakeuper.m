//
//  SPWakeuper.m
//  CMPCore
//
//  Created by zeb on 2017/2/25.
//
//

#import "SPWakeuper.h"
#import "SPTools.h"
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import "BDSEventManager.h"
#import "XZCore.h"
#import <AVFoundation/AVFoundation.h>

@interface SPWakeuper ()<BDSClientWakeupDelegate> {
    void (^_wakeupAction)(void);
}
@property (nonatomic, strong) NSDictionary *words;
@property (nonatomic) BOOL isStrat;
@property (nonatomic, strong) BDSEventManager *wakeupEventManager;
@end

@implementation SPWakeuper

+ (instancetype)sharedInstance {
    static SPWakeuper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SPWakeuper alloc] init];
    });
    return instance;
}
- (void)startWakeupWithAction:(void (^)(void))wakeupAction {
    [self startBaiduWakeupWithAction:wakeupAction];
}
- (void)stopWakeup {
    [self stopWakeupBaidu];
}

/************** 百度 *******************/

- (NSString *)wakeupAPPId {
    if ([SPTools isM3InHouse]) {
        //测试版本299使用，因为唤醒与app ID有关
        return kBaiduSpeechAppId;
    }
    return  [XZCore sharedInstance].baiduSpeechInfo.baiduSpeechAppId;
}

- (void)startBaiduWakeupWithAction:(void (^)(void))wakeupAction {
    _wakeupAction = wakeupAction;
    if (_isStrat) {
        return;
    }
#if TARGET_IPHONE_SIMULATOR
#else
    _isStrat = YES;
    if(!self.wakeupEventManager) {
        // 创建语音识别对象
        self.wakeupEventManager = [BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME];
        // 设置语音唤醒代理
        [self.wakeupEventManager setDelegate:self];
        // 参数配置：离线授权APPID
        NSString *APPID = [self wakeupAPPId];
        [self.wakeupEventManager setParameter:APPID forKey:BDS_WAKEUP_APP_CODE];
        // 参数配置：唤醒语言模型文件路径, 默认文件名为 bds_easr_basic_model.dat
        NSString* dat = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
        
        [self.wakeupEventManager setParameter:dat forKey:BDS_WAKEUP_DAT_FILE_PATH];
        //设置唤醒词文件路径
        // 默认的唤醒词文件为"bds_easr_wakeup_words.dat"，包含的唤醒词为"百度一下"
        // 如需自定义唤醒词，请在 http://ai.baidu.com/tech/speech/wake 中评估并下载唤醒词文件，替换此参数
        NSString* words = [[NSBundle mainBundle] pathForResource:@"aidemo" ofType:@"dms"];
        [self.wakeupEventManager setParameter:words forKey:BDS_WAKEUP_WORDS_FILE_PATH];
        
        [self.wakeupEventManager setParameter:@(YES) forKey:BDS_WAKEUP_DISABLE_AUDIO_OPERATION];
        
        // 发送指令：加载语音唤醒引擎
        [self.wakeupEventManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
        // 发送指令：启动唤醒
        [self.wakeupEventManager sendCommand:BDS_WP_CMD_START];
    }
    else  {
        // 发送指令：启动唤醒
        /**
         OA-146233 智能助手：IOS端，听音乐状态下进入M3，占用麦克风权限有问题
         关闭唤醒会导致 AudioSession 失效，这么改有风险
         */
        [self.wakeupEventManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
        [self.wakeupEventManager sendCommand:BDS_WP_CMD_START];
    }
#endif
}

- (void)stopWakeupBaidu {
    _wakeupAction = nil;
    if (!_isStrat) {
        return;
    }
    _isStrat = NO;
    /**
     OA-146233 智能助手：IOS端，听音乐状态下进入M3，占用麦克风权限有问题
     关闭唤醒会导致 AudioSession 失效，这么改有风险
     */
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_STOP];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_UNLOAD_ENGINE];
}

#pragma mark BDSClientWakeupDelegate
- (void)WakeupClientWorkStatus:(int)workStatus obj:(id)aObj {
    NSLog(@"workStatus = %d,value = %@",workStatus,aObj);
    if (workStatus == EWakeupEngineWorkStatusTriggered) {
        if (_wakeupAction) {
            _wakeupAction();
            _wakeupAction = nil;
        }
    }
}

@end
