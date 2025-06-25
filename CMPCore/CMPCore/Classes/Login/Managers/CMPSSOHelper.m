//
//  CMPSSOHelper.m
//  M3
//
//  Created by CRMO on 2018/7/31.
//

#import "CMPSSOHelper.h"
#import "M3LoginManager.h"
#import "CMPCheckUpdateManager.h"
#import "AppDelegate.h"
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/CMPDataProvider.h>
#import "CMPCookieTool.h"
#import "CMPLoginResponse.h"
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/GTMUtil.h>
#import "CMPServerManager.h"
#import "CMPMigrateWebDataViewController.h"

@interface CMPSSOHelper ()<CMPDataProviderDelegate>

@property (strong, nonatomic) NSString *loginRequestID;
@property (strong, nonatomic) CMPServerManager *serverManager;

@end

@implementation CMPSSOHelper

- (void)ssoWithUrl:(NSURL *)url {
    [[AppDelegate shareAppDelegate] clearViews:^{
        [AppDelegate shareAppDelegate].window.rootViewController = [UIViewController new];
        [[M3LoginManager sharedInstance] logout];
        [[AppDelegate shareAppDelegate] showStartPageView];
        [self _ssoWithUrl:url];
    }];
}

+ (BOOL)cotainSSOParam:(NSURL *)url {
    if (!url || ![url isKindOfClass:[NSURL class]]) {
        return NO;
    }
    NSURLComponents *urlComp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    return urlComp.queryItems.count;
}

- (void)_ssoWithUrl:(NSURL *)url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSArray *queryItems = urlComponents.queryItems;
    
    if (!queryItems) {
        DDLogError(@"zl---单点登录失败：queryItems为空");
        return;
    }
    
    NSURLQueryItem *standardItem = [self _standardParams:queryItems];
    if (standardItem) {
        NSString *loginParams = standardItem.value;
        loginParams = [loginParams decodeFromPercentEscapeString];
        NSDictionary *dic = [loginParams JSONValue];
        NSLog(@"_ssoWithUrl标准登录参数:%@",dic);
        NSString *username = dic[@"name"] ?: @"";
        NSString *password = dic[@"password"] ?: @"";
        NSString *ticket = dic[@"ticket"] ?: @"";
        NSString *ext = dic[@"ext"] ?: @"";
        NSString *serverUrl = [self checkUrl:dic[@"serverUrl"]];
        
        NSString *encryptUsername = [GTMUtil encrypt:username];
        NSString *encryptPassword = [GTMUtil encrypt:password];
        NSDictionary *aParam = @{@"name": encryptUsername,
                                 @"password": encryptPassword,
                                 @"ticket" : ticket,
                                 @"ext" : ext,
                                 @"loginParams" : loginParams};
        [self _checkServerWithUserName:username password:password params:aParam serverUrl:serverUrl];
    } else { // 自定义方式
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *item in queryItems) {
            if ([NSString isNull:item.value] ||
                [NSString isNull:item.name]) {
                continue;
            }
            [dic setObject:item.value forKey:item.name];
        }
        NSString *serverUrl = [self checkUrl:dic[@"serverUrl"]];
        NSDictionary *loginParamDic = @{@"loginParams" : dic};
        NSLog(@"_ssoWithUrl自定义登录参数:%@",dic);
        [self _checkServerWithUserName:nil password:nil params:loginParamDic serverUrl:serverUrl];
    }
}
- (NSString *)checkUrl:(NSString *)url {
    if ([NSString isNull:url]) {
        return url;
    }
    NSURL *aUrl = [NSURL URLWithString:url];
    NSString *aScheme = aUrl.scheme;
    if (!aScheme) {
        return url;
    }
    NSString *aHost = aUrl.host;
    NSNumber *port = aUrl.port;
    NSString *aPort = @"";
   
    if (port) {
        aPort = [NSString stringWithFormat:@"%@", port];
    }
    else {
        if ([aScheme.lowercaseString hasPrefix:@"https"]) {
            aPort = @"443";
        }
        else {
            aPort = @"80";
        }
    }
    return [NSString stringWithFormat:@"%@://%@:%@", aScheme, aHost, aPort];
}

/**
 获取标准登录方式参数，参数小于等于2
 loginParams、gotoParams

 @param queryItems
 @return loginParams
 */
- (NSURLQueryItem *)_standardParams:(NSArray *)queryItems {
    if (queryItems.count == 0 || queryItems.count > 2) {
        return nil;
    }
    
    NSURLQueryItem *standardItem = nil;
//    BOOL hasLoginParams = NO;
//    BOOL hasGotoParams = NO;
    
    for (NSURLQueryItem *item in queryItems) {
        if ([item.name isEqualToString:@"loginParams"]) {
//            hasLoginParams = YES;
            standardItem = item;
        } else if ([item.name isEqualToString:@"gotoParams"]) {
//            hasGotoParams = YES;
        }
    }
    return standardItem;
}

- (void)_checkServerWithUserName:(NSString *)userName password:(NSString *)password params:(NSDictionary *)params serverUrl:(NSString *)serverUrl {
    if ([NSString isNull:serverUrl]) {
        [self _loginWithParams:params];
        return;
    }
    
    self.serverManager = [[CMPServerManager alloc] init];
    __weak __typeof(self)weakSelf = self;
    [self.serverManager checkServerWithURL:serverUrl success:^(CMPCheckEnvResponse *response, NSString *url) {
        NSURL *aUrl = [NSURL URLWithString:url];
        // 设置给webview
        NSString *aHost = aUrl.host;
        NSString *aPort = aUrl.port?[NSString stringWithFormat:@"%@", aUrl.port]:@"";
        NSString *aScheme = aUrl.scheme;
        NSString *aNote = @"";
        NSString *aServerVersion = response.data.version;
        NSString *identifier = response.data.identifier;
        NSString *aUpdateDic = [response.data.updateServer yy_modelToJSONObject];
        NSString *aUpdateStr = [response.data.updateServer yy_modelToJSONString];
       /* NSDictionary *h5CacheDic = @{@"ip" : aHost,
                                     @"port": aPort,
                                     @"model" : aScheme,
                                     @"identifier" : identifier,
                                     @"updateServer" : aUpdateDic,
                                     @"serverVersion" : aServerVersion};
        NSString *h5CacheStr = [h5CacheDic JSONRepresentation];
        [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:h5CacheStr];
        */
        CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
        // 保存到本地
        CMPServerModel *newModel = [[CMPServerModel alloc] initWithHost:aHost
                                                                   port:aPort
                                                                 isSafe:[aScheme isEqualToString:@"https"] ? YES : NO
                                                                 scheme:aScheme
                                                                   note:aNote
                                                                 inUsed:YES
                                                               serverID:identifier
                                                          serverVersion:aServerVersion
                                                           updateServer:aUpdateStr];
        NSArray *serverList = [loginDBProvider findServersWithServerID:identifier];
        if (serverList.count == 0 ) {
            //服务器没有保存，才保存
            [loginDBProvider addServerWithModel:newModel];
        }
        [loginDBProvider switchUsedServerWithUniqueID:newModel.uniqueID];
        [[CMPCore sharedInstance] setup];
        [weakSelf _loginWithUserName:userName password:password params:params];
    } fail:^(NSError *error) {
        [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error];
        [[AppDelegate shareAppDelegate] hideStartPageView];
    }];
}

- (void)_loginWithUserName:(NSString *)userName password:(NSString *)password params:(NSDictionary *)params {
    NSLog(@"%s:%@",__func__,params);
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        NSLog(@"检查应用更新结束，准备登录");
        [[M3LoginManager sharedInstance] requestLoginWithUserName:userName password:password encrypted:NO refreshToken:NO verificationCode:nil type:CMPLoginAccountModelLoginTypeLegacy externParams:params start:nil success:^{
            NSLog(@"登录成功");
            if ([[M3LoginManager sharedInstance] needSetGesturePassword]) {
                [[AppDelegate shareAppDelegate] showSetGesturePwdView];
            } else {
                [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
            }
        } fail:^(NSError *error) {
            NSLog(@"登录失败");
            if ([[M3LoginManager sharedInstance] needDeviceBind:error]) {
                [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:nil error:nil username:userName password:password];
                [[M3LoginManager sharedInstance] showBindTipAlert];
                [[AppDelegate shareAppDelegate] hideStartPageView];
                return;
            }
            [[M3LoginManager sharedInstance] showLoginViewControllerWithMessage:error.domain error:error username:userName password:password];
            [[AppDelegate shareAppDelegate] hideStartPageView];
        }];
    }];
}

- (void)_loginWithParams:(NSDictionary *)params {
    [self _loginWithUserName:nil password:nil params:params];
}

@end
