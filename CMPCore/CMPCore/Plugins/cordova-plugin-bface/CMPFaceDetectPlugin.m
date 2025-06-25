//
//  CMPFacePlugin.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//

#import "CMPFaceDetectPlugin.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDevicePermissionHelper.h>

#import "CMPCore_XiaozhiBridge.h"
#import "CMPFaceManager.h"

@implementation CMPFaceDetectPlugin

/**
 {
     "domain" : "seeyoncloudv5test",
     "endpoint" : "https://faceid.seeyoncloud.com",
     "clientId" : "BM9rifoCWbM6_bEUlpuAoqpwpbWL4cx5",
     "clientSecret" : "L_4PJU6Qf6dA4401rgOYdHmJEZ3rWVJh",
     "userName" : "raosj",
     //"password" : "qwer1234"
 }
 */

//faceEE 旷视人脸检测验证
- (void)faceEECheck:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    
    [[CMPFaceManager sharedInstance] faceEECheckWithDict:param inVC:self.viewController detectCompletion:^(NSInteger statusCode, NSString *message,NSString *qrCodeId,NSInteger type) {
        //h5->先判断code==200，再判断type，错误提示只在error和非200的情况
        //type=1认证成功 type=2录入成功 type=0错误 type=-1(用户主动取消：协议不同意、人脸录入取消、验证人脸取消)
        CDVCommandStatus status = statusCode == 200?CDVCommandStatus_OK:CDVCommandStatus_ERROR;
        if (statusCode == 9027) {//协议弹框点击了[不同意并退出]9,027-FACEIAL_BIOMETRICS_FIRST_TIME_USE_NOTIFICATION-用户已取消
            type = -1;
            message = @"";//用户已取消置为空字符串，前端调用后不会提示
        }else if (statusCode == 9008){//9,008 - USER_CANCELLATION - 认证流程已取消
            type = -1;
            message = @"";
        }else if(statusCode == 9029){ //9,029-MOBILE_CAMERA_AUTHORIZATION_REQUIRED-您需要开启摄像头权限后使用刷脸功能（摄像头权限）
            type = -1;
            message = @"";
        }else if (statusCode == 501){//外置条件不符合使用人脸的情况
            type = -1;
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsDictionary:@{@"code":@(statusCode),@"type":@(type),@"message":message?:@"数据异常",@"qrCodeId":qrCodeId?:@""}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
           
    }];
}


- (void)bfaceActonWithCommand:(CDVInvokedUrlCommand *)command type:(NSInteger)handleType {
    __weak typeof(self) weakSelf = self;
    [CMPDevicePermissionHelper permissionsForPhotosTrueCompletion:^{
        [weakSelf bfaceWithCommand:command type:handleType];
    } falseCompletion:^{
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:60001], @"code",@"Has no access to camera", @"message",@"",@"detail", nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } showAlert:NO];
}

- (void)bfaceWithCommand:(CDVInvokedUrlCommand *)command type:(NSInteger)handleType {
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = command.arguments[0];
    NSString *userId = [CMPCore sharedInstance].userID;
    NSString *groupId = [CMPCore sharedInstance].serverID;
    [CMPCore_XiaozhiBridge showFaceDetectionView:groupId useId:userId vc:self.viewController handleType:handleType params:params completion:^(NSDictionary *result,NSError *error) {
        if (error) {
            NSNumber *code = [NSNumber numberWithInteger:60003];
            NSDictionary *errorDic= @{@"code" :code,
                                      @"message" : error.domain,
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    } cancel:^{
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:60002], @"code",@"cancel", @"message",@"",@"detail", nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)create:(CDVInvokedUrlCommand *)command {
    [self bfaceActonWithCommand:command type:1];
}

- (void)update:(CDVInvokedUrlCommand *)command {
    [self bfaceActonWithCommand:command type:2];
}

- (void)remove:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = command.arguments[0];
    NSString *useId = dic[@"useId"];
    if ([NSString isNull:useId]) {
        useId  = [CMPCore sharedInstance].userID;
    }
    __weak typeof(self) weakSelf = self;
    NSString *groupId = [CMPCore sharedInstance].serverID;
    [CMPCore_XiaozhiBridge removeFace:groupId useId:useId completion:^(NSDictionary *result,NSError *error) {
        if (error) {
            NSNumber *code = [NSNumber numberWithInteger:60003];
            NSDictionary *errorDic= @{@"code" :code,
                                      @"message" : error.domain,
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)obtain:(CDVInvokedUrlCommand *)command {
    [self bfaceActonWithCommand:command type:3];
}

- (void)check:(CDVInvokedUrlCommand *)command {
    [self bfaceActonWithCommand:command type:4];
}

- (void)registered:(CDVInvokedUrlCommand *)command {
    NSString *useId  = [CMPCore sharedInstance].userID;
    NSString *groupId = [CMPCore sharedInstance].serverID;

    __weak typeof(self) weakSelf = self;
    [CMPCore_XiaozhiBridge isRegisteredFace:groupId useId:useId completion:^(NSDictionary *result,NSError *error) {
        if (error) {
            NSNumber *code = [NSNumber numberWithInteger:60003];
            NSDictionary *errorDic= @{@"code" :code,
                                      @"message" : error.domain,
                                      @"detail" : @""};
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}


- (void)hasPermission:(CDVInvokedUrlCommand *)command {
    BOOL success = [CMPCore_XiaozhiBridge hasFacePermission];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:success],@"success", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)dealloc {
    [CMPCore_XiaozhiBridge cleanFaceData];
    [super dealloc];
}


@end
