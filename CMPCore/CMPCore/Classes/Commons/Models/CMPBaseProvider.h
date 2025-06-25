//
//  CMPBaseProvider.h
//  M3
//
//  Created by CRMO on 2017/11/20.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataRequest.h>
#import "CMPBaseRequest.h"
#import "CMPBaseResponse.h"

@class CMPBaseRequest, CMPBaseResponse;

@interface CMPBaseProvider : CMPObject<CMPDataProviderDelegate>

@property (nonatomic, copy) void(^requestStart)(void);
@property (nonatomic, copy) void(^requestSuccess)(CMPBaseResponse *response, NSDictionary *responseHeader);
@property (nonatomic, copy) void(^requestFail)(NSError *error);

/**
 子类必须调用[super request:aRequest start:start success:success fail:fail];

 @param aRequest 请求
 @param start 开始回调
 @param success 成功回调
 @param fail 失败回调
 */
- (void)request:(CMPBaseRequest *)aRequest
          start:(void(^)(void))start
        success:(void(^)(CMPBaseResponse *response, NSDictionary *responseHeaders))success
           fail:(void(^)(NSError *error))fail;

/**
 返回reponse的实体类型，子类必须继承！
 */
- (Class)classOfResponse;

/**
 取消网络请求
 */
- (void)cacelRequest;

@end
