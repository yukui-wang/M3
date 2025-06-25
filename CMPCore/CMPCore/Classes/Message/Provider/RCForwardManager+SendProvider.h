//
//  RCForwardManager+SendProvider.h
//  M3
//
//  Created by 程昆 on 2019/11/5.
//


#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ContentModel;

typedef void(^CMPGetMessageChatContentIdDoneBlock)(NSString * _Nullable chatContentId, NSError * _Nullable error);

@interface RCForwardManager (SendProvider)

- (NSString *)getCombineMessageSummaryTitle:(NSArray *)nameList forwardConversationType:(RCConversationType)forwardConversationType targetId:(NSString *)targetId;
+ (NSString *)packageContent:(ContentModel *)contentModel;
- (NSString *)getCombineMessageSummaryTitleWithSelectedMessages:(NSArray<RCMessageModel *> *)selectedMessages forwardConversationType:(RCConversationType)forwardConversationType targetId:(NSString *)targetId;
- (void)turnOnOpinion:(NSArray *)messageList targetId:(NSString *)targetId  forwardConversationType:(RCConversationType)forwardConversationType completion:(CMPGetMessageChatContentIdDoneBlock)block;
- (void)collectionChatRecord:(NSArray *)messageList targetId:(NSString *)targetId  forwardConversationType:(RCConversationType)forwardConversationType completion:(CMPGetMessageChatContentIdDoneBlock)block;

@end

NS_ASSUME_NONNULL_END
