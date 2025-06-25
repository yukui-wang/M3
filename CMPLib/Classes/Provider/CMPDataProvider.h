//
//  CMPDataProvider.h
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#import "CMPObject.h"
#import "CMPDataRequest.h"
#import "CMPDataResponse.h"

@class CMPDataProvider;

@protocol CMPDataProviderDelegate <NSObject>

@optional
/**
 * 1. 请求数据完成时调用
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 * aResponse: 返回对象
 */
- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse;

/**
 * 2. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error;
/**
 * 2.1. 当请求数据出现错误时调用
 *
 * aProvider: 数据访问类
 * anError: 错误信息
 * aRequest: 请求对象
 */
- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithOriginalError:(NSError *)error errorMsg:(NSError *)erroeMsg;

/**
 * 3. 开始请求时调用
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 */
- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest;


/**
 * 4. 更新进度
 *
 * aProvider: 数据访问类
 * aRequest: 请求对象
 * ext：额外参数
 */
- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt;

@end

@interface CMPDataProvider : CMPObject

+ (CMPDataProvider *)sharedInstance;

/**
 * 发送数据请求
 *
 * aRequest: 请求参数类
 */
- (void)addRequest:(CMPDataRequest *)aRequest;
/**
 * 发送数据请求
 *
 * aRequest: 请求参数类
 * encode: 是否对urlencode
 */

- (void)addRequest:(CMPDataRequest *)aRequest isEncodeUrl:(BOOL)encode;

/**
 * 取消数据请求
 *
 * aRequestId: 请求id
 */
- (void)cancelWithRequestId:(NSString *)aRequestId;

/**
 * 取消数据请求
 */
- (void)cancelAllRequestsWithCompleteBlock:(void(^)(void))block;

/**
 *  根据delegate取消请求
 *
 * aDelegate: 代理
 */
- (void)cancelRequestsWithDelegate:(id)aDelegate;

/**
 * headers
 *
 */
+ (NSDictionary *)headers;

- (void)resetRequestSerialize;

- (NSURLSessionTask *)getTaskByUrl:(NSString *)url;

@end
