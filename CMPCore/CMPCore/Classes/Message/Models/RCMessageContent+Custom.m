//
//  RCMessageContent+Custom.m
//  CMPCore
//
//  Created by CRMO on 2017/9/14.
//
//

#import "RCMessageContent+Custom.h"
#import "CMPUCSystemMessage.h"
#import "CMPReadedMessage.h"
#import "CMPOAMessage.h"
#import "CMPFileStatusReceiptMessage.h"
#import "CMPMassNotificationMessage.h"
#import "CMPPCCreateGroupMessage.h"
#import "CMPClearMsg.h"


@implementation RCMessageContent(Custom)

- (BOOL)isSpecialMessage {
    if ([self isKindOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *notificationMessage = (RCGroupNotificationMessage *)self;
        NSString *operation = notificationMessage.operation;
        if ([operation isEqualToString:@"Filedelete"] ||
            [operation isEqualToString:@"Rebulletin"] ||
            [operation isEqualToString:@"removeDisplayPostSettingNotice"] ||
            [operation isEqualToString:@"setDisplayPostSettingNotice"] ||
            [operation isEqualToString:@"removeSetAllowNotice"] ||
            [operation isEqualToString:@"setAllowNotice"]) {
            return YES;
        }
    }else if([self isMemberOfClass:[CMPMassNotificationMessage class]] ||
              [self isKindOfClass:[CMPPCCreateGroupMessage class]]){
        
        return YES;
    }
    return NO;
}

- (BOOL)isDisplayInChatView {
    if ([self isKindOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *notificationMessage = (RCGroupNotificationMessage *)self;
        NSString *operation = notificationMessage.operation;
        if ([operation isEqualToString:@"Filedelete"] ||
            [operation isEqualToString:@"Rebulletin"] ||
            [operation isEqualToString:@"removeDisplayPostSettingNotice"] ||
            [operation isEqualToString:@"setDisplayPostSettingNotice"] ||
            [operation isEqualToString:@"removeSetAllowNotice"] ||
            [operation isEqualToString:@"setAllowNotice"]) {
            return NO;
        }
    } else if ([self isKindOfClass:[CMPUCSystemMessage class]] ||
               [self isKindOfClass:[CMPReadedMessage class]] ||
               [self isKindOfClass:[CMPOAMessage class]] ||
               [self isKindOfClass:[CMPFileStatusReceiptMessage class]] ||
               [self isKindOfClass:[CMPPCCreateGroupMessage class]] ||
               [self isKindOfClass:[CMPClearMsg class]] ) {//CMPClearMsg不显示到消息页面
        return NO;
    }
    return YES;
}

@end

