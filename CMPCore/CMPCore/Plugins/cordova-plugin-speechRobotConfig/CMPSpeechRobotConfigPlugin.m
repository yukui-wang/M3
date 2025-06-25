//
//  CMPSpeechSettingPlugin.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/20.
//
//

#import "CMPSpeechRobotConfigPlugin.h"
#import "CMPCore_XiaozhiBridge.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPConstant.h>
#import "AppDelegate.h"
#import "CMPPadTabBarViewController.h"

@interface CMPSpeechRobotConfigPlugin ()
@property(nonatomic, copy)   NSString     *callbackId;
@end

@implementation CMPSpeechRobotConfigPlugin

- (void)setRobotOnOffState:(CDVInvokedUrlCommand *)command{
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:args[@"isOnOff"],@"isOnOff", nil];
    [CMPCore_XiaozhiBridge updateSpeechRobotConfig:params];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)getRobotOnOffState:(CDVInvokedUrlCommand *)command{
    NSArray *keys = [NSArray arrayWithObjects:@"isOnOff", nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}



- (void)setRobotAssistiveTouchOnShowState:(CDVInvokedUrlCommand *)command{
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:args[@"isOnShow"],@"isOnShow", nil];
    [CMPCore_XiaozhiBridge updateSpeechRobotConfig:params];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)getRobotAssistiveTouchOnShowState:(CDVInvokedUrlCommand *)command {
    NSArray *keys = [NSArray arrayWithObjects:@"isOnShow", nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}



- (void)setRobotAutoAwakeState:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:args[@"isAutoAwake"],@"isAutoAwake", nil];
    [CMPCore_XiaozhiBridge updateSpeechRobotConfig:params];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)getRobotAutoAwakeState:(CDVInvokedUrlCommand *)command {
    NSArray *keys = [NSArray arrayWithObjects:@"isAutoAwake", nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setRobotWorkTime:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:args[@"startTime"],@"startTime",args[@"endTime"],@"endTime", nil];
    [CMPCore_XiaozhiBridge updateSpeechRobotConfig:params];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)getRobotWorkTime:(CDVInvokedUrlCommand *)command{
    NSArray *keys = [NSArray arrayWithObjects:@"startTime",@"endTime", nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


-(void)getRobotConfig:(CDVInvokedUrlCommand *)command
{
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainXiaozhiSettings];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


-(void)toggleShowAssistiveTouchOnPageSwitch:(CDVInvokedUrlCommand *)command
{
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:args[@"showOrNot"],@"showOrNot", nil];
    [CMPCore_XiaozhiBridge updateSpeechRobotConfig:params];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


//小致权限
- (void)checkXiaoZhiPermission:(CDVInvokedUrlCommand *)command
{
    NSArray *keys = [NSArray arrayWithObjects:@"showInSetting", nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    BOOL showInSetting = [dic[@"showInSetting"] boolValue];
    if (showInSetting) {
        NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"sucess",@"1", @"status", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:57001], @"code",@"", @"message",@"",@"detail", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict ];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getSpeechInput:(CDVInvokedUrlCommand *)command {
    NSDictionary *speechInput = [CMPCore_XiaozhiBridge obtainSpeechInput:self.viewController];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:speechInput];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setMessageSwitch:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    [CMPCore_XiaozhiBridge updateMsgSwitchInfo:args];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//QA之类 h5打开小致-智能助手
- (void)openRobot:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *param = args[@"params"];
    NSString *intentId = param[@"intentId"];
    if ([intentId isKindOfClass:[NSNumber class]]) {
        NSNumber *number = param[@"intentId"];
        intentId = [number stringValue];
    }
    [CMPCore_XiaozhiBridge showQAWithIntentId:intentId];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

//语音播报（小致平台中H5卡片语音播报）
- (void)broadcast:(CDVInvokedUrlCommand *)command {
    //受小致界面静音按钮控制
    self.callbackId = command.callbackId;
    NSDictionary *args = [command.arguments lastObject];
    NSString *text = args[@"text"];//需要播报的文本
    NSLog(@"!!!!broadcast :%@",text);
    if ([NSString isNull:text]) {
        [self sendPluginResult:59004 message:@"播报文本不能为空" detail:@""];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [CMPCore_XiaozhiBridge broadcast:text success:^{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.callbackId];
    } fail:^(NSError *error) {
        NSString *msg = error.domain?:@"";
        [weakSelf sendPluginResult:59005 message:msg detail:@""];
    }];
}

- (void)sendPluginResult:(NSInteger)code message:(NSString *)msg detail:(NSString *)detail {
    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:code], @"code",msg, @"message",detail,@"detail", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:self.callbackId];
}



- (void)openPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSDictionary *params =@{
        @"params":args[@"params"],
        @"viewController":self.viewController
    };
    
    [CMPCore_XiaozhiBridge showWebViewWithParam:params];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

//打开语音速记
- (void)openShorthand:(CDVInvokedUrlCommand *)command {
//    XZShortHandListViewController *vc = [[XZShortHandListViewController alloc] init];
//    if (self.viewController.navigationController) {
//        [self.viewController.navigationController pushViewController:vc animated:YES];
//    }
//    else {
//        [self.viewController presentViewController:vc animated:YES completion:nil];
//    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}
//可选项卡片：设置选中的选项对当前意图
- (void)setOptionValue:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    [CMPCore_XiaozhiBridge setOptionValue:args controller:self.viewController];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//可选项卡片：设置选中的选项对下一个意图
- (void)nextIntent:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    [CMPCore_XiaozhiBridge nextIntent:args controller:self.viewController];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//可选项卡片：设置选择命令词
- (void)setOptionCommands:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    self.callbackId = command.callbackId;
    __weak typeof(self) weakSelf = self;
    [CMPCore_XiaozhiBridge setOptionCommands:args controller:self.viewController block:^(NSString *key, NSString *word) {
        if (key) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:key,@"key",word,@"word", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.callbackId];
        }
        else {
            [weakSelf sendPluginResult:57002 message:@"没有识别到命令词" detail:@""];
        }
    }];
}

- (void)webviewChangeHeight:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSString *height = args[@"height"];
    [CMPCore_XiaozhiBridge webviewChangeHeight:height controller:self.viewController];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)passOperationText:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSString *text = args[@"text"];
    [CMPCore_XiaozhiBridge passOperationText:text controller:self.viewController];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
- (void)openQAPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:args];
    [dic setObject:self.viewController forKey:@"pushVC"];
    [CMPCore_XiaozhiBridge openQAPage:dic];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
- (void)xiaozOpenQAPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *args = [command.arguments lastObject];
    [CMPCore_XiaozhiBridge callXiaozMethod:@"xiaozOpenQAPage:" params:args];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}



- (void)openAllSearchPage:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *callbackId = command.callbackId;
    NSDictionary *args = [command.arguments lastObject];
    [CMPCore_XiaozhiBridge openAllSearchPage:args];
    if (INTERFACE_IS_PAD) {
        CMPPadTabBarViewController *tabbar = (CMPPadTabBarViewController *)[[AppDelegate shareAppDelegate] tabBarViewController];
        if ([tabbar isKindOfClass:[CMPPadTabBarViewController class]]) {
            [tabbar openAllSearchPage4Xiaoz:args];
        }
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];

}


- (void)getShortCutIds:(CDVInvokedUrlCommand *)command {
    NSString *key = @"shortCutIds";
    NSArray *keys = [NSArray arrayWithObjects:key, nil];
    NSDictionary *dic = [CMPCore_XiaozhiBridge obtainSpeechRobotConfig:keys];
    NSLog(@"getShortCutIds:");

    NSArray *ids = dic[key];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:ids];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


@end
