//
//  RCMessageModel+type.m
//  CMPCore
//
//  Created by CRMO on 2017/8/1.
//
//

#import "RCMessageModel+Type.h"
#import <objc/runtime.h>
#import <CMPLib/NSObject+JSON.h>

static NSString *const kRCImageMessage = @"RC:ImgMsg";
static NSString *const kRCFileMessage = @"RC:FileMsg";
static NSString *const kRCVideoMessage = @"OA:VideoMsg";
static NSString *const kRCForwardMessage = @"OA:TransmitMessage";//转发消息
//static NSString *const kRConvertMissionMessage = @"OA:ConvertMissionMessage";//文字转任务消息
static NSString *const kRConvertMissionMessage = @"RC:ImMsg";//文字转任务消息

static NSString *const kRCShakeWinMessage = @"OA:ShakeWinMessage";//抖动消息
static NSString *const kRCUrgeMessage = @"OA:UrgeMessage";//催办消息
static NSString *const kRCObjectName_QuoteMessage = @"RC:QuoteMessage";

static NSString *const kRCRobotMessage = @"OA:OARobotMsg";
static NSString *const kRCRobotAtMessage = @"OA:OARobotAtMsg";

@implementation RCMessageModel(Type)

//+ (void)load
//{
//    // 获取系统的对象方法
//    Method initMethod = class_getInstanceMethod(self, @selector(initWithMessage:));
//
//    // 获取自己定义的对象方法
//    Method self_initMethod = class_getInstanceMethod(self, @selector(self_initWithMessage:));
//
//    // 方法交换
//    method_exchangeImplementations(initMethod, self_initMethod);
//}

- (instancetype)self_initWithMessage:(RCMessage *)rcMessage{
    RCMessageModel *model = [self self_initWithMessage:rcMessage];
    NSDictionary *extraDic = nil;
    if (rcMessage.conversationType == ConversationType_PRIVATE && [rcMessage.senderUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        if ([rcMessage.content respondsToSelector:@selector(extra)]) {
            extraDic = [[rcMessage.content performSelector:@selector(extra)] JSONValue];
            NSString *from = extraDic[@"from_c"];
            if ([from isEqualToString:@"PC"]) {
                //model.messageDirection = MessageDirection_RECEIVE;
            }
        }
    }
    return model;
}

- (BOOL)isImageMessage {
    return [self.objectName isEqualToString:kRCImageMessage];
}

- (BOOL)isFileMessage {
    return [self.objectName isEqualToString:kRCFileMessage];
}

- (BOOL)isVideoMessage {
    return [self.objectName isEqualToString:kRCVideoMessage];
}

- (BOOL)isRCForwardMessage {
    return [self.objectName isEqualToString:kRCForwardMessage];
}

- (BOOL)isRCConvertMissionMessage {
    return [self.objectName isEqualToString:kRConvertMissionMessage];
}

- (BOOL)isRCShakeWinMessage {
    return [self.objectName isEqualToString:kRCShakeWinMessage];
}

- (BOOL)isRCUrgeMessage {
    return [self.objectName isEqualToString:kRCUrgeMessage];
}

-(BOOL)isQuoteMessage
{
    return [self.objectName isEqualToString:kRCObjectName_QuoteMessage];
}

- (BOOL)isRobotMessage{
    return [self.objectName isEqualToString:kRCRobotMessage];
}
- (BOOL)isRobotAtMessage{
    return [self.objectName isEqualToString:kRCRobotAtMessage];
}
@end
