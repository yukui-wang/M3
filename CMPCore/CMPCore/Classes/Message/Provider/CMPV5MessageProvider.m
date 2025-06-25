//
//  CMPMessageNetProvider.m
//  M3
//
//  Created by CRMO on 2018/1/4.
//

#import "CMPV5MessageProvider.h"
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import "AppDelegate.h"
#import "CMPMessageManager.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPThreadSafeMutableDictionary.h>
#import <CMPLib/CMPThreadSafeMutableArray.h>
#import "CMPOnlineDevModel.h"
#import "CMPImpAlertManager.h"

NSString * const kCMPSmartMessageReadUrl = @"/rest/m3/message/intelligent/status";
NSString * const kCMPUploadMessageSettingUrl = @"/rest/m3/config/user/message/setting";
NSString * const kCMPGetMessageSettingUrl = @"/rest/m3/config/user/message/setting/list";
NSString * const kCMPAssociateUnreadUrl = @"%@/seeyon/rest/m3/message/unreadCount/%@";
NSString * const kCMPLogoutOtherDeviceUrl = @"/rest/m3/individual/exit/%d";

NSString * const kCMPMessageSettingTop = @"top";
NSString * const kCMPMessageSettingSort = @"sort";
NSString * const kCMPMessageSettingParent = @"parent";
NSString * const kCMPMessageSettingRemind = @"remind";

@interface CMPV5MessageProvider()<CMPDataProviderDelegate>

@property (strong, nonatomic) NSDictionary *localModuleConfig;
//@property (strong, nonatomic) NSString *messageListRequestID;
@property (strong, nonatomic) NSString *messageSettingRequestID;
@property (strong, nonatomic) CMPThreadSafeMutableArray *uploadRequestIDS;
@property (strong, nonatomic) CMPThreadSafeMutableArray *messageListRequestIDS;
@property (strong, nonatomic) NSString *updateOnlineStateRequestID;
@property (strong, nonatomic) CMPThreadSafeMutableArray *associateUnreadRequestIDs;
@property (strong, nonatomic) CMPThreadSafeMutableDictionary *associateUnreadBlocks;
@property (strong, nonatomic) NSString *logoutOtherDeviceRequestID;

@end

@implementation CMPV5MessageProvider

- (void)requestMessageCompletion:(void(^)(NSArray *messageList, NSError *error))completion
{
    NSString *identifier = [CMPCore sharedInstance].messageIdentifier;
    if (!identifier) {
        identifier = @"0";
    }
    // 需要cancel上一次的请求
    //[[CMPDataProvider sharedInstance] cancelWithRequestId:self.messageListRequestID];
    int bg =  ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) ? 1 : 0;
    NSString *url = [NSString stringWithFormat:@"%@?identifier=%@&bg=%d&clientType=%d",[CMPCore fullUrlPathMapForPath:@"/api/message/classification"],identifier,bg,([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 2 : 1)];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.timeout = 60; // 设置10秒，未了快速监听服务器连接状态；
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.messageListBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [self.messageListRequestIDS addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma updateOnlineState
- (void)requestUpdateOnlineState
{
    NSString *url = [CMPCore fullUrlForPath:@"/rest/m3/individual/updateOnlineState"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers = [CMPDataProvider headers];;
    aDataRequest.requestType = kDataRequestType_Url;
    self.updateOnlineStateRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)deleteMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    double t = [[NSDate date] timeIntervalSince1970];
    NSString *url = [NSString stringWithFormat:@"%@%@/%f",[CMPCore fullUrlPathMapForPath:@"/api/message/delete/"],appID, t];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)deleteMessageWithAppIDs:(NSArray *)appIDs completion:(void(^)(NSError *error))completion {
    double t = [[NSDate date] timeIntervalSince1970];
    NSString *url = [NSString stringWithFormat:@"%@application/%f", [CMPCore fullUrlPathMapForPath:@"/api/message/delete/"],t];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestParam = [appIDs yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)readMessageWithAppID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    NSString *url = [NSString stringWithFormat:@"%@%@/1", [CMPCore fullUrlPathMapForPath:@"/api/message/update/"],appID];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestParam = [[NSArray array] yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)readMessageWithAppIDs:(NSArray *)appIDs completion:(void(^)(NSError *error))completion {
    NSString *url = [NSString stringWithFormat:@"%@application/1",[CMPCore fullUrlPathMapForPath:@"/api/message/update/"]];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    if (!appIDs.count) {
        appIDs = [NSArray array];
    }
    aDataRequest.requestParam = [appIDs yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)readSmartPushMessageWithID:(NSString *)messageID {
    NSString *url = [CMPCore fullUrlForPath:kCMPSmartMessageReadUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    NSDictionary *param = @{@"messageId" : messageID};
    aDataRequest.requestParam = [param yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)updateUnreadCountToServer {
    NSString *url = [NSString stringWithFormat:@"%@%@/%ld", [CMPCore fullUrlPathMapForPath:@"/api/pns/message/setOfflineMsgCount/"],[CMPCore sharedInstance].userID, (long)[CMPCore sharedInstance].applicationIconBadgeNumber];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark 消息设置

- (void)setTopStatus:(BOOL)isTop appID:(NSString *)appID completion:(void (^)(NSError *))completion {
    [self uploadSettingWithAppID:appID Key:kCMPMessageSettingTop value:[NSString stringWithInt:isTop] completion:completion];
}

- (void)setParent:(NSString *)parent appID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    [self uploadSettingWithAppID:appID Key:kCMPMessageSettingParent value:parent completion:completion];
}

- (void)setSort:(NSString *)sort appID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    [self uploadSettingWithAppID:appID Key:kCMPMessageSettingSort value:sort completion:completion];
}

- (void)setRemind:(BOOL)remind appID:(NSString *)appID completion:(void(^)(NSError *error))completion {
    [self uploadSettingWithAppID:appID Key:kCMPMessageSettingRemind value:[NSString stringWithInt:remind] completion:completion];
}

- (void)uploadSettingWithAppID:(NSString *)appID
                           Key:(NSString *)key
                         value:(NSString *)value
                    completion:(void (^)(NSError *))completion {
    NSString *url = [CMPCore fullUrlForPath:kCMPUploadMessageSettingUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    NSDictionary *dic = @{@"appId" : appID,
                          @"type" : key,
                          @"value" : value};
    aDataRequest.requestParam = [dic yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};

    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)batchUploadSettingWithSettingArray:(NSArray *)settingArray
                         completion:(void (^)(NSError *error))completion {
    NSString *url = [CMPCore fullUrlForPath:kCMPGetMessageSettingUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestParam = [settingArray yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    [self.uploadRequestIDS addObject:aDataRequest.requestID];
    
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.uploadDoneBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};

    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getMessagesSetting:(void(^)(NSArray *settingList))completion {
    NSString *url = [CMPCore fullUrlForPathFormat:kCMPGetMessageSettingUrl];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    self.messageSettingRequestID = aDataRequest.requestID;
    CMPV5MessageProviderBlock *block = [[CMPV5MessageProviderBlock alloc] init];
    block.getSettingBlock = completion;
    aDataRequest.userInfo = @{@"block" : block};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark 关联账号

- (void)requestAssociateUnreadWithUrl:(NSString *)serverUrl
                               userID:(NSString *)userID
                            timestamp:(NSString *)timestamp
                           completion:(CMPRequestAssociateUnreadComletion)completion {
    NSString *url = [NSString stringWithFormat:kCMPAssociateUnreadUrl, serverUrl, userID];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.headers =  [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.timeout = 30;
    aDataRequest.httpShouldHandleCookies = NO;
    NSDictionary *dic = @{@"after" : timestamp ?:@""};
    aDataRequest.requestParam = [dic yy_modelToJSONString];
    [self.associateUnreadRequestIDs addObject:aDataRequest.requestID];
    [self.associateUnreadBlocks setObject:[completion copy] forKey:aDataRequest.requestID];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)cancelAllAssociateUnreadRequest {
    for (NSString *requestID in self.associateUnreadRequestIDs) {
        [[CMPDataProvider sharedInstance] cancelWithRequestId:requestID];
        CMPRequestAssociateUnreadComletion block = [self.associateUnreadBlocks objectForKey:requestID];
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"请求被取消" code:-1 userInfo:nil];
            block(0, error);
        }
    }
    
    [self.associateUnreadRequestIDs removeAllObjects];
    [self.associateUnreadBlocks removeAllObjects];
}

#pragma mark-
#pragma mark 多端在线

- (void)logoutDeviceType:(NSInteger)type completion:(CMPLogoutOtherDeviceComletion)completion {
    NSString *url = [CMPCore fullUrlForPathFormat:kCMPLogoutOtherDeviceUrl,type];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    self.logoutOtherDeviceRequestID = aDataRequest.requestID;
    aDataRequest.userInfo = @{@"completion" : completion};
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark-
#pragma mark CMPDataProviderDelegate

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
    [CMPCommonManager updateReachableServer:nil];
    // end
    
    NSString *requestID = aRequest.requestID;
    NSDictionary *userInfo = aRequest.userInfo;
    CMPV5MessageProviderBlock *block = [userInfo objectForKey:@"block"];
    
    if ([self.messageListRequestIDS containsObject:requestID]) {
        [self.messageListRequestIDS removeObject:requestID];
        NSDictionary *responseData = [aResponse.responseStr JSONValue];
        NSString *code = [responseData objectForKey:@"code"];
        NSString *identifier = [responseData objectForKey:@"identifier"];
        NSArray *data = [responseData objectForKey:@"data"];
        if ([code integerValue] == 200) {
            [CMPCore sharedInstance].messageIdentifier = identifier;
            [self dispatchAsyncToChild:^{
                NSArray *messages = [self parseResponse:data];
                [[CMPMessageManager sharedManager] saveMessages:messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageDidFinishRequest object:nil];
                if (block && block.messageListBlock) {
                    block.messageListBlock(messages, nil);
                }
            }];
        }
        
        NSArray *greetingArr = responseData[@"greeting"];
        if (greetingArr && [greetingArr isKindOfClass:NSArray.class]) {
            [CMPImpAlertManager showMsgWithDatas:greetingArr];
        }
        
        NSString *onlineDev = [responseData objectForKey:@"onlineDev"];
        if (onlineDev && [onlineDev isKindOfClass:[NSString class]]) {
            CMPOnlineDevModel *onlineDevModel = [CMPOnlineDevModel modelWithString:onlineDev];
            if (onlineDevModel) {
                [CMPCore sharedInstance].isMultiOnline = onlineDevModel.isMultiOnline;
                [CMPCore sharedInstance].isUcOnline = onlineDevModel.ucOnline;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_OnlineDevDidChange object:self userInfo:@{@"onlineDev" : onlineDevModel}];
            }
        }
        NSString *mute = [NSString stringWithFormat:@"%@",responseData[@"mute"]];
        if (mute && [mute isKindOfClass:NSString.class]) {
            if ([@"1" isEqualToString:mute]) {
                [CMPCore sharedInstance].multiLoginReceivesMessageState = NO;
            }else if ([@"0" isEqualToString:mute]) {
                [CMPCore sharedInstance].multiLoginReceivesMessageState = YES;
            }
        }
    } else if ([self.uploadRequestIDS containsObject:requestID]) {
        [self.uploadRequestIDS removeObject:requestID];
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            if (block && block.uploadDoneBlock) {
                block.uploadDoneBlock(nil);
            }
        }
    } else if ([requestID isEqualToString:self.messageSettingRequestID]) {
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            if (block && block.getSettingBlock) {
                NSDictionary *responseData = [aResponse.responseStr JSONValue];
                
                if (!responseData || ![responseData isKindOfClass:[NSDictionary class]]) {
                    block.getSettingBlock(nil);
                    return;
                }
                NSArray *data = [responseData objectForKey:@"data"];
                if (![data isKindOfClass:[NSArray class]]) {
                    block.getSettingBlock(nil);
                    return;
                }
                NSMutableArray *result = [NSMutableArray array];
                for (NSDictionary *dic in data) {
                    CMPV5MessageSetting *setting = [CMPV5MessageSetting yy_modelWithDictionary:dic];
                    [result addObject:setting];
                }
                block.getSettingBlock(result);
            }
        }
    } else if ([self.associateUnreadRequestIDs containsObject:requestID]) {
        [self.associateUnreadRequestIDs removeObject:requestID];
        NSDictionary *responseData = [aResponse.responseStr JSONValue];
        CMPRequestAssociateUnreadComletion block = [self.associateUnreadBlocks objectForKey:requestID];
        [self.associateUnreadBlocks removeObjectForKey:requestID];
        if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
            NSNumber *count = responseData[@"count"];
            if (count && [count isKindOfClass:[NSNumber class]]) {
                if (block) {
                    block([count integerValue], nil);
                    return;
                }
            }
        }
        // 数据异常，走错误回调
        if (block) {
            NSError *aError = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"接口返回数据异常：%@", aResponse.responseStr] code:0 userInfo:nil];
            block(0, aError);
        }
    } else if ([self.logoutOtherDeviceRequestID isEqualToString:requestID]) {
        CMPLogoutOtherDeviceComletion block = [userInfo objectForKey:@"completion"];
        if (block) {
            block(nil);
        }
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    NSString *requestID = aRequest.requestID;
    NSDictionary *userInfo = aRequest.userInfo;
    CMPV5MessageProviderBlock *block = [userInfo objectForKey:@"block"];
    
    if ([self.messageListRequestIDS containsObject:requestID]) {
        [self.messageListRequestIDS removeObject:requestID];
        // 网络监听，检查是否能够连接服务器 add by guoyl at 2018/1/10
        [CMPCommonManager updateReachableServer:error];
        // end
        AppDelegate *delegate = [AppDelegate shareAppDelegate];
        BOOL result = [delegate handleError:error];
        if (result) {
            [[CMPMessageManager sharedManager] stopV5MessagePolling];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageDidFinishRequest object:nil];
        if (block && block.messageListBlock) {
            block.messageListBlock(nil, error);
        }
    } else if ([self.uploadRequestIDS containsObject:requestID]) {
        [self.uploadRequestIDS removeObject:requestID];
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            if (block && block.uploadDoneBlock) {
                block.uploadDoneBlock(error);
            }
        }
    } else if ([requestID isEqualToString:self.messageSettingRequestID]) {
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            if (block && block.getSettingBlock) {
                block.getSettingBlock(nil);
            }
        }
    } else if ([self.associateUnreadRequestIDs containsObject:requestID]) {
        [self.associateUnreadRequestIDs removeObject:requestID];
        CMPRequestAssociateUnreadComletion block = [self.associateUnreadBlocks objectForKey:requestID];
        [self.associateUnreadBlocks removeObjectForKey:requestID];
        if (block) {
            block(0, error);
        }
    } else if ([self.logoutOtherDeviceRequestID isEqualToString:requestID]) {
        CMPLogoutOtherDeviceComletion block = [userInfo objectForKey:@"completion"];
        if (block) {
            block(error);
        }
    }
}

- (NSArray *)parseResponse:(NSArray *)data {
    if (!data || ![data isKindOfClass:[NSArray class]] || data.count == 0) {
        return nil;
    }
    
    NSMutableArray *objectList = [NSMutableArray array];
    for (NSDictionary *message in data) {
        CMPMessageObject *obj = [[CMPMessageObject alloc] initWithV5Message:message localModuleConfig:self.localModuleConfig];
        if ([obj.cId isEqualToString:@"-1"]) {
            continue;
        }
        [objectList addObject:obj];
    }
    return objectList;
}

#pragma mark-
#pragma mark 私有方法

- (NSDictionary *)localModuleConfig {
    if (!_localModuleConfig) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MessageModuleList" ofType:@"plist"];
        _localModuleConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _localModuleConfig;
}

#pragma mark-
#pragma mark Getter & Setter

- (CMPThreadSafeMutableArray *)uploadRequestIDS {
    if (!_uploadRequestIDS) {
        _uploadRequestIDS = [[CMPThreadSafeMutableArray alloc] init];
    }
    return _uploadRequestIDS;
}

- (CMPThreadSafeMutableArray *)messageListRequestIDS {
    if (!_messageListRequestIDS) {
        _messageListRequestIDS = [[CMPThreadSafeMutableArray alloc] init];
    }
    return _messageListRequestIDS;
}

- (CMPThreadSafeMutableArray *)associateUnreadRequestIDs {
    if (!_associateUnreadRequestIDs) {
        _associateUnreadRequestIDs = [[CMPThreadSafeMutableArray alloc] init];
    }
    return _associateUnreadRequestIDs;
}

- (CMPThreadSafeMutableDictionary *)associateUnreadBlocks {
    if (!_associateUnreadBlocks) {
        _associateUnreadBlocks = [[CMPThreadSafeMutableDictionary alloc] init];
    }
    return _associateUnreadBlocks;
}

@end

@implementation CMPV5MessageProviderBlock
@end
