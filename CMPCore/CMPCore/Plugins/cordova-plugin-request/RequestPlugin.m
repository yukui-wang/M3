//
//  RequestPlugin.m
//  CMPCore
//
//  Created by lin on 15/9/10.
//
//

#import "RequestPlugin.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPLoginResponse.h"

@interface RequestPlugin()<CMPDataProviderDelegate> {
}

@property (strong, nonatomic) NSString *nowPassword;

@end

@implementation RequestPlugin

- (void)dealloc
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_nowPassword);
    [super dealloc];
}

- (void)get:(CDVInvokedUrlCommand*)command
{
    NSDictionary *htmlParameter = [[command arguments] lastObject];
    NSString *url = [htmlParameter objectForKey:@"url"];
    NSLog(@"ks log --- RequestPlugin get begin:\nURL--%@\nPARAMS--%@",url, htmlParameter);
    
    BOOL needSync = NO;
    if ([url hasPrefix:@"null://null:null"]) {
        url = [url replaceCharacter:@"null://null:null" withString:[CMPCore sharedInstance].currentServer.fullUrl];
        needSync = YES;
    }else if ([url hasPrefix:@"file:///var"]){
        url = [url replaceCharacter:@"file:///var" withString:[CMPCore sharedInstance].serverurlForSeeyon];
        needSync = YES;
    }else if ([url hasPrefix:@"undefined://undefined:undefined"]){
        url = [url replaceCharacter:@"undefined://undefined:undefined" withString:[CMPCore sharedInstance].currentServer.fullUrl];
        needSync = YES;
    }
    if (![url containsString:@"://"]) {
        url = [[CMPCore sharedInstance].currentServer.fullUrl stringByAppendingString:url];
    }
    
    NSString *aParameter = [htmlParameter objectForKey:@"parameter"];
    if ([NSString isNotNull:aParameter]) {
        aParameter = [aParameter urlEncoding2Times];
    }
    NSString *aRequestID = [htmlParameter objectForKey:@"requestId"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] initWithRequestID:aRequestID];
    aDataRequest.requestUrl = [url urlEncoding2Times];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    NSDictionary *aDict = [htmlParameter objectForKey:@"headers"];
    NSMutableDictionary *aHeader = [self replaceContenttypeWithHeader:aDict];
    NSString *aTicket = [CMPCore sharedInstance].contentTicket;;
    NSString *aExtension = [CMPCore sharedInstance].contentExtension;
    NSString *token = [CMPCore sharedInstance].token;
    if (![NSString isNull:token]) {
        [aHeader setObject:token forKey:@"ltoken"];
    }
    if (![NSString isNull:aTicket]) {
        [aHeader setObject:aTicket forKey:@"Content-Ticket"];
    }
    if (![NSString isNull:aExtension]) {
        [aHeader setObject:aExtension forKey:@"Content-Extension"];
    }
    
    if ([aHeader isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
        [mutableHeader addEntriesFromDictionary:aHeader];
        aDataRequest.headers =  [mutableHeader copy];
    }
    
    aDataRequest.timeout = [[htmlParameter objectForKey:@"timeout"] integerValue]/1000;
    aDataRequest.requestParam = aParameter;
    aDataRequest.requestType = kDataRequestType_Url;
    NSString *callBackID = [command callbackId];
    aDataRequest.userInfo = (NSDictionary *)callBackID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
    
    if (needSync) {
        [self dispatchAsyncToMain:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_SyncModelToJs" object:nil];
        }];
    }
}

- (void)post:(CDVInvokedUrlCommand*)command
{
    NSDictionary *htmlParameter = [[command arguments] lastObject];
    NSString *url = [[htmlParameter objectForKey:@"url"] urlEncoding2Times];
    NSLog(@"ks log --- RequestPlugin post begin:\nURL--%@\nPARAMS--%@",url, htmlParameter);
    
    BOOL needSync = NO;
    if ([url hasPrefix:@"null://null:null"]) {
        url = [url replaceCharacter:@"null://null:null" withString:[CMPCore sharedInstance].currentServer.fullUrl];
        needSync = YES;
    }else if ([url hasPrefix:@"file:///var"]){
        url = [url replaceCharacter:@"file:///var" withString:[CMPCore sharedInstance].serverurlForSeeyon];
        needSync = YES;
    }else if ([url hasPrefix:@"undefined://undefined:undefined"]){
        url = [url replaceCharacter:@"undefined://undefined:undefined" withString:[CMPCore sharedInstance].currentServer.fullUrl];
        needSync = YES;
    }
    if (![url containsString:@"://"]) {
        url = [[CMPCore sharedInstance].currentServer.fullUrl stringByAppendingString:url];
    }
    
    NSString *aParameter = [htmlParameter objectForKey:@"parameter"];
    if ([aParameter isKindOfClass:[NSString class]]) {
        aParameter = [aParameter urlEncoding2Times];
    }
    
    if ([self isModifyPwdUrl:url]) { // 如果是修改密码，保存新密码
        NSDictionary *paramDic = [aParameter JSONValue];
        if (paramDic && [paramDic isKindOfClass:[NSDictionary class]]) {
            self.nowPassword = paramDic[@"nowpassword"];
        }
    }
    NSString *aRequestID = [htmlParameter objectForKey:@"requestId"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] initWithRequestID:aRequestID];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    NSDictionary *aDict = [htmlParameter objectForKey:@"headers"];
    NSMutableDictionary *aHeader = [self replaceContenttypeWithHeader:aDict];
    NSString *aTicket = [CMPCore sharedInstance].contentTicket;
    NSString *aExtension = [CMPCore sharedInstance].contentExtension;
    if (![NSString isNull:aTicket]) {
        [aHeader setObject:aTicket forKey:@"Content-Ticket"];
    }
    if (![NSString isNull:aExtension]) {
        [aHeader setObject:aExtension forKey:@"Content-Extension"];
    }
    NSString *token = [CMPCore sharedInstance].token;
    if (![NSString isNull:token]) {
        [aHeader setObject:token forKey:@"ltoken"];
    }
    
    if ([aHeader isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
        [mutableHeader addEntriesFromDictionary:aHeader];
        aDataRequest.headers =  [mutableHeader copy];
    }
    aDataRequest.timeout = [[htmlParameter objectForKey:@"timeout"] integerValue]/1000;
    aDataRequest.requestParam = aParameter;
    aDataRequest.requestType = kDataRequestType_Url;
    NSString *callBackID = [command callbackId];
    aDataRequest.userInfo = (NSDictionary *)callBackID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
    
    if (needSync) {
        [self dispatchAsyncToMain:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_SyncModelToJs" object:nil];
        }];
    }
}

- (void)getCsrfToken:(CDVInvokedUrlCommand*)command {
    NSString *csrfToken = [CMPCore sharedInstance].csrfToken;
    CDVPluginResult* pluginResult = nil;
    if ([NSString isNull:csrfToken]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"csrfToken为空"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:csrfToken];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)cancel:(CDVInvokedUrlCommand *)command
{
    NSDictionary *htmlParameter = [[command arguments] lastObject];
    NSArray *aList = [htmlParameter objectForKey:@"requestIds"];
    for (NSString *aRequestID in aList) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:aRequestID];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    [self updatePwdWithUrl:aRequest.requestUrl];
    if ([self isModifyPwdUrl:aRequest.requestUrl]) {
        CMPBaseResponse *resp = [CMPBaseResponse yy_modelWithJSON:aResponse.responseStr];
        NSInteger insideCode = resp.code.integerValue;
        if (insideCode != 200) {
            NSError *error = [NSError errorWithDomain:@"modify pwd err" code:insideCode userInfo:@{NSLocalizedDescriptionKey:resp.message?:@"unknown reason"}];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:cancel];
            [self.viewController presentViewController:ac animated:YES completion:nil];
        }
    }
    
    NSDictionary *responseHeader = aResponse.responseHeaders;
    NSString *aTicket = [responseHeader objectForKey:@"Content-Ticket"];
    NSString *aExtension = [responseHeader objectForKey:@"Content-Extension"];
    if (![NSString isNull:aTicket]) {
        [CMPCore sharedInstance].contentTicket = aTicket;
    }
    if (![NSString isNull:aExtension]) {
        [CMPCore sharedInstance].contentExtension = aExtension;
    }
    NSString *aStr = aResponse.responseStr;
    NSString *aCallBackId = (NSString *)aRequest.userInfo;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:aStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
}

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    NSString *aCallBackId = (NSString *)aRequest.userInfo;
    NSString *aResult = nil;
    if ([error.userInfo isKindOfClass:[NSDictionary class]] && error.userInfo.count > 0) {
        aResult = [error.userInfo objectForKey:@"responseString"];
        // 判断是否是标准的错误返回格式
        NSDictionary *dict = [aResult JSONValue];
        if (dict && [dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
            NSString *aMessage = [dict objectForKey:@"message"];
            if ([NSString isNull:aMessage]) {
                aResult = nil;
            }
        }
        else {
            aResult = nil;
        }
        // 判断结束
    }
    if ([NSString isNull:aResult]) {
       NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", error.domain, @"message", nil];
        aResult = [aDict JSONRepresentation];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:aResult];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
}

#pragma mark-
#pragma mark 修改密码

/**
 调用修改密码接口后，更新本地密码
 */
- (void)updatePwdWithUrl:(NSString *)url {
    if (![self isModifyPwdUrl:url]) {
        return;
    }
    
    CMPLoginAccountModel *currentUser = [CMPCore sharedInstance].currentUser;
    CMPLoginDBProvider *dbProvider = [CMPCore sharedInstance].loginDBProvider;
    currentUser.loginPassword = [self.nowPassword copy];
    currentUser.extend2 = [self.nowPassword copy];
    
    // 临时处理逻辑
    // 修复Bug OA-161690
    // 修改密码后下次登录不弹弱口令
    NSString *loginResult = currentUser.loginResult;
    CMPLoginResponse *oldLoginResponse = [CMPLoginResponse yy_modelWithJSON:loginResult];
    oldLoginResponse.data.config.passwordOvertime = NO;
    oldLoginResponse.data.config.passwordStrong = YES;
    currentUser.loginResult = [oldLoginResponse yy_modelToJSONString];
    
    [dbProvider addAccount:currentUser inUsed:YES];
}

/**
 判断是否是修改密码接口
 */
- (BOOL)isModifyPwdUrl:(NSString *)url {
    BOOL result = NO;
    NSString *modifyPwdUrl = [CMPCore fullUrlForPath:@"/rest/m3/individual/modifypwd"];
    if ([url containsString:modifyPwdUrl]) {
        result = YES;
    }
    return result;
}

//兼容低版本Content-Type 键值有误
- (NSMutableDictionary *)replaceContenttypeWithHeader:(NSDictionary *)headerDic {
    NSMutableDictionary *aHeader = [NSMutableDictionary dictionaryWithDictionary:headerDic];
    NSString *contentTypeValue = [aHeader objectForKey:@"Content-type"];
    if ([NSString isNotNull:contentTypeValue]) {
        [aHeader setObject:contentTypeValue forKey:@"Content-Type"];
        [aHeader removeObjectForKey:@"Content-type"];
    }
    return [[aHeader mutableCopy] autorelease];
}

@end

