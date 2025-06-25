//
//  CMPLoginUpdateConfigProvider.h
//  M3
//
//  Created by CRMO on 2018/9/27.
//

#import <CMPLib/CMPObject.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPAppListModel.h>
#import "CMPCustomNavBarModel.h"

NS_ASSUME_NONNULL_BEGIN

// 1.8.0版本之后返回CMPLoginConfigInfoModel_2
typedef void(^CMPRequestConfigInfoDidSuccess)(id response,NSString *responseStr);
typedef void(^CMPRequestConfigInfoDidFail)(NSError *error);
// 1.8.0版本之后返回CMPAppListModel_2
typedef void(^CMPRequestAppListDidSuccess)(id response, NSString *reponseStr);
typedef void(^CMPRequestAppListDidFail)(NSError *error);

typedef void(^CMPRequestUserInfoDidSuccess)(NSString *response);
typedef void(^CMPRequestUserInfoDidFail)(NSError *error);

typedef void(^CMPCustomNavBarIndexSuccess)(CMPCustomNavBarModel *response);
typedef void(^CMPCustomNavBarIndexFail)(NSError *error);

@interface CMPLoginUpdateConfigProvider : CMPObject

- (void)requestConfigInfoSuccess:(CMPRequestConfigInfoDidSuccess)success
                            fail:(CMPRequestConfigInfoDidFail)fail;

- (void)requestAppListSuccess:(CMPRequestAppListDidSuccess)success
                         fail:(CMPRequestAppListDidFail)fail;

- (void)requestUserInfoSuccess:(CMPRequestUserInfoDidSuccess)success
                            fail:(CMPRequestUserInfoDidFail)fail;

/**
 将用户自定义的首页同步到服务器
 
 @param portalID 门户ID
 @param appkey appkey
 */
- (void)updateCustomNavBarIndexWithPortalID:(NSString *)portalID
                                     appKey:(NSString *)appkey
                                    success:(CMPCustomNavBarIndexSuccess)success
                                       fail:(CMPCustomNavBarIndexFail)fail;

/**
 上报登录位置信息
 
 @param provice 省份
 @param city 城市
 @param rectangle 经纬度
 */
- (void)reportLoginLocationWithProvice:(NSString *)provice
                                  city:(NSString *)city
                             rectangle:(NSString *)rectangle;

@end

NS_ASSUME_NONNULL_END
