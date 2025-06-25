//
//  CMPGeneralBusinessMessage.m
//  M3
//
//  Created by 程昆 on 2019/11/1.
//

#import "CMPGeneralBusinessMessage.h"
#import <CMPLib/CMPAppListModel.h>

@implementation CMPGeneralBusinessMessage

// 消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.messageId) {
        [dataDict setObject:self.content forKey:@"id"];
    }
    if (self.content) {
        [dataDict setObject:self.content forKey:@"content"];
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
            self.messageId = dictionary[@"id"];
            self.content = dictionary[@"content"];
            self.messageCard = dictionary[@"messageCard"];
            if (self.messageCard && [self.messageCard isKindOfClass:[NSDictionary class]]) {
                self.uuid = self.messageCard[@"id"];
                self.appId = self.messageCard[@"appId"];
                self.messageCategory = self.messageCard[@"messageCategory"];
                self.messageContent = self.messageCard[@"messageContent"];
                self.dynamicData = self.messageCard[@"dynamicData"];
                self.imageUrl = self.messageCard[@"imageUrl"];
                self.pcUrl = self.messageCard[@"pcUrl"];
                self.mobileUrlParam = self.messageCard[@"mobileUrlParam"];
                self.mobileOpenEnable = self.messageCard[@"mobileOpenEnable"] ? [self.messageCard[@"mobileOpenEnable"] boolValue] : YES;
                self.mobilePicUrl = self.messageCard[@"mobilePicUrl"];
                self.extraData = self.messageCard[@"extraData"];
                self.appName = self.messageCard[@"appName"];
                self.appIconUrl = self.messageCard[@"appIconUrl"];
                if ([NSString isNotNull:self.appIconUrl]) {
                     self.appIconUrl = [CMPCore fullUrlForPath:self.appIconUrl];
                }
            }
            NSDictionary *userinfoDic = dictionary[@"appIconUrl"];
            [self decodeUserInfo:userinfoDic];
        }
        
    }
}


// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    if ([NSString isNull:self.appName]) {
        NSString *appList = [CMPCore sharedInstance].currentUser.appList;
        CMPAppListModel_2 *appListModel = [CMPAppListModel_2 yy_modelWithJSON:appList];
        CMPAppList_2 *appInfo = [appListModel appInfoWithType:@"default" ID:self.messageCategory];
        self.appName = appInfo.appName;
        if ([NSString isNull:self.appName]) {
            self.appName = @"";
        }
    }
//    NSString *digest = [NSString stringWithFormat:SY_STRING(@"rc_msg_general_business"),self.appName];
    NSString *digest = [NSString stringWithFormat:@"[%@]",self.appName];
    return digest;
}

/*!
 返回消息的类型名
 */
+ (NSString *)getObjectName {
    return @"OA:OACardMsg";
}


@end
