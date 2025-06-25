//
//  CMPChatListViewModel.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2022/9/23.
//

#import "CMPChatListViewModel.h"
#import "CMPRCChatCommonDataProvider.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPMessageObject.h"
#import "CMPMessageManager.h"
#import "CMPChatManager.h"
#import "CMPRCGroupMemberObject.h"

@interface CMPChatListViewModel()
{
    NSArray *_needUpdateGroupChatObjList;
    NSArray *_needCheckGroupIfContainMeChatObjList;
}
@property (nonatomic,strong) CMPRCChatCommonDataProvider *dataProvider;
@property (nonatomic,strong) __block NSMutableArray *serverTopArr;

@end

@implementation CMPChatListViewModel

-(void)fetchGroupsInfoByChats:(NSArray<CMPMessageObject *> *)chats completion:(CommonCompletionBlk)completion
{
    if (!chats || chats.count == 0) {
        return;
    }
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        return;
    }
    NSMutableArray *gids = [NSMutableArray array];
    NSMutableArray *gObjArr = [NSMutableArray array];
    [chats enumerateObjectsUsingBlock:^(CMPMessageObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CMPMessageTypeRC && obj.subtype == CMPRCConversationType_GROUP) {
            if (!obj.groupTypeInfo.isMarked) {
                [gids addObject:obj.cId];
                [gObjArr addObject:obj];
            }
        }
    }];
    if (gids.count == 0) {
        return;
    }
    _needUpdateGroupChatObjList = gObjArr;
    
    [self.dataProvider fetchGroupsInfoByParams:@{@"gids":gids} result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData) {
            if ([respData isKindOfClass:NSDictionary.class] && ((NSDictionary *)respData).count >0) {
                NSMutableDictionary *dbResultDic = [NSMutableDictionary dictionary];
                [self->_needUpdateGroupChatObjList enumerateObjectsUsingBlock:^(CMPMessageObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *aOb = respData[obj.cId];
                    if (aOb && [aOb isKindOfClass:NSDictionary.class] && aOb[@"groupType"]) {
                        NSDictionary *finalVal = @{@"tag":@"1",@"val":@{@"groupType":aOb[@"groupType"]}};
                        [obj updateGroupTypeInfo:finalVal];
                        [dbResultDic setObject:[finalVal JSONRepresentation] forKey:obj.cId];
                    }
                }];
                [[CMPMessageManager sharedManager] updateGroupConversationTypeInfo:dbResultDic];
            }
        }
        if (completion) {
            completion(respData,error,ext);
        }
    }];
}

-(void)checkGroupsIfContainMeByChats:(NSArray<CMPMessageObject *> *)chats completion:(CommonCompletionBlk)completion
{
    if (!chats || chats.count == 0) {
        return;
    }
    if (![CMPServerVersionUtils serverIsLaterV8_2]) {
        return;
    }
    NSMutableArray *gids = [NSMutableArray array];
    NSMutableArray *gObjArr = [NSMutableArray array];
    [chats enumerateObjectsUsingBlock:^(CMPMessageObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CMPMessageTypeRC && obj.subtype == CMPRCConversationType_GROUP) {
            [gids addObject:obj.cId];
            [gObjArr addObject:obj];
        }
    }];
    if (gids.count == 0) {
        return;
    }
    _needCheckGroupIfContainMeChatObjList = gObjArr;
    
    [self.dataProvider fetchGroupsInfoByParams:@{@"gids":gids} result:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error && respData) {
            if ([respData isKindOfClass:NSDictionary.class] && ((NSDictionary *)respData).count >0) {
                NSMutableArray *needRemoveArr = [NSMutableArray array];
                [self->_needCheckGroupIfContainMeChatObjList enumerateObjectsUsingBlock:^(CMPMessageObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //ks fix --(此接口获取到的人员列表更新不及时) V5-39281 iosM3查看群消息后，对话框会从会话列表中消失
                    if ((obj.groupTypeInfo && obj.groupTypeInfo.groupType == 1)
                        || obj.extradDataModel.groupInfo.enumGroupType == 1) {
                        NSDictionary *aOb = respData[obj.cId];
                        if (aOb && [aOb isKindOfClass:NSDictionary.class]) {
                            NSArray *memberArray = aOb[@"memberArray"];
                            if (memberArray && [memberArray isKindOfClass:NSArray.class]) {
                                if (![memberArray containsObject:[CMPCore sharedInstance].userID]) {
                                    [needRemoveArr addObject:obj];
                                }
                            }
                        }
                    }
                }];
                if (needRemoveArr.count) {
                    [[CMPChatManager sharedManager] deleteMessageObjects:needRemoveArr];
                }
            }
        }
        if (completion) {
            completion(respData,error,ext);
        }
    }];
}


- (void)fetchAllTopChatListWithCompletion:(CommonCompletionBlk)result
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (result) {
            result(nil,[CMPServerVersionUtils versionIsLowError],nil);
        }
        return;
    }
    __weak typeof(self) wSelf = self;
    if (!CMPCore.sharedInstance.jsessionId) {
        return;
    }
    [self.dataProvider fetchAllTopChatListWithCompletion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (result && !error) {
            //数组 {"talkId" : "-7013102407412069288","talkType" : 0,"recordValue" : 1690191209}
            //拿去本地所有置顶列表，比较合并，将服务器没有的本地数据，保存到服务器
            NSArray *serverTopArr = respData;
            [wSelf.serverTopArr removeAllObjects];
            [wSelf.serverTopArr addObjectsFromArray:serverTopArr];
            [[CMPMessageManager sharedManager] allMessageList:^(NSArray<CMPMessageObject *> *chatList) {
                [wSelf handleTopChatWithLocalData:chatList];
            }];
        }
    }];
}

-(void)handleTopChatWithLocalData:(NSArray<CMPMessageObject *> *)chatList
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        return;
    }
    if (!chatList || chatList.count == 0) {
        return;
    }
    if (!_serverTopArr) {
        return;
    }
    NSString *userid = [CMPCore sharedInstance].userID;
    NSString *key = [@"hebingtoplist_" stringByAppendingString:userid];
    NSString *localTag = [UserDefaults objectForKey:key];
    localTag = localTag ? : @"";
    BOOL isSyned = [@"1" isEqualToString:localTag];
    __weak typeof(self) wSelf = self;
    [self dispatchAsyncToMain:^{
        NSArray *serverTopArr = wSelf.serverTopArr;
        NSMutableArray *serverTopIds = [NSMutableArray array];
        for (NSDictionary *item in serverTopArr) {
            if (item[@"talkId"]) {
                [serverTopIds addObject:item[@"talkId"]];
            }
        }
        NSMutableArray *arr = [NSMutableArray array], *arr2 = [NSMutableArray array], *arr3 = [NSMutableArray array];
        NSMutableArray *localTopExceptServerArr = [NSMutableArray array];
        for (CMPMessageObject *msg in chatList) {
            if (msg.type == CMPMessageTypeRC && (msg.subtype == CMPRCConversationType_GROUP ||msg.subtype == CMPRCConversationType_PRIVATE )) {
                [arr addObject:msg.cId];
                BOOL conain = [serverTopIds containsObject:msg.cId];
                if (conain) {
                    [arr3 addObject:msg.cId];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSInteger index = [serverTopIds indexOfObject:msg.cId];
                        NSDictionary *serverTopInfo = serverTopArr[index];
                        NSString *talkId = serverTopInfo[@"talkId"];
                        NSInteger talkType = [serverTopInfo[@"talkType"] integerValue];
                        long long recordValue = [serverTopInfo[@"recordValue"] longLongValue];
                        NSString *conversationType = (talkType == 0) ? kChatManagerRCChatTypePrivate : kChatManagerRCChatTypeGroup;
                        [[CMPChatManager sharedManager] setChatTopStatus:@"1" targetId:talkId type:conversationType ext:@{@"serverTopTime":@(recordValue)}];
                    });
                } else {
                    if (msg.isTop && !isSyned) {
                        [arr2 addObject:msg.cId];
                        [localTopExceptServerArr addObject:@{@"talkId":msg.cId,
                                                             @"talkType":@(msg.subtype == CMPRCConversationType_PRIVATE ? 0 : 1),
                                                             @"recordValue":@(-(msg.topSort))
                                                           }];
                    }
                }
            }
        }
        if (localTopExceptServerArr.count) {
            NSLog(@"所有本地有服务器没有的置顶会话数组:%@",localTopExceptServerArr);
            [self saveLocalChatsTopStatesByValues:localTopExceptServerArr completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                if (!error) {
                    [UserDefaults setObject:@"1" forKey:key];
                    [UserDefaults synchronize];
                }
            }];
        }else{
            [UserDefaults setObject:@"1" forKey:key];
            [UserDefaults synchronize];
        }
        NSLog(@"所有服务器置顶会话id:%@",serverTopIds);
        NSLog(@"所有本地会话id:%@",arr);
        NSLog(@"所有服务器有本地需要置顶会话id:%@",arr3);
        NSLog(@"所有本地有服务器没有的置顶会话id:%@",arr2);
    }];
}

- (void)saveChatTopStateByCid:(NSString *)cid
                        state:(NSInteger)state
                   completion:(CommonCompletionBlk)result
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (result) {
            result(nil,[CMPServerVersionUtils versionIsLowError],nil);
        }
        return;
    }
    [self.dataProvider saveChatTopStateByCid:cid state:state completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (result) {
            result(respData,error,ext);
        }
    }];
}

- (void)saveLocalChatsTopStatesByValues:(NSArray *)values
                   completion:(CommonCompletionBlk)result
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (result) {
            result(nil,[CMPServerVersionUtils versionIsLowError],nil);
        }
        return;
    }
    [self.dataProvider saveLocalChatsTopStatesByValues:values completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (result) {
            result(respData,error,ext);
        }
    }];
}

- (void)signChatToUnreadByCid:(NSString *)cid isUnread:(BOOL)isUnread completion:(CommonCompletionBlk)result
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (result) {
            result(nil,[CMPServerVersionUtils versionIsLowError],nil);
        }
        return;
    }
    [self.dataProvider signChatToUnreadByCid:cid isUnread:isUnread completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (result) {
            result(respData,error,ext);
        }
    }];
}

- (void)deleteChatByCid:(NSString *)cid completion:(CommonCompletionBlk)result
{
    if (![CMPServerVersionUtils serverIsLaterV8_2_810]) {
        if (result) {
            result(nil,[CMPServerVersionUtils versionIsLowError],nil);
        }
        return;
    }
    [self.dataProvider deleteChatByCid:cid completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (result) {
            result(respData,error,ext);
        }
    }];
}

-(CMPRCChatCommonDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPRCChatCommonDataProvider alloc] init];
    }
    return _dataProvider;
}

-(NSMutableArray *)serverTopArr
{
    if (!_serverTopArr) {
        _serverTopArr = [[NSMutableArray alloc] init];
    }
    return _serverTopArr;
}

@end
