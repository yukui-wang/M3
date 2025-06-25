//
//  CMPSignMessage.m
//  M3
//
//  Created by 程昆 on 2020/1/8.
//

#import "CMPSignMessage.h"
#import <CMPLib/CMPConstant.h>

@implementation CMPSignMessage

// 消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.m_id) {
        [dataDict setObject:self.name forKey:@"id"];
    }
    if (self.content) {
        [dataDict setObject:self.content forKey:@"content"];
    }
    if (self.type) {
        [dataDict setObject:self.type forKey:@"type"];
    }
    if (self.messageCard) {
        [dataDict setObject:self.messageCard forKey:@"messageCard"];
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
            self.m_id = dictionary[@"id"];
            self.content = dictionary[@"content"];
            self.type = dictionary[@"type"];
            self.messageCard = dictionary[@"messageCard"];
            if (self.messageCard && [self.messageCard isKindOfClass:[NSDictionary class]]) {
                self.name = self.messageCard[@"name"];
                NSString *signTime = [NSString isNotNull:self.messageCard[@"signTime"]] ?
                self.messageCard[@"signTime"] : @"0";
                self.signTime = [signTime longLongValue];
                self.signType = self.messageCard[@"signType"];
                self.address = self.messageCard[@"address"];
                NSString *latitude = [NSString isNotNull:self.messageCard[@"latitude"]] ?
                self.messageCard[@"latitude"] : @"0";
                self.latitude = [latitude doubleValue];
                NSString *longitude = [NSString isNotNull:self.messageCard[@"longitude"]] ? self.messageCard[@"longitude"] : @"0";
                self.longitude = [longitude doubleValue];
                self.messageCategory = [NSString convertToString:self.messageCard[@"messageCategory"]];
                self.mobileUrlParam = self.messageCard[@"mobileUrlParam"];
                self.pcUrl = self.messageCard[@"pcUrl"];
                self.extraData = self.messageCard[@"extraData"];
            }
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return self.content;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:SignMessage";
}



@end
