//
//  CMPSpeechPlugin.m
//  M3
//
//  Created by wujiansheng on 2019/3/25.
//

#import "CMPSpeechPlugin.h"
#import "CMPCore_XiaozhiBridge.h"
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPFileManager.h>

@interface CMPSpeechPlugin ()

@property(nonatomic, retain) NSDictionary *params;
@property(nonatomic, copy)   NSString     *callbackId;

@end

@implementation CMPSpeechPlugin

- (void)dealloc {
    //清空语音合成block
    [CMPCore_XiaozhiBridge clearBroadcastTextBlock];
    self.params = nil;
    self.callbackId = nil;
}

- (void)command:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    NSDictionary *args = [command.arguments lastObject];
    self.params = args;

    if (![args isKindOfClass:[NSDictionary class]]) {
        [self sendPluginResult:59002 message:@"param必须是字典" detail:@""];
        return;
    }
    NSArray *keyArray = args.allKeys;
    if (keyArray.count == 0) {
        [self sendPluginResult:59002 message:@"没有命令词" detail:@""];
        return;
    }
    for (NSString *key in keyArray) {
        if ([NSString isNull:key]) {
            [self sendPluginResult:59002 message:@"key不能为NULL" detail:@""];
            return;
        }
    }
    NSArray *valueArray = args.allValues;
    for (NSString *vaule in valueArray) {
        if (![vaule isKindOfClass:[NSArray class]]) {
            [self sendPluginResult:59002 message:@"value必须是数组" detail:@""];
            return;
        }
    }
    __weak typeof(self) weakSelf = self;
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        [weakSelf showSpeechViewWithType:1 endBlock:^(NSString *result, BOOL finish,UIView *speechView) {
            if ([weakSelf handleCommandResult:result speechView:speechView]) {
                [weakSelf removeSpeechView];
            }
        } cancelBlock:^{
            [weakSelf removeSpeechView];
            [weakSelf sendPluginResult:59003 message:@"cancel" detail:@""];
        }];
    } falseCompletion:^{
        [weakSelf sendPluginResult:59001 message:@"没有录音权限" detail:@""];
    }];
}

- (BOOL)handleCommandResult:(NSString *)resultStr speechView:(UIView *)speechView {
    NSArray *paramsKeys = [self.params allKeys];
    for (NSString *key in  paramsKeys) {
        NSArray *valueArray = self.params[key];
        if ([valueArray containsObject:resultStr]) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:key,@"key",resultStr,@"word", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
            return YES;
        }
    }
    [speechView cmp_showHUDWithText:@"未能识别到命令"];
//    [self sendPluginResult:59002 message:@"未能识别到命令" detail:@""];
    return NO;
}


- (void)sendPluginResult:(NSInteger)code message:(NSString *)msg detail:(NSString *)detail {
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:code], @"code",msg, @"message",detail,@"detail", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)inputing:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    __weak typeof(self) weakSelf = self;
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        [weakSelf showSpeechViewWithType:2 endBlock:^(NSString *result, BOOL finish,UIView *speechView) {
            if (finish) {
                [weakSelf removeSpeechView];
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:result?result:@"",@"content",[NSNumber numberWithBool:finish],@"finish", nil];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
            [pluginResult setKeepCallbackAsBool:YES];
            [weakSelf.commandDelegate  sendPluginResult:pluginResult callbackId:weakSelf.callbackId];
           
        } cancelBlock:^{
            [weakSelf removeSpeechView];
            [weakSelf sendPluginResult:59003 message:@"cancel" detail:@""];
        }];
        
    } falseCompletion:^{
        [weakSelf sendPluginResult:59001 message:@"没有录音权限" detail:@""];
    }];
}


- (void)showSpeechViewWithType:(NSInteger) type
                      endBlock:(void (^)(NSString *result, BOOL finish, UIView *speechView))endBlock
                   cancelBlock:(void(^)(void))cancelBlock {
//    [self removeSpeechView];
    [CMPCore_XiaozhiBridge showSpeechViewInView:self.viewController.view Type:type endBlock:endBlock cancelBlock:cancelBlock];
}

- (void)removeSpeechView {
    [CMPCore_XiaozhiBridge removeSpeechView];
}


//语音播报（文字转语音）
- (void)broadcastText:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    NSDictionary *args = [command.arguments lastObject];
    NSString *text = args[@"text"];//需要播报的文本
    if ([NSString isNull:text]) {
        [self sendPluginResult:59004 message:@"播报文本不能为空" detail:@""];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [CMPCore_XiaozhiBridge broadcastText:text success:^{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.callbackId];
    } fail:^(NSError *error) {
        NSString *msg = error.domain?:@"";
        [weakSelf sendPluginResult:59005 message:msg detail:@""];
    }];
}

//停止语音播报
- (void)stopBroadcastText:(CDVInvokedUrlCommand *)command {
    [CMPCore_XiaozhiBridge stopBroadcastText];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

//语音组件权限校验
- (void)checkPermission:(CDVInvokedUrlCommand *)command {
    NSString *key = @"hasVoicePermission";
    NSArray *keys = [NSArray arrayWithObjects:key, nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    BOOL hasPermission = [dic[key] boolValue];
    NSDictionary *resultDic = @{@"success":[NSNumber numberWithBool:hasPermission]};
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)obtainSpeechReplyFile:(CDVInvokedUrlCommand *)command {
    //todo 插件名称还没定
    self.callbackId = command.callbackId;
    __weak typeof(self) weakSelf = self;
    NSString *path = [NSString stringWithFormat:@"%@/spr_%@.wav", [CMPFileManager fileTempPath],[NSString uuid]];
    [CMPCore_XiaozhiBridge speechReplyWithFilePath:path flushStrBlock:^(NSString *flushStr) {
        
    } completeBlock:^(NSString *filePath, NSString *resultStr) {
        NSString *path = [NSString stringWithFormat:@"file://%@",filePath];
        NSDictionary *resultDic = @{@"filepath":path,@"text":resultStr};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    } errorBlock:^(NSError *error) {
        [weakSelf sendPluginResult:59005 message:@"识别错误" detail:@""];
    }];
}
//语音回复，返回文本
- (void)obtainSpeechReplyText:(CDVInvokedUrlCommand *)command {
    //todo 插件名称还没定
    self.callbackId = command.callbackId;
    __weak typeof(self) weakSelf = self;
    [CMPCore_XiaozhiBridge speechReplyWithFilePath:nil flushStrBlock:^(NSString *flushStr) {
        NSDictionary *resultDic = @{@"text":flushStr,@"finish":[NSNumber numberWithBool:NO]};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [result setKeepCallbackAsBool:YES];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        
    } completeBlock:^(NSString *filePath, NSString *resultStr) {
        NSDictionary *resultDic = @{@"text":@"",@"finish":[NSNumber numberWithBool:YES]};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [result setKeepCallbackAsBool:YES];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:self.callbackId];

    } errorBlock:^(NSError *error) {
        [weakSelf sendPluginResult:59005 message:@"识别错误" detail:@""];
    }];
}
//语音回复停止
- (void)stopSpeechReply:(CDVInvokedUrlCommand *)command{
    //todo 插件名称还没定
    [CMPCore_XiaozhiBridge stopSpeechReply];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//语音回复取消
- (void)cancelSpeechReply:(CDVInvokedUrlCommand *)command{

    [CMPCore_XiaozhiBridge cancelSpeechReply];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)getXiaozIntents:(CDVInvokedUrlCommand *)command{
    NSString *key = @"intentNames";
    NSArray *keys = [NSArray arrayWithObjects:key, nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    NSArray *intents = dic[key];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:intents];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//其他模块打卡小致
- (void)openXiaoz:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    __weak typeof(self) weakSelf = self;
    NSString *callbackId = command.callbackId;
    NSDictionary *args = [command.arguments lastObject];
    NSString *openFrom = args[@"openFrom"];
    
    void(^returnBlock)(NSString *) = ^(NSString *question) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString isNull:question]?@"":question,@"question", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:callbackId];
    };
    [dic setObject:self.viewController forKey:@"pushVC"];
    if (![NSString isNull:openFrom] && [openFrom isEqualToString:@"fullsearch"]) {
        [dic setObject:returnBlock forKey:@"returnBlock"];
    }
    else {
        returnBlock(@"");
    }
    [CMPCore_XiaozhiBridge openXiaoz:dic];
}
@end
