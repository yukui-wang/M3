//
//  SPSpeechEngine.m
//  封装语音识别、朗读工具接口类
//
//  Created by CRMO on 2017/2/14.
//
//

#import "SPSpeechEngine.h"
#import "SPBaiduSpeechEngine.h"

@implementation SPSpeechEngine

#pragma mark - Init

+ (instancetype)sharedInstance:(SPSpeechEngineType)type {
    switch (type) {
        case SPSpeechEngineIFly:
            NSLog(@"speech---对不起，暂不支持百度语音识别！");
            break;
            
        case SPSpeechEngineBaidu:
            return [SPBaiduSpeechEngine sharedInstance];
            break;
            
        case SPSpeechEngineSougou:
            NSLog(@"speech---对不起，暂不支持搜狗语音识别！");
            break;
            
        default:
            
            break;
    }
    return nil;
}
- (void)setupBaseInfo:(id)info {
    
}
#pragma mark - Interface

- (void)speak:(NSString *)word {
    if (self.canSpeak) {
        
    }
    return;
}
//长文本播放
- (void)speakLongStr:(NSString *)word {
    
}

- (BOOL)isSpeaking {
    return NO;
}
- (void)recognizeShortText {
    return;
}

- (void)recognizeLongText {
    return;
}

- (void)recognizeFirstCommond {
    return;
}

- (void)recognizeMember {
    return;
}

- (void)recognizeOption:(NSString *)optionKey {
    return;
}



- (void)reload
{
    
}

- (void)stop{
    
}

/**
 停止识别
 */
- (void)stopRecognize{
    
}

/**
 停止播放语音
 */
- (void)stopSpeak{
    
}



- (void)recognizeSearchColText{
    
}

/**
 全文检索-----非小致部分，仅用于M3全文检索
 */
- (void)recognizeFullTextSearch {
    
}

- (void)logout {
    
}
//语音播报（小致平台中H5卡片语音播报）
- (void)broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    if (!self.canSpeak) {
        //静音直接返回success
        if (success) {
            success();
        }
    }
    else {
        [self stopSpeak];
        self.speakSuccessBlock = success;
        self.speakFailBlock = fail;
        [self speakLongStr:text];
    }
}

//语音播报文本
- (void)broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail {
    [self stopSpeak];
    self.speakSuccessBlock = success;
    self.speakFailBlock = fail;
    [self speakLongStr:text];
}
//停止语音播报文本
- (void)stopBroadcastText {
    [self clearBroadcastTextBlock];
    [self stopSpeak];
}
//清空语音合成block
- (void)clearBroadcastTextBlock {
    self.speakSuccessBlock = nil;
    self.speakFailBlock = nil;
}

@end

