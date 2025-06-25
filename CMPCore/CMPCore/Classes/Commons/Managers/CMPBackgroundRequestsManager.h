//
//  CMPBackgroundRequestsManager.h
//  CMPCore
//
//  Created by youlin on 2017/1/14.
//
//

#import <CMPLib/CMPObject.h>
#import "CMPRequestBgImageUtil.h"

@interface CMPBackgroundRequestsManager : CMPObject

+ (CMPBackgroundRequestsManager *)sharedManager;
// 注册远程消息推送
- (void)registerRemoteNotification;
// 请求启动页
- (void)requestCustomStartPage;

- (CMPRequestBgImageUtil *)requestBgImageUtil;

@end
