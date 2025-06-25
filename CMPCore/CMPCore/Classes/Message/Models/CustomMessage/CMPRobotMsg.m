//
//  CMPRobotMsg.m
//  M3
//
//  Created by Shoujian Rao on 2022/2/24.
//

#import "CMPRobotMsg.h"
#import <CMPLib/CMPConstant.h>

@implementation CMPRobotMsg
+ (NSString *)getObjectName {
    return @"OA:OARobotMsg";
}

- (NSString *)conversationDigest{
    NSString *str = [self.senderUserInfo.name stringByAppendingFormat:@":[%@]",SY_STRING(@"rc_msg_robot_msg")];
    return str;//SY_STRING(@"rc_msg_unknown_msgtype");
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:kNilOptions
                                          error:&error];
        if (dictionary) {
            NSDictionary *voDic = dictionary[@"zxRobotVO"];
            self.title = voDic[@"title"];
            self.content = voDic[@"content"];
            self.pierceUrl = voDic[@"pierceUrl"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

@end
