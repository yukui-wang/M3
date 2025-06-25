//
//  CMPMassNotificationMessage.m
//  M3
//
//  Created by 程昆 on 2019/1/14.
//

#import "CMPMassNotificationMessage.h"

@implementation CMPMassNotificationMessage

// 消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    
    return MessagePersistent_ISPERSISTED;
    
}

// NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.broadcastId = [aDecoder decodeObjectForKey:@"broadcastId"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.sendMemberId = [aDecoder decodeObjectForKey:@"sendMemberId"];
        self.sendMemberName = [aDecoder decodeObjectForKey:@"sendMemberName"];
        self.sendTime = [aDecoder decodeObjectForKey:@"sendTime"];
        self.broadcastType = [aDecoder decodeObjectForKey:@"broadcastType"];
    
    }
    return self;
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.broadcastId forKey:@"broadcastId"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.sendMemberId forKey:@"sendMemberId"];
    [aCoder encodeObject:self.sendMemberName forKey:@"sendMemberName"];
    [aCoder encodeObject:self.sendTime forKey:@"sendTime"];
    [aCoder encodeObject:self.broadcastType forKey:@"broadcastType"];
    
}

- (NSData *)encode {
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    
    if (self.type) {
        
        [dataDict setObject:self.type forKey:@"type"];
        
    }
    
    if (self.broadcastId) {
        
        [dataDict setObject:self.broadcastId forKey:@"broadcastId"];
        
    }
    
    if (self.content) {
        
        [dataDict setObject:self.content forKey:@"content"];
        
    }
    
    if (self.sendMemberId) {
        
        [dataDict setObject:self.sendMemberId forKey:@"sendMemberId"];
        
    }
    
    if (self.sendMemberName) {
        
        [dataDict setObject:self.sendMemberName forKey:@"sendMemberName"];
        
    }
    
    if (self.sendTime) {
        
        [dataDict setObject:self.sendTime forKey:@"sendTime"];
        
    }
    
    if (self.broadcastType) {
        
        [dataDict setObject:self.type forKey:@"broadcastType"];
        
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
            
            self.type = dictionary[@"type"];
            self.broadcastId = dictionary[@"broadcastId"];
            self.content = dictionary[@"content"];
            self.sendMemberId = dictionary[@"sendMemberId"];
            self.sendMemberName = dictionary[@"sendMemberName"];
            self.sendTime = dictionary[@"sendTime"];
            self.broadcastType = dictionary[@"broadcastType"];
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
    return @"RC:LittleBroadcastMsg";
}


@end
