//
//  CMPVoicePlugin.m
//  M3
//
//  Created by 程昆 on 2019/12/19.
//

#import "CMPVoicePlugin.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPCustomAlertView.h>
#import <CMPLib/CMPDateHelper.h>

@interface CMPVoicePlugin ()

@property (nonatomic,strong)NSMutableDictionary *recordCacheDic;

@property (nonatomic, strong) AVAudioSession* avSession;

@end

@implementation CMPVoicePlugin

#pragma mark - 插件

/// 开始录音
/// @param command
- (void)startRecord:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *recordId = param[@"recordId"];
    
    __block CDVPluginResult *pluginResult;
    if ([NSString isNull:recordId]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        dispatch_semaphore_signal(semaphore);
    }  falseCompletion:^{
        id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:SY_STRING(@"audio_component_no_permission") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_goto_setting")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
            if (buttonIndex == 1) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        [alert setTheme:CMPTheme.new];
        [alert show];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有录音权限"];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (pluginResult) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSString *voiceRecordFilePath = [self.recordCacheDic objectForKey:recordId][@"voiceRecordFilePath"];
    if ([NSString isNotNull:voiceRecordFilePath]) {
        //停止录音
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AudioRecorderWillStop object:nil];
        AVAudioRecorder *recorder = [self.recordCacheDic objectForKey:recordId][@"recorder"];
        [recorder stop];
        [self.avSession setActive:NO error:nil];
        [self.recordCacheDic removeObjectForKey:recordId];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"重复录制"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSError* __autoreleasing error = nil;
    if (![self.avSession.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        [self.avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    }
    
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"初始化播放失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    if (![self.avSession setActive:YES error:&error]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"初始化播放失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"初始化播放失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    //添加百度语音识别音频配置 要求 采样率 ：16000 固定值。 编码：16bit 位深的单声道。
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:16000] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    voiceRecordFilePath = [self voiceRecordFilePath];
    NSURL *resourceURL = [NSURL URLWithString:voiceRecordFilePath];
    if(!resourceURL){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"音频文件路径出错"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:resourceURL settings:settings error:&error];
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"初始化播放失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *recordDic = @{
        @"voiceRecordFilePath" : voiceRecordFilePath,
        @"recorder" : recorder
    };
    [self.recordCacheDic setObject:recordDic forKey:recordId];
    
    //开始录音
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AudioRecorderWillRecording object:nil];
    BOOL recordingSuccess = [recorder record];
    
    if (!recordingSuccess) {
        [self.recordCacheDic removeObjectForKey:recordId];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"录制失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    
}

/// 结束录音
/// @param command
- (void)stopRecord:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *recordId = param[@"recordId"];
    
    CDVPluginResult *pluginResult;
    NSString *voiceRecordFilePath = [self.recordCacheDic objectForKey:recordId][@"voiceRecordFilePath"];
    if ([NSString isNull:voiceRecordFilePath]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"结束录制不存在的录音"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AudioRecorderWillStop object:nil];
    AVAudioRecorder *recorder = [self.recordCacheDic objectForKey:recordId][@"recorder"];
    [recorder stop];
    [self.avSession setActive:NO error:nil];
    [self.recordCacheDic removeObjectForKey:recordId];
     
    NSString *filepath = voiceRecordFilePath;
    NSString *type = filepath.pathExtension;
    NSString *size = [NSString stringWithLongLong:[CMPFileManager fileSizeAtPath:filepath]];
    NSDictionary *dic = @{
        @"filepath" : filepath,
        @"type" : type,
        @"fileSize" : size
    };
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

/// 播放录音
/// @param command
//- (void)playVoiceRecord:(CDVInvokedUrlCommand *)command {
//
//}

#pragma mark - 私有方法

#pragma mark - lazy

- (NSMutableDictionary *)recordCacheDic {
    if (!_recordCacheDic) {
        _recordCacheDic = [NSMutableDictionary dictionary];
    }
    return _recordCacheDic;
}

- (AVAudioSession *)avSession {
    if (!_avSession) {
       _avSession = [AVAudioSession sharedInstance];
    }
    return _avSession;
}

#pragma mark - 业务方法

- (NSString *)voiceRecordFilePath {
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *date = [CMPDateHelper currentDateNumberFormatter];
    NSString *fileName = [NSString stringWithFormat:@"audio_%@.wav",date];
    NSString *recordFilePath = [tmpPath stringByAppendingPathComponent:fileName];
    return recordFilePath;
}

//#pragma mark - AVAudioRecorderDelegate
//
//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag {
//    
//   
//}

@end
