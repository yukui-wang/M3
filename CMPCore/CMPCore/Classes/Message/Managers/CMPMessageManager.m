//
//  CMPMessageManager.m
//  CMPCore
//
//  Created by wujiansheng on 2017/6/28.
//
//

#define kTopTag_Top 1
#define kTopTag_NotTop 0
#define kNotification_DeleteMsg @"com.seeyon.m3.message.statusChange"
#define kMessageRequestTimeInterval 30

#define kSshortcutItem_M3 @"kSshortcutItem_M3"

#import "CMPMessageManager.h"
#import <CMPLib/JSONKit.h>
#import "CMPMessageObject.h"
#import "CMPChatManager.h"
#import "CMPRCTargetObject.h"
#import "CMPRCGroupNotificationViewController.h"

#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPMessageWebViewController.h"

#import "AppDelegate.h"

#import "CMPScanWebViewController.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPReadedMessage.h"
#import "CMPRCUserCacheManager.h"
#import "CMPRCGroupNotificationManager.h"
#import <CMPLib/CMPAppListModel.h>

#import "CMPMessageDbProvider.h"
#import <CMPLib/MSWeakTimer.h>
#import "CMPV5MessageProvider.h"
#import "CMPAggregationMessageViewController.h"
#import "CMPPushConfigProvider.h"
#import "CMPMessageAlertTool.h"
#import <CMPLib/CMPAssociateAccountModel.h>
#import "CMPAssociateAccountMessageViewController.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPCheckUpdateManager.h"
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPWaterMarkUtil.h>
#import "CMPLoginConfigInfoModel.h"
#import <CMPLib/CMPWebViewUrlUtils.h>
#import "CMPMassNotificationProvider.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "M3-Swift.h"
#import "CMPCore_XiaozhiBridge.h"
#import <CMPLib/CMPFeatureSupportControlHeader.h>
#import "CMPAttachmentHelper.h"
#import "CMPCommonManager.h"
#import "CMPMeetingManager.h"
#import "CMPChatListViewModel.h"

/** V5消息30S轮询一次 **/
static const NSUInteger V5MessagePollingInterval = 30;
/** 关联账号轮询间隔 **/
static const NSUInteger associateMessagePollingInterval = 30;
/** 水印间隔 **/
static NSString * const kWaterMarkInterval = @"      ";

@interface CMPMessageManager ()
{
    dispatch_group_t associateMessagePollingGroup;
}

@property (strong, nonatomic) NSDictionary *localModuleConfig;
@property (strong, nonatomic) NSMutableArray *shortcutItemArray;//快捷模块缓存
@property (strong, nonatomic) NSMutableArray *readedSmartMessageIDs; // 已经弹过的智能消息ID

@property (strong, nonatomic) CMPMessageDbProvider *dbProvider;
@property (strong, nonatomic) CMPV5MessageProvider *V5MessageProvider;
@property (strong, nonatomic) CMPPushConfigProvider *pushConfigProvider;
@property (strong, nonatomic) CMPMassNotificationProvider *massNotificationMessageProvider;
@property (nonatomic, strong) CMPGeneralBusinessMessageProvider *businessMessageProvider;

@property (strong, nonatomic) MSWeakTimer *V5MessagePollingTimer;
@property (strong, nonatomic) MSWeakTimer *associateMessagePollingTimer;
@property (strong, nonatomic) CMPMessageAlertTool *messageAlertTool;
@property (strong, nonatomic) CMPWaterMarkUtil *waterMarkUtil;
 
@property (strong, nonatomic) dispatch_queue_t serialRequestRongCloudMessageQueue;
@property (strong, nonatomic) CMPChatListViewModel *chatListViewModel;

@end

@implementation CMPMessageManager

#pragma mark 单例

static CMPMessageManager *instance = nil;

- (void)dealloc {
    [self userLogout];
}

+ (CMPMessageManager *)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[CMPMessageManager alloc] init];
    });
    return instance;
}

-(CMPChatListViewModel *)chatListViewModel
{
    if (!_chatListViewModel) {
        _chatListViewModel = [[CMPChatListViewModel alloc] init];
    }
    return _chatListViewModel;
}
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)begin {
    [self userLogout];
    _dbProvider = [[CMPMessageDbProvider alloc] init];
    _V5MessageProvider = [[CMPV5MessageProvider alloc] init];
    _massNotificationMessageProvider = [[CMPMassNotificationProvider alloc] init];
    _businessMessageProvider = [[CMPGeneralBusinessMessageProvider alloc] init];
    [[CMPChatManager sharedManager].groupNotificationManager setDataQueue:[self.dbProvider dataQueue]];
    [[CMPChatManager sharedManager].groupNotificationManager createSqlite];
    [self registNotification];
    [self updatePushConfig];
    [CMPCore sharedInstance].messageIdentifier = @"0";
    [self.V5MessageProvider requestMessageCompletion:^(NSArray *messageList, NSError *error) {
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            [[CMPMessageManager sharedManager] updateMessageSetting];
        }
    }];
    [self startV5MessagePolling];
    [self startAssociateMessagePolling];
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:kNotificationName_UserLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRongCloudMessage) name:kRongCloudReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveXMPPMessage:) name:kXmppDidReceiveMessageToMsg object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIconBadgeAsyncToServer) name:kNotificationName_ApplicationDidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIconBadgeAsyncToServer) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMsgFromTwoLevelMsgView:) name:kNotification_DeleteMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTabBarMsgBadge) name:kNotificationName_TabbarViewControllerDidAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDidUpdate) name:kNotificationName_DBMessageDidUpdate object:nil];
}

- (void)stop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)userLogout {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopV5MessagePolling];
    [self stopAssociateMessagePolling];
    
    _dbProvider = nil;
    _V5MessageProvider = nil;
    [self.shortcutItemArray removeAllObjects];
    self.shortcutItemArray = nil;
    [_readedSmartMessageIDs removeAllObjects];
    _readedSmartMessageIDs = nil;
    _messageAlertTool = nil;
    _waterMarkUtil = nil;
}

/**
 更新消息推送设置
 */
- (void)updatePushConfig {
    [_pushConfigProvider cacelRequest];
    _pushConfigProvider = nil;
    _pushConfigProvider = [[CMPPushConfigProvider alloc] init];
    CMPPushConfigRequest *request = [[CMPPushConfigRequest alloc] init];
    [_pushConfigProvider request:request
                           start:nil
                         success:^(CMPBaseResponse *response, NSDictionary *responseHeaders) {
                             CMPPushConfigResponse *aResponse = (CMPPushConfigResponse *)response;
                             CMPCore *core = [CMPCore sharedInstance];
                             core.pushAcceptInformation = aResponse.mainSwitch;
                             core.pushSoundRemind = aResponse.ringSwitch;
                             core.pushVibrationRemind = aResponse.shakeSwitch;
                             core.startReceiveTime = aResponse.startDate;
                             core.endReceiveTime = aResponse.endDate;
                             core.multiLoginReceivesMessageState = aResponse.multiLoginReceivesMessageState;
                             core.pushConfig = [aResponse yy_modelToJSONString];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AcceptInformationChange object:nil];
                         }
                            fail:nil];
}

- (NSMutableArray *)readedSmartMessageIDs {
    if (!_readedSmartMessageIDs) {
        _readedSmartMessageIDs = [NSMutableArray array];
    }
    return _readedSmartMessageIDs;
}

- (CMPMessageAlertTool *)messageAlertTool {
    if (!_messageAlertTool) {
        _messageAlertTool = [[CMPMessageAlertTool alloc] init];
    }
    return _messageAlertTool;
}

- (dispatch_queue_t)serialRequestRongCloudMessageQueue {
    if (!_serialRequestRongCloudMessageQueue) {
        _serialRequestRongCloudMessageQueue = dispatch_queue_create("com.serialRequestRongCloudMessageQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialRequestRongCloudMessageQueue;
}

#pragma mark-
#pragma mark V5消息

- (void)startV5MessagePolling {
    [self stopV5MessagePolling];
    self.V5MessagePollingTimer = [MSWeakTimer scheduledTimerWithTimeInterval:V5MessagePollingInterval
                                                                      target:self
                                                                    selector:@selector(refreshMessage)
                                                                    userInfo:nil
                                                                     repeats:YES
                                                               dispatchQueue:dispatch_get_main_queue()];
}

- (void)stopV5MessagePolling {
    [self.V5MessagePollingTimer invalidate];
}

- (void)saveMessages:(NSArray<CMPMessageObject *> *)messages {
    [self.dbProvider saveMessages:messages isChat:NO];
}

- (void)saveMessages:(NSArray<CMPMessageObject *> *)messages isChat:(BOOL)isChat{
    [self.dbProvider saveMessages:messages isChat:isChat];
}

static NSInteger _refreshMessageCount;
- (void)refreshMessage {
    NSLog(@"%s",__func__);
    if (![CMPCore sharedInstance].loginSuccessTime) {
        NSLog(@"当前没有登录成功时间，无法请求");
        return;
    }
    NSTimeInterval sp = [[NSDate date] timeIntervalSinceDate:[CMPCore sharedInstance].loginSuccessTime];
    NSLog(@"请求间隔：%f",sp);
    if (sp < 2) {
        NSLog(@"当前登录成功时间间隔小于2s，无法请求");
        return;
    }
    NSString *newssessionid = [CMPCore sharedInstance].anewSessionAfterLogin;
    NSString *cursessionid = [CMPCore sharedInstance].jsessionId;
    NSLog(@"new:%@__cur:%@",newssessionid,cursessionid);
    if ([NSString isNull:newssessionid]
        || [NSString isNull:cursessionid]
        || ![cursessionid isEqualToString:newssessionid]) {
        NSLog(@"当前session有问题，无法请求");
        return;
    }
    if (_refreshMessageCount%4 == 0) {
        [[CMPAttachmentHelper shareManager] updateAttaPreviewConfigWithCompletion:nil];
    }
    _refreshMessageCount ++;
    // 同时更新在线状态 add by guoyl for bug OA-138358，如果是1.8以后的服务器不需要调用
    if (![[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        // 8次消息刷新，做一次在线更新请求
        if (_refreshMessageCount%8 == 0) {
            [self.V5MessageProvider requestUpdateOnlineState];
        }
    }
    // end
    [self.V5MessageProvider requestMessageCompletion:nil];
}

#pragma mark-
#pragma mark 消息操作

- (void)messageList:(void (^)(NSArray *))completion {
    if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        [self.dbProvider messageList:completion];
    } else if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
        [self.dbProvider messageListWithoutAggregationCompletion:completion];
    } else {
        [self.dbProvider messageList:completion];
    }
}

- (void)allMessageList:(void (^)(NSArray *))completion {
    [self.dbProvider messageList:completion];
}

- (void)messageListWithType:(NSInteger)type completion:(void (^)(NSArray *))completion {
    [self.dbProvider messageListWithAggregationType:type completion:completion];
}

- (void)clearV5Message {
    [self.dbProvider deleteV5MessageOnly];
}

// 二级界面删除了，一级界面要处理下
- (void)deleteMsgFromTwoLevelMsgView:(NSNotification *)noti {
    NSDictionary *msg = (NSDictionary *)[noti object];
    NSString *appId = [msg objectForKey:@"appId"];
    NSString *changeType = [msg objectForKey:@"changeType"];
    if ([changeType isEqualToString:@"deleteAll"]) {
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            [self refreshMessage];
        } else {
            [self.dbProvider clearMessageWithAppID:appId];
            [self messageDidUpdate];
        }
    }
}

- (void)deleteMessageWithAppId:(CMPMessageObject *)obj {
    [self.dbProvider deleteMessageWithAppID:obj.cId];
    
    if (obj.type == CMPMessageTypeApp) {
        __weak CMPV5MessageProvider *weakV5Provider = self.V5MessageProvider;
        [self.V5MessageProvider deleteMessageWithAppID:obj.cId completion:^(NSError *error) {
            if (!error) {
                [weakV5Provider requestMessageCompletion:nil];
            }
        }];
    }
    else if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
        [[CMPChatManager sharedManager] removeConversation:obj.subtype targetId:obj.cId];
        [[CMPChatManager sharedManager] sendReadedMessageWithType:(RCConversationType)obj.subtype targetId:obj.cId];
    }
    else if (obj.type == CMPMessageTypeUC) {
        
    } else if (obj.type == CMPMessageTypeRCGroupNotification) {
        [[CMPChatManager sharedManager] readRCGroupNotification];
    }
    
    [self setupTabBarMsgBadge];
}

- (void)deleteMessagesWithObjs:(NSArray<CMPMessageObject *> *)objs {
    if (!objs || objs.count == 0) {
        return;
    }
    for (CMPMessageObject *obj in objs) {
        [self.dbProvider deleteMessageWithAppID:obj.cId];
        
        if (obj.type == CMPMessageTypeApp) {
            __weak CMPV5MessageProvider *weakV5Provider = self.V5MessageProvider;
            [self.V5MessageProvider deleteMessageWithAppID:obj.cId completion:^(NSError *error) {
                if (!error) {
                    [weakV5Provider requestMessageCompletion:nil];
                }
            }];
        }
        else if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
            [[CMPChatManager sharedManager] removeConversation:obj.subtype targetId:obj.cId];
            [[CMPChatManager sharedManager] sendReadedMessageWithType:(RCConversationType)obj.subtype targetId:obj.cId];
        }
        else if (obj.type == CMPMessageTypeUC) {
            
        } else if (obj.type == CMPMessageTypeRCGroupNotification) {
            [[CMPChatManager sharedManager] readRCGroupNotification];
        }
    }
    
    [self setupTabBarMsgBadge];
}

- (void)deleteAppMessage {
    __weak CMPV5MessageProvider *weakV5Provider = self.V5MessageProvider;
    [self.dbProvider appIDsOfAppMessage:^(NSArray *IDs) {
        if (!IDs || IDs.count == 0) {
            return;
        }
        [weakV5Provider deleteMessageWithAppIDs:IDs completion:^(NSError *error) {
            if (!error) {
                [weakV5Provider requestMessageCompletion:nil];
            }
        }];
    }];
    [self.dbProvider deleteAppMessage];
    [self setupTabBarMsgBadge];
}

- (void)topMessage:(CMPMessageObject *)obj {
    if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
        [self.chatListViewModel saveChatTopStateByCid:obj.cId state:obj.isTop completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            if (!error) {
//                [self.dbProvider topMessage:obj];
            }else if (error.code == -1111){
                [self.dbProvider topMessage:obj];
            }else{
                
            }
        }];
    }else{
        [self.dbProvider topMessage:obj];
    }
    
    if ([CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
        if (obj.type == CMPMessageTypeApp) {
            __weak typeof(self) weakSelf = self;
            [self.V5MessageProvider setTopStatus:obj.isTop appID:obj.cId completion:^(NSError *error) {
                [weakSelf refreshMessage];
            }];
        }
    }
}

- (void)onlyLocalTopMessage:(CMPMessageObject *)obj {
    [self.dbProvider topMessage:obj];
}

- (void)remindMessage:(CMPMessageObject *)obj completion:(void(^)(NSError *error))completion {
    __weak __typeof(self)weakSelf = self;
    [self.V5MessageProvider setRemind:[obj.extra2 boolValue] appID:obj.cId completion:^(NSError *error) {
        if (!error) {
            [weakSelf.dbProvider remindMessage:obj];
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)batchUploadSettingWithSettingArray:(NSArray *)settingArray
                                completion:(void (^)(NSError *))completion {
    [self.V5MessageProvider batchUploadSettingWithSettingArray:settingArray completion:^(NSError *error) {
        completion(error);
    }];
}

- (void)onlyLocalRemindMessage:(CMPMessageObject *)obj {
    [self.dbProvider remindMessage:obj];
}

- (void)remindRCMessage:(CMPMessageObject *)obj {
    [self.dbProvider remindMessage:obj];
}

- (void)readAppMessage {
    __weak CMPV5MessageProvider *weakV5Provider = self.V5MessageProvider;
    [self.dbProvider appIDsOfAppMessage:^(NSArray *IDs) {
        if (!IDs || IDs.count == 0) {
            return;
        }
        [weakV5Provider readMessageWithAppIDs:IDs completion:^(NSError *error) {
            if (!error) {
                [weakV5Provider requestMessageCompletion:nil];
            }
        }];
    }];
    [self.dbProvider readAppMessage];
    [self setupTabBarMsgBadge];
}

- (void)readMessageWithAppId:(CMPMessageObject *)obj clearMessage:(BOOL)isClear
{
    [self.dbProvider readMessageWithAppID:obj.cId];
    
    if (obj.type == CMPMessageTypeApp) {
        //v8.0以后应用消息服务器未读数不清掉
        if ([CMPFeatureSupportControl isTapAppMessageUnreadCountResetZero] && [obj.cId isEqualToString:kMessageType_AppMessage] && isClear == NO) {
            return;
        }
        //__weak CMPV5MessageProvider *weakV5Provider = self.V5MessageProvider;
        [self.V5MessageProvider readMessageWithAppID:obj.cId completion:^(NSError *error) {
//            if (!error) {
//                [weakV5Provider requestMessageCompletion:nil];
//            }
        }];
    } else if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
        if (isClear) {
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:(RCConversationType)obj.subtype targetId:obj.cId];
            [[CMPChatManager sharedManager] sendReadedMessageWithType:(RCConversationType)obj.subtype targetId:obj.cId];
        }
    }else if (obj.type == CMPMessageTypeUC) {
        
    }else if (obj.type == CMPMessageTypeRCGroupNotification) {
        [[CMPChatManager sharedManager] readRCGroupNotification];
        [[CMPChatManager sharedManager] sendGroupNotificationReadedMessage];
    }else if (obj.type == CMPMessageTypeMassNotification) {
        [self.massNotificationMessageProvider readedMessage];
    }
    
    [self setupTabBarMsgBadge];
}

- (void)readMessageWithAppID:(NSString *)appID {
    [self.dbProvider readMessageWithAppID:appID];
}

- (void)markUnreadWithMessage:(CMPMessageObject *)obj isMarkUnread:(BOOL)isMarkUnread {
    [obj markUnread:isMarkUnread];
    [self.dbProvider updateMessageExtraDataString:obj];
}

- (void)setGroupInfoWithMessage:(CMPMessageObject *)obj groupInfo:(CMPRCGroupMemberObject*)groupInfo {
    [obj setGroupInfo:groupInfo];
    [self.dbProvider updateMessageExtraDataString:obj];
}

-(void)updateGroupConversationTypeInfo:(NSDictionary *)val
{
    [self.dbProvider updateMessageExtraDataString14:val];
}

- (void)sendBusinessMessageWithParam:(NSDictionary * _Nonnull)param receiverIds:(NSString * _Nonnull)receiverIds success:(void (^ _Nonnull)(NSString * _Nonnull,id _Nonnull))success fail:(void (^ _Nonnull)(NSError * _Nonnull, NSString * _Nonnull))fail {
    [self.businessMessageProvider sendBusinessMessageWithParam:param receiverIds:receiverIds success:^(NSString * _Nonnull messageId,id _Nonnull data) {
        if (success) {
            success(messageId,data);
        }
    } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
        if (fail) {
            fail(error,messageId);
        }
    }];
}

- (void)getQuickProcessWithId:(NSString * _Nonnull)messageId messageCategory:(NSString * _Nonnull)messageCategory success:(void (^ _Nonnull)(NSString * _Nonnull messageId,id _Nonnull))success fail:(void (^ _Nonnull)(NSError * _Nonnull error, NSString * _Nonnull messageId))fail {
    [self.businessMessageProvider getQuickProcessWithId:messageId messageCategory:messageCategory success:^(NSString * _Nonnull messageId,id _Nonnull data) {
        if (success) {
            success(messageId,data);
        }
    } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
        if (fail) {
            fail(error,messageId);
        }
    }];
}

- (void)quickProcessWithParam:(NSDictionary * _Nonnull)param success:(void (^ _Nonnull)(NSString * _Nonnull, id _Nonnull))success fail:(void (^ _Nonnull)(NSError * _Nonnull, NSString * _Nonnull))fail {
    [self.businessMessageProvider quickProcessWithParam:param success:^(NSString * _Nonnull messageId, id _Nonnull data) {
        if (success) {
            success(messageId,data);
        }
    } fail:^(NSError * _Nonnull error, NSString * _Nonnull messageId) {
        if (fail) {
            fail(error,messageId);
        }
    }];
}

#pragma mark-
#pragma mark 消息设置

- (void)updateMessageSetting {
    __weak CMPMessageDbProvider *weakDbProvider = self.dbProvider;
    [self.V5MessageProvider getMessagesSetting:^(NSArray *settingList) {
        [weakDbProvider updateWithMessageSettings:settingList];
    }];
}

- (void)getTopStatusWithAppID:(NSString *)appID completion:(void(^)(BOOL isTop))completion {
    [self.dbProvider getTopStatusWithAppID:appID completion:completion];
}

- (void)getParentWithAppID:(NSString *)appID completion:(void(^)(NSString *parent))completion {
    [self.dbProvider getParentWithAppID:appID completion:completion];
}

- (void)getSortWithAppID:(NSString *)appID completion:(void(^)(NSString *sort))completion {
    [self.dbProvider getSortWithAppID:appID completion:completion];
}

- (BOOL)getRemindWithAppID:(NSString *)appID {
    return [self.dbProvider getRemindWithAppID:appID];
}

#pragma mark-
#pragma mark 消息聚合

- (void)aggregationMessageWithType:(CMPMessageType)type appID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    __weak __typeof(self)weakSelf = self;
    [self.V5MessageProvider setParent:kMessageType_AppMessage appID:appID completion:^(NSError *error) {
        if (!error) {
           // if (![CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
                [weakSelf.dbProvider aggregationMessageWithType:type appID:appID];
            //}
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)cancelAggregationMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    __weak __typeof(self)weakSelf = self;
    [self.V5MessageProvider setParent:@"" appID:appID completion:^(NSError *error) {
        if (!error) {
            //if (![CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
            [weakSelf.dbProvider cancelAggregationMessageWithAppID:appID];
            //}
        }
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark-
#pragma mark 消息未读条数更新

/**
 消息更新，发送通知刷新UI，更新未读条数
 */
- (void)messageDidUpdate {
    [self setupTabBarMsgBadge];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageUpdate object:nil];
}

/**
 更新应用角标，并同步到服务器
 */
- (void)updateIconBadgeAsyncToServer {
    __weak typeof(CMPV5MessageProvider) *weakProvider = _V5MessageProvider;
    [self.dbProvider totalUnreadCount:^(NSInteger  count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CMPCore sharedInstance].applicationIconBadgeNumber = count;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
            [weakProvider updateUnreadCountToServer];
        });
    }];
}

/**
 底导航未读条数更新
 */
- (void)setupTabBarMsgBadge {
    [self.dbProvider totalUnreadCount:^(NSInteger count) {
        [self dispatchAsyncToMain:^{
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            BOOL aShow = count != 0;
            [delegate.tabBarViewController setTabBarBadge:kM3AppID_Message show:aShow];
        }];
    }];
}

/**
 获取消息未读数
 */
- (void)totalUnreadCount:(void (^)(NSInteger count))completion {
    [self.dbProvider totalUnreadCount:^(NSInteger count) {
        [self dispatchAsyncToMain:^{
            if (completion) {
                completion(count);
            }
        }];
    }];
}

#pragma mark  快捷模块

/**
 根据新老版本AppList接口，解析出app列表数组
 */
- (NSArray *)appListModelToArray:(CMPObject *)model {
    NSArray *result = nil;
    if ([model isKindOfClass:[CMPAppListModel class]]) {
        NSDictionary *dic = [model yy_modelToJSONObject];
        result = dic[@"data"];
    } else if ([model isKindOfClass:[CMPAppListModel_2 class]]) {
        NSMutableArray *tempData = [NSMutableArray array];
        for (CMPAppListData_2 *data in ((CMPAppListModel_2 *)model).data) {
            for (CMPAppList_2 *app in data.appList) {
                NSDictionary *dic = [app yy_modelToJSONObject];
                if (dic) {
                    [tempData addObject:dic];
                }
            }
        }
        result = [tempData copy];
    }
    return result;
}

- (BOOL)hasZhiXin {
    BOOL result = [self hasAppWithAppID:@"61" appType:@"integration_shortcut"];
    NSLog(@"local no zhixin:61");
    return result;
}

- (BOOL)hasZhiXinPermissionAndServerAvailable {
    if (![CMPCommonManager reachableNetwork]) {
        return self.hasZhiXin;
    }
    return self.hasZhiXin && [CMPCore sharedInstance].isZhixinServerAvailable;
}

- (BOOL)hasTask {
    BOOL result = [self hasAppWithAppID:@"30" appType:@"default"];
    return result;
}

- (BOOL)hasAppWithAppID:(NSString *)appID appType:(NSString *)appType {
    NSString *aResultStr = [CMPCore sharedInstance].currentUser.appList;
    CMPObject *model = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        model = [CMPAppListModel_2 yy_modelWithJSON:aResultStr];
    } else {
        model = [CMPAppListModel yy_modelWithJSON:aResultStr];
    }
    NSArray *data = [self appListModelToArray:model];
    
    for (NSDictionary *item in data) {
        NSString *isShow = [item objectForKey:@"isShow"];
        NSString *appId = [item objectForKey:@"appId"];
        NSString *appTypeKey = [item objectForKey:@"appType"];
        if ([appId isEqualToString:appID] &&
            [isShow isEqualToString:@"1"] &&
            [appTypeKey isEqualToString:appType]) {
            return YES;
        }
    }
    return NO;
}

//快捷模块数据
- (NSArray *)shortcutItemList {
    NSString *aResultStr = [CMPCore sharedInstance].currentUser.appList;
    CMPObject *model = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        model = [CMPAppListModel_2 yy_modelWithJSON:aResultStr];
    } else {
        model = [CMPAppListModel yy_modelWithJSON:aResultStr];
    }
    
    // 处理新老版本applist数据兼容
    NSArray *data = [self appListModelToArray:model];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[CMPFeatureSupportControl quickModulePlistName] ofType:@"plist"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //清空快捷模块
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *appIDs = [NSMutableArray array];
    for (NSDictionary *item in data) {
        NSString *appType = [item objectForKey:@"appType"];
        NSString *isShow = [item objectForKey:@"isShow"];
        
        if (![appType isEqualToString:@"integration_shortcut"] ||
            ![isShow isEqualToString:@"1"]) {
            continue;
        }
        
        NSString *appId = [item objectForKey:@"appId"];
        if ([NSString isNull:appId]) {
            //扫一扫
            appId = @"scan";
        }
        else if ([appId isEqualToString:@"1"]) {
            NSString *gotoParam = [item objectForKey:@"gotoParam"];
            NSDictionary *gotoParamDic = [gotoParam JSONValue];
            NSString *openFrom = [gotoParamDic objectForKey:@"openFrom"];
            if (![NSString isNull:openFrom]) {
                if ([openFrom isEqualToString:@"templateIndex"]) {
                    //表单
                    appId = @"1_2";
                }
            }
        }
        
        NSString *appKey = [NSString stringWithFormat:@"appId_%@",appId];
        NSDictionary *info = [plistDic objectForKey:appKey];
        if (info) {
            NSString *appName = [info objectForKey:@"name"];
            NSString *icon = [info objectForKey:@"icon"];
            NSString *url = [info objectForKey:@"url"];
            NSString *color = [info objectForKey:@"color"];
            NSString *sort = [info objectForKey:@"sort"];
            url = [NSString isNull:url]?@"":url;
            
            if ([appId isEqualToString:@"61"]) {
                if ([[CMPChatManager sharedManager] useRongCloud]) {
                    url = @"http://uc.v5.cmp/v1.0.0/html/ucStartChatPage.html";
                    appName = @"quick_chat";
                } else if ([CMPChatManager sharedManager].chatType == CMPChatType_null) { // 如果没有连上服务器，不展示快捷菜单
                    continue;
                }
            }
            
            if ([appIDs containsObject:appId]) { // 防止服务器返回重复数据
                continue;
            }
            
            UIImage *iconImage = [UIImage imageNamed:icon];
            //改用NSMutableDictionary可以防止添加nil时crash
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            item[@"appName"] = appName;
            item[@"icon"] = iconImage;
            item[@"color"] = UIColorFromRGB([color longLongValue]);
            item[@"sortNum"] = sort;
            item[@"url"] = url;
            item[@"appID"] = appId;
//            NSDictionary *item = @{@"appName" : appName,
//                                   @"icon" : iconImage,
//                                   @"color" : UIColorFromRGB([color longLongValue]),
//                                   @"sortNum" : sort,
//                                   @"appID" : appId,
//                                   @"url" : url
//                                   };
            [items addObject:item];
            [appIDs addObject:appId];
        }
    }
    
    if ([CMPMeetingManager otmIfServerSupport]) {
        if ([[CMPMeetingManager shareInstance] otmIfServerOpen]) {
            NSDictionary *meetItem = [CMPMeetingManager otmQuickItemConfig];
            if (meetItem) {
                [items addObject:meetItem];
            }
        }
    }
    
    [items sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *sortNum1 = obj1[@"sortNum"];
        NSInteger sort1 = [sortNum1 integerValue];
        NSString *sortNum2 = obj2[@"sortNum"];
        NSInteger sort2 = [sortNum2 integerValue];
        if (sort1 < sort2) {
            return NSOrderedAscending;
        } else if (sort1 > sort2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    self.shortcutItemArray = items;
    return [items copy];
}

//融云快捷新建入口数据
- (NSArray *)RCQuickNewEntryItemList {
    NSString *aResultStr = [CMPCore sharedInstance].currentUser.appList;
    CMPObject *model = nil;
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        model = [CMPAppListModel_2 yy_modelWithJSON:aResultStr];
    } else {
        model = [CMPAppListModel yy_modelWithJSON:aResultStr];
    }
    
    // 处理新老版本applist数据兼容
    NSArray *data = [self appListModelToArray:model];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[CMPFeatureSupportControl quickModulePlistName] ofType:@"plist"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    //清空快捷模块
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *appIDs = [NSMutableArray array];
    for (NSDictionary *item in data) {
        NSString *appType = [item objectForKey:@"appType"];
        NSString *isShow = [item objectForKey:@"isShow"];
        
        if (![appType isEqualToString:@"integration_shortcut"] ||
            ![isShow isEqualToString:@"1"]) {
            continue;
        }
        
        NSString *appId = [item objectForKey:@"appId"];
        if ([NSString isNull:appId] || [appId isEqualToString:@"36"] || [appId isEqualToString:@"61"]) {
            //扫一扫,发起聊天,签到
            continue;
        }
        else if ([appId isEqualToString:@"1"]) {
            NSString *gotoParam = [item objectForKey:@"gotoParam"];
            NSDictionary *gotoParamDic = [gotoParam JSONValue];
            NSString *openFrom = [gotoParamDic objectForKey:@"openFrom"];
            if (![NSString isNull:openFrom]) {
                if ([openFrom isEqualToString:@"templateIndex"]) {
                    //表单
                    appId = @"1_2";
                }
            }
        }
        
        if ([appIDs containsObject:appId]) { // 防止服务器返回重复数据
            continue;
        }
        NSString *appKey = [NSString stringWithFormat:@"appId_%@",appId];
        NSDictionary *info = [plistDic objectForKey:appKey];
        if (info) {
//            NSString *appName = [info objectForKey:@"name"];
//            NSString *icon = [info objectForKey:@"icon"];
//            NSString *url = [info objectForKey:@"url"];
//            NSString *color = [info objectForKey:@"color"];
//            NSString *sort = [info objectForKey:@"sort"];
//            url = [NSString isNull:url]?@"":url;
//
//            UIImage *iconImage = [UIImage imageNamed:icon];
            //改用NSMutableDictionary可以防止添加nil时crash
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
//            item[@"appName"] = appName;
//            item[@"icon"] = iconImage;
//            item[@"color"] = UIColorFromRGB([color longLongValue]);
//            item[@"sortNum"] = sort;
//            item[@"url"] = url;
            
            item[@"appID"] = appId;
            [items addObject:item];
            [appIDs addObject:appId];
        }
    }
    
    return [items copy];
}

#pragma mark-
#pragma mark 新建聊天会话

- (void)showChatViewAfterShare:(CMPMessageObject *)obj vc:(UIViewController *)viewController filePaths:(NSArray *)filePaths {
    if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
        if (obj.unreadCount > 0) {
            [self readMessageWithAppId:obj clearMessage:NO];
        }
        CMPRCTargetObject *targetObjec =  [[CMPRCTargetObject alloc] init];
        targetObjec.targetId = obj.cId;
        targetObjec.type = obj.subtype;
        targetObjec.title = obj.appName;
        targetObjec.tabbar = [viewController rdv_tabBarController];
        targetObjec.navigationController = viewController.navigationController;
        [[CMPChatManager sharedManager] showChatView:targetObjec isShowShareTips:YES filePaths:filePaths];
    }
}

- (void)showChatView:(CMPMessageObject *)obj viewController:(UIViewController *)viewController {
    [self showChatView:obj viewController:viewController filePaths:nil];
}

- (void)showChatView:(CMPMessageObject *)obj viewController:(UIViewController *)viewController filePaths:(NSArray *)filePaths {
    if (obj.type == CMPMessageTypeRC || obj.type == CMPMessageTypeFileAssistant) {
        if (obj.unreadCount > 0) {
            [self readMessageWithAppId:obj clearMessage:NO];
        }
        CMPRCTargetObject *targetObjec =  [[CMPRCTargetObject alloc] init];
        targetObjec.targetId = obj.cId;
        targetObjec.type = obj.subtype;
        targetObjec.title = obj.appName;
        targetObjec.tabbar = [viewController rdv_tabBarController];
        targetObjec.navigationController = viewController.navigationController;
        targetObjec.messageObject = obj;
        [[CMPChatManager sharedManager] showChatView:targetObjec isShowShareTips:NO filePaths:filePaths];
    } else if (obj.type == CMPMessageTypeUC) {
        NSString *href = @"http://uc.v5.cmp/html/ucIndex.html";
        [self showWebviewWithUrl:href viewController:viewController];
    } else if (obj.type == CMPMessageTypeApp) {
        [self readMessageWithAppId:obj clearMessage:NO];
        if ([obj.cId isEqualToString:kMessageType_AppMessage]
            && [CMPCore sharedInstance].serverIsLaterV7_1_SP1) {
            NSString *href = @"http://message.m3.cmp/v/layout/message-all.html";
            CMPBannerWebViewController *vc = [[CMPBannerWebViewController alloc] init];
            NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
            localHref = [localHref appendHtmlUrlParam:@"appId" value:[obj.cId urlUTF8Encoded]];
            localHref = [localHref appendHtmlUrlParam:@"messageTitle" value:[obj.appName urlUTF8Encoded]];
            vc.startPage = localHref;
//            [self pushInMasterWithViewController:vc in:viewController];
            [self pushInDetailWithViewController:vc in:viewController];
        }
        else if([obj.cId isEqualToString:kMessageType_SmartMessage] && CMPFeatureSupportControl.isShoweIntelligentQA){
            UIViewController *controller = [CMPCore_XiaozhiBridge showIntelligentPage];
            [self pushInDetailWithViewController:controller in:viewController];
        }
        else {
            CMPMessageWebViewController *messageWebViewController = [[CMPMessageWebViewController alloc] init];
            messageWebViewController.hideBannerNavBar = YES;
            messageWebViewController.backBarButtonItemHidden = YES;
            messageWebViewController.appId = obj.cId;
            messageWebViewController.appName = SY_STRING(obj.appName);
            [self pushInDetailWithViewController:messageWebViewController in:viewController];
        }
    } else if (obj.type == CMPMessageTypeRCGroupNotification) {
        [self readMessageWithAppId:obj clearMessage:NO];
        CMPRCGroupNotificationViewController *vc = [[CMPRCGroupNotificationViewController alloc] init];
        [self pushInDetailWithViewController:vc in:viewController];
    } else if (obj.type == CMPMessageTypeAggregationApp) {
        CMPAggregationMessageViewController *vc = [[CMPAggregationMessageViewController alloc] init];
        vc.allowRotation = NO;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else if (obj.type == CMPMessageTypeAssociate) {
        CMPAssociateAccountMessageViewController *vc = [[CMPAssociateAccountMessageViewController alloc] init];
        vc.allowRotation = NO;
        [self pushInMasterWithViewController:vc in:viewController];
    }else if (obj.type == CMPMessageTypeMassNotification) {
        
        if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) {
            [self cmp_showHUDWithText:SY_STRING(@"msg_zhixin_notHasPermission")];
            return;
        }
        
        //if (obj.unreadCount > 0) {
            [self readMessageWithAppId:obj clearMessage:NO];
        //}
        NSString *href = @"http://uc.v5.cmp/v1.0.0/html/ucSmallBroadcast.html";
        href = [href appendHtmlUrlParam:@"userId" value:[CMPCore sharedInstance].userID];
        [self showWebviewWithUrl:href viewController:viewController];
    }
}

- (void)pushInDetailWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc {
    if (CMP_IPAD_MODE &&
        [parentVc cmp_canPushInDetail]) {
        [parentVc cmp_clearDetailViewController];
        [parentVc cmp_showDetailViewController:vc];
    } else {
        [parentVc.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushInMasterWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc {
    if (CMP_IPAD_MODE) {
        [parentVc cmp_clearDetailViewController];
        [parentVc cmp_pushPageInMasterView:vc navigation:parentVc.navigationController];
    } else {
        [parentVc.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showWebviewWithUrl:(NSString *)url viewController:(UIViewController *)viewController params:(id)tParams actionBlk:(void(^)(id params, NSError *error, NSInteger act))actBlk{
    if ([NSString isNull:url]) {
        return;
    }
    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    if (![url containsString:@"ucStartChatPage.html"]) {
        url = [CMPWebViewUrlUtils handleUrl:url];
    }
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
    aCMPBannerViewController.startPage = localHref;
    if (actBlk) {
        aCMPBannerViewController.actionBlk = actBlk;
    }
    if (tParams && localHref) {
        aCMPBannerViewController.pageParam = @{@"url":localHref,
                                               @"param":tParams};
    }
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)viewController pushViewController:aCMPBannerViewController animated:YES];
    } else if ([viewController isKindOfClass:[CMPTabBarViewController class]]) {
        CMPTabBarViewController *tabBar = (CMPTabBarViewController *)viewController;
        if (tabBar.selectedViewController.cmp_splitViewController) {
            [tabBar.selectedViewController.cmp_splitViewController cmp_clearDetailViewController];
            [tabBar.selectedViewController.cmp_splitViewController showDetailViewController:aCMPBannerViewController];
        } else {
            [(UINavigationController *)tabBar.selectedViewController pushViewController:aCMPBannerViewController animated:YES];
        }
    } else {
        [self pushInDetailWithViewController:aCMPBannerViewController in:viewController];
    }
}
- (void)showWebviewWithUrl:(NSString *)url viewController:(UIViewController *)viewController {
    [self showWebviewWithUrl:url viewController:viewController params:nil actionBlk:nil];
}

- (void)showScanViewWithUrl:(NSString *)url viewController:(UIViewController *)viewController {
    [self showScanViewWithUrl:url viewController:viewController scanImage:nil];
}

- (void)showScanViewWithUrl:(NSString *)url viewController:(UIViewController *)viewController scanImage:(nullable UIImage *)scanImage {
    if ([NSString isNull:url]) {
        url = @"http://commons.m3.cmp/v1.0.0/m3-scan-page.html";
    }
    
    CMPScanWebViewController *aCMPBannerViewController = [[CMPScanWebViewController alloc] init];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
    aCMPBannerViewController.startPage = localHref;
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = YES;
    aCMPBannerViewController.scanImage = scanImage;
    
    CMPNavigationController *naviVC = [[CMPNavigationController alloc] initWithRootViewController:aCMPBannerViewController];
    [viewController presentViewController:naviVC animated:YES completion:^{
    }];
}

#pragma mark-
#pragma mark Xmpp

- (void)receiveXMPPMessage:(NSNotification *)noti {
    CMPMessageObject *obj = (CMPMessageObject *)noti.object;
    NSString* key = @"appid_61";
    NSDictionary *localAppIno =  [self.localModuleConfig objectForKey:key];
    NSInteger bgColor = [[localAppIno objectForKey:@"backColor"] longLongValue];
    obj.iconUrl = [NSString stringWithFormat:@"image:%@:%ld",localAppIno[@"icon"],(long)bgColor];
    [self.dbProvider saveMessages:[NSArray arrayWithObject:obj] isChat:YES];
}

#pragma mark-
#pragma mark 致信

// 获取融云消息
- (void)requestRongCloudMessage {
    __weak CMPMessageDbProvider *weakDb = _dbProvider;
    NSString *currentServerID = [CMPCore sharedInstance].serverID;
    dispatch_async(self.serialRequestRongCloudMessageQueue, ^{
        [[CMPChatManager sharedManager] getRCMessageList:^(NSArray *result) {
                   // 切换了服务器，数据不是当前服务器的，不写入数据库
            if (![currentServerID isEqualToString:[CMPCore sharedInstance].serverID]) {
                return;
             }
             [weakDb saveMessages:result isChat:YES];
         }];
    });
}

- (void)updateGroupName:(CMPMessageObject *)obj {
    [self.dbProvider updateGroupName:obj];
}

- (void)setRCChatTopStatus:(CMPMessageObject *)obj type:(RCConversationType)type ext:(NSDictionary *)ext {
    [self.dbProvider setRCChatTopStatus:obj type:type ext:ext];
}

- (void)getRCChatTopStatusWithTargetId:(NSString *)targetId type:(RCConversationType)type completion:(void (^)(BOOL))completion {
    [self.dbProvider getRCChatTopStatusWithTargetId:targetId type:type completion:completion];
}

- (void)clearRCChatMsgWithTargetId:(NSString *)targetId type:(RCConversationType)type {
    [self.dbProvider clearRCChatMsgWithTargetId:targetId type:type];
}

- (void)clearRCGroupChatMsgWithGroupId:(NSString *)groupId {
    [self.dbProvider clearRCChatMsgWithTargetId:groupId type:ConversationType_GROUP];
}

- (void)clearRCGroupNotification {
    [self.dbProvider clearRCGroupNotification];
}

#pragma mark-
#pragma mark 关联消息

- (void)startAssociateMessagePolling {
    [self stopAssociateMessagePolling];
    if (!associateMessagePollingGroup) {
        associateMessagePollingGroup = dispatch_group_create();
    }
    self.associateMessagePollingTimer = [MSWeakTimer scheduledTimerWithTimeInterval:associateMessagePollingInterval
                                                                      target:self
                                                                    selector:@selector(refreshAssociateMessage)
                                                                    userInfo:nil
                                                                     repeats:YES
                                                               dispatchQueue:dispatch_get_global_queue(0, 0)];
}

- (void)stopAssociateMessagePolling {
    [self.associateMessagePollingTimer invalidate];
    self.associateMessagePollingTimer = nil;
    [self.V5MessageProvider cancelAllAssociateUnreadRequest];
//    NSLog(@"zl---销毁Group");
    associateMessagePollingGroup = nil;
}

- (void)refreshAssociateMessage {
    [self.V5MessageProvider cancelAllAssociateUnreadRequest];
    NSString *currentUserID = [CMPCore sharedInstance].userID;
    NSArray *assocaiteArr = [[CMPCore sharedInstance].loginDBProvider assAcountListWithServerID:[CMPCore sharedInstance].serverID userID:currentUserID];
    if (assocaiteArr.count == 0) { // 没有关联账号信息，自动删除其它企业消息条目，并停止消息轮询
        [self deleteAssociateMessage];
        [self stopAssociateMessagePolling];
        return;
    }
    
    for (CMPAssociateAccountModel *associate in assocaiteArr) {
        if (!associateMessagePollingGroup) {
            return;
        }
        dispatch_group_enter(associateMessagePollingGroup);
        [self.V5MessageProvider
         requestAssociateUnreadWithUrl:[CMPCore serverurlWithUrl:associate.server.fullUrl serverVersion:associate.server.serverVersion]
         userID:associate.userID
         timestamp:[associate.switchTime stringValue]
         completion:^(NSInteger unreadCount, NSError *error) {
             if (!self->associateMessagePollingGroup) {
                 return;
             }
             if (!error) {
                 associate.unreadCount = unreadCount;
             }
             dispatch_group_leave(self->associateMessagePollingGroup);
        }];
    }
    
    dispatch_group_notify(associateMessagePollingGroup, dispatch_get_main_queue(), ^{
        NSInteger sum = 0;
        NSString *shortName = nil;
        for (CMPAssociateAccountModel *associate in assocaiteArr) {
            if (associate.unreadCount > 0 && !shortName) {
                shortName = associate.loginAccount.extend1;
            }
            sum += associate.unreadCount;
            [[CMPCore sharedInstance].loginDBProvider updateUnreadWithAssAccount:associate];
        }
        
        CMPMessageObject *message = [[CMPMessageObject alloc] init];
        message.type = CMPMessageTypeAssociate;
        message.cId = kMessageType_AssociateMessage;
        message.sId = [CMPCore sharedInstance].serverID;
        if (![NSString isNull:shortName]) {
            message.content = [NSString stringWithFormat:@"[%@]收到新消息", shortName];
        } else {
            message.content = SY_STRING(kMsg_NoAssMessage);
        }
        message.unreadCount = sum;
        message.isTop = YES;
        message.topSort = kTopSort_AssociateMessage;
        NSString* key = [NSString stringWithFormat:@"appid_%@", kMessageType_AssociateMessage];
        NSDictionary *localAppInfo =  [self.localModuleConfig objectForKey:key];
        NSString * name = [localAppInfo objectForKey:@"name"];
        if (![NSString isNull:name]) {
            message.appName = name;
        }
        NSInteger bgColor = [[localAppInfo objectForKey:@"backColor"] longLongValue];
        NSString *iconName = localAppInfo[@"icon"];
        message.iconUrl = [NSString stringWithFormat:@"image:%@:%ld", iconName, (long)bgColor];
        [self.dbProvider saveAssociateMessage:message];
    });
}

- (void)deleteAssociateMessage {
    [self.dbProvider deleteAssociateMessage];
}

- (void)insetEmptyAssociateMessage {
    CMPMessageObject *message = [[CMPMessageObject alloc] init];
    message.type = CMPMessageTypeAssociate;
    message.cId = kMessageType_AssociateMessage;
    message.sId = [CMPCore sharedInstance].serverID;
    message.content = SY_STRING(kMsg_NoAssMessage);
    message.unreadCount = 0;
    message.isTop = YES;
    message.topSort = kTopSort_AssociateMessage;
    NSString* key = [NSString stringWithFormat:@"appid_%@", kMessageType_AssociateMessage];
    NSDictionary *localAppInfo =  [self.localModuleConfig objectForKey:key];
    NSString * name = [localAppInfo objectForKey:@"name"];
    if (![NSString isNull:name]) {
        message.appName = name;
    }
    NSInteger bgColor = [[localAppInfo objectForKey:@"backColor"] longLongValue];
    NSString *iconName = localAppInfo[@"icon"];
    message.iconUrl = [NSString stringWithFormat:@"image:%@:%ld", iconName, (long)bgColor];
    [self.dbProvider saveAssociateMessage:message];
}

- (void)addWaterMarkToView:(UIView *)view {
    [self.waterMarkUtil addWaterMarkToView:view];
}

#pragma mark-
#pragma mark Getter & Setter

- (NSDictionary *)localModuleConfig {
    if (!_localModuleConfig) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MessageModuleList" ofType:@"plist"];
        _localModuleConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _localModuleConfig;
}

#pragma mark-
#pragma mark 消息查询

- (CMPMessageObject *)messageWithAppID:(NSString *)appID {
    return [self.dbProvider messageWithAppID:appID];
}

- (CMPWaterMarkUtil *)waterMarkUtil {
    if (!_waterMarkUtil) {
        NSString *configStr = [CMPCore sharedInstance].currentUser.configInfo;
        CMPLoginConfigInfo *config = nil;
        if ([CMPCore sharedInstance].serverIsLaterV1_8_0) {
            CMPLoginConfigInfoModel_2 *model = [CMPLoginConfigInfoModel_2 yy_modelWithJSON:configStr];
            config = model.config;
        } else {
            CMPLoginConfigInfoModel *model = [CMPLoginConfigInfoModel yy_modelWithJSON:configStr];
            config = model.data;
        }
        
        // 判断水印开关
        if ([CMPCore sharedInstance].serverIsLaterV7_1) {
            if (![config.materMarkZxEnable boolValue]) {
                return nil;
            }
        } else {
            if (![config.materMarkEnable boolValue]) {
                return nil;
            }
        }
        
        NSMutableString *text = [NSMutableString string];
        
        if ([config.materMarkNameEnable boolValue]) {
            NSString *name = [CMPCore sharedInstance].currentUser.name ?: @"";
            [text appendString:name];
            [text appendString:kWaterMarkInterval];
        }
        
        if ([config.materMarkDeptEnable boolValue]) {
            NSString *accountShortName = [CMPCore sharedInstance].currentUser.extend1 ?: @"";
            [text appendString:accountShortName];
            [text appendString:kWaterMarkInterval];
        }
        
        if ([config.materMarkTimeEnable boolValue]) {
            NSDate *date = [NSDate date];
            NSDateFormatter *formt = [[NSDateFormatter alloc] init];
            [formt setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [formt stringFromDate:date];
            [text appendString:dateStr];
        }
        CMPWaterMarkStyle *style = [CMPWaterMarkStyle defaultStyle];
        _waterMarkUtil = [[CMPWaterMarkUtil alloc] initWithText:[text copy] Style:style];
    }
    return _waterMarkUtil;
}

#pragma mark-
#pragma mark 多端在线

- (void)logoutDeviceType:(NSInteger)type completion:(void(^)(NSError *error))completion {
    [self.V5MessageProvider logoutDeviceType:type completion:completion];
}

@end
