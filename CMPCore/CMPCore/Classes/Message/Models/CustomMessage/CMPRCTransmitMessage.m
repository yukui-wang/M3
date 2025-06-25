//
//  CMPRCTransmitMessage.m
//  M3
//
//  Created by wujiansheng on 2018/7/2.
//

#import "CMPRCTransmitMessage.h"
//#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/CMPConstant.h>

@implementation CMPRCTransmitMessage

- (void)dealloc {
    SY_RELEASE_SAFELY(_content);
    SY_RELEASE_SAFELY(_extra);
    SY_RELEASE_SAFELY(_title);
    SY_RELEASE_SAFELY(_type);
    SY_RELEASE_SAFELY(_imgURL);
    SY_RELEASE_SAFELY(_sendName);
    SY_RELEASE_SAFELY(_sendTime);
    SY_RELEASE_SAFELY(_mobilePassURL);
    SY_RELEASE_SAFELY(_PCPassURL);
    SY_RELEASE_SAFELY(_appId);
    SY_RELEASE_SAFELY(_actionType);

    [super dealloc];
}

+ (instancetype)messageWithContent:(NSString *)content {
    
    CMPRCTransmitMessage *text = [[[CMPRCTransmitMessage alloc] init] autorelease];
    if (text) {
        text.content = content;
    }
    return text;
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
       
        self.title = [aDecoder decodeObjectForKey:@"extra"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.imgURL = [aDecoder decodeObjectForKey:@"imgURL"];
        self.sendName = [aDecoder decodeObjectForKey:@"sendName"];
        self.sendTime = [aDecoder decodeObjectForKey:@"sendTime"];
        self.mobilePassURL = [aDecoder decodeObjectForKey:@"mobilePassURL"];
        self.PCPassURL = [aDecoder decodeObjectForKey:@"PCPassURL"];
        self.appId = [aDecoder decodeObjectForKey:@"appId"];
        self.actionType = [aDecoder decodeObjectForKey:@"actionType"];

    }
    return self;
}

/// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.imgURL forKey:@"imgURL"];
    [aCoder encodeObject:self.sendName forKey:@"sendName"];
    [aCoder encodeObject:self.sendTime forKey:@"sendTime"];
    [aCoder encodeObject:self.mobilePassURL forKey:@"mobilePassURL"];
    [aCoder encodeObject:self.PCPassURL forKey:@"PCPassURL"];
    [aCoder encodeObject:self.appId forKey:@"appId"];
    [aCoder encodeObject:self.actionType forKey:@"actionType"];
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    if (self.title) {
        [dataDict setObject:self.title forKey:@"title"];
    }
    if (self.type) {
        [dataDict setObject:self.type forKey:@"type"];
    }
    if (self.imgURL) {
        [dataDict setObject:self.imgURL forKey:@"imgURL"];
    }
    if (self.sendName) {
        [dataDict setObject:self.sendName forKey:@"sendName"];
    }
    if (self.sendTime) {
        [dataDict setObject:self.sendTime forKey:@"sendTime"];
    }
    if (self.mobilePassURL) {
        [dataDict setObject:self.mobilePassURL forKey:@"mobilePassURL"];
    }
    if (self.PCPassURL) {
        [dataDict setObject:self.PCPassURL forKey:@"PCPassURL"];
    }
    if (self.appId) {
        [dataDict setObject:self.appId forKey:@"appId"];
    }
    if (self.actionType) {
        [dataDict setObject:self.actionType forKey:@"actionType"];
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
            self.title = dictionary[@"title"];
            self.type = dictionary[@"type"];
            self.imgURL = dictionary[@"imgURL"];
            self.sendName = dictionary[@"sendName"];
            self.sendTime = dictionary[@"sendTime"];
            self.mobilePassURL = dictionary[@"mobilePassURL"];
            self.PCPassURL = dictionary[@"PCPassURL"];
            self.appId = dictionary[@"appId"];
            self.actionType = dictionary[@"actionType"];
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
    return @"OA:TransmitMessage";
}


@end
