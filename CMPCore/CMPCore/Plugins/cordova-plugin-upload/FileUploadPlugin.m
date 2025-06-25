//
//  FileUploadPlugin.m
//  HelloCordova
//
//  Created by lin on 15/8/24.
//

#import "FileUploadPlugin.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPDateHelper.h>
#import <CMPLib/NSURL+CMPURL.h>

@interface FileUploadPlugin()<CMPDataProviderDelegate>
{
    NSTimeInterval progressTimeInterval;
}
@end

@implementation FileUploadPlugin

-(void)dealloc
{
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    [super dealloc];
}

- (void)upload:(CDVInvokedUrlCommand*)command
{
    NSDictionary *htmlParameter = [[command arguments] lastObject];
    NSString *url = [htmlParameter objectForKey:@"url"];
    if ([NSString isNull:url] || [url isEqualToString:@"null"]) {
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:23001],@"code",SY_STRING(@"common_uploadServerEmpty"),@"message",@"",@"detail", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDict];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    NSArray *aFileList = [htmlParameter objectForKey:@"fileList"];
    BOOL sortNum = [htmlParameter.allKeys containsObject:@"imgIndex"];
    NSString *imgIndexValue = [htmlParameter objectForKey:@"imgIndex"];
    NSInteger i = 0;
    for (NSDictionary *aDict in aFileList) {
        NSString *aRequestID = [aDict objectForKey:@"requestId"];
        CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] initWithRequestID:aRequestID];
        NSString *requestUrl = url;
        if (sortNum && ![NSString isNull:imgIndexValue]) {//@"imgIndex" 字段为空时，不拼接
            requestUrl = [url appendHtmlUrlParam:imgIndexValue value:[NSString stringWithLongLong:(long long)i]];
        }
        i++;
        aDataRequest.requestUrl = requestUrl;//[requestUrl urlEncoding2Times];
        aDataRequest.delegate = self;
        aDataRequest.requestMethod = @"Post";
        NSString *aFilePath =  [aDict objectForKey:@"filepath"];
        NSString *filename =  [aDict objectForKey:@"filename"];
        if (![filename isEqualToString:aFilePath.lastPathComponent] && [NSString isNotNull:filename]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *sourcePath = aFilePath;
            NSString *destinationPath = [NSTemporaryDirectory()  stringByAppendingPathComponent:filename];
            sourcePath = [sourcePath replaceCharacter:@"file://" withString:@""];
            destinationPath = [destinationPath replaceCharacter:@"file://" withString:@""];
            [fileManager removeItemAtPath:destinationPath error:nil];
            BOOL isCopySeccess  = [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:nil];
            if (isCopySeccess) {
                aFilePath = destinationPath;
            }
        }
        aFilePath = [aFilePath replaceCharacter:@"file://" withString:@""];

        aDataRequest.uploadFilePath = aFilePath;
        // 设置header
        NSDictionary *aHeaders = [htmlParameter objectForKey:@"headers"];
        if ([aHeaders isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutableHeader = [[CMPDataProvider headers] mutableCopy];
            [mutableHeader addEntriesFromDictionary:aHeaders];
            aDataRequest.headers =  [mutableHeader copy];
        }
        aDataRequest.requestType = kDataRequestType_FileUpload;
        NSString *callBackID = [command callbackId];
        NSString *aFileId = [aDict objectForKey:@"fileId"];
        if (!aFileId || ![aFileId isKindOfClass:[NSString class]]) {
            aFileId = @"";
        }
        aDataRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:callBackID, @"callBackID", aFileId, @"fileId", nil];
        [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
        [aDataRequest release];
    }
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
    NSString *aStr = aResponse.responseStr;
    NSDictionary *responseDic = [aResponse.responseStr JSONValue];
    NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
    NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
    NSString *aFileId = [aDict objectForKey:@"fileId"];
    NSString *code = [NSString stringWithFormat:@"%@",responseDic[@"code"]];//有的返回类型会是数值类型，兼容下
    NSString *message = responseDic[@"message"] ?: @"";
    if (!aFileId) {
        aFileId = @"";
    }
    if ([code isEqualToString:@"1"]) {//文件上传失败
        NSDictionary *resultDic = @{
            @"code" : code,
            @"response" : aStr,
            @"message" : message,
            @"fileId" : aFileId
        };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
        return;
        
    }
    NSDictionary *aResult = [NSDictionary dictionaryWithObjectsAndKeys:aFileId, @"fileId", aStr, @"response", [NSNumber numberWithInt:1], @"pos", nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aResult];
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
    NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
    NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
    NSString *aFileId = [aDict objectForKey:@"fileId"];

    NSString *aResult = nil;
    NSMutableDictionary *aResultDic = nil;
    if ([error.userInfo isKindOfClass:[NSDictionary class]] && error.userInfo.count > 0) {
        aResult = [error.userInfo objectForKey:@"responseString"];
        // 判断是否是标准的错误返回格式
        NSDictionary *dict = [aResult JSONValue];
        if (dict && [dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
            if (![dict objectForKey:@"code"]) {
                aResult = nil;
            }
            else {
                aResultDic = [NSMutableDictionary dictionaryWithDictionary:dict];
                [aResultDic setObject:aFileId forKey:@"fileId"];
            }
        }
        else {
            aResult = nil;
        }
        // 判断结束
    }

    if ([NSString isNull:aResult]) {
        aResultDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", error.domain, @"message",aFileId,@"fileId", nil];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:aResultDic];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
}


/**
 * 4. 更新进度
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 */
- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{
    NSTimeInterval aCurrentTimeInterval = [CMPDateHelper getNowTimeTimestamp3];
    NSTimeInterval l = aCurrentTimeInterval - progressTimeInterval;
    if (l > 500) { // 如果大于500毫秒执行js方法，优化性能
        progressTimeInterval = aCurrentTimeInterval;
        float aProgress = [[aExt objectForKey:@"progress"] floatValue];
           if (aProgress < 1) {
               NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
               NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
               NSString *aFileId = [aDict objectForKey:@"fileId"];
               NSDictionary *aResult = [NSDictionary dictionaryWithObjectsAndKeys:aFileId, @"fileId", [NSNumber numberWithFloat:aProgress], @"pos", nil];
               CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aResult];
               [pluginResult setKeepCallbackAsBool:YES];
               [self.commandDelegate sendPluginResult:pluginResult callbackId:aCallBackId];
           }
    }
}

@end
