//
//  RCIM+MediaMessages.h
//  M3
//
//  Created by 程昆 on 2020/1/13.
//

#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPStringConst.h>
@class CMPImageBrowseCellDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface RCIM (MediaMessages)

/// / 获取会话中所有的图片和GIF
/// @param targetId
/// @param conversationType
/// @param messageId
- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId;

/// 获取文件来源
+ (NSString *)getFileFromWithMsgModel:(RCMessageModel *)model targetId:(NSString *)targetId conversationType:(RCConversationType)conversationType;
/// 获取文件来源类型
+ (CMPFileFromType)getFileFromTypeWithMsgModel:(RCMessageModel *)model targetId:(NSString *)targetId conversationType:(RCConversationType)conversationType;
- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType;
// 获取会话中所有的 图片/gif/视频 类型的消息
- (NSDictionary *)getPicAndVideoMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId;
// 获取会话中所有的指定类型的消息
- (NSDictionary *)getMediaMessagesWithTargetId:(NSString *)targetId conversationType:(RCConversationType)conversationType  currentMessageId:(long)messageId objectNames:(NSArray *)objectNames;

//ks add --- fix preview image slow when too many images
+ (NSArray<CMPImageBrowseCellDataModel *> *)getSomeMediaBrowseCellDataModelsFromModel:(RCMessageModel *)model;
+ (NSArray<RCMessageModel *> *)getSomeMediaMessagesFromModel:(RCMessageModel *)model;
+(NSInteger)rcModel:(RCMessageModel *)model indexInArr:(NSArray<RCMessageModel *>*)arr;
+(NSArray<CMPImageBrowseCellDataModel *> *)transferRcMediaMessageModelToMediaBrowseCellDataModel:(NSArray<RCMessageModel *> *)rcMsgModels;
+ (NSArray<RCMessageModel *> *)getLaterMediaMessagesThanModel:(RCMessageModel *)model
                                                   count:(NSInteger)count
                                                        times:(int)times;
+ (NSArray<RCMessageModel *> *)getOlderMediaMessagesThanModel:(RCMessageModel *)model
                                                   count:(NSInteger)count
                                                        times:(int)times;

@end

NS_ASSUME_NONNULL_END
