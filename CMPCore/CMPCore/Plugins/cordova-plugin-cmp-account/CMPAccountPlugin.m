//
//  CMPAccountPlugin.m
//  M3
//
//  Created by CRMO on 2018/1/22.
//

#import "CMPAccountPlugin.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPLoginResponse.h"
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/GTMUtil.h>
#import "CMPAssociateAccountListViewController.h"
#import "CMPAssociateAccountSwitchViewController.h"
#import "CMPPartTimeHelper.h"
#import "M3LoginManager.h"
#import <CMPLib/CMPFontProvider.h>
#include <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import "M3LoginManager.h"

@implementation CMPAccountPlugin

- (void)getLoginInfo:(CDVInvokedUrlCommand *)command {
    CMPLoginAccountModel *aUser = [self currentAccount];
    CMPLoginResponse *loginResponse = [CMPLoginResponse yy_modelWithJSON:aUser.loginResult];
    NSString *loginInfo = [loginResponse.data yy_modelToJSONString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:loginInfo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLoginInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [command.arguments firstObject];
    NSString *loginInfo = dic[@"loginInfo"];
    
    if ([NSString isNull:loginInfo]) {
        NSDictionary *errorDict = @{@"code" : @"0" ,
                                    @"message" : @"参数错误",
                                    @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    CMPLoginDBProvider *dbProvider = [CMPCore sharedInstance].loginDBProvider;
    CMPLoginAccountModel *aUser = [self currentAccount];
    aUser.loginResult = loginInfo;
    [dbProvider addAccount:aUser inUsed:YES];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMinStandardFont:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *dic = [command.arguments firstObject];
    CGFloat fontSize = [dic[@"size"] floatValue];
    [CMPFontProvider setMinStandardFont:fontSize];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)checkPassword:(CDVInvokedUrlCommand *)command {
    __block CDVPluginResult *pluginResult = nil;
    NSDictionary *dic = [command.arguments firstObject];
    NSString *password = dic[@"password"];
    
    if ([CMPServerVersionUtils serverIsLaterV8_2_810]) {
        //ks add -- 8.2 810
        CMPLoginAccountModelLoginType aType = [M3LoginManager sharedInstance].currentAccount.loginType;
        if (aType == CMPLoginAccountModelLoginTypeSMS) {
            [[M3LoginManager sharedInstance] verifyRemotePwd:password result:^(id respObj, NSError *err, id  _Nullable ext) {
                if (!err) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"1"];
                }else{
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"0"];
                }
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
            return;
        }
    }
    
    if ([NSString isNull:password]) {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"];
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"0"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    password = [GTMUtil encrypt:password];
    CMPLoginAccountModel *aUser = [self currentAccount];
    NSString *currentPassword = aUser.loginPassword;
    
    if ([currentPassword isEqualToString:password]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"1"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"0"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getConfigInfo:(CDVInvokedUrlCommand *)command {
    CMPLoginAccountModel *aUser = [self currentAccount];
    
//    NSString *configInfo;
//    if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
//        CMPLoginConfigInfoModel_2 *configInfoModel = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:aUser.configInfo];
//        configInfo = [configInfoModel.config yy_modelToJSONString];
//    } else {
//        CMPLoginConfigInfoModel *configInfoModel = [CMPLoginConfigInfoModel yy_modelWithJSON:aUser.configInfo];
//        configInfo = [configInfoModel.data yy_modelToJSONString];
//    }
    //直接返回从接口的数据字段config的数据
    if (aUser.configInfo) {
        NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:[aUser.configInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *config = allData[@"data"][@"config"];
        NSString *configInfo = [config yy_modelToJSONString];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:configInfo];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

- (void)getServerInfo:(CDVInvokedUrlCommand *)command {
    CMPLoginDBProvider *provider = [CMPCore sharedInstance].loginDBProvider;
    CMPServerModel *server = [provider inUsedServer];
    NSString *model = server.scheme;
    NSString *identifier = server.serverID;
    NSString *ip = server.host;
    NSString *port = server.port;
    
    if ([NSString isNull:model] ||
        [NSString isNull:identifier] ||
        [NSString isNull:ip] ||
        [NSString isNull:port]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取服务器信息错误"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *dic = @{@"model" : model,
                          @"identifier" : identifier,
                          @"ip" : ip,
                          @"port" : port};
    NSString *result = [dic yy_modelToJSONString];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openAssociateAccountList:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        CMPAssociateAccountListViewController *vc = [[CMPAssociateAccountListViewController alloc] init];
        vc.allowRotation = NO;
        if (CMP_IPAD_MODE && [self.viewController cmp_inMasterStack]) {
            [self.viewController cmp_clearDetailViewController];
            [self.viewController.navigationController.topViewController cmp_pushPageInMasterView:vc navigation:self.viewController.navigationController];
        } else {
            [self.viewController.navigationController pushViewController:vc animated:YES];
        }
    });
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openAssociateAccountSwitcher:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        CMPAssociateAccountSwitchViewController *vc = [[CMPAssociateAccountSwitchViewController alloc] init];
        vc.allowRotation = NO;
        [self.viewController.navigationController pushViewController:vc animated:YES];
    });
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAssociateAccountState:(CDVInvokedUrlCommand *)command {
    NSString *currentServerID = [CMPCore sharedInstance].serverID;
    NSString *currentUserID = [CMPCore sharedInstance].userID;
    NSArray *assServers = [[CMPCore sharedInstance].loginDBProvider assAcountListWithServerID:currentServerID userID:currentUserID];
    NSArray *partTimes = [[M3LoginManager sharedInstance].partTimeHelper partTimeList];
    int state = (assServers.count > 0 || partTimes.count > 0) ? 1 : 0;
    NSDictionary *resultDic = @{@"state" : [NSNumber numberWithInt:state]};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (CMPLoginAccountModel *)currentAccount {
    return [CMPCore sharedInstance].currentUser;
}

- (void)getAppAndConfigRequestStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [[M3LoginManager sharedInstance] appAndConfigSyncStatus];
    if (!dic) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取数据失败"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSNumber *appListSyncDone = dic[@"appList"];
    NSNumber *configInfoSyncDone = dic[@"configInfo"];
    NSNumber *unserInfoSyncDone = dic[@"userInfo"];
    NSDictionary *result = @{@"config" : configInfoSyncDone , @"applist" : appListSyncDone, @"userInfo": unserInfoSyncDone};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[result yy_modelToJSONString]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)refreshAppListAndConfigInfo:(CDVInvokedUrlCommand *)command {
    [[M3LoginManager sharedInstance] retryAppAndConfig:^(NSDictionary *dic) {
        NSNumber *appListSyncDone = dic[@"appList"];
        NSNumber *configInfoSyncDone = dic[@"configInfo"];
        NSNumber *unserInfoSyncDone = dic[@"userInfo"];
        NSDictionary *result = @{@"config" : appListSyncDone , @"applist" : configInfoSyncDone, @"userInfo": unserInfoSyncDone};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[result yy_modelToJSONString]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)refreshAppList:(CDVInvokedUrlCommand *)command {
    [[M3LoginManager sharedInstance] refreshAppList:^(BOOL success) {
        CDVPluginResult *pluginResult = nil;
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)showPrivacyProtection:(CDVInvokedUrlCommand *)command {
    CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
    viewController.startPage = [CMPCommonManager privacyAgreementUrl];
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = NO;
    viewController.isShowBannerProgress = YES;
    
    CMPBannerWebViewController *bannerViewController = (CMPBannerWebViewController *)self.viewController;
    if ([bannerViewController isKindOfClass:[CMPBannerWebViewController class]]) {
        [bannerViewController pushVc:viewController inVc:bannerViewController inDetail:YES clearDetail:YES animate:YES];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if (CMP_IPAD_MODE &&
        [self.viewController.navigationController.topViewController cmp_canPushInDetail]) {
        [self.viewController.navigationController.topViewController cmp_clearDetailViewController];
        [self.viewController.navigationController.topViewController cmp_showDetailViewController:viewController];
    } else {
        [self.viewController.navigationController pushViewController:viewController animated:YES];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end
