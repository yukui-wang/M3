//
//  CMPQuoteMessage.m
//  M3
//
//  Created by Kaku Songu on 4/19/21.
//

#import "CMPQuoteMessage.h"
#import <CMPLib/NSObject+JSON.h>
#import <CMPLib/YYModel.h>

@interface CMPQuoteMessage()
{
    NSDictionary *_extraDic;
}
@end

@implementation CMPQuoteMessage

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    
    NSString *extraOriStr = self.extra;
    if (extraOriStr.length) {
        NSDictionary *extraOriDic = [extraOriStr JSONValue];
        if (extraOriDic && [extraOriDic isKindOfClass:[NSDictionary class]]) {
            [extraDic addEntriesFromDictionary:extraOriDic];
        }
    }
    
    if (self.quotedMsgUId) {
        [extraDic setObject:self.quotedMsgUId forKey:@"messageUId"];
    }
    if (self.quotedMsgId) {
        [extraDic setObject:self.quotedMsgId forKey:@"messageId"];
    }
    if ([self.quotedMsgContent isKindOfClass:[RCTextMessage class]]) {
        [extraDic setObject:kQuotedMessageType_Text forKey:@"messageType"];
        [extraDic setObject:((RCTextMessage *)self.quotedMsgContent).content forKey:@"content"];
        NSString *name = self.quotedMsgContent.senderUserInfo.name;
        [extraDic setObject:name?:@"" forKey:@"name"];
    }
    if (extraDic.allValues.count) {
        NSString *extra = [extraDic JSONRepresentation];
        [dataDict setObject:extra forKey:@"extra"];
        _extraDic = extraDic;
    }
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    if (self.mentionedInfo) {
        [dataDict setObject:[self encodeMentionedInfo:self.mentionedInfo] forKey:@"mentionedInfo"];
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
        
        [self _queryValueByDictionary:dictionary];
    }
}


-(void)_queryValueByDictionary:(NSDictionary *)dictionary
{
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
        self.content = dictionary[@"content"]?:@"";
        NSString *extra = dictionary[@"extra"]?:@"";
        self.extra = extra;
        NSDictionary *extraDic = [extra isKindOfClass:[NSDictionary class]]? extra : [extra JSONValue];
        _extraDic = extraDic;
        if (extraDic && [extraDic isKindOfClass:[NSDictionary class]]) {
            self.quotedMsgUId = extraDic[@"messageUId"];
            self.quotedMsgId = [NSString stringWithFormat:@"%@",extraDic[@"messageId"]];
            self.quotedMsgType = extraDic[@"messageType"];
            if (self.quotedMsgUId && self.quotedMsgType) {
                if ([self.quotedMsgType isEqualToString:kQuotedMessageType_Text]
                    ||[self.quotedMsgType isEqualToString:kQuotedMessageType_Quote]) {
                    RCTextMessage *quotedMsgContent = [[RCTextMessage alloc] init];
                    quotedMsgContent.content = extraDic[@"content"]?:@"";
                    self.quotedMsgContent = quotedMsgContent;
                }
                _quotedShowStr = [CMPQuoteMessage queryQuotedShowStrByQuotedMsgContent:_quotedMsgContent extraDic:_extraDic];
            }
        }
        id userInfo = dictionary[@"user"];
        if ([userInfo isKindOfClass:[NSString class]]) {
            userInfo = [userInfo JSONValue];
        }
        if (userInfo) {
            [self decodeUserInfo:userInfo];
        }
        
        id mentionedInfo = dictionary[@"mentionedInfo"];
        if ([mentionedInfo isKindOfClass:[NSString class]]) {
            mentionedInfo = [mentionedInfo JSONValue];
        }
        if (mentionedInfo) {
            [self decodeMentionedInfo:mentionedInfo];
        }

    }
}


 //会话列表中显示的摘要
- (NSString *)conversationDigest {
    return self.content;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"RC:QuoteMessage";
}

/*!
 返回可搜索的关键内容列表
 */
- (NSArray<NSString *> *)getSearchableWords {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.content.length) {
        [arr addObject:self.content];
    }
    return arr.count>0 ? arr:nil;
}

-(instancetype)initWithMessageContent:(RCMessageContent *)msgContent
                   quotedMessageModel:(RCMessageModel *)quotedMsgModel
                                  ext:(nullable id)ext
{
    if (self = [super init]) {
        
        if ([msgContent isKindOfClass:[RCTextMessage class]]) {
            RCTextMessage *textMsg = (RCTextMessage *)msgContent;
            self.content = textMsg.content;
            self.mentionedInfo = textMsg.mentionedInfo;
            self.senderUserInfo = textMsg.senderUserInfo;
            self.extra = textMsg.extra;
            self.destructDuration = textMsg.destructDuration;
            self.rawJSONData = textMsg.rawJSONData;
        }
        if (quotedMsgModel) {
            self.quotedMsgContent = quotedMsgModel.content;
            self.quotedMsgId = [NSString stringWithFormat:@"%ld",quotedMsgModel.messageId];
            self.quotedMsgUId = quotedMsgModel.messageUId;
        }
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
                              ext:(nullable id)ext
{
    self = [super init];
    if (self) {
        [self _queryValueByDictionary:dictionary];
    }
    return self;
}

-(NSString *)quotedShowStr
{
    if (!_quotedShowStr) {
        _quotedShowStr = [CMPQuoteMessage queryQuotedShowStrByQuotedMsgContent:_quotedMsgContent extraDic:_extraDic];
    }
    return _quotedShowStr;
}


+(NSString *)queryQuotedShowStrByQuotedMsgContent:(RCMessageContent *)quotedMsgContent
                                          extraDic:(NSDictionary *)extraDic
{
    NSString *finalStr = @"";
    if (quotedMsgContent) {
        NSString *name = (extraDic && extraDic[@"name"]) ? extraDic[@"name"]:@"";
        NSString *content = @"";
        if ([quotedMsgContent isKindOfClass:[RCTextMessage class]]) {
            content = ((RCTextMessage *)quotedMsgContent).content;
        }else if ([quotedMsgContent isKindOfClass:[RCImageMessage class]]){
            content = @"[图片]";
        }
        finalStr = [NSString stringWithFormat:@"%@%@: %@",@"回复 ",name,content];
    }
    return finalStr;
}

@end
