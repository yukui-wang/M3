//
//  CMPRCGroupNotificationObject.m
//  CMPCore
//
//  Created by CRMO on 2017/8/3.
//
//

#import "CMPRCGroupNotificationObject.h"
#import "RCGroupNotificationMessage+Format.h"
#import <CMPLib/CMPDateHelper.h>

NSString *const CMPRCGroupNotificationOperationAdd = @"Add";
NSString *const CMPRCGroupNotificationOperationCreate = @"Create";
NSString *const CMPRCGroupNotificationOperationDismiss = @"Dismiss";
NSString *const CMPRCGroupNotificationOperationQuit = @"Quit";
NSString *const CMPRCGroupNotificationOperationKicked = @"Kicked";
NSString *const CMPRCGroupNotificationOperationRename = @"Rename";
NSString *const CMPRCGroupNotificationOperationReplacement = @"Replacement";
NSString *const CMPRCGroupNotificationOperationBulletin = @"Rebulletin";
NSString *const CMPRCGroupNotificationOperationSetAdmin = @"SetAdmin";
NSString *const CMPRCGroupNotificationOperationUnSetAdmin = @"UnSetAdmin";

NSString *const CMPRCGroupNotificationNameMembersChanged = @"CMPRCGroupNotificationNameMembersChanged";

@implementation CMPRCGroupNotificationObject

- (void)dealloc {
    SY_RELEASE_SAFELY(_sId);
    SY_RELEASE_SAFELY(_mId);
    SY_RELEASE_SAFELY(_targetId);
    SY_RELEASE_SAFELY(_msgId);
    SY_RELEASE_SAFELY(_receiveTime);
    SY_RELEASE_SAFELY(_content);
    SY_RELEASE_SAFELY(_iconUrl);
    SY_RELEASE_SAFELY(_operatorUserId);
    SY_RELEASE_SAFELY(_data);
    SY_RELEASE_SAFELY(_operation);
    SY_RELEASE_SAFELY(_extra1);
    SY_RELEASE_SAFELY(_extra2);
    SY_RELEASE_SAFELY(_extra3);
    SY_RELEASE_SAFELY(_extra4);
    SY_RELEASE_SAFELY(_extra5);
    SY_RELEASE_SAFELY(_extra6);
    SY_RELEASE_SAFELY(_extra7);
    SY_RELEASE_SAFELY(_extra8);
    SY_RELEASE_SAFELY(_extra9);
    SY_RELEASE_SAFELY(_extra10);
    SY_RELEASE_SAFELY(_extra11);
    SY_RELEASE_SAFELY(_extra12);
    SY_RELEASE_SAFELY(_extra13);
    SY_RELEASE_SAFELY(_extra14);
    SY_RELEASE_SAFELY(_extra15);
    [super dealloc];
}

- (id)initWithRCConversation:(RCConversation *)conversation {
    if (self = [super init]) {
        RCMessageContent *lastestMessage = conversation.lastestMessage;
        if (![lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
            NSLog(@"RC---CMPRCGroupNotificationObjec initWithRCConversation error:latestMessage is not a RCGroupNotificationMessage!");
            return nil;
        }
        
        RCGroupNotificationMessage *notificationMessage = (RCGroupNotificationMessage *)lastestMessage;
        
        _sId = [[CMPCore sharedInstance].serverID copy];
        _mId = [[CMPCore sharedInstance].userID copy];
        _targetId = [conversation.targetId copy];
        _msgId = [conversation.lastestMessageUId copy];
        NSString *receiveTimeStr = [CMPDateHelper dateStrFromLongLong:conversation.sentTime];
        _receiveTime = [receiveTimeStr copy];
        _content = [[notificationMessage groupNotification] copy];
        _iconUrl = [conversation.targetId copy];
        _operatorUserId = [notificationMessage.operatorUserId copy];
        _data = [notificationMessage.data copy];
        _operation = [notificationMessage.operation copy];
        _extra1 = [notificationMessage.extra copy];
        // 处理'特殊字符
        [self handleForSql];
    }
    return self;
}

- (id)initWithRCMessage:(RCMessage *)message {
    if (self = [super init]) {
        RCMessageContent *lastestMessage = message.content;
        if (![lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
            NSLog(@"RC---CMPRCGroupNotificationObjec initWithRCConversation error:latestMessage is not a RCGroupNotificationMessage!");
            return nil;
        }
        
        RCGroupNotificationMessage *notificationMessage = (RCGroupNotificationMessage *)lastestMessage;
        
        _sId = [[CMPCore sharedInstance].serverID copy];
        _mId = [[CMPCore sharedInstance].userID copy];
        _targetId = [message.targetId copy];
        _msgId = [message.messageUId copy];
        NSString *receiveTimeStr = [CMPDateHelper dateStrFromLongLong:message.sentTime];
        _receiveTime = [receiveTimeStr copy];
        _content = [[notificationMessage groupNotification] copy];
        _iconUrl = [message.targetId copy];
        _operatorUserId = [notificationMessage.operatorUserId copy];
        _data = [notificationMessage.data copy];
        _operation = [notificationMessage.operation copy];
        _extra1 = [notificationMessage.extra copy];
        // 处理'特殊字符
        [self handleForSql];
    }
    return self;
}

- (void)handleForSql
{
    self.content = [self.content replaceCharacter:@"'" withString:@"''"];
    self.data = [self.data replaceCharacter:@"'" withString:@"''"];
    self.extra1 = [self.extra1 replaceCharacter:@"'" withString:@"''"];
}

@end
