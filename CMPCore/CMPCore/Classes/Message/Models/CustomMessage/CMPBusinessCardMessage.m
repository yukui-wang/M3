//
//  CMPMassNotificationMessage.m
//  M3
//
//  Created by 程昆 on 2019/1/14.
//

#import "CMPBusinessCardMessage.h"
#import <CMPLib/CMPConstant.h>

@interface CMPBusinessCardMessage ()

@end

@implementation CMPBusinessCardMessage

// 消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.personnelId) {
        [dataDict setObject:self.personnelId forKey:@"personnelId"];
    }
    if (self.name) {
        [dataDict setObject:self.name forKey:@"name"];
    }
    if (self.department) {
        [dataDict setObject:self.department forKey:@"department"];
    }
    if (self.post) {
        [dataDict setObject:self.post forKey:@"post"];
    }
    if (self.extraData) {
        [dataDict setObject:self.extraData forKey:@"extraData"];
    }
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
            self.personnelId = dictionary[@"personnelId"];
            self.name = dictionary[@"name"];
            self.department = dictionary[@"department"];
            self.post = dictionary[@"post"];
            self.extraData = dictionary[@"extraData"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return SY_STRING(@"rc_msg_business_card");
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:BusinessCard";
}


@end
