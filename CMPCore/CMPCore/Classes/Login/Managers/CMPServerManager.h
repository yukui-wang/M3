//
//  CMPServerManager.h
//  M3
//
//  Created by CRMO on 2018/6/12.
//

#import <CMPLib/CMPObject.h>
#import "CMPCheckEnvRequest.h"
#import "CMPCheckEnvResponse.h"

@class CMPCheckEnvResponse;

typedef void(^CMPServerManagerCheckSuccess)(CMPCheckEnvResponse *response, NSString *url);
typedef void(^CMPServerManagerCheckFail)(NSError *error);

@interface CMPServerManager : CMPObject

- (void)checkServerWithHost:(NSString *)aHost
                       port:(NSString *)aPort
                    success:(CMPServerManagerCheckSuccess)success
                       fail:(CMPServerManagerCheckFail)fail;

- (void)checkServerWithURL:(NSString *)url
                   success:(CMPServerManagerCheckSuccess)success
                      fail:(CMPServerManagerCheckFail)fail;

- (void)checkServerWithServerModel:(CMPServerModel *)serverModel
                           success:(CMPServerManagerCheckSuccess)success
                              fail:(CMPServerManagerCheckFail)fail;


/**
 取消所有请求
 */
- (void)cancel;

+ (void)showNetworkTipInView:(UIView *)view port:(NSNumber *)port;

@end
