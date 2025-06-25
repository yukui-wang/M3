//
//  IATBaiduHelper.m
//  M3
//
//  Created by wujiansheng on 2017/12/12.
//

#import "IATBaiduHelper.h"
#import "SPBaiduSpeechEngine.h"

@interface IATBaiduHelper ()<SPSpeechEngineDelegate> {
    BOOL  _isListening;
}
@property (nonatomic, retain)NSMutableString   * curResult;//当前session的结果
@property (nonatomic, retain)SPBaiduSpeechEngine *speechEngine;
@end

@implementation IATBaiduHelper


- (instancetype) init {
    self = [super init];
    if (self) {
        if (!self.speechEngine) {
            self.speechEngine = [SPBaiduSpeechEngine sharedInstance];
        }
    }
    return self;
}

-(void)startAudioSourceWithParaDic:(NSDictionary *)aDic {
    if (_isListening) {
        return;
    }
    _isListening = YES;
    self.speechEngine.delegate = self;
    self.curResult = [NSMutableString string];
    [self.speechEngine recognizeFullTextSearch];
}

-(void)buildGrammerWithParaDic:(NSDictionary *)aDic{
}

-(void)cancelVoice {
    [self.speechEngine stopRecognize];
    self.speechEngine.delegate = nil;
}

#pragma mark SPSpeechEngineDelegate
//识别结果返回代理
- (void)onResults:(NSArray *)result type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    for (NSString *string in result) {
        [self.curResult appendString:string];
    }
    if (isLast) {
        [self.curResult appendString:@"."];//会被去掉最后的字符，。。。
        NSLog(@"result is:%@",self.curResult);
        _isListening = NO;
        if ([_delegate respondsToSelector:@selector(didFinishVoiceRecognizedWithResult:)]) {
            [_delegate didFinishVoiceRecognizedWithResult:self.curResult];
        }
    }
}

- (void)onError:(NSError *)error {
    _isListening = NO;
    if ([_delegate respondsToSelector:@selector(faidWithError:)]) {
        [_delegate faidWithError:error];
    }
}

//停止录音回调
- (void)onEndOfSpeech {
}
//开始录音回调
- (void)onBeginOfSpeech {
}
//音量回调函数
- (void)onVolumeChanged:(NSInteger)volume {
}
//会话取消回调
- (void)onCancel {
}
//机器说话结束
- (void)onSpeakEnd {
}
@end
