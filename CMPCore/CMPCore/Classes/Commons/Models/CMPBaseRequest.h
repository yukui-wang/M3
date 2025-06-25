//
//  CMPBaseRequest.h
//  M3
//
//  Created by CRMO on 2017/11/20.
//

#import <CMPLib/CMPObject.h>
#import <CMPLib/CMPDataRequest.h>

UIKIT_EXTERN NSString * const kCMPRequestMethodPost;
UIKIT_EXTERN NSString * const kCMPRequestMethodGet;

@interface CMPBaseRequest : CMPObject

/** 必须重载，请求URL **/
- (NSString *)requestUrl;
/** 默认GET，POST、GET **/
- (NSString *)requestMethod;
/** 默认kDataRequestType_Url，见CMPDataRequest.h定义 **/
- (NSInteger)requestType;
/** 是否处理Cookie，默认处理 **/
- (BOOL)handleCookie;

@end
