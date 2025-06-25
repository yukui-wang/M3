//
//  CMPChatListViewModel.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/23.
//

#import <CMPLib/CMPBaseViewModel.h>

@class CMPMessageObject;

NS_ASSUME_NONNULL_BEGIN

@interface CMPChatListViewModel : CMPBaseViewModel

-(void)fetchGroupsInfoByChats:(NSArray<CMPMessageObject *> *)chats
                   completion:(CommonCompletionBlk)completion;
/**
 检查群组是否包含自己，如果不包含则删除操作
 */
-(void)checkGroupsIfContainMeByChats:(NSArray<CMPMessageObject *> *)chats
                          completion:(CommonCompletionBlk)completion;

- (void)fetchAllTopChatListWithCompletion:(CommonCompletionBlk)result;

- (void)saveChatTopStateByCid:(NSString *)cid
                        state:(NSInteger)state
                   completion:(CommonCompletionBlk)result;

- (void)signChatToUnreadByCid:(NSString *)cid isUnread:(BOOL)isUnread completion:(CommonCompletionBlk)result;

- (void)deleteChatByCid:(NSString *)cid completion:(CommonCompletionBlk)result;

-(void)handleTopChatWithLocalData:(NSArray<CMPMessageObject *> *)chatList;

@end

NS_ASSUME_NONNULL_END
