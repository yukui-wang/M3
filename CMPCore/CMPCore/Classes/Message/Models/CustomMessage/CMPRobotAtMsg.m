//
//  CMPRobotAtMsg.m
//  M3
//
//  Created by Shoujian Rao on 2022/2/24.
//

#import "CMPRobotAtMsg.h"
#import <CMPLib/CMPConstant.h>

@implementation CMPRobotAtMsg
+ (NSString *)getObjectName {
    return @"OA:OARobotAtMsg";
}

- (NSString *)conversationDigest{
    return SY_STRING(@"rc_msg_robot_msg");
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
            NSDictionary *voDic = dictionary[@"zxRobotAtVO"];
            self.noticeMemberId = voDic[@"noticeMemberId"];
            self.noticeMemberName = voDic[@"noticeMemberName"]?:@"";
            self.content = voDic[@"noticeMemberName"]?:@"";
            if ([NSString isNull:self.content]) {
                self.content = SY_STRING(@"msg_at_all");
            }
            self.content = [@"@" stringByAppendingString:self.content];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
            NSDictionary *mentionedInfoDic = dictionary[@"mentionedInfo"];
            [self decodeMentionedInfo:mentionedInfoDic];
        }
        
    }
}

@end
