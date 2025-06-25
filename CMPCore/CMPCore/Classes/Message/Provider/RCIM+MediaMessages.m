//
//  RCIM+MediaMessages.m
//  M3
//
//  Created by 程昆 on 2020/1/13.
//

#import "RCIM+MediaMessages.h"
#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPImageBrowseCellDataModel.h>
#import "CMPVideoMessage.h"
#import "CMPMessageManager.h"
#import <CMPLib/CMPCommonTool.h>


@implementation RCIM (MediaMessages)

- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  {
   return [self getMediaMessagesWithTargetId:targetId conversationType:conversationType currentMessageId:0];
}

// 获取会话中所有的图片和GIF
- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId {
    NSArray *objectNames = @[[RCImageMessage getObjectName],[RCGIFMessage getObjectName]];
    NSDictionary *returnValue = [self getMediaMessagesWithTargetId:targetId conversationType:conversationType currentMessageId:messageId objectNames:objectNames];
    return returnValue;
    
}

// 获取会话中所有的 图片/gif/视频 类型的消息
- (NSDictionary *)getPicAndVideoMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId {
    NSArray *objectNames = @[[RCImageMessage getObjectName],[RCGIFMessage getObjectName],[CMPVideoMessage getObjectName]];
    NSDictionary *returnValue = [self getMediaMessagesWithTargetId:targetId conversationType:conversationType currentMessageId:messageId objectNames:objectNames];
    return returnValue;
}
// 获取会话中所有的指定类型的消息
- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId objectNames:(NSArray *)objectNames {
    long lastestMessageId = [[RCIMClient sharedRCIMClient] getConversation:conversationType targetId:targetId].lastestMessageId;
    RCMessageModel *model = [[RCMessageModel alloc] initWithMessage:[[RCIMClient sharedRCIMClient] getMessage:lastestMessageId]];
    
    NSArray *imageArrayForward = [[RCIMClient sharedRCIMClient]
                                  getHistoryMessages:model.conversationType
                                  targetId:model.targetId
                                  objectNames:objectNames
                                  sentTime:model.sentTime
                                  isForward:YES
                                  count:INT_MAX];
    
    NSMutableArray *ImageArr = [[NSMutableArray alloc] init];
    for (NSInteger j = [imageArrayForward count] - 1; j >= 0; j--) {
        RCMessage *rcMsg = [imageArrayForward objectAtIndex:j];
        if (rcMsg.content) {
            RCMessageModel *modelindex = [RCMessageModel modelWithMessage:rcMsg];
            [ImageArr addObject:modelindex];
        }
    }
    if ([model.content isMemberOfClass:[RCImageMessage class]] || [model.content isMemberOfClass:[RCGIFMessage class]] || [model.content isMemberOfClass:[CMPVideoMessage class]]) {
        [ImageArr addObject:model];
    }
    
    NSMutableArray *imageUrlArr = [NSMutableArray array];
    __block NSInteger currentIndex = 0;
    
    [ImageArr enumerateObjectsUsingBlock:^(RCMessageModel *aModel, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *from = [RCIM getFileFromWithMsgModel:aModel targetId:targetId conversationType:conversationType];
        NSString *fromType = [RCIM getFileFromTypeWithMsgModel:aModel targetId:targetId conversationType:conversationType];
        RCMessageContent *content = aModel.content;
        NSString *fileId;
        NSString *fileName;
        NSString *originUrlStr;
        NSString *videoLocalPath;
        long long fileSize = 0;
        id thumbObject = nil;
        if ([content isMemberOfClass:[RCImageMessage class]]) {
            RCImageMessage *imageMessage = (RCImageMessage *)content;
            fileId = [CMPCommonTool getSourceIdWithUrl:imageMessage.imageUrl];
            NSString *imageUrl = [RCIM rcAttachmentFileUrlWithFileId:fileId];
            //imageMessage.imageUrl = imageUrl;
            
            fileName = imageMessage.localPath.lastPathComponent;
            NSDictionary *extraDic = [imageMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName] || [NSString isNull:fileName.pathExtension]) {
                fileName = [NSString stringWithFormat:@"%@.png",fileId];
            }
            originUrlStr = imageUrl;
//            thumbObject = [imageMessage performSelector:@selector(thumbnailBase64String)];
            thumbObject = imageMessage.thumbnailImage;
        }
        
        if ([content isMemberOfClass:[RCGIFMessage class]]) {
            RCGIFMessage *GIFMessage = (RCGIFMessage *)content;
            fileId = [CMPCommonTool getSourceIdWithUrl:GIFMessage.remoteUrl];
            NSString *imageUrl = [RCIM rcAttachmentFileUrlWithFileId:fileId];
//            GIFMessage.remoteUrl = imageUrl;
            
            fileName = GIFMessage.localPath.lastPathComponent;
            NSDictionary *extraDic = [GIFMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName]) {
                fileName = [NSString stringWithFormat:@"%@.gif",fileId];
            }
            originUrlStr = imageUrl;
        }
        
        if ([content isMemberOfClass:[CMPVideoMessage class]]) {
            CMPVideoMessage *videoMessage = (CMPVideoMessage *)content;
            fileSize = videoMessage.size;
            fileId = [CMPCommonTool getSourceIdWithUrl:videoMessage.remoteUrl];
            NSString *videoUrl =[RCIM rcAttachmentFileUrlWithFileId:fileId];
//            videoMessage.remoteUrl = videoUrl;
            fileName = videoMessage.name;
            NSDictionary *extraDic = [videoMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName]) {
                fileName = [NSString stringWithFormat:@"%@.mp4",fileId];
            }
            originUrlStr = videoUrl;
            thumbObject = videoMessage.videoThumImage;
            videoLocalPath = videoMessage.localPath;
        }
        
        NSString *time = @"";
        NSDateFormatter *formatter = NSDateFormatter.alloc.init;
        formatter.dateFormat = @"yyyy-MM";
        if (aModel.messageDirection == MessageDirection_SEND) {
            time = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:aModel.sentTime/1000]];
        }else {
            time = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:aModel.receivedTime/1000]];
        }
        CMPImageBrowseCellDataModel *dataModel = [[CMPImageBrowseCellDataModel alloc] init];
        dataModel.showUrlStr = originUrlStr;
        dataModel.originUrlStr = originUrlStr;
        dataModel.thumbObject = thumbObject;
        dataModel.filenName = fileName;
        dataModel.from = from;
        dataModel.fromType = fromType;
        dataModel.time = time;
        dataModel.videoLocalPath = videoLocalPath;
        dataModel.fileId = fileId;
        dataModel.fileSize = fileSize;
        
        [imageUrlArr addObject:dataModel];
        
        RCMessageModel *modelindex1 = [ImageArr objectAtIndex:idx];
        if (messageId == modelindex1.messageId && messageId) {
            currentIndex = idx;
        }
        
    }];
    
    NSDictionary *returnValue = @{
                                  @"imageUrlArr" : [imageUrlArr copy],
                                  @"currentIndex" : [NSNumber numberWithInteger:currentIndex],
                                  @"rcMessageModels" : [ImageArr copy]
                                  };
    return returnValue;
    
}

+ (NSString *)rcAttachmentFileUrlWithFileId:(NSString *)fileId {
    NSString *attachmentFileUrl = [CMPCore fullUrlForPathFormat:@"/rest/attachment/file/%@",fileId];
    attachmentFileUrl = [attachmentFileUrl appendHtmlUrlParam:@"ucFlag" value:@"yes"];
    return attachmentFileUrl;
}

/// 获取文件来源
/// @param model msgModel
+ (NSString *)getFileFromWithMsgModel:(RCMessageModel *)model targetId:(NSString *)targetId conversationType:(RCConversationType)conversationType {
    CMPMessageObject *messageObject = [[CMPMessageManager sharedManager] messageWithAppID:targetId];
    if ([targetId isEqualToString:CMP_USERID]) {
        return SY_STRING(messageObject.appName);
    }
    return messageObject.appName;
}

/// 获取文件来源类型
/// @param model msgModel
+ (CMPFileFromType)getFileFromTypeWithMsgModel:(RCMessageModel *)model targetId:(NSString *)targetId conversationType:(RCConversationType)conversationType {
    NSString *fromType = nil;
    if (model.messageDirection == MessageDirection_SEND) {
        if (conversationType == ConversationType_PRIVATE) {
            fromType = CMPFileFromTypeSendToUC;
        }else {
            fromType = CMPFileFromTypeSendToUCGroup;
        }
        
    }else {
        
        if (conversationType == ConversationType_PRIVATE) {
            fromType = CMPFileFromTypeComeFromUC;
        }else {
            fromType = CMPFileFromTypeComeFromUCGroup;
        }
    }
    
    
    return fromType;
}


+(NSArray<CMPImageBrowseCellDataModel *> *)transferRcMediaMessageModelToMediaBrowseCellDataModel:(NSArray<RCMessageModel *> *)rcMsgModels
{
    if (!rcMsgModels || !rcMsgModels.count) {
        return @[];
    }
    NSMutableArray *imageUrlArr = [NSMutableArray array];
    
    [rcMsgModels enumerateObjectsUsingBlock:^(RCMessageModel *aModel, NSUInteger idx, BOOL * _Nonnull stop) {
        RCMessageContent *content = aModel.content;
        NSString *fileId;
        NSString *fileName;
        NSString *originUrlStr;
        NSString *videoLocalPath;
        long long fileSize = 0;
        id thumbObject = nil;
        if ([content isMemberOfClass:[RCImageMessage class]]) {
            RCImageMessage *imageMessage = (RCImageMessage *)content;
            if ([imageMessage.imageUrl containsString:@"://"]) {
                fileId = [CMPCommonTool getSourceIdWithUrl:imageMessage.imageUrl];
                originUrlStr = imageMessage.imageUrl;
            }else{
                fileId = imageMessage.imageUrl;
                originUrlStr = [self rcAttachmentFileUrlWithFileId:fileId];
            }
            
            fileName = imageMessage.localPath.lastPathComponent;
            NSDictionary *extraDic = [imageMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName] || [NSString isNull:fileName.pathExtension]) {
                fileName = [NSString stringWithFormat:@"%@.png",fileId];
            }
            thumbObject = imageMessage.thumbnailImage;
        }else
        
        if ([content isMemberOfClass:[RCGIFMessage class]]) {
            RCGIFMessage *GIFMessage = (RCGIFMessage *)content;
            if ([GIFMessage.remoteUrl containsString:@"://"]) {
                fileId = [CMPCommonTool getSourceIdWithUrl:GIFMessage.remoteUrl];
                originUrlStr = GIFMessage.remoteUrl;
            }else{
                fileId = GIFMessage.remoteUrl;
                originUrlStr = [self rcAttachmentFileUrlWithFileId:fileId];
            }
            
            fileName = GIFMessage.localPath.lastPathComponent;
            NSDictionary *extraDic = [GIFMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName]) {
                fileName = [NSString stringWithFormat:@"%@.gif",fileId];
            }
        }else
        
        if ([content isMemberOfClass:[CMPVideoMessage class]]) {
            CMPVideoMessage *videoMessage = (CMPVideoMessage *)content;
            fileSize = videoMessage.size;
            if ([videoMessage.remoteUrl containsString:@"://"]) {
                fileId = [CMPCommonTool getSourceIdWithUrl:videoMessage.remoteUrl];
                originUrlStr =videoMessage.remoteUrl;
            }else{
                fileId = videoMessage.remoteUrl;
                originUrlStr =[self rcAttachmentFileUrlWithFileId:fileId];
            }
            fileName = videoMessage.name;
            NSDictionary *extraDic = [videoMessage.extra JSONValue];
            if (extraDic[@"fileName"]) {
                fileName = extraDic[@"fileName"];
            }
            if ([NSString isNull:fileName]) {
                fileName = [NSString stringWithFormat:@"%@.mp4",fileId];
            }
            thumbObject = videoMessage.videoThumImage;
            videoLocalPath = videoMessage.localPath;
        }
        
        NSString *time = @"";
        NSDateFormatter *formatter = NSDateFormatter.alloc.init;
        formatter.dateFormat = @"yyyy-MM";
        if (aModel.messageDirection == MessageDirection_SEND) {
            time = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:aModel.sentTime/1000]];
        }else {
            time = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:aModel.receivedTime/1000]];
        }
        
        NSString *from = [RCIM getFileFromWithMsgModel:aModel targetId:aModel.targetId conversationType:aModel.conversationType];
        NSString *fromType = [RCIM getFileFromTypeWithMsgModel:aModel targetId:aModel.targetId conversationType:aModel.conversationType];
        
        CMPImageBrowseCellDataModel *dataModel = [[CMPImageBrowseCellDataModel alloc] init];
        dataModel.showUrlStr = originUrlStr;
        dataModel.originUrlStr = originUrlStr;
        dataModel.thumbObject = thumbObject;
        dataModel.filenName = fileName;
        dataModel.from = from;
        dataModel.fromType = fromType;
        dataModel.time = time;
        dataModel.videoLocalPath = videoLocalPath;
        dataModel.fileId = fileId;
        dataModel.fileSize = fileSize;
        
        [imageUrlArr addObject:dataModel];
        
    }];
    return imageUrlArr;
}

+ (NSArray<CMPImageBrowseCellDataModel *> *)getSomeMediaBrowseCellDataModelsFromModel:(RCMessageModel *)model
{
    NSArray *arr = [self getSomeMediaMessagesFromModel:model];
    NSArray *result = [self transferRcMediaMessageModelToMediaBrowseCellDataModel:arr];
    return result;
}

+(NSInteger)rcModel:(RCMessageModel *)model indexInArr:(NSArray<RCMessageModel *>*)arr
{
    if (!model || !arr ||arr.count == 0) {
        return 0;
    }
    __block NSInteger index = 0;
    [arr enumerateObjectsUsingBlock:^(RCMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.messageId == obj.messageId) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

////取当前界面中一定数量的图片
+ (NSArray<RCMessageModel *> *)getSomeMediaMessagesFromModel:(RCMessageModel *)model {
    if (!model) {
        NSLog(@"传入的参数不允许是 nil");
        return @[];
    }
    NSMutableArray *ImageArr = [[NSMutableArray alloc] init];
    NSArray *imageArrayForward = [RCIM getOlderMediaMessagesThanModel:model count:5 times:0];
    NSArray *imageArrayBackward = [RCIM getLaterMediaMessagesThanModel:model count:5 times:0];
    for (NSInteger j = [imageArrayForward count] - 1; j >= 0; j--) {
        RCMessage *rcMsg = [imageArrayForward objectAtIndex:j];
        if (rcMsg.content) {
            RCMessageModel *modelindex = [RCMessageModel modelWithMessage:rcMsg];
            [ImageArr addObject:modelindex];
        }
    }
    [ImageArr addObject:model];
    for (int i = 0; i < [imageArrayBackward count]; i++) {
        RCMessage *rcMsg = [imageArrayBackward objectAtIndex:i];
        if (rcMsg.content) {
            RCMessageModel *modelindex = [RCMessageModel modelWithMessage:rcMsg];
            [ImageArr addObject:modelindex];
        }
    }
    return ImageArr;
}

+ (NSArray<RCMessageModel *> *)getLaterMediaMessagesThanModel:(RCMessageModel *)model
                                                   count:(NSInteger)count
                                                   times:(int)times {
    NSArray<RCMessageModel *> *imageArrayBackward =
        [[RCIMClient sharedRCIMClient] getHistoryMessages:model.conversationType
                                                 targetId:model.targetId
                                               objectNames:[self _mediaObjectNames] sentTime:model.sentTime isForward:false count:(int)count];
    NSArray *messages = [self filterBurnImageMessage:imageArrayBackward];
    if (times < 2 && messages.count == 0 && imageArrayBackward.count == count) {
        messages = [self getLaterMediaMessagesThanModel:imageArrayBackward.lastObject count:count times:times + 1];
    }
    return messages;
}

+ (NSArray<RCMessageModel *> *)getOlderMediaMessagesThanModel:(RCMessageModel *)model
                                                   count:(NSInteger)count
                                                   times:(int)times {
    NSArray<RCMessageModel *> *imageArrayForward =
        [[RCIMClient sharedRCIMClient] getHistoryMessages:model.conversationType
                                                 targetId:model.targetId
                                               objectNames:[self _mediaObjectNames] sentTime:model.sentTime isForward:true count:(int)count];
    NSArray *messages = [self filterBurnImageMessage:imageArrayForward];
    if (times < 2 && imageArrayForward.count == count && messages.count == 0) {
        messages = [self getOlderMediaMessagesThanModel:imageArrayForward.lastObject count:count times:times + 1];
    }
    return messages;
}

//过滤阅后即焚图片消息
+ (NSArray *)filterBurnImageMessage:(NSArray *)array {
    NSMutableArray *backwardMessages = [NSMutableArray array];
    for (RCMessageModel *model in array) {
        if (!(model.content.destructDuration > 0)) {
            [backwardMessages addObject:model];
        }
    }
    return backwardMessages.copy;
}

+(NSArray *)_mediaObjectNames
{
    NSArray *objectNames = @[[RCImageMessage getObjectName],[RCGIFMessage getObjectName],[CMPVideoMessage getObjectName]];
    return objectNames;
}

@end
