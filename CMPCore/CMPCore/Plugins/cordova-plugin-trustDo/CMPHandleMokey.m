//
//  CMPHandleMokey.m
//  M3-InHouse
//
//  Created by wangxinxu on 2017/12/18.
//

#import "CMPHandleMokey.h"
#import <Mokey_SDK_FrameWork/Mokey_SDK_FrameWork.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <CMPLib/GTMUtil.h>
#import <CMPLib/CMPObject.h>
#import "CMPLocalAuthenticationTools.h"

@implementation CMPHandleMokey

- (void)openMokey:(CDVInvokedUrlCommand *)command
{
    // type：0 激活 1登录 2 重置 3修改口令 4更新证书 5解密
    NSDictionary *parameter = [[command arguments] lastObject];
    NSArray * url_values =  [parameter objectForKey:@"value"];

    if (url_values.count >= 2) {
        NSString *typeStr = [NSString stringWithFormat:@"%@", [url_values objectAtIndex:0]];

        NSString *keyIdStr = [NSString stringWithFormat:@"%@", [url_values objectAtIndex:1]];
        NSString *eventDataStr = nil;
        if (url_values.count >= 3) {
            eventDataStr = [NSString stringWithFormat:@"%@", [url_values objectAtIndex:2]];
        }

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *serverdic = [userDefaults objectForKey:@"Mokey_Save_CertAndUrl"];
        NSString *sdk_Url = [NSString stringWithFormat:@"%@", [serverdic objectForKey:@"url"]];
        NSString *sdk_Cert = [NSString stringWithFormat:@"%@", [serverdic objectForKey:@"cert"]];


        NSData *data = [[NSData alloc]initWithBase64EncodedString:sdk_Cert options:NSDataBase64DecodingIgnoreUnknownCharacters];

        MoKey_SDK *moKey_sdk = [[MoKey_SDK alloc] initWithRootPath:sdk_Url httpsCert:data];


//        if([self getPhoneTouchID] != YES){
//            UIAlertView *swithAlertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您暂时还没有开启touch ID，请去系统设置-Touch ID与密码中添加Touch ID来开启此功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [swithAlertview show];
//        } else {
        CMPLocalAuthenticationType supportType = [CMPLocalAuthenticationTools supportType];
        if (supportType != CMPLocalAuthenticationTypeNone) {
            BOOL isEnrolled = [CMPLocalAuthenticationTools isEnrolled];
            if (isEnrolled == NO) {
                return;
            }
        }
        
            if ([typeStr isEqualToString:@"0"]) {
                // 激活
                [moKey_sdk MK_activateWithMKKeyId:keyIdStr ActivateResult:^(int errorCode) {
                    if (errorCode == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", nil];
                        [self getSuccessDic:dic openMokey:command];

                    } else {
                        if (errorCode != 400128) {
                            [self getErrorMsgWitherrorCode:errorCode openMokey:command];
                        }
                    }
                }];
            } else if ([typeStr isEqualToString:@"1"]) {
                // 登录
                [moKey_sdk MK_doUserLoginWithMKKeyId:keyIdStr EventData:eventDataStr UserLoginResult:^(int errorCode, NSString *accToken) {
                    if (errorCode == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", accToken, @"message", nil];
                        [self getSuccessDic:dic openMokey:command];
                    } else {
                        if (errorCode != 400128) {
                            [self getErrorMsgWitherrorCode:errorCode openMokey:command];
                        }
                    }
                }];
            } else if ([typeStr isEqualToString:@"2"]) {
                // 重置
                [moKey_sdk MK_doUserResetWithMKKeyId:keyIdStr EventData:eventDataStr UserResetResult:^(int errorCode) {
                    if (errorCode == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", @"重置手机盾成功！", @"message", nil];
                        [self getSuccessDic:dic openMokey:command];
                    } else {
                        if (errorCode != 400128) {
                            [self getErrorMsgWitherrorCode:errorCode openMokey:command];
                        }
                    }
                }];
            } else if ([typeStr isEqualToString:@"3"]) {
                // 修改口令
                [moKey_sdk MK_modifyPinWithMKKeyId:keyIdStr ModifyResult:^(int errorCode) {
                    if (errorCode == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", @"修改口令成功！", @"message", nil];
                        [self getSuccessDic:dic openMokey:command];
                    } else if (errorCode == 400901) {
                        NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:400901],@"code",@"当前设备不支持口令，无需进行需改！",@"message",@"",@"detail", nil];
                        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                    } else {
                        if (errorCode != 400128) {
                            [self getErrorMsgWitherrorCode:errorCode openMokey:command];
                        }
                    }
                }];
            } else if ([typeStr isEqualToString:@"4"])  {
                // 更新证书
                [moKey_sdk MK_doUserUpdateWithKeyId:keyIdStr EventData:eventDataStr UserUpdateResult:^(int errorCode) {
                    if (errorCode == 0) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", @"更新证书成功！", @"message", nil];
                        [self getSuccessDic:dic openMokey:command];
                    } else {
                        if (errorCode != 400128) {
                            [self getErrorMsgWitherrorCode:errorCode openMokey:command];
                        }
                    }
                }];
            } else if ([typeStr isEqualToString:@"5"]) {
                // 解密
                NSString *decodeStr = [NSString stringWithFormat:@"%@", [url_values objectAtIndex:1]];

                NSString *aLoginName = [GTMUtil decrypt:decodeStr];
                NSArray *array = @[[url_values objectAtIndex:0],aLoginName];

                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        //}
    } else {
        [self getErrorMsgWitherrorCode:40406 openMokey:command];
    }
}

/* copy from persistentDbLocation to webkitDbLocation */
- (void)restore:(CDVInvokedUrlCommand*)command
{
    
}


-(void)getSuccessDic:(NSDictionary *)dic openMokey:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)getErrorMsgWitherrorCode:(NSInteger)errorCode openMokey:(CDVInvokedUrlCommand *)command {
    if (errorCode == 40406) {
        NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode],@"code",@"请求登录用户名出错",@"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else if (errorCode == 811018) {
         NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", SY_STRING(@"login_mokey_error_qrcodefailure"), @"message", @"", @"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else if (errorCode == 811033) {
        NSDictionary *errorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", SY_STRING(@"reset_mokey_error_account_atypism"), @"message", @"", @"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        [MoKey_SDK MK_getErrMsgWithErrorCode:errorCode ErrMsg:^(NSString *errMsg) {
            NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode],@"code",errMsg,@"message",@"",@"detail", nil];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

//是否支持指纹
- (BOOL)getPhoneTouchID
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return YES;
    }else {
        return NO;
    }
}

@end
