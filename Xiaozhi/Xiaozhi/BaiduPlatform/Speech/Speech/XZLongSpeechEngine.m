//
//  XZLongSpeechEngine.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZLongSpeechEngine.h"
#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import "SPTools.h"

@interface XZLongSpeechEngine () {
    BOOL _isIdentifying;//正在识别
}
@property (nonatomic, strong) BDSEventManager *speechRecognizer;   // 语音识别对象
@property (nonatomic, strong)NSString *filePath;//语音识别录音文件地址
@property (nonatomic, strong)NSMutableData *speechData;//语音识别录音文件地址
@property (nonatomic, strong)NSMutableString *resultStr;//识别后w的文本

@property (nonatomic, copy)LongSpeechFlushStrBlock flushStrBlock;
@property (nonatomic, copy)LongSpeechCompleteBlock completeBlock;
@property (nonatomic, copy)LongSpeechErrorBlock errorBlock;

@end
@implementation XZLongSpeechEngine
static id shareInstance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [super allocWithZone:zone];
            }
        }
    }
    return shareInstance;
}

+ (instancetype)sharedInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
                [shareInstance initRecognizer];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}
- (void)initRecognizer {
#if TARGET_IPHONE_SIMULATOR
#else
    //初始化及在线识别
    if (!self.speechRecognizer) {
        self.speechRecognizer = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
        //@"采样率"
        [self.speechRecognizer setParameter:@(EVoiceRecognitionRecordSampleRate16K) forKey:BDS_ASR_SAMPLE_RATE];
        //"识别语言"
        [self.speechRecognizer setParameter:@(EVoiceRecognitionLanguageChinese) forKey:BDS_ASR_LANGUAGE];
        //"开启提示音"
        [self.speechRecognizer setParameter:@(0) forKey:BDS_ASR_PLAY_TONE];
        //"识别策略"
        [self.speechRecognizer setParameter:@(EVR_STRATEGY_ONLINE) forKey:BDS_ASR_STRATEGY];
        //"开启端点检测"
        [self.speechRecognizer setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
        // 当前触发唤醒词，唤醒后立即调用识别的情况下配置，其他情况请忽略该参数
        [self.speechRecognizer setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
        //唤醒后立刻进行识别需开启该参数，其他情况请忽略该参数
        [self.speechRecognizer setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
        [self.speechRecognizer setParameter:@(YES) forKey:BDS_WAKEUP_DISABLE_AUDIO_OPERATION];
        [self.speechRecognizer setParameter:nil forKey:BDS_ASR_AUDIO_FILE_PATH];
        [self.speechRecognizer setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    }
    //设置DEBUG_LOG的级别
    [self.speechRecognizer setParameter:@(EVRDebugLogLevelOff) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    // 设置语音识别代理
    [self.speechRecognizer setDelegate:self];
    // configModelVAD 配置端点检测  端点检测，即自动检测音频输入的起始点和结束点 检测更加精准，抗噪能力强，响应速度较慢
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.speechRecognizer setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.speechRecognizer setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
#endif
}

- (void)recognizerLongText{
#if TARGET_IPHONE_SIMULATOR
#else
    // 是否启用长语音识别
    [self.speechRecognizer setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.speechRecognizer setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    //开启标点
    [self.speechRecognizer setParameter:@(NO) forKey:BDS_ASR_DISABLE_PUNCTUATION];
    // 普通话标点
    [self.speechRecognizer setParameter:@"15373" forKey:BDS_ASR_PRODUCT_ID];
    [self.speechRecognizer sendCommand:BDS_ASR_CMD_START];
    [self onBeginOfSpeech];
#endif
}


#pragma mark BDSClientASRDelegate
- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj {
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            // 识别工作开始，开始采集及处理数据
            NSLog(@"EVoiceRecognitionClientWorkStatusStartWorkIng");
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            
            break;
        }
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            NSData *originData = (NSData *)aObj;
            [self handleSpeechData:originData];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            [self handleResult:(NSDictionary *)aObj];
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            [self onVolumeChanged:aObj];
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            NSLog(@"EVoiceRecognitionClientWorkStatusCancel");
            [self clearData];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            [self onError:(NSError *)aObj];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            [self handleLongSpeechEnd];
            break;
        }
        default:
            break;
    }
}




//识别结果返回代理
- (void)handleResult:(NSDictionary *)dic {
    NSArray *stringArray = [dic objectForKey:@"results_recognition"];
    NSString *string = [stringArray firstObject];
    NSLog(@"!!!!!1handleResult:%@",string);
    if (self.resultStr) {
        [self.resultStr appendString:string];
    }
    if (self.flushStrBlock) {
        self.flushStrBlock(string);
    }
}

- (void)onError:(NSError *)error {
    NSLog(@"onError :%@",error);
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}

//开始录音回调
- (void)onBeginOfSpeech {
    _isIdentifying = YES;
}
//音量回调函数
- (void)onVolumeChanged:(id)obj {
}

- (void)handleSpeechData:(NSData *)data {
    if (self.speechData) {
        [self.speechData appendData:data];
    }
}

- (void)handleLongSpeechEnd {
    [self writePcmDataToWavFile];
    [self clearData];
}

- (void)writePcmDataToWavFile {
    [SPTools pcmData:self.speechData toWavFilePath:self.filePath];
    if (self.completeBlock) {
        self.completeBlock(self.filePath,self.resultStr);
    }
    self.speechData = nil;
}

- (void)recognizerWithFilePath:(NSString *)filePath
                 flushStrBlock:(LongSpeechFlushStrBlock)flushStrBlock
                 completeBlock:(LongSpeechCompleteBlock)completeBlock
                    errorBlock:(LongSpeechErrorBlock)errorBlock {
    self.flushStrBlock = flushStrBlock;
    self.completeBlock = completeBlock;
    self.errorBlock = errorBlock;
    
    self.filePath = filePath;
    if (self.filePath) {
        self.speechData = [NSMutableData data];
    }
    self.resultStr = [NSMutableString string];
    [self recognizerLongText];
}

- (void)stopRecognizerLong{
    if (_isIdentifying) {
        [self.speechRecognizer sendCommand:BDS_ASR_CMD_STOP];
    }
}
- (void)cancelRecognizerLong{
    if (_isIdentifying) {
        [self.speechRecognizer sendCommand:BDS_ASR_CMD_STOP];
    }
}

- (void)clearData {
    self.flushStrBlock = nil;
    self.completeBlock = nil;
    self.errorBlock = nil;
    self.filePath = nil;
    self.speechData = nil;
    self.resultStr = nil;
    _isIdentifying = NO;
}


@end


