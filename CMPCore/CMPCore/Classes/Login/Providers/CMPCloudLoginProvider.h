//
//  CMPCloudLoginProvider.h
//  M3
//
//  Created by CRMO on 2018/9/11.
//

#import <CMPLib/CMPObject.h>
#import "CMPCloudLoginResponse.h"

typedef void(^CloudLoginGetServerInfoDidSuccess)(CMPCloudLoginResponse *response);
typedef void(^CloudLoginGetServerInfoDidFail)(NSError *error);

@interface CMPCloudLoginProvider : CMPObject

/**
 从云联获取服务器信息

 @param mobile 明文手机号
 @param time 当前终端时间
 @param type 取值范围 m3 oa
 */
- (void)serverInfoWithMobile:(NSString *)mobile
                        time:(NSString *)time
                        type:(NSString *)type
                     success:(CloudLoginGetServerInfoDidSuccess)success
                        fail:(CloudLoginGetServerInfoDidFail)fail;

@end
