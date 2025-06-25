//
//  SPBaiduSpeechEngine.m
//  M3
//
//  Created by wujiansheng on 2017/12/7.
//


#import "SPBaiduSpeechEngine.h"
#import "SPAudioPlayer.h"

#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"

#import "BDSSpeechSynthesizer.h"

#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import "BDSEventManager.h"
#import "SPBaiduSpeechInfo.h"

#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPConstant.h>

@interface SPBaiduSpeechEngine ()<BDSClientASRDelegate,BDSSpeechSynthesizerDelegate> {
    BOOL _isSpeaking;
    BOOL _isCancelRecognizer;
    BOOL _hasSetInfo;//是否配置了百度参数
    BOOL _isRecognizering;//正在识别
}
@property (nonatomic, strong) BDSEventManager *speechRecognizer;   // 语音识别对象
@property (nonatomic) SpeechRecognizeType recognizeType; // 识别类型
@property (nonatomic) BOOL isUploadingGrammar; // 正在上传语法文件标志位
@property (nonatomic, strong) NSString *longtextTmp;    // 长文本识别容器
@property (nonatomic, strong) SPAudioPlayer *audioPlayer;
@property (nonatomic, strong)NSMutableArray *speechFlushArray;//语音识别连续上屏，用于识别报错时用
@property (nonatomic, strong)NSString *speakRemainingStr;//字符串太长，分多次合成，当前合成剩下的

@end

@implementation SPBaiduSpeechEngine

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
                [shareInstance initSynthesizer];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}

- (void)setupBaseInfo:(SPBaiduSpeechInfo *)info {
    if (!info || [NSString isNull:info.baiduSpeechApiKey] || [NSString isNull:info.baiduSpeechSecretKey]|| [NSString isNull:info.baiduSpeechAppId]) {
        return;
    }
    if (_hasSetInfo) {
        //防止重复设置
        return;
    }
    _hasSetInfo = YES;
    
    //语音识别
    [self.speechRecognizer setParameter:@[info.baiduSpeechApiKey, info.baiduSpeechSecretKey] forKey:BDS_ASR_API_SECRET_KEYS];
    //设置 APPID
    [self.speechRecognizer setParameter:info.baiduSpeechAppId forKey:BDS_ASR_OFFLINE_APP_CODE];
    
    // 语音合成
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:info.baiduSpeechApiKey withSecretKey:info.baiduSpeechSecretKey];
}

- (void)logout {
    [self stopRecognize];
    [self stopSpeak];
    _hasSetInfo = NO;
}
#pragma mark   语音识别对象
- (void)initRecognizer {
    _hasSetInfo = NO;
    self.netWorkAvailable = YES;
    if (!_audioPlayer) {
        _audioPlayer = [SPAudioPlayer sharedInstance];
    }
    if (!_speechFlushArray) {
        _speechFlushArray = [[NSMutableArray alloc] init];
    }
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
        //音频文件转文字可使用BDS_ASR_AUDIO_FILE_PATH
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
    _isCancelRecognizer = NO;
    if (self.isNeedPlayStartAudio && self.netWorkAvailable) {
        [_audioPlayer playStartAudio];
        [NSThread sleepForTimeInterval:0.1];
    }
    self.isNeedPlayStartAudio = YES;
    [self stopSpeak];
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
- (void)recognizerShortText {
#if TARGET_IPHONE_SIMULATOR
#else
    _isCancelRecognizer = NO;
    if (self.isNeedPlayStartAudio && self.netWorkAvailable) {
        [_audioPlayer playStartAudio];
        [NSThread sleepForTimeInterval:0.1];
    }
    self.isNeedPlayStartAudio = YES;
    [self stopSpeak];
    [self.speechRecognizer setParameter:@(NO) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    
    //关闭标点
    [self.speechRecognizer setParameter:@(YES) forKey:BDS_ASR_DISABLE_PUNCTUATION];
    
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
            if ([self.delegate respondsToSelector:@selector(onEndOfSpeech)]) {
                [self.delegate onEndOfSpeech];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            [self handleFlushDataResult:(NSDictionary *)aObj];
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
            [self onCancel];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            [self onError:(NSError *)aObj];
            break;
        }
        default:
            break;
    }
}


//识别结果返回代理
- (void)handleFlushDataResult:(NSDictionary *)dic {
    NSArray *array = [dic objectForKey:@"results_recognition"];
    if (array && array.count > 0) {
        NSString *string = [array firstObject];
        if (![string isEqualToString:@" "]) {
            [_speechFlushArray addObject:string];
        }
        else {
            NSDictionary *origin_result = dic[@"origin_result"];
            NSDictionary *result = origin_result[@"result"];
            NSArray *uncertain_word = result[@"uncertain_word"];
            string = [uncertain_word firstObject];
            if (string &&![string isEqualToString:@" "]) {
                [_speechFlushArray addObject:string];
            }
        }
    }
}

//识别结果返回代理
- (void)handleResult:(NSDictionary *)dic {
    _isRecognizering = NO;
    [_speechFlushArray removeAllObjects];
    NSArray *stringArray = [dic objectForKey:@"results_recognition"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onResults:type:isLast:)]) {
        [self.delegate onResults:stringArray type:_recognizeType isLast:YES];
    }
}

- (void)onError:(NSError *)error {
    NSLog(@"onError :%@",error);
    _isRecognizering = NO;
    if (_speechFlushArray.count >0) {
        //连续上屏有数据，直接返回，不返回error
        NSString *string = _speechFlushArray.lastObject;
        if (![NSString isNull:string] && ![string isEqualToString:@" "]) {
            NSArray *array = [NSArray arrayWithObject:string];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onResults:type:isLast:)]) {
                [self.delegate onResults:array type:_recognizeType isLast:YES];
            }
            [_speechFlushArray removeAllObjects];
            return;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onError:)]) {
        [self.delegate onError:(id)error];
    }
}

//开始录音回调
- (void)onBeginOfSpeech {
    [_speechFlushArray removeAllObjects];
    if ( _isCancelRecognizer) {
        return;
    }
    _isRecognizering = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginOfSpeech)]) {
        [self.delegate onBeginOfSpeech];
    }
}
//音量回调函数
- (void)onVolumeChanged:(id)obj {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onVolumeChanged:)]) {
        NSInteger volume = 0;
        if ([obj respondsToSelector:@selector(integerValue)]) {
            volume = [obj integerValue];
        }
        [self.delegate onVolumeChanged:volume];
    }
}

- (void)onCancel {
    _isCancelRecognizer = NO;
    _isRecognizering = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancel)]) {
        [self.delegate onCancel];
    }
}



#pragma mark - Interface

- (void)recognizeFirstCommond {
    _recognizeType = SpeechRecognizeFirstCommond;
    [self recognizerShortText];
}


- (void)recognizeShortText {
    _recognizeType = SpeechRecognizeShortText;
    [self recognizerShortText];
}

- (void)recognizeLongText {
    _recognizeType = SpeechRecognizeLongText;
    [self recognizerLongText];
}


- (void)recognizeMember {
    _recognizeType = SpeechRecognizeMember;
    [self recognizerShortText];
}

- (void)recognizeOption:(NSString *)optionKey {
    _recognizeType = SpeechRecognizeOption;
    [self recognizerShortText];
}

- (void)recognizeSearchColText{
    _recognizeType = SpeechRecognizeSearchColText;
    [self recognizerShortText];
}

/**
 全文检索-----非小致部分，仅用于M3全文检索
 */
- (void)recognizeFullTextSearch {
    _recognizeType = SpeechRecognizeFullTextSearch;
    [self recognizerShortText];
}


- (void)stop{
    [self stopRecognize];
    [self stopSpeak];
}

/**
 停止识别
 */
- (void)stopRecognize{
    _isCancelRecognizer = YES;
    _isRecognizering = NO;
    NSLog(@"百度停止---stopRecognize");
    [self.speechRecognizer sendCommand:BDS_ASR_CMD_CANCEL];
}


#pragma mark   语音合成
- (void)initSynthesizer {
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_OFF];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(YES) forKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:8] forKey:BDS_SYNTHESIZER_PARAM_VOLUME];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:7] forKey:BDS_SYNTHESIZER_PARAM_SPEED];
}


//机器说话结束
- (void)onSpeakEnd {
    _isSpeaking = NO;
    self.speakRemainingStr = nil;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onSpeakEnd)]) {
            [weakSelf.delegate onSpeakEnd];
        }
    });
}

- (void)speak:(NSString *)word {
    if (self.canSpeak && !_isRecognizering) {
        [self speakLongStr:word];
    }
}
//长文本播放
- (void)speakLongStr:(NSString *)word {
    NSLog(@"speakLongStr: %@",word);
#if TARGET_IPHONE_SIMULATOR
#else
    _isSpeaking = YES;
    NSError* err = nil;
    NSString *speakWord = word;
    NSInteger maxSpeak = 500;
    if (speakWord.length >maxSpeak) {
        speakWord = [word substringToIndex:maxSpeak];
        self.speakRemainingStr = [word substringFromIndex:maxSpeak];
    }
    else {
        self.speakRemainingStr = nil;
    }
    [[BDSSpeechSynthesizer sharedInstance] speakSentence:speakWord withError:&err];
#endif
}

- (BOOL)isSpeaking {
    return _isSpeaking;
}
/**
 停止播放语音
 */
- (void)stopSpeak{
    if (!_isSpeaking) {
        return;
    }
    self.speakRemainingStr = nil;
    BDSSynthesizerStatus status = [[BDSSpeechSynthesizer sharedInstance] synthesizerStatus];
    if (_isSpeaking || status == BDS_SYNTHESIZER_STATUS_WORKING) {
        [[BDSSpeechSynthesizer sharedInstance] cancel];
    }
    _isSpeaking = NO;
}


#pragma mark BDSSpeechSynthesizerDelegate
- (void)synthesizerStartWorkingSentence:(NSInteger)SynthesizeSentence {
    _isSpeaking = YES;
}

- (void)synthesizerSpeechEndSentence:(NSInteger)SpeakSentence {
    //SpeakSentence  是合成的id 目前没啥用
    if ([NSString isNull:self.speakRemainingStr]) {
        if (self.speakSuccessBlock) {
            self.speakSuccessBlock();
            [self clearBroadcastTextBlock];
            return;
        }
        [self onSpeakEnd];
    }
    else {
        [self speakLongStr:self.speakRemainingStr];
    }
}

- (void)synthesizerErrorOccurred:(NSError *)error
                        speaking:(NSInteger)SpeakSentence
                    synthesizing:(NSInteger)SynthesizeSentence {
    if (self.speakFailBlock) {
        self.speakFailBlock(error);
        [self clearBroadcastTextBlock];
        return;
    }
    [self onSpeakEnd];
}


@end


