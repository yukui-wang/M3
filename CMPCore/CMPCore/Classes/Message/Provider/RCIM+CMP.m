//
//  RCIM+CMP.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/4/27.
//

#import "RCIM+CMP.h"
#import "CMPMessageFilterManager.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/SOSwizzle.h>

@implementation RCIM (CMP)

+ (void)load {
//    SOSwizzleInstanceMethod(self, @selector(sendMessage:targetId:content:pushContent:pushData:success:error:),@selector(cmp_sendMessage:targetId:content:pushContent:pushData:success:error:));
}

- (RCMessage *)cmp_sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock
{
    if ([content isKindOfClass:RCTextMessage.class]) {
        NSString  *contentStr = ((RCTextMessage *)content).content;
        CMPMsgFilterResult *filterRslt = [CMPMessageFilterManager filterStr:contentStr];
        if (filterRslt.filter.level == CMPMsgFilterLevelIntercept) {
            [self cmp_showHUDWithText:@"消息包含敏感信息,不可发送"];
            return nil;
        }
        contentStr = filterRslt.rslt;
        ((RCTextMessage *)content).content = contentStr;
    }
    return [self cmp_sendMessage:conversationType targetId:targetId content:content pushContent:pushContent pushData:pushData success:successBlock error:errorBlock];
}

@end
