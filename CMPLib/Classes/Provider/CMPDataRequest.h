//
//  MDataRequest.h
//  CMPCore
//
//  Created by youlin guo on 14-10-30.
//  Copyright (c) 2014年 CMPCore. All rights reserved.
//

#define kDataRequestType_Url 0 // http链接数据
#define kDataRequestType_FileDownload 1 // 文件下载
#define kDataRequestType_FileUpload 2 //  文件上传
#define kRequestMethodType_GET @"GET"
#define kRequestMethodType_POST @"POST"


#import "CMPObject.h"

@protocol CMPDataProviderDelegate;

@interface CMPDataRequest : CMPObject

@property (nonatomic, weak)id<CMPDataProviderDelegate>  delegate;  //委托
@property (nonatomic, assign)NSInteger requestType; // 请求类型
@property (nonatomic, copy)NSString *requestID; // 请求id， 随机生成
@property (nonatomic, retain)NSObject *requestParam; // 请求参数
@property (nonatomic, copy)NSString *requestUrl; // 请求url
@property (nonatomic, retain)NSDictionary *userInfo;// 用户自定义数据
@property (nonatomic, copy)NSString *downloadDestinationPath; //文件下载路径
@property (nonatomic, copy)NSString *uploadFilePath; // 上传文件路径
@property (nonatomic, weak)id progressDelegate; // 上传下载进度委托
@property (nonatomic, retain)NSMutableArray *requestCookies; // 请求cookies
@property (nonatomic, copy)NSString *requestMethod; // 请求方法， get、post
@property (nonatomic, retain)NSDictionary *headers; // 请求头信息
@property (nonatomic, assign)NSInteger timeout; // 连接超时时间
@property (nonatomic, assign)BOOL httpShouldHandleCookies; // 默认为YES

@property (assign) SEL requestDidStartSelector;
@property (assign) SEL requestDidFinishSelector;
@property (assign) SEL requestDidFailSelector;

- (id)initWithRequestID:(NSString *)aRequestID;


@end
