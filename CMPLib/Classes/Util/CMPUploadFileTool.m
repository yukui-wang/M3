//
//  CMPUploadFileTool.m
//  CMPLib
//
//  Created by MacBook on 2020/1/18.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPUploadFileTool.h"

#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>

static id instance_ = nil;

@interface CMPUploadFileTool()<CMPDataProviderDelegate>

/* startBlock */
@property (copy, nonatomic) void(^startBlock)(void);
/* completionBlock */
@property (copy, nonatomic) void(^successBlock)(NSString *fileId);
/* failedBlock */
@property (copy, nonatomic) void(^failedBlock)(NSError *error);

@end

@implementation CMPUploadFileTool

#pragma mark - 单例实现
/// 这里是生成一个单例对象，如果是需要一个非单例对象的话，可以通过正常的alloc.init方法生成
+ (instancetype)sharedTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    return instance_;
}

#pragma mark - 数据请求

- (void)requestToUploadFileWithFilePath:(NSString *)filePath startBlock:(nullable void(^)(void))startBlock successBlock:(nullable void (^)(NSString *fileId))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock {
    NSString *tmpPath = [filePath stringByRemovingPercentEncoding];
    if (tmpPath.length) {
        filePath = tmpPath;
    }
    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/attachment?option.n_a_s=1"];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Post";
    aDataRequest.requestType = kDataRequestType_FileUpload;
    aDataRequest.uploadFilePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.httpShouldHandleCookies = NO;
    
    
    self.startBlock = startBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)uploadFileWithPath:(NSString *)filePath startBlock:(void(^)(NSString *requestId))startBlock  successBlock:(nullable void (^)(NSString *fileId))successBlock failedBlock:(nullable void(^)(NSError *error))failedBlock {
    
    NSString *tmpPath = [filePath stringByRemovingPercentEncoding];
    if (tmpPath.length) {
        filePath = tmpPath;
    }
    NSString *requestUrl = [CMPCore fullUrlForPath:@"/rest/attachment?option.n_a_s=1"];
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = requestUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"Post";
    aDataRequest.requestType = kDataRequestType_FileUpload;
    aDataRequest.uploadFilePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.httpShouldHandleCookies = NO;
    
    aDataRequest.userInfo = @{
        @"startBlock_1": startBlock,
        @"successBlock_1" : successBlock,
        @"failedBlock_1":failedBlock
    };
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)cancelRequestById:(NSString *)requestId{
    [[CMPDataProvider sharedInstance] cancelWithRequestId:requestId];
}

#pragma mark - 上传回调

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    if (self.startBlock) {
        self.startBlock();
    }
    NSDictionary *userInfo = aRequest.userInfo;
    void(^startBlock_1)(NSString *requestId) = [userInfo objectForKey:@"startBlock_1"];
    if (startBlock_1) {
        startBlock_1(aRequest.requestID);
    }
}
/// 请求成功回调
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if (aResponse.responseStr.length) {
        NSDictionary *responseDic = [CMPCommonTool dictionaryWithJsonString:aResponse.responseStr];
        NSDictionary *firstData = [responseDic[@"atts"] firstObject];
        NSString *fileId = firstData[@"fileUrl"];
        if (self.successBlock) {
            self.successBlock(fileId);
        }
        
        NSDictionary *userInfo = aRequest.userInfo;
        void(^successBlock_1)(NSString *fileId) = [userInfo objectForKey:@"successBlock_1"];
        if (successBlock_1) {
            successBlock_1(fileId);
        }
        
        
    }else {
        
    }
}

/// 请求失败回调
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [MBProgressHUD cmp_hideProgressHUD];
    
    if (error) {
        [MBProgressHUD cmp_showHUDWithText:error.domain];
    }
    
    if (self.failedBlock) {
        self.failedBlock(error);
    }
    
    
    NSDictionary *userInfo = aRequest.userInfo;
    void(^failedBlock_1)(NSError *error) = [userInfo objectForKey:@"failedBlock_1"];
    if (failedBlock_1) {
        failedBlock_1(error);
    }
    
    
}

/**
 * 4. 更新进度
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 */
- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt
{
    float aProgress = [[aExt objectForKey:@"progress"] floatValue];
    if (aProgress < 1) {
        CMPLog(@"upload progress = %f",aProgress);
//        NSDictionary *aDict = (NSDictionary *)aRequest.userInfo;
//        NSString *aCallBackId = [aDict objectForKey:@"callBackID"];
//        NSString *aFileId = [aDict objectForKey:@"fileId"];
//        NSDictionary *aResult = [NSDictionary dictionaryWithObjectsAndKeys:aFileId, @"fileId", [NSNumber numberWithFloat:aProgress], @"pos", nil];
    }
}
@end
