//
//  CMPRCMissionHelper.m
//  M3
//
//  Created by CRMO on 2018/10/17.
//

#import "CMPRCMissionHelper.h"
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPDateHelper.h>

@implementation CMPRCMissionHelper

+ (NSString *)paramForCovertMission:(RCMessageModel *)message {
    if (!message) {
        NSLog(@"zl---[%s]message is nil", __FUNCTION__);
        return nil;
    }
    
    RCTextMessage *testMsg = (RCTextMessage *)message.content;
    if (![testMsg isKindOfClass:[RCTextMessage class]]) {
        NSLog(@"zl---[%s]message type error", __FUNCTION__);
        return nil;
    }
    
    NSString *subject = testMsg.content ?: @"";
    NSString *plannedStartTime = [CMPDateHelper nowMillisecondStr] ?: @"";
    NSString *plannedEndTime = [CMPDateHelper tomorrowMillisecondStr] ?: @"";
    NSArray *managerIDs = @[[CMPCore sharedInstance].userID];
    NSArray *managerNames = @[[CMPCore sharedInstance].userName];
    NSString *sourceType = [CMPFeatureSupportControl paramSourceTypeForCovertMission];
    NSDictionary *dic = @{@"subject" : subject,
                          @"plannedStartTime" : plannedStartTime,
                          @"plannedEndTime" : plannedEndTime,
                          @"managers" : managerIDs,
                          @"managerNames" : managerNames,
                          @"sourceId" : message.targetId,
                          @"sourceType" : sourceType
                          };
    NSString *result = [dic yy_modelToJSONString];
    return result;
}

@end
