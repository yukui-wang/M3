//
//  CMPSignMessage.m
//  M3
//
//  Created by 程昆 on 2020/1/8.
//

#import "CMPSettingMessage.h"

@implementation CMPSettingMessage

// 消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.memberId) {
        [dataDict setObject:self.memberId forKey:@"memberId"];
    }
    if (self.talkId) {
        [dataDict setObject:self.talkId forKey:@"talkId"];
    }
    [dataDict setObject:@(self.recordType) forKey:@"recordType"];
    [dataDict setObject:@(self.recordValue) forKey:@"recordValue"];
    [dataDict setObject:@(self.talkType) forKey:@"talkType"];
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
            self.memberId = dictionary[@"memberId"];
            self.talkId = dictionary[@"talkId"];
            self.recordType = [dictionary[@"recordType"] intValue];
            self.recordValue = [dictionary[@"recordValue"] intValue];
            self.talkType = [dictionary[@"talkType"] intValue];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"RC:MessageSettingMsg";
}



@end
