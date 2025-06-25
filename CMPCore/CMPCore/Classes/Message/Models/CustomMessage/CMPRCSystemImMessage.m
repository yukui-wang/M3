//
//  CMPRCConvertMissionMessage.m
//  M3
//
//  Created by 曾祥洁 on 2018/9/27.
//

#import "CMPRCSystemImMessage.h"
#import <CMPLib/CMPConstant.h>
#import <CMPLib/YYModel.h>
#import <CMPLib/NSObject+JSON.h>

@implementation CMPRCSystemImMessageExtraMessage
@end

@implementation CMPRCSystemImMessageExtra
@end

@implementation CMPRCSystemImMessage

#pragma mark -
#pragma mark -RCMessageCoding

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content ?: @"" forKey:@"content"];
    [dataDict setObject:self.extra ?: @"" forKey:@"extra"];
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
    return @"RC:ImMsg";
}

///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark-
#pragma mark Getter

- (void)setExtra:(NSString *)extra {
    if ([NSString isNull:extra]) {
        DDLogError(@"zl---%s,extra is nil", __FUNCTION__);
        return;
    }
    self.extraData = [CMPRCSystemImMessageExtra yy_modelWithJSON:extra];
    NSDictionary *extraDic = [extra JSONValue];
    if (!extraDic || ![extraDic isKindOfClass:[NSDictionary class]]) {
        DDLogError(@"zl---%s,extra解析失败：%@", __FUNCTION__, extra);
        return;
    }
    
    NSMutableDictionary *mutableExtra = [extraDic mutableCopy];
    [mutableExtra setValue:_extraData.message.si ?: @"" forKey:@"userId"];
    [mutableExtra setValue:_extraData.message.sn ?: @"" forKey:@"userName"];
    [mutableExtra setValue:_extraData.message.ui ?: @"" forKey:@"toId"];
    [mutableExtra setValue:_extraData.message.un ?: @"" forKey:@"toName"];
    _extra = [mutableExtra JSONRepresentation];
}

- (NSString *)appId {
    RCSystemImMessageCategory category = self.category;
    if (category == RCSystemImMessageCategoryColHasten) {
        return @"1";
    } else if (category == RCSystemImMessageCategoryTask) {
        return @"30";
    }
    return nil;
}

- (RCSystemImMessageCategory)category {
    NSString *category = self.extraData.messageCategory;
    if ([category isEqualToString:@"col_hasten"]) {
        return RCSystemImMessageCategoryColHasten;
    } else if ([category isEqualToString:@"task_create"]) {
        return RCSystemImMessageCategoryTask;
    }
    return RCSystemImMessageCategoryUnkown;
}

@end
