//
//  CMPGesturePlugin.m
//  CMPCore
//
//  Created by youlin on 16/7/12.
//
//

#import "GestureLockPlugin.h"
#import "CMPGestureHelper.h"
#import <CMPLib/JSON.h>
#import <CMPLib/CMPConstant.h>
#import "M3LoginManager.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import "AppDelegate.h"

@interface GestureLockPlugin()<CMPGestureHelperDelegate>
{
}

@property (nonatomic, copy)NSString *callbackId;

@end

@implementation GestureLockPlugin

- (void)dealloc
{
    self.callbackId = nil;
//    [CMPGestureHelper shareInstance].delegate = nil;
    [super dealloc];
}


- (void)pluginInitialize
{
    [super pluginInitialize];
    [CMPGestureHelper shareInstance].delegate = nil;
}

//*****************插件*******************

//用于h5获取本地存储的手势密码
- (void)getUserGesturePassword:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSString *ges = [CMPGestureHelper shareInstance].gesturePwd;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ges];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

//设置手势密码后台时间
- (void)registerTimeInterval:(CDVInvokedUrlCommand *)command
{
//    self.callbackId = command.callbackId;
//    NSDictionary *aDict = [command.arguments lastObject];
//    if (aDict) {
//        NSInteger interval = [[aDict objectForKey:@"timeInterval"] integerValue];
//        [[CMPGestureHelper shareInstance] setTimeInterval:interval?interval : 300];
//    }
    // 没有必要让前端设置
//    [[M3LoginManager sharedInstance].loginDBProvider setGesturePassword:[CMPGestureHelper shareInstance].gesturePwd
//                                                               serverID:[CMPCore sharedInstance].serverID
//                                                              loginName:[CMPCore sharedInstance].currentUser.loginName];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

//注销后台设置
- (void)unRegisterTimeInterval:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    [CMPGestureHelper shareInstance].gesturePwd = @"";
    [CMPGestureHelper shareInstance].gesSwitchState = NO;
    // 关闭手势密码
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    NSString *aUserID = [CMPCore sharedInstance].userID;
    [[CMPCore sharedInstance].loginDBProvider updateGesturePassword:nil serverID:aServerId userID:aUserID gestureMode:CMPLoginAccountModelGestureClose];
    [[CMPCore sharedInstance] setup];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

//关闭手势密码插件
- (void)closeGestureLock:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    [[CMPGestureHelper shareInstance] closeGestureViewWithType:TYPE_NORMAL];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

//设置手势密码插件
- (void)setGestureLock:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSDictionary *aDict = [command.arguments lastObject];
    [[CMPGestureHelper shareInstance] showGestureViewWithDelegate:self from:FROM_INIT object:aDict ext:nil];
}

//校验手势密码插件
- (void)verifyGestureLock:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSDictionary *aDict = [command.arguments lastObject];
    [[CMPGestureHelper shareInstance] showGestureViewWithDelegate:self from:FROM_VERIFY object:aDict ext:nil];
}

// 获取当前手势状态
- (void)gestureState:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSInteger aState = [CMPCore sharedInstance].currentUser.gestureMode;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:aState];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

//*****************插件*******************

//*****************代理*******************
#pragma -mark CMPGestureViewControllerDelegate
- (void)gestureHelperDidFail:(CMPGestureHelper *)aHelper
{
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25007],@"code",SY_STRING(@"parameters_error"),@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperSkip:(CMPGestureHelper *)aHelper
{
    //跳过
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25001],@"code",SY_STRING(@"gesture_clicked_skip"),@"message",@"1",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperReturn:(CMPGestureHelper *)aHelper
{
    //返回
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25002],@"code",SY_STRING(@"gesture_clicked_return"),@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelper:(CMPGestureHelper *)aHelper didSetPassword:(NSString *)password
{
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSString *aServerId = [CMPCore sharedInstance].serverID;
    NSString *aUserID = [CMPCore sharedInstance].userID;
    [[CMPCore sharedInstance].loginDBProvider updateGesturePassword:password serverID:aServerId userID:aUserID gestureMode:CMPLoginAccountModelGestureOpen];
    
    [[CMPCore sharedInstance] setup];
    
    [CMPCore sharedInstance].currentUser.gestureMode = CMPLoginAccountModelGestureOpen;
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:password];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperDidGetCorrectPswd:(CMPGestureHelper *)aHelper {
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperDidGetIncorrectPswd:(CMPGestureHelper*)aHelper
{
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25004],@"code",@"验证失败",@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperForgetPswd:(CMPGestureHelper *)aHelper inputPassword:(NSString *)password
{
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25006],@"code",SY_STRING(@"gesture_clicked_forgot"),@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)gestureHelperOtherVerify:(CMPGestureHelper *)aHelper
{
    [AppDelegate shareAppDelegate].allowRotation =  ((CMPBannerWebViewController *)self.viewController).allowRotation;
    NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:25003],@"code",SY_STRING(@"gesture_clicked_right"),@"message",@"",@"detail", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

@end
