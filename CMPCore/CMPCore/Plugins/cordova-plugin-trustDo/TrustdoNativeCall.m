//
//  TrustdoNativeCall.m
//  M3
//
//  Created by wangxinxu on 2019/2/20.
//

#import "TrustdoNativeCall.h"
#import <Mokey_SDK_FrameWork/Mokey_SDK_FrameWork.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "CMPLocalAuthenticationTools.h"

#define MokeyActivateSuccess @"MokeyActivateSuccess"
#define MokeyCertExpire @"MokeyCertExpire"

// 手机盾原生调用SDK逻辑
@implementation TrustdoNativeCall

static TrustdoNativeCall *_instance;

+ (TrustdoNativeCall *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}
// 获取调用手机盾数据
// type：0 激活 1登录 2 重置 3修改口令 4更新证书
- (void)mokeyNativeCallWithDic:(NSDictionary *)dic {
    NSString *mokeyServerCert = [NSString stringWithFormat:@"%@", [dic objectForKey:@"cert"]];
    NSString *mokeyServerUrl = [NSString stringWithFormat:@"%@", [dic objectForKey:@"url"]];
    NSString *keyIdStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"keyId"]];
    NSString *eventDataStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eventData"]];
    NSString *typeStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"type"]];

    NSData *data = [[NSData alloc]initWithBase64EncodedString:mokeyServerCert options:NSDataBase64DecodingIgnoreUnknownCharacters];

    MoKey_SDK *moKey_sdk = [[MoKey_SDK alloc] initWithRootPath:mokeyServerUrl httpsCert:data];

//    if([CMPLocalAuthenticationTools supportType] != CMPLocalAuthenticationTypeNone){
//        UIAlertView *swithAlertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您暂时还没有开启touch ID，请去系统设置-Touch ID与密码中添加Touch ID来开启此功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [swithAlertview show];
//    } else {
    
    CMPLocalAuthenticationType supportType = [CMPLocalAuthenticationTools supportType];
        if (supportType != CMPLocalAuthenticationTypeNone) {
            BOOL isEnrolled = [CMPLocalAuthenticationTools isEnrolled];
            if (isEnrolled == NO) {
                return;
            }
        }
        
        // 退出后再登录确定为手机盾的操作
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"Mokey" forKey:kNotificationName_MokeyGetUseState];
        [userDefaults synchronize];

        if ([typeStr isEqualToString:@"0"]) {
            // 激活
            [moKey_sdk MK_activateWithMKKeyId:keyIdStr ActivateResult:^(int errorCode) {
                if (errorCode == 0) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", nil];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:MokeyActivateSuccess
                     object:dic];
                } else {
                    if (errorCode != 400128) {
                        [self MokeyShowErrorWithErrorCode:errorCode];
                    }
                }
                 [self setMokey_Get_User];
            }];
        } else if ([typeStr isEqualToString:@"1"]) {
            // 登录
            [moKey_sdk MK_doUserLoginWithMKKeyId:keyIdStr EventData:eventDataStr UserLoginResult:^(int errorCode, NSString *accToken) {
                if (errorCode == 0) {
                    NSDictionary *loginSuccessDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", accToken, @"message", nil];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kNotificationName_MokeyLoginSuccess
                     object:loginSuccessDic];
                } else {
                    if (errorCode != 400128) {
                        if (errorCode == 811035) {
                            // 证书已过期
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                message:SY_STRING(@"login_mokey_error_certexpire")
                                delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"确定", nil];
                            alertView.tag = 1000;
                            [alertView show];

                        } else {
                            [self MokeyShowErrorWithErrorCode:errorCode];
                        }
                    }
                }
                 [self setMokey_Get_User];
            }];
        } else if ([typeStr isEqualToString:@"2"]) {
            // 重置
            [moKey_sdk MK_doUserResetWithMKKeyId:keyIdStr EventData:eventDataStr UserResetResult:^(int errorCode) {
                if (errorCode == 0) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", SY_STRING(@"mokey_userReset_success"), @"message", nil];

                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kNotificationName_MokeySDKNotification
                     object:dic];
                } else {
                    if (errorCode != 400128) {
                        [self MokeyShowErrorWithErrorCode:errorCode];
                    }
                }
                 [self setMokey_Get_User];
            }];
        }  else if ([typeStr isEqualToString:@"4"])  {
            // 更新证书
            [moKey_sdk MK_doUserUpdateWithKeyId:keyIdStr EventData:eventDataStr UserUpdateResult:^(int errorCode) {
                if (errorCode == 0) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0], @"code", SY_STRING(@"mokey_updateCert_success"), @"message", nil];

                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kNotificationName_MokeySDKNotification
                     object:dic];

                } else {
                    if (errorCode != 400128) {
                        [self MokeyShowErrorWithErrorCode:errorCode];
                    }
                }
                [self setMokey_Get_User];
            }];
        } else {
            [self setMokey_Get_User];
        }
    //}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    if (alertView.tag == 1000 && buttonIndex == 1) {
        NSDictionary *certDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:811035], @"code", SY_STRING(@"login_mokey_error_certexpire"), @"message", nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:MokeyCertExpire
         object:certDic];
    }
}

-(void)setMokey_Get_User {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:kNotificationName_MokeyGetUseState];
    [userDefaults synchronize];
}

#pragma mark 是否支持指纹
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

#pragma mark 错误提示语
-(void)MokeyShowErrorWithErrorCode:(NSInteger )errorCode {
    if (errorCode == 460105) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", SY_STRING(@"login_mokey_error_beenbound"), @"message", nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificationName_MokeySDKNotification
         object:dic];
    } else if (errorCode == 811018) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", SY_STRING(@"login_mokey_error_qrcodefailure"), @"message", nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificationName_MokeySDKNotification
         object:dic];
    } else if (errorCode == 811033) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", SY_STRING(@"reset_mokey_error_account_atypism"), @"message", nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificationName_MokeySDKNotification
         object:dic];
    } else {
        [MoKey_SDK MK_getErrMsgWithErrorCode:errorCode ErrMsg:^(NSString *errMsg) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:errorCode], @"code", errMsg, @"message", nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kNotificationName_MokeySDKNotification
             object:dic];
        }];
    }
}

@end
