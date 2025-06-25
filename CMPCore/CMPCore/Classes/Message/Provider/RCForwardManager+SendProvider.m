//
//  RCForwardManager+SendProvider.m
//  M3
//
//  Created by 程昆 on 2019/11/5.
//

#import "RCForwardManager+SendProvider.h"
#import <CMPLib/CMPConstant.h>
#import "M3-Swift.h"
#import "RCMessageModel+Type.h"
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/NSString+CMPString.h>

NSString * const kCMPGetMessageChatContentIdUrl = @"/rest/uc/rong/chatmessage/create";

@interface RCForwardManager ()<CMPDataProviderDelegate>

@end

@implementation RCForwardManager (SendProvider)

- (void)sendCombienMessage:(NSArray *)messageList selectConversation:(NSArray *)conversationList isCombine:(BOOL)isCombine forwardConversationType:(RCConversationType)forwardConversationType {
    NSString *senderTargetId = [((RCConversation *)conversationList.lastObject).targetId copy];
    NSMutableArray *mutableConversationList = [conversationList mutableCopy];
    [mutableConversationList removeLastObject];
    conversationList = [mutableConversationList copy];
    
    //组装消息
    NSMutableArray *nameList= [[NSMutableArray alloc] init];
    NSMutableArray *summaryList= [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < messageList.count ; i ++) {
        RCMessageModel *messageModel = [messageList objectAtIndex:i];
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:messageModel.senderUserId];
        NSString *senderUserName = userInfo.name;
        //组装名字
        if (forwardConversationType == ConversationType_GROUP) {
            RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:messageModel.targetId];
            if (![nameList containsObject:groupInfo.groupName]) {
                [nameList addObject:groupInfo.groupName];
            }
        }
        
        //组装缩略信息
        [summaryList addObject:[self packageContentParam:messageModel senderUserName:senderUserName]];
        
    }
    
    if (forwardConversationType == ConversationType_PRIVATE) {
        RCUserInfo *targetUserInfo = [[RCIM sharedRCIM] getUserInfoCache:senderTargetId];
        NSString *targetUserName = targetUserInfo.name;
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:RCIM.sharedRCIM.currentUserInfo.userId];
        NSString *currentUserName = userInfo.name;
        [nameList addObject:targetUserName];
        [nameList addObject:currentUserName];
    }

    
    NSString *title = [self getCombineMessageSummaryTitle:[nameList copy] forwardConversationType:forwardConversationType];
    NSString *content = [summaryList JSONRepresentation];
    
    for (RCConversation *conversation in conversationList) {
        NSMutableDictionary *aParamDict = [NSMutableDictionary dictionary];
        aParamDict[@"data"] = summaryList;
        aParamDict[@"receiverId"] = senderTargetId;
        if (forwardConversationType == ConversationType_GROUP) {
            aParamDict[@"receiverType"] = @"group";
        }else{
            aParamDict[@"receiverType"] = @"personal";
        }
        [self getMessageChatContentIdWithParamDict:[aParamDict copy] isSaveDoc:NO completion:^(NSString *chatContentId, NSError *error) {
            if ([NSString isNotNull:chatContentId]) {
                CMPCombineMessage *combineMessage = [[CMPCombineMessage alloc] init];
                combineMessage.title = title;
                combineMessage.content = content;
                combineMessage.chatContentId = chatContentId;
                [self forwardWithConversationType:conversation.conversationType targetId:conversation.targetId content:combineMessage isCombine:isCombine];
            }
        }];
    }
}

- (void)turnOnOpinion:(NSArray *)messageList targetId:(NSString *)targetId  forwardConversationType:(RCConversationType)forwardConversationType completion:(CMPGetMessageChatContentIdDoneBlock)block  {
    [self assembledMessages:messageList targetId:targetId isSaveDoc:NO forwardConversationType:forwardConversationType completion:block];
}

- (void)collectionChatRecord:(NSArray *)messageList targetId:(NSString *)targetId  forwardConversationType:(RCConversationType)forwardConversationType completion:(CMPGetMessageChatContentIdDoneBlock)block  {
    [self assembledMessages:messageList targetId:targetId isSaveDoc:YES forwardConversationType:forwardConversationType completion:block];
}

- (void)assembledMessages:(NSArray *)messageList targetId:(NSString *)targetId isSaveDoc:(BOOL)isSaveDoc forwardConversationType:(RCConversationType)forwardConversationType completion:(CMPGetMessageChatContentIdDoneBlock)block {
    //组装消息
       NSMutableArray *summaryList= [[NSMutableArray alloc] init];
       for (int i = 0 ; i < messageList.count ; i ++) {
           RCMessageModel *messageModel = [messageList objectAtIndex:i];
           RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:messageModel.senderUserId];
           NSString *senderUserName = userInfo.name;
           //组装缩略信息
           [summaryList addObject:[self packageContentParam:messageModel senderUserName:senderUserName]];
       }
       
       NSMutableDictionary *aParamDict = [NSMutableDictionary dictionary];
       aParamDict[@"data"] = summaryList;
       aParamDict[@"receiverId"] = targetId;
       if (forwardConversationType == ConversationType_GROUP) {
           aParamDict[@"receiverType"] = @"group";
       }else{
           aParamDict[@"receiverType"] = @"personal";
       }
       [self getMessageChatContentIdWithParamDict:[aParamDict copy] isSaveDoc:isSaveDoc completion:^(NSString *chatContentId, NSError *error) {
           if (block) {
               block(chatContentId,error);
           }
       }];
}


+ (NSString *)packageSummaryList:(RCMessageModel *)messageModel senderUserName:(NSString *)senderUserName {
    NSMutableString *summaryContent = [[NSMutableString alloc] init];
    [summaryContent appendString:[NSString stringWithFormat:@"%@：",senderUserName]];
    if ([messageModel.objectName  isEqualToString:RCTextMessageTypeIdentifier]) {
        RCTextMessage *textMessage = (RCTextMessage *)messageModel.content;
        [summaryContent appendString:textMessage.content];
    }else if ([messageModel.objectName  isEqualToString:RCImageMessageTypeIdentifier]){
        [summaryContent appendString:NSLocalizedStringFromTable(RCImageMessageTypeIdentifier, @"RongCloudKit", nil)];
    }else if ([messageModel.objectName  isEqualToString:@"RC:ImgTextMsg"]){
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:ImgTextMsg", @"RongCloudKit", nil)];
    }else if ([messageModel.objectName isEqualToString:RCHQVoiceMessageTypeIdentifier]||[messageModel.objectName isEqualToString:RCVoiceMessageTypeIdentifier]) {
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:VcMsg", @"RongCloudKit", nil)];
    }else if ([messageModel.objectName  isEqualToString:RCFileMessageTypeIdentifier]){
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:FileMsg", @"RongCloudKit", nil)];
    }else if ([messageModel.objectName  isEqualToString:RCCombineMessageTypeIdentifier]){
        [summaryContent appendString:NSLocalizedStringFromTable(RCCombineMessageTypeIdentifier, @"RongCloudKit", nil)];
    }else if ([messageModel.objectName  isEqualToString:RCSightMessageTypeIdentifier]){
        [summaryContent appendString:NSLocalizedStringFromTable(RCSightMessageTypeIdentifier, @"RongCloudKit", nil)];
    }else if ([messageModel.objectName  isEqualToString:RCLocationMessageTypeIdentifier]){
        [summaryContent appendString:NSLocalizedStringFromTable(RCLocationMessageTypeIdentifier, @"RongCloudKit", nil)];
    }else if ([messageModel.objectName isEqualToString:@"RC:CardMsg"]){
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:CardMsg", @"RongCloudKit", nil)];
    }else if ([messageModel.objectName isEqualToString:@"RC:StkMsg"] || [messageModel.objectName isEqualToString:RCGIFMessageTypeIdentifier]) {
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:StkMsg", @"RongCloudKit", nil)];
    }else if ([messageModel.objectName isEqualToString:@"RC:VCSummary"]) {
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:VCSummary", @"RongCloudKit", nil)];
    }
    return summaryContent;
}

+ (NSString *)packageContent:(ContentModel *)contentModel {
    NSMutableString *summaryContent = [[NSMutableString alloc] init];
    [summaryContent appendString:
     [NSString stringWithFormat:@"%@: ",contentModel.creatorName]];
    if ([contentModel.type isEqualToString:@"text"]) {
        [summaryContent appendString:contentModel.deCodeContent];
    }else if ([contentModel.type isEqualToString:@"image"] || [contentModel.type isEqualToString:@"gif"]){
        [summaryContent appendString:NSLocalizedStringFromTable(RCImageMessageTypeIdentifier, @"RongCloudKit", nil)];
    }else if ([contentModel.type isEqualToString:@"file"]){
        [summaryContent appendString:NSLocalizedStringFromTable(@"RC:FileMsg", @"RongCloudKit", nil)];
    }
    return summaryContent;
}

- (NSDictionary *)packageContentParam:(RCMessageModel *)messageModel senderUserName:(NSString *)senderUserName {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([messageModel.objectName  isEqualToString:RCTextMessageTypeIdentifier]) {
        RCTextMessage *textMessage = (RCTextMessage *)messageModel.content;
        dic[@"type"] = @"text";
        dic[@"content"] = [textMessage.content emojiEncode];
        dic[@"createDate"] = [NSString stringWithLongLong:messageModel.sentTime] ;
        dic[@"creatorId"] = messageModel.senderUserId;
        dic[@"creatorName"] = senderUserName;
    } else if ([messageModel isImageMessage]) {
        RCImageMessage *imageMessage = (RCImageMessage *)messageModel.content;
        dic[@"type"] = @"image";
        dic[@"content"] = @"";
        dic[@"externalId"] = imageMessage.imageUrl;
        dic[@"createDate"] = [NSString stringWithLongLong:messageModel.sentTime] ;
        dic[@"creatorId"] = messageModel.senderUserId;
        dic[@"creatorName"] = senderUserName;
    } else if ([messageModel.content isKindOfClass:[RCGIFMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)messageModel.content;
        dic[@"type"] = @"gif";
        dic[@"content"] = @"";
        dic[@"externalId"] = imageMessage.remoteUrl;
        dic[@"createDate"] = [NSString stringWithLongLong:messageModel.sentTime] ;
        dic[@"creatorId"] = messageModel.senderUserId;
        dic[@"creatorName"] = senderUserName;
    }else if ([messageModel.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *fileMessage = (RCFileMessage *)messageModel.content;
        dic[@"type"] = @"file";
        dic[@"content"] = @"";
        dic[@"externalId"] = fileMessage.fileUrl;
        dic[@"createDate"] = [NSString stringWithLongLong:messageModel.sentTime] ;
        dic[@"creatorId"] = messageModel.senderUserId;
        dic[@"creatorName"] = senderUserName;
    }else if ([messageModel isQuoteMessage]) {
        CMPQuoteMessage *aMessage = (CMPQuoteMessage *)messageModel.content;
        dic[@"type"] = @"text";
        dic[@"subType"] = @"quote";
        dic[@"content"] = [aMessage.content emojiEncode];
        dic[@"createDate"] = [NSString stringWithLongLong:messageModel.sentTime] ;
        dic[@"creatorId"] = messageModel.senderUserId;
        dic[@"creatorName"] = senderUserName;
        dic[@"extendContent"] = aMessage.quotedShowStr;
    }
    return [dic copy];
}

- (NSString *)getCombineMessageSummaryTitle:(NSArray *)nameList forwardConversationType:(RCConversationType)forwardConversationType {
    if (!nameList.count) {
        return @"";
    }
    NSString * title = @"";
    if (forwardConversationType == ConversationType_GROUP) {
        title = NSLocalizedStringFromTable(@"GroupChatHistory", @"RongCloudKit", nil);
        title = [NSString stringWithFormat:@"%@%@",nameList.firstObject,SY_STRING(@"rc_group_chat_record")];
    }else {
        if (nameList && nameList.count > 1) {
            title= [NSString stringWithFormat:NSLocalizedStringFromTable(@"ChatHistoryForXAndY",@"RongCloudKit", nil),[nameList firstObject],[nameList lastObject]];
        }else if(nameList && nameList.count == 1){
            title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"ChatHistoryForX",@"RongCloudKit", nil),[nameList firstObject]];
        }
    }
    return title;
}

- (NSString *)getCombineMessageSummaryTitleWithSelectedMessages:(NSArray<RCMessageModel *> *)selectedMessages forwardConversationType:(RCConversationType)forwardConversationType targetId:(NSString *)targetId {
    if (!selectedMessages.count) {
        return @"";
    }
    NSArray *nameList = [self getNameListWithSelectedMessages:selectedMessages forwardConversationType:forwardConversationType targetId:targetId];
    NSString *title = [self getCombineMessageSummaryTitle:nameList forwardConversationType:forwardConversationType];
    return title;
}

- (NSArray *)getNameListWithSelectedMessages:(NSArray<RCMessageModel *> *)selectedMessages forwardConversationType:(RCConversationType)forwardConversationType targetId:(NSString *)targetId {
    NSArray *selectedMessage = selectedMessages;
    NSMutableArray *nameList = [NSMutableArray array];
    for (int i = 0 ; i < selectedMessage.count ; i ++) {
        RCMessageModel *messageModel = [selectedMessage objectAtIndex:i];
        //组装名字
        if (forwardConversationType == ConversationType_GROUP) {
            RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:messageModel.targetId];
            if (![nameList containsObject:groupInfo.groupName]) {
                [nameList addObject:groupInfo.groupName];
            }
        }
    }
    if (forwardConversationType == ConversationType_PRIVATE) {
        RCUserInfo *targetUserInfo = [[RCIM sharedRCIM] getUserInfoCache:targetId];
        NSString *targetUserName = targetUserInfo.name;
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:RCIM.sharedRCIM.currentUserInfo.userId];
        NSString *currentUserName = userInfo.name;
        [nameList addObject:targetUserName];
        [nameList addObject:currentUserName];
    }
    return [nameList copy];
}


- (NSString *)getCombineMessageSummaryContent:(NSArray *)summaryList {
    if (!summaryList.count) {
        return @"";
    }
    NSMutableString * summaryContent = [[NSMutableString alloc] init];
    for (int i = 0; i < summaryList.count ; i ++) {
        NSString *summary = [summaryList objectAtIndex:i];
        [summaryContent appendString:summary];
        if (i <summaryList.count - 1) {
            [summaryContent appendString:@"\n"];
        }
    }
    return [summaryContent copy];
}

- (void)forwardWithConversationType:(RCConversationType)type targetId:(NSString *)targetId content:(RCMessageContent *)content isCombine:(BOOL)isCombine {
    [[RCIM sharedRCIM] sendMessage:type targetId:targetId content:content pushContent:nil pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
    [NSThread sleepForTimeInterval:0.4];
}

#pragma mark - 获取chatContentId

- (void)getMessageChatContentIdWithParamDict:(NSDictionary *)aParamDic isSaveDoc:(BOOL)isSaveDoc completion:(CMPGetMessageChatContentIdDoneBlock)block {
    NSString *url = [CMPCore fullUrlForPath:kCMPGetMessageChatContentIdUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    if (isSaveDoc) {
        NSMutableDictionary *mutableParamDic = [aParamDic mutableCopy];
        mutableParamDic[@"isSaveDoc"] = @"1";
        aParamDic = [mutableParamDic copy];
    }
    aDataRequest.requestParam = [aParamDic JSONRepresentation];
    aDataRequest.userInfo = @{@"block" : [block copy]};
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    CMPGetMessageChatContentIdDoneBlock block = aRequest.userInfo[@"block"];
    NSDictionary *responseDic = [aResponse.responseStr JSONValue];
    NSString *chatContentId = [responseDic[@"data"] stringValue];
    if (block) {
        block(chatContentId,nil);
    }

}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    CMPGetMessageChatContentIdDoneBlock block = aRequest.userInfo[@"block"];
    if (block) {
        block(nil,error);
    }
}

@end
