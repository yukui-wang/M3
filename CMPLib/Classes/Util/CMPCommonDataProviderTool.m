//
//  CMPCommonDataProviderTool.m
//  CMPLib
//
//  Created by MacBook on 2020/1/2.
//  Copyright © 2020 crmo. All rights reserved.
//

#import "CMPCommonDataProviderTool.h"

#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPStringConst.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPUploadFileTool.h>


static id instance_ = nil;

@interface CMPCommonDataProviderTool()<CMPDataProviderDelegate>

@end

@implementation CMPCommonDataProviderTool
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

/// 添加进收藏
- (void)requestToCollectWithSourceId:(NSString *)sourceId isUc:(BOOL)isUc filePath:( NSString * _Nullable )filePath {
    [MBProgressHUD cmp_showProgressHUD];
    [self requestToCollectWithSourceId:sourceId isUc:isUc completionBlock:^(BOOL isSeccessful, NSString * _Nullable responseData, NSError * _Nullable error) {
        if (isSeccessful) {
            NSDictionary *dic = [CMPCommonTool dictionaryWithJsonString:responseData];
            NSInteger code = [dic[@"code"] integerValue];
            NSString *msg = dic[@"message"];
            if (code == 0) {
                [MBProgressHUD cmp_showHUDWithText:SY_STRING(@"rc_msg_collection_handel_success")];
            } else {
                [MBProgressHUD cmp_showHUDWithText:msg];
            }
        } else {
            //需要重新上传
            if (error.code == 2 && [NSString isNotNull:filePath]) {
                [CMPUploadFileTool.sharedTool requestToUploadFileWithFilePath:filePath startBlock:^{
                } successBlock:^(NSString * _Nonnull fileId) {
                    [CMPCommonDataProviderTool.sharedTool requestToCollectWithSourceId:fileId isUc:isUc filePath:nil];
                } failedBlock:^(NSError * _Nonnull error) {
                    [MBProgressHUD cmp_showHUDWithText:error.domain];
                }];
                return;
            }
           [MBProgressHUD cmp_showHUDWithText:error.domain];
        }
    }];
}

- (void)requestToCollectWithSourceId:(NSString *)sourceId isUc:(BOOL)isUc completionBlock:(nullable CollectCompletionBlock)completionBlock {
    NSString *appKey = @"0";
    if (isUc) {
        appKey = @"61";
    }
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [CMPCore fullUrlForPathFormat:@"%@?sourceId=%@&favoriteType=4&appKey=%@&hasAtt=false",CMPCollectToDoc,sourceId,appKey];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.httpShouldHandleCookies = NO;
    
    NSMutableDictionary *mUserInfo = [NSMutableDictionary dictionary];
    mUserInfo[@"completionBlock"] = [completionBlock copy];
    aDataRequest.userInfo = [mUserInfo copy];
    
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/// 请求成功回调
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    
    CollectCompletionBlock completionBlock = aRequest.userInfo[@"completionBlock"];
    NSDictionary *dic = [CMPCommonTool dictionaryWithJsonString:aResponse.responseStr];
    NSInteger code = [dic[@"code"] intValue];

    if (code == 0 || code == 1) {
//        [MBProgressHUD zl_showSuccess:SY_STRING(@"rc_msg_collection_handel_success")];
//        if (self.completionBlock) {
//            self.completionBlock();
//        }
        completionBlock(YES,aResponse.responseStr,nil);
    }else {
        NSString *errMsg = dic[@"message"];
        NSError *error = [NSError errorWithDomain:errMsg code:code userInfo:@{@"data":[aResponse.responseStr copy]}];
        if (completionBlock) {
            completionBlock(NO,aResponse.responseStr,error);
        }
//        NSString *errMsg = dic[@"message"];
//        [MBProgressHUD zl_showError:errMsg];
    }
    
}

/// 请求失败回调
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    CollectCompletionBlock completionBlock = aRequest.userInfo[@"completionBlock"];
    if (error.code == -1009) {//网络不可用
        //[MBProgressHUD zl_showError:SY_STRING(@"review_image_network_cannot_connect")];
        NSString *errMsg = SY_STRING(@"review_image_network_cannot_connect");
        NSError *customError = [NSError errorWithDomain:errMsg code:error.code userInfo:nil];
        if (completionBlock) {
            completionBlock(NO,nil,customError);
        }
        return;
    }
    
    NSString *errInfo = error.userInfo[@"responseString"];
    NSDictionary *errDic = [CMPCommonTool dictionaryWithJsonString:errInfo];
    NSString *errMsg = errDic[@"message"];
    if ([NSString isNull:errMsg]) {
        errMsg = error.domain;
    }
    NSError *customError = [NSError errorWithDomain:errMsg code:error.code userInfo:errDic];
    if (completionBlock) {
        completionBlock(NO,nil,customError);
    }
    
//    NSString *errInfo = error.userInfo[@"responseString"];
//    NSDictionary *errDic = [CMPCommonTool dictionaryWithJsonString:errInfo];
//    NSString *errMsg = errDic[@"message"];
//    [MBProgressHUD zl_showError:errMsg];
    NSLog(@"添加收藏失败--errorMsg = %@",errMsg);
    
}

@end
