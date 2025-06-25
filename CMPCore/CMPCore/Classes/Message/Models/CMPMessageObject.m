//
//  CMPMessageObject.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/27.
//
//

#import "CMPMessageObject.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPUCSystemMessage.h"
#import "RCGroupNotificationMessage+Format.h"
#import "CMPRCV5Message.h"
#import "CMPRCTransmitMessage.h"
#import "CMPRCSystemImMessage.h"
#import "CMPRCShakeWinMessage.h"
#import "CMPRCUrgeMessage.h"
#import "CMPMassNotificationMessage.h"
#import "CMPChatManager.h"
#import "CMPContactsManager.h"
#import "CMPMessageManager.h"
#import "CMPVideoMessage.h"
#import <CMPLib/CMPFeatureSupportControlHeader.h>
#import "CMPRCUserCacheManager.h"
#import "CMPGeneralBusinessMessage.h"
#import "CMPRCGroupMemberObject.h"
#import "RCIM+InfoCache.h"
#import "CMPQuoteMessage.h"

@interface CMPMessageObject()
{
    CMPPGroupTypeInfoModel *_groupTypeInfoModel;
}
@end
@implementation CMPMessageObject

//v5消息
- (id)initWithV5Message:(NSDictionary *)message localModuleConfig:(NSDictionary *)localModuleConfig
{
    if (self = [super init]) {
        NSDictionary *latestMessage = [message objectForKey:@"latestMessage"];
        self.cId = [message objectForKey:@"appId"];//会话Id  聊天--- targetId  业务-- appId
        self.topSort = kTopSort_Default;//置顶计数
        self.type = CMPMessageTypeApp;//业务 ---0  rong cloud --1  xmpp -- 2
        
        NSString *unreadCount = [message objectForKey:@"unreadCount"];
        if ([unreadCount isKindOfClass:[NSNumber class]] || [unreadCount isKindOfClass:[NSString class]]) {
            self.unreadCount = [unreadCount integerValue];//未读数
        }
        else {
            self.unreadCount = 0;
        }
        
        CMPMessageObject *obj = [[CMPMessageManager sharedManager] messageWithAppID:self.cId];
        if (obj) {
            self.extra15 = obj.extra15;
            self.extra2 = obj.extra2;
        }
        
        if (!self.isNoDisturb && self.unreadCount) {
            [self markUnread:NO];
        }
        
        if(![latestMessage isKindOfClass:[NSDictionary class]]) {
            latestMessage = [NSDictionary dictionary];
        }
        NSString *increment = [latestMessage objectForKey:@"increment"];
        if ([NSString isNull:increment]) {
            increment = @"";
        }
        self.timeStamp =  increment;//最新会话时间戳
        NSString *content = [latestMessage objectForKey:@"content"];
        if ([NSString isNull:content]) {
            content = @"";
        }
        content = [content replaceCharacter:@"\n" withString:@""];
        self.content = content;
        NSString *iconUrl = [latestMessage objectForKey:@"iconUrl"];
        if ([NSString isNull:iconUrl]) {
            iconUrl = @"";
        }
        self.iconUrl = iconUrl;
        
        NSString *createTime = [latestMessage objectForKey:@"createTime"];
        if ([NSString isNull:createTime]) {
            createTime = @"";
        }
        self.createTime = createTime;
        NSString *senderName = [latestMessage objectForKey:@"senderName"];
        if ([NSString isNull:senderName]) {
            senderName = @"";
        }
        self.senderName = senderName;
        NSString *serverIdentifier = [latestMessage objectForKey:@"serverIdentifier"];
        if ([NSString isNull:serverIdentifier]) {
            serverIdentifier = kCMP_ServerID;
        }
        self.sId = serverIdentifier;//serverId
        NSString *senderFaceUrl = [latestMessage objectForKey:@"senderFaceUrl"];
        if ([NSString isNull:senderFaceUrl]) {
            senderFaceUrl = @"";
        }
        self.senderFaceUrl = senderFaceUrl;
        NSString *messageId = [latestMessage objectForKey:@"messageId"];
        if ([NSString isNull:messageId]) {
            messageId = @"";
        }
        NSString *readStatus = [latestMessage objectForKey:@"status"];
        if ([NSString isNull:readStatus]) {
            readStatus = @"";
        }
        self.extra3 = readStatus;
        NSNumber *popType = [latestMessage objectForKey:@"popType"];
        if (![popType isKindOfClass:[NSNumber class]]) {
            popType = 0;
        }
        self.popType = [popType integerValue];
        
        self.msgId = messageId;//消息ID
        self.isTop = NO;//置顶
        self.latestMessage = @"";//json string
        
        self.appName = @"";
        NSString* key = [NSString stringWithFormat:@"appid_%@",self.cId];
        NSDictionary *localAppInfo =  [localModuleConfig objectForKey:key];
        NSString * name = [localAppInfo objectForKey:@"name"];
        if (![NSString isNull:name]) {
            self.appName = name;
        }
        
        if (CMPFeatureSupportControl.isMessagListLeadershipIconEtcUseSeverImage) {
            self.iconUrl = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, iconUrl];
        }
        else if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
            if ([self.cId isEqualToString:kMessageType_LeadershipMessage]) { // 领导消息
                self.iconUrl = @"image:msg_leader_new:5544444";
            } else if ([self.cId isEqualToString:kMessageType_TrackMessage]) { // 跟踪消息
                self.iconUrl = @"image:msg_track_new:5544444";
            } else if ([self.cId isEqualToString:kMessageType_MentionMessage]) { // @我的消息
                self.iconUrl = @"image:msg_mention_new:11983133";
            } else {
                self.iconUrl = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, iconUrl];
            }
        }
        else {
            NSString *appType = latestMessage[@"appType"];
            NSString *iconName = localAppInfo[@"icon"];
            if(![NSString isNull:appType] && [appType isEqualToString:@"default"] && ![NSString isNull:iconName]){
                NSInteger bgColor = [[localAppInfo objectForKey:@"backColor"] longLongValue];
                self.iconUrl = [NSString stringWithFormat:@"image:%@:%ld", iconName, (long)bgColor];
            }
        }
        
        if ([NSString isNull:self.iconUrl]) { // 设置默认图标
            self.iconUrl = [CMPMessageObject defaultIconUrl];
        }
       
        if ([self.cId isEqualToString:@"12"] && [NSString isNull:self.appName]) {
            self.appName = SY_STRING(@"msg_SystemMsg");
        }
        
        NSString *appName = [latestMessage objectForKey:@"appName"];
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            if (![NSString isNull:appName] &&
                ![self.cId isEqualToString:kMessageType_MentionMessage] &&
                ![self.cId isEqualToString:kMessageType_TrackMessage] &&
                ![self.cId isEqualToString:kMessageType_LeadershipMessage] &&
                ![self.cId isEqualToString:kMessageType_SmartMessage]
                &&![self.cId isEqualToString:kMessageType_AppMessage]) {
                self.appName = appName;
            }
        }
        
        if (([CMPCore sharedInstance].serverIsLaterV1_8_0 || ![self.cId isEqualToString:@"12"]) && [NSString isNull:self.appName]) {
            self.appName = appName;
        }
        
        // V7.1 SP1新增逻辑
        NSString *displayName = [message objectForKey:@"msgClassifyDisplayName"];
        if (![NSString isNull:displayName]) {
            self.appName = displayName;
//            if ([self.cId isEqualToString:kMessageType_AppMessage]) {
//                NSString *latestMessageAppName = [latestMessage objectForKey:@"appName"];
//                latestMessageAppName = [NSString isNull:latestMessageAppName] ? @"" : latestMessageAppName;
//                self.content = [NSString stringWithFormat:@"[%@]%@",latestMessageAppName,self.content];
//            }
        }
        
        self.receiveTime = self.createTime;
        NSString *gotoParams = [latestMessage objectForKey:@"gotoParams"];
        if ([NSString isNull:gotoParams]) {
            gotoParams = @"";
        }
        self.gotoParams = gotoParams;
        
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) { // 1.8.0 版本 新增消息分类
            NSString *messageClassify = [message objectForKey:@"messageClassify"];
            if (![messageClassify isEqualToString:kMessageType_V5Message]) {
//                NSString *subtypeId = latestMessage[@"appId"];
//                NSString* key = [NSString stringWithFormat:@"appid_%@", subtypeId];
//                NSDictionary *localAppIno =  [localModuleConfig objectForKey:key];
//                NSString *subtypeName = [localAppIno objectForKey:@"name"];
//                NSString *aContent = self.content;
//                if (![NSString isNull:subtypeName]) {
//                    aContent = [NSString stringWithFormat:@"【%@】%@", SY_STRING(subtypeName), self.content];
//                }
//                self.content = aContent;
                self.cId = messageClassify;
            }
        }
    }
    return self;
}

//融云消息
- (id)initWithRCConversation:(RCConversation *)conversation
{
    if (self = [super init]) {
        self.cId = conversation.targetId;
        self.topSort = kTopSort_Default;
        self.type = CMPMessageTypeRC;
        self.unreadCount = conversation.unreadMessageCount;
        self.timeStamp = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
        self.iconUrl = @"";
        self.appName = @"";
        
        CMPMessageObject *obj = [[CMPMessageManager sharedManager] messageWithAppID:self.cId];
        if (obj) {
            self.extra15 = obj.extra15;
        }
        
        if (!self.isNoDisturb && self.unreadCount) {
            [self markUnread:NO];
        }
        
        RCMessageContent *lastestMessage = conversation.lastestMessage;
        NSString *currentUserId = [CMPCore sharedInstance].userID;
        NSString *senderUserId = conversation.senderUserId;
        RCMessageDirection lastestMessageDirection = conversation.lastestMessageDirection ;
        __block NSString *userName;
        
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:senderUserId];
        NSString *userInfoName = userInfo.name;
        if ([NSString isNotNull:userInfoName]) {
            userName = userInfoName;
        } else {
            //获取人员信息
            [[CMPContactsManager defaultManager] memberNamefromServerForId:senderUserId completion:^(NSString *name) {
                self.appName = name;
                if ([NSString isNotNull:name]) {
                    [[RCIM sharedRCIM] refreshUserNameCache:name withUserId:senderUserId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
                }
                userName = name;
            }];
        }
        
        if (conversation.conversationType == ConversationType_PRIVATE) {
            if (lastestMessageDirection == MessageDirection_RECEIVE) {
                 self.appName = userName;
            } else if (lastestMessageDirection == MessageDirection_SEND) {
                NSString *useriId = conversation.targetId;
                RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:useriId];
                NSString *userInfoName = userInfo.name;
                if ([NSString isNotNull:userInfoName]) {
                    self.appName = userInfoName;
                } else {
                    [[CMPContactsManager defaultManager] memberNamefromServerForId:useriId completion:^(NSString *name) {
                        self.appName = name;
                        if ([NSString isNotNull:name]) {
                            [[RCIM sharedRCIM] refreshUserNameCache:name withUserId:useriId];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
                        }
                    }];
                }
            }
        } else if(conversation.conversationType == ConversationType_GROUP) {
            NSString *groupId = conversation.targetId;
            CMPChatManager *chatManager = CMPChatManager.sharedManager;
            //CMPRCGroupMemberObject *groupInfo = obj.extradDataModel.groupInfo;
            RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:groupId];
            NSString *groupName = groupInfo.groupName;
            if ([NSString isNotNull:groupName]) {
                self.appName = groupName;
            } else {
                [chatManager getGroupUserListByGroupId:groupId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
                     NSString *groupName = groupInfo.name;
                     self.appName = groupName;
                     [self setGroupInfo:groupInfo];
                    if ([NSString isNotNull:groupName]) {
                        [[RCIM sharedRCIM] refreshGroupNameCache:groupName withGroupId:groupId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
                    }
                } fail:^(NSError *error, id ext) {}];
            }
        }
        
        if ([lastestMessage isMemberOfClass:[RCTextMessage class]]
            ||[lastestMessage isMemberOfClass:[CMPQuoteMessage class]]) {
            RCTextMessage *m = (RCTextMessage *)lastestMessage;
            
            if (conversation.conversationType == ConversationType_PRIVATE) {
                self.content = [m content];
            } else {
                if ([senderUserId isEqualToString:currentUserId]) {
                    self.content = [m content];
                } else {
                    self.content = [NSString stringWithFormat:@"%@：%@",  userName, [m content]];
                }
            }
            
            self.content = [self formatMessage:self.content];
            self.latestMessage = @"";
            self.hasUnreadMentioned = conversation.hasUnreadMentioned || m.mentionedInfo.isMentionedMe;
        } else if ([lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) { // 群消息通知
            RCGroupNotificationMessage *m = (RCGroupNotificationMessage *)lastestMessage;
            self.content = [m messageList];
            self.latestMessage = @"";
            self.subtype = CMPRCConversationType_GROUP;
        } else if ([lastestMessage isKindOfClass:[CMPUCSystemMessage class]]) { // 自定义消息类型
            self.type = CMPMessageTypeRCCustom;
        } else if ([lastestMessage isKindOfClass:[RCImageMessage class]] ||
                   [lastestMessage isKindOfClass:[RCLocationMessage class]] ||
                   [lastestMessage isMemberOfClass:[RCFileMessage class]] ||
                   [lastestMessage isKindOfClass:[RCVoiceMessage class]]) { // 文件、图片、语音、位置类型信息加上发起人名字
            NSString *typeStr = NSLocalizedStringFromTable(conversation.objectName,@"RongCloudKit", nil);
            if (conversation.conversationType == ConversationType_PRIVATE) {
                self.content = typeStr;
            } else {
                if ([senderUserId isEqualToString:currentUserId]) {
                    self.content = typeStr;
                } else {
                    self.content = [NSString stringWithFormat:@"%@：%@",  userName, typeStr];
                }
            }
            self.latestMessage = @"";
        }
        else if ([lastestMessage isKindOfClass:[CMPRCV5Message class]]) {
            //协同催办
            CMPRCV5Message *m = (CMPRCV5Message*)lastestMessage;
			
			NSString *type = m.appId;
			NSString *str = @"";
			if ([type integerValue] == 1) {
				str = SY_STRING(@"msg_coll");
			}
			else if ([type integerValue] == 4) {
				str = SY_STRING(@"msg_edoc");
			}
			else if ([type integerValue] == 3) {
				str = SY_STRING(@"msg_doc");
			}
			else if ([type integerValue] == 6){
				
				str = SY_STRING(@"msg_meeting");
			}
			else {
				str = m.appName;
			}
            if (conversation.conversationType == ConversationType_PRIVATE) {
                self.content = [NSString stringWithFormat:@"[%@]%@", str,m.content];
            } else {
                if ([senderUserId isEqualToString:currentUserId]) {
					self.content = [NSString stringWithFormat:@"[%@]%@", str,m.content];
                } else {
                    self.content = [NSString stringWithFormat:@"%@：[%@]%@",  userName, str,m.content];
                }
            }
        }
        else if ([lastestMessage isKindOfClass:[CMPRCTransmitMessage class]]) {
            self.content = SY_STRING(@"forward_message_list_info");
        }
        else if ([lastestMessage isKindOfClass:[CMPRCSystemImMessage class]]){
            CMPRCSystemImMessage *m = (CMPRCSystemImMessage *)lastestMessage;
            self.content = m.content;
        }
        else if([lastestMessage isKindOfClass:[CMPRCShakeWinMessage class]]){
            //CMPRCShakeWinMessage *m = (CMPRCShakeWinMessage *)lastestMessage;
            NSString *content = @"";
            if (lastestMessageDirection == MessageDirection_RECEIVE) {
                content = [NSString stringWithFormat:@"%@%@",userName,NSLocalizedStringFromTable(@"sent you a window jitter", @"Localizable", nil)];
            } else if (lastestMessageDirection == MessageDirection_SEND) {
                content = NSLocalizedStringFromTable(@"You sent a window jitter", @"Localizable", nil);
            }
            
            self.content = content;
        }
        else if ([lastestMessage isKindOfClass:[CMPRCUrgeMessage class]]){
            CMPRCUrgeMessage *m = (CMPRCUrgeMessage *)lastestMessage;
            self.content = m.content;
        }
        else if ([lastestMessage isKindOfClass:[CMPVideoMessage class]] ||
                 [lastestMessage isKindOfClass:[CMPGeneralBusinessMessage class]]) {
            // 视频,业务消息
            NSString *typeStr = [lastestMessage conversationDigest];
            if (conversation.conversationType == ConversationType_PRIVATE) {
                self.content = typeStr;
            } else {
                if ([senderUserId isEqualToString:currentUserId]) {
                    self.content = typeStr;
                } else {
                    self.content = [NSString stringWithFormat:@"%@：%@",  userName, typeStr];
                }
            }
            self.latestMessage = @"";
        }
        else {
            self.content = [RCKitUtility formatMessage:lastestMessage];
        }
        
        if ([self.cId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            
            self.type = CMPMessageTypeFileAssistant;
            self.appName = @"msg_fileass";
            
        }

        self.createTime = [CMPDateHelper dateStrFromLongLong:conversation.sentTime];
        self.senderName = @"";
        self.sId = [CMPCore sharedInstance].serverID;
        self.senderFaceUrl = @"";
        self.msgId = conversation.lastestMessageUId;//消息ID
        self.isTop = NO;//置顶
        self.receiveTime = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
        self.subtype = (CMPRCConversationType)conversation.conversationType;
        self.gotoParams = @"";
    }
    return self;
}

-(NSString *)extra4
{
    if (self.type == CMPMessageTypeRC || self.type == CMPMessageTypeUC || self.type == CMPMessageTypeRCCustom) {
//        if ( !_extra4 || _extra4.length == 0 || [_extra4 isEqualToString:@"(null)"] ) {
            RCConversation *conversation = [[RCIMClient sharedRCIMClient] getConversation:self.subtype targetId:self.cId];
            _extra4 = [NSString stringWithFormat:@"%lu",(unsigned long)conversation.sentStatus];
//        }
    }
    return _extra4;;
}

- (id)initWithGroup:(RCGroup *)groupInfo istop:(BOOL)istop {
    if (self = [super init]) {
        self.cId = groupInfo.groupId;
        self.topSort =  istop ? -[[NSDate date] timeIntervalSince1970]:kTopSort_Default;
        self.type = CMPMessageTypeRC;
        self.unreadCount = 0;
        self.timeStamp = [CMPDateHelper dateStrFromLongLong:0];
        self.content = @"";
        self.latestMessage = @"";

        self.iconUrl = @"";
        self.createTime = [CMPDateHelper getCurrentDateStr];
        self.senderName = @"";
        self.sId = [CMPCore sharedInstance].serverID;
        self.senderFaceUrl = @"";
        self.msgId = @"0";//消息ID
        self.isTop = istop;//置顶
        self.receiveTime = self.createTime;
        self.subtype = CMPRCConversationType_GROUP;
        self.gotoParams = @"";
    }
    return self;
}

- (id)initWithUserInfo:(RCUserInfo *)userInfo istop:(BOOL)istop {
    if (self = [super init]) {
        self.cId = userInfo.userId;
        self.topSort =  istop ? -[[NSDate date] timeIntervalSince1970]:kTopSort_Default;
        self.type = [userInfo.userId isEqualToString:[CMPCore sharedInstance].userID] ? CMPMessageTypeFileAssistant: CMPMessageTypeRC;
        self.unreadCount = 0;
        self.timeStamp = [CMPDateHelper dateStrFromLongLong:0];
        self.content = @"";
        self.latestMessage = @"";
        self.appName = userInfo.name;
        self.iconUrl = @"";
        self.createTime = [CMPDateHelper getCurrentDateStr];
        self.senderName = @"";
        self.sId = [CMPCore sharedInstance].serverID;
        self.senderFaceUrl = @"";
        self.msgId = @"0";//消息ID
        self.isTop = istop;//置顶
        self.receiveTime = self.createTime;
        self.subtype = CMPRCConversationType_PRIVATE;
        self.gotoParams = @"";
    }
    return self;
}

- (id)initNoMessageWithRCConversation:(RCConversation *)conversation {
    if (self = [super init]) {
        RCMessageContent *latestMessage = conversation.lastestMessage;
        
        if (![latestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
            return nil;
        }
        
        RCGroupNotificationMessage *message = (RCGroupNotificationMessage *)latestMessage;
        NSDictionary *extraDic = [message.extra JSONValue];
        self.sId = [CMPCore sharedInstance].serverID;
        self.cId = conversation.targetId;
        self.type = CMPMessageTypeRC;
        self.subtype = CMPRCConversationType_GROUP;
        self.appName = extraDic[@"groupName"];
        self.unreadCount = 0;
        self.content = @"";
        self.receiveTime = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
        self.createTime = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
        self.timeStamp = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
        self.topSort = kTopSort_Default;
        self.isTop = NO;
    }
    return self;
}


//初始化一条小广播消息
- (id)initMassNotificationMessageeWithMessage:(RCMessageContent *)message {
    if (self = [super init]) {
        
        
        if (![message isMemberOfClass:[CMPMassNotificationMessage class]]) {
            return nil;
        }
        
        CMPMassNotificationMessage * msg = (CMPMassNotificationMessage *)message;
        
        self.sId = [CMPCore sharedInstance].serverID;
        self.cId = kMessageType_MassNotificationMessage;
        self.type = CMPMessageTypeMassNotification;
        self.subtype = CMPRCConversationType_PRIVATE;
        self.appName = SY_STRING(@"msg_xiaoguangbo");
        
        self.receiveTime = [CMPDateHelper dateStrFromLongLong:msg.sendTime.longLongValue];
        self.createTime = [CMPDateHelper dateStrFromLongLong:msg.sendTime.longLongValue];
        self.timeStamp = [CMPDateHelper dateStrFromLongLong:msg.sendTime.longLongValue];
        
        //小广播的类型
        if (msg.broadcastType.integerValue == 0) {//有新广播通知
            
            self.unreadCount = 1;
            self.content = SY_STRING(@"msg_xgbnewMessage");
            
        } else if (msg.broadcastType.integerValue == 1) {//已读确认通知
            
            self.unreadCount = 0;
            self.content = @"";
            self.createTime = @"";
            
        } else if (msg.broadcastType.integerValue == 2) {//撤销广播通知
            
            self.unreadCount = 1;
            self.content = [NSString stringWithFormat:@"%@%@",msg.sendMemberName,SY_STRING(@"msg_xgbrecalltip")];
        }
        
        //self.msgId = message.broadcastId;
        self.senderName = msg.sendMemberName;
        self.topSort = kTopSort_Default;
        self.isTop = NO;
    }
    return self;
}

//初始化一条空小广播消息
- (id)initNoneMassNotificationMessage{
    if (self = [super init]) {
        
        self.sId = [CMPCore sharedInstance].serverID;
        self.cId = kMessageType_MassNotificationMessage;
        self.type = CMPMessageTypeMassNotification;
        self.subtype = CMPRCConversationType_PRIVATE;
        self.appName = SY_STRING(@"msg_xiaoguangbo");
        self.unreadCount = 0;
        self.content = @"";
        
        self.msgId = @"";
        self.senderName = @"";
        self.receiveTime = @"0";
        self.createTime = @"0";
        self.timeStamp = @"0";
        self.topSort = kTopSort_Default;
        self.isTop = NO;
    }
    return self;
}

//初始化一条空文件助手消息
- (id)initFileAssistantMessageWithAppID:(NSString *)appID{
    if (self = [super init]) {
        
        self.sId = [CMPCore sharedInstance].serverID;
        self.cId = appID;
        self.type = CMPMessageTypeFileAssistant;
        self.subtype = CMPRCConversationType_PRIVATE;
        self.appName = @"msg_fileass";
        self.unreadCount = 0;
        self.content = @"";
        
        self.msgId = @"";
        self.senderName = @"";
        self.receiveTime = @"1";
        self.createTime = @"1";
        self.timeStamp = @"1";
        self.topSort = kTopSort_Default;
        self.isTop = NO;
    }
    return self;
}


/**
 去掉所有回车，去掉首尾空格
 */
- (NSString *)formatMessage:(NSString *)message {
    NSString *result = message;
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    result = [result replaceCharacter:@"\n" withString:@""];
    return result;
}

- (void)handleForSql
{
    self.content = [self.content replaceCharacter:@"'" withString:@"''"];
    self.latestMessage = [self.latestMessage replaceCharacter:@"'" withString:@"''"];
    self.appName = [ self.appName replaceCharacter:@"'" withString:@"''"];
}

+ (NSString *)cIDWithMessageType:(CMPMessageType)type {
    NSDictionary *dic = [self typeAndCIDMap];
    NSString *key = [NSString stringWithInt:type];
    return [dic objectForKey:key];
}

+ (NSDictionary *)typeAndCIDMap {
    return @{[NSString stringWithInt:CMPMessageTypeAggregationApp] : kMessageType_AppMessage ,
             [NSString stringWithInt:CMPMessageTypeApp] : kMessageType_V5Message ,
             //             [NSString stringWithInt:CMPMessageTypeMention] : kMessageType_MentionMessage ,
             //             [NSString stringWithInt:CMPMessageTypeTrack] : kMessageType_TrackMessage ,
             //             [NSString stringWithInt:CMPmessageTypeLeadership] : kMessageType_LeadershipMessage ,
             };
}

/**
 默认图标，与系统消息相同
 */
+ (NSString *)defaultIconUrl {
    NSString *iconName = @"msg_bul";
    NSInteger bgColor = 6330850;
    NSString *iconUrl = [NSString stringWithFormat:@"image:%@:%ld", iconName, (long)bgColor];
    return iconUrl;
}

- (void)markUnread:(BOOL)isMarkUnread {
    CMPPMessageObjectExtradDataModel *model = [CMPPMessageObjectExtradDataModel yy_modelWithJSON:self.extra15];
    model.isMarkUnread = isMarkUnread;
    self.extra15 = [model yy_modelToJSONString];
}

- (void)setGroupInfo:(CMPRCGroupMemberObject *)groupInfo {
    CMPPMessageObjectExtradDataModel *model = [CMPPMessageObjectExtradDataModel yy_modelWithJSON:self.extra15];
    model.groupInfo = groupInfo;
    self.extra15 = [model yy_modelToJSONString];
}


- (BOOL)isNoDisturb {
    if (self.type == CMPMessageTypeRC ||
        self.type == CMPMessageTypeRCGroupNotification) {
        return ([[CMPChatManager sharedManager] getChatAlertStatus:self.cId] ||
                ![CMPCore sharedInstance].pushAcceptInformation ||
                ![CMPCore sharedInstance].inPushPeriod);
    } else if(self.type == CMPMessageTypeApp ||
              self.type == CMPMessageTypeAggregationApp) {
        return ([self.extra2 isEqualToString:@"0"] ||
        ![CMPCore sharedInstance].pushAcceptInformation ||
        ![CMPCore sharedInstance].inPushPeriod);
    }
    return NO;
}

- (NSString *)extra15 {
    if (!_extra15 || [_extra15 isEqualToString:@"(null)"]) {
        _extra15 = [[[CMPPMessageObjectExtradDataModel alloc] init] yy_modelToJSONString];
    }
    return _extra15;
}

- (CMPPMessageObjectExtradDataModel *)extradDataModel {
    return [CMPPMessageObjectExtradDataModel yy_modelWithJSON:self.extra15];
}

-(void)updateGroupTypeInfo:(NSDictionary *)val
{
    if (!val || val.count == 0) {
        return;
    }
    CMPPGroupTypeInfoModel *aModel = self.groupTypeInfo;
    NSString *tag = val[@"tag"];
    aModel.isMarked = tag && [tag isEqualToString:@"1"];
    aModel.val = val[@"val"];
}

- (CMPPGroupTypeInfoModel *)groupTypeInfo
{
    if (_groupTypeInfoModel) {
        return _groupTypeInfoModel;
    }
    CMPPGroupTypeInfoModel *aModel = [[CMPPGroupTypeInfoModel alloc] init];
    if (_extra14 && ![_extra14 isEqualToString:@"(null)"]) {
        NSDictionary *extDic = [_extra14 JSONValue];
        if (extDic) {
            NSString *tag = extDic[@"tag"];
            aModel.isMarked = tag && [tag isEqualToString:@"1"];
            aModel.val = extDic[@"val"];
        }
    }
    _groupTypeInfoModel = aModel;
    return aModel;
}

@end

@implementation CMPPMessageObjectExtradDataModel

@end


@implementation CMPPGroupTypeInfoModel

-(NSInteger)groupType
{
    if (!_val || _val.count == 0) {
        return CMPGroupTypeOrdinary;
    }
    NSString *type = [NSString stringWithFormat:@"%@",_val[@"groupType"]];
    if ([@"DEPARTMENT" isEqualToString:type]) {
        return CMPGroupTypeDepartment;
    }
    return CMPGroupTypeOrdinary;
}

@end
