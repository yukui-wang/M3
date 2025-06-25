//
//  SPSpeechEngine.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/14.
//
//


#import <Foundation/Foundation.h>
#import "SPConstant.h"

typedef void(^SpeechEngineSpeakSuccessBlock)(void);
typedef void(^SpeechEngineSpeakFailBlock)(NSError *error);


@protocol SPSpeechEngineDelegate <NSObject>
//识别结果返回代理
- (void)onResults:(NSArray *)result type:(SpeechRecognizeType)type isLast:(BOOL)isLast;
- (void)onError:(NSError *)error;
//停止录音回调
- (void)onEndOfSpeech;
//开始录音回调
- (void)onBeginOfSpeech;
//音量回调函数
- (void)onVolumeChanged:(NSInteger)volume;
//会话取消回调
- (void)onCancel;
//机器说话结束
- (void)onSpeakEnd;


@end

@interface SPSpeechEngine : NSObject

@property (weak, nonatomic) id<SPSpeechEngineDelegate> delegate;
@property (nonatomic) BOOL isNeedPlayStartAudio;
@property (nonatomic) BOOL isNeedPlayEndAudio;
@property (nonatomic) BOOL canSpeak;

@property (nonatomic) BOOL netWorkAvailable;

@property (nonatomic,copy) SpeechEngineSpeakSuccessBlock speakSuccessBlock;
@property (nonatomic,copy) SpeechEngineSpeakFailBlock speakFailBlock;


+ (instancetype)sharedInstance:(SPSpeechEngineType)type;
/**
设置语音 key ....
] */
- (void)setupBaseInfo:(id)info;
#pragma -mark 语音合成、识别


/**
 合成语音并播放

 @param word 带合成语音的内容
 */
- (void)speak:(NSString *)word;
//长文本播放
- (void)speakLongStr:(NSString *)word;

- (BOOL)isSpeaking;
/**
 停止播放语音
 */
- (void)stop;

/**
 停止播放语音
 */
- (void)stopSpeak;
/**
 停止识别
 */
- (void)stopRecognize;


/**
 识别短文本
 */
- (void)recognizeShortText;

- (void)recognizeSearchColText;

/**
 识别长文本
 */
- (void)recognizeLongText;

/**
 识别一级命令词
 */
- (void)recognizeFirstCommond;


/**
 识别人员
 */
- (void)recognizeMember;

/**
 识别选项
 */
- (void)recognizeOption:(NSString *)optionKey;


/**
 全文检索-----非小致部分，仅用于M3全文检索
 */
- (void)recognizeFullTextSearch;

- (void)reload;

- (void)logout;

//语音播报（小致平台中H5卡片语音播报）
- (void)broadcast:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//语音播报文本
- (void)broadcastText:(NSString *)text success:(void(^)(void))success fail:(void(^)(NSError *error))fail;
//停止语音播报文本
- (void)stopBroadcastText;
//清空语音合成block
- (void)clearBroadcastTextBlock;

@end
