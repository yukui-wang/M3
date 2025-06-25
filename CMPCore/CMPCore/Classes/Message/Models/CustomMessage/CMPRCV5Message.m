//
//  CMPReminderMessage.m
//  M3
//
//  Created by zengbixing on 2018/1/15.
//

#import "CMPRCV5Message.h"
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPConstant.h>


@implementation CMPRCV5Message

- (void)dealloc {
    
//    SY_RELEASE_SAFELY(_content);
//    SY_RELEASE_SAFELY(_extra);
    SY_RELEASE_SAFELY(_appId);
    SY_RELEASE_SAFELY(_senderName);
    SY_RELEASE_SAFELY(_sendDate);
    SY_RELEASE_SAFELY(_gotoParam);
    SY_RELEASE_SAFELY(_messageType);
    SY_RELEASE_SAFELY(_appName);
    [super dealloc];
}


///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

/// NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
        self.appId = [aDecoder decodeObjectForKey:@"appId"];
        self.senderName = [aDecoder decodeObjectForKey:@"senderName"];
        self.sendDate = [aDecoder decodeObjectForKey:@"sendDate"];
        self.gotoParam = [aDecoder decodeObjectForKey:@"gotoParam"];
        self.messageType = [aDecoder decodeObjectForKey:@"messageType"];
        self.appName = [aDecoder decodeObjectForKey:@"appName"];
    }
    return self;
}

/// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    [aCoder encodeObject:self.appId forKey:@"appId"];
    [aCoder encodeObject:self.senderName forKey:@"senderName"];
    [aCoder encodeObject:self.sendDate forKey:@"sendDate"];
    [aCoder encodeObject:self.gotoParam forKey:@"gotoParam"];
    [aCoder encodeObject:self.messageType forKey:@"messageType"];
    [aCoder encodeObject:self.appName forKey:@"appName"];
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    
    if (self.appId) {
        [dataDict setObject:self.appId forKey:@"appId"];
    }
    
    if (self.senderName) {
        [dataDict setObject:self.senderName forKey:@"senderName"];
    }
    
    if (self.sendDate) {
        [dataDict setObject:self.sendDate forKey:@"sendDate"];
    }
    
    if (self.gotoParam) {
        [dataDict setObject:self.gotoParam forKey:@"gotoParam"];
    }
    
    if (self.messageType) {
        [dataDict setObject:self.messageType forKey:@"messageType"];
    }
    
    if (self.appName) {
        [dataDict setObject:self.appName forKey:@"appName"];
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
            self.content = dictionary[@"content"];
            self.extra = dictionary[@"extra"];
            self.appId = dictionary[@"appId"];
            self.senderName = dictionary[@"senderName"];
            self.sendDate = dictionary[@"sendDate"];
            self.gotoParam = dictionary[@"gotoParam"];
            self.messageType = dictionary[@"messageType"];
            self.appName = dictionary[@"appName"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return self.content;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:V5Msg";
}


@end


