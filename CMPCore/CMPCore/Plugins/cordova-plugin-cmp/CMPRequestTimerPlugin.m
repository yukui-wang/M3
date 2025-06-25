//
//  CMPRequestTimerPlugin.m
//  CMPCore
//
//  Created by youlin on 2016/10/30.
//
//

#import "CMPRequestTimerPlugin.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import "AppDelegate.h"
@interface CMPRequestTimerPlugin ()<CMPDataProviderDelegate> {

}

@property (nonatomic, retain)NSDictionary *parameter;
@property (nonatomic, copy)NSString *callBackID;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation CMPRequestTimerPlugin

- (void)dealloc
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    
    [_parameter release];
    _parameter = nil;
    
    [_callBackID release];
    _callBackID = nil;
    
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    
    [super dealloc];
}

- (void)start:(CDVInvokedUrlCommand *)command
{
    NSDictionary *aParameter = [[command arguments] lastObject];
    NSString *aCallBackID = command.callbackId;
    self.parameter = aParameter;
    self.callBackID = aCallBackID;
    
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    NSInteger aTimeInterval = [[aParameter objectForKey:@"timeInterval"] integerValue]/1000;
//    aTimeInterval = 5; // 调试使用
    self.timer = [NSTimer scheduledTimerWithTimeInterval:aTimeInterval target:self selector:@selector(requestWithParam) userInfo:nil repeats:YES];
    [_timer fire];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)invalidate:(CDVInvokedUrlCommand *)command
{
    [_timer release];
    [_timer invalidate];
    _timer = nil;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestWithParam
{
    if ([NSString isNull:[CMPCore sharedInstance].jsessionId]) {
        
        return;
    }
    NSString *url = [self.parameter objectForKey:@"url"];
    NSString *aParameter = [self.parameter objectForKey:@"parameter"];
    aParameter = [aParameter urlEncoding];
    aParameter = [aParameter urlEncoding];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = [[self.parameter objectForKey:@"requestMethod"] uppercaseString];
//    aDataRequest.headers = [self.parameter objectForKey:@"headers"];
    NSDictionary *aDict = [self.parameter objectForKey:@"headers"];
    NSMutableDictionary *aHeader = [NSMutableDictionary dictionaryWithDictionary:aDict];
    NSString *aTicket = [CMPCore sharedInstance].contentTicket;;
    NSString *aExtension = [CMPCore sharedInstance].contentExtension;
    if (![NSString isNull:aTicket]) {
        [aHeader setObject:aTicket forKey:@"Content-Ticket"];
    }
    if (![NSString isNull:aExtension]) {
        [aHeader setObject:aExtension forKey:@"Content-Extension"];
    }
    aDataRequest.headers = aHeader;
    aDataRequest.timeout = [[self.parameter objectForKey:@"timeout"] integerValue]/1000;
    aDataRequest.requestParam = aParameter;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = (NSDictionary *)self.callBackID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

#pragma -mark CMPDataProviderDelegate
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *aStr = aResponse.responseStr;
    NSString *aCallBackId = (NSString *)aRequest.userInfo;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:aStr];
    [pluginResult setKeepCallbackAsBool:YES];
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
    if (error.code == 1005) {
        [[AppDelegate shareAppDelegate]handleError:error];
    }
}

@end
