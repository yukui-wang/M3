//
//  CMPChatManager.m
//  CMPCore
//
//  Created by wujiansheng on 2016/12/12.
//
//

#define kConnectType_IntranetIP 2//5.6 内网
#define kConnectType_ExtranetIP 3//5.6 外网

#import "CMPChatManager.h"
#import <CMPLib/XMPP.h>
#import <CMPLib/FMDatabase.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>

#import "CMPRCChatViewController.h"
#import "CMPMessageObject.h"
#import "CMPContactsManager.h"
#import <CMPLib/CMPDateHelper.h>
#import "CMPMessageManager.h"
#import "CMPMessageObject.h"
#import "CMPUCSystemMessage.h"
#import "CMPRCGroupNotificationManager.h"
#import "RCGroupNotificationMessage+Format.h"
#import "CMPRCUserCacheManager.h"
#import "CMPRCUserCacheObject.h"
#import <CMPLib/NSDate+XMP_Extensions.h>
#import "CMPReadedMessage.h"
#import "CMPCommonManager.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "AppDelegate.h"
#import "CMPOAMessage.h"
#import "CMPFileStatusReceiptMessage.h"
#import "RCMessageContent+Custom.h"
#import "CMPFileStatusProvider.h"
#import "CMPPushConfigResponse.h"
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/AFNetworkReachabilityManager.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPRCV5Message.h"
#import <CMPLib/CMPThreadSafeMutableDictionary.h>
#import "CMPRCTransmitMessage.h"
#import "CMPRCSystemImMessage.h"
#import "CMPRCShakeWinMessage.h"
#import "CMPRCUrgeMessage.h"
#import "CMPMassNotificationMessage.h"
#include <CMPLib/CMPSplitViewController.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPNavigationController.h>
#import "CMPBusinessCardMessage.h"
#import "M3-Swift.h"
#import "CMPGeneralBusinessMessage.h"
#import "CMPRCGroupMemberObject.h"
#import "CMPVideoMessage.h"
#import "CMPSignMessage.h"
#import <CMPLib/CMPPopOverManager.h>
#import "CMPPCCreateGroupMessage.h"
#import <CMPLib/FCFileManager.h>
#import <CMPLib/CMPCommonTool.h>
#import "CMPChatSentFile.h"
#import <CMPLib/FLAnimatedImage.h>
#import "RCIM+InfoCache.h"
#import "CMPSettingMessage.h"
#import "CMPQuoteMessage.h"
#import "CMPClearMsgRemoteTextMessage.h"
#import "CMPRobotMsg.h"
#import "CMPRobotAtMsg.h"
#import "CMPClearMsg.h"
#import <CMPLib/GTMUtil.h>

typedef void (^ReturnBlock)(id info);

@interface CMPChatManager()<CMPDataProviderDelegate,XMPPStreamDelegate,RCIMReceiveMessageDelegate,RCIMConnectionStatusDelegate,RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMGroupMemberDataSource>
{
    XMPPStream*                                 _xmppStream;
    BOOL      _isConnecting;
    BOOL isReceiving; // 是否正在接收消息
    NSString *_logPath;
}

@property(nonatomic,strong) XMPPStream*         xmppStream;
@property(nonatomic,strong) XMPPJID*         myJid;
@property(nonatomic,strong) NSString*         intranetIp;
@property(nonatomic,strong) NSString*         extranetIp;
@property(nonatomic,strong) NSString*         port;
@property(nonatomic,strong) NSString*         password;
@property(nonatomic,strong) NSString*         loginIP;

@property (nonatomic, strong) FMDatabase *localMsgDB;
@property (nonatomic, strong) NSString *serverID;



//rong cloud
@property(nonatomic, copy)NSString *appKey;
@property(nonatomic, copy)NSString *token;
@property(nonatomic, copy)NSString *userId;
@property(nonatomic,strong) CMPThreadSafeMutableDictionary *groupInformations; // 缓存群信息
@property(nonatomic,strong) CMPThreadSafeMutableDictionary *conversationAlertMap; // 缓存群是否免打扰
@property (nonatomic, copy)NSString *loginRequestID;
@property (nonatomic, copy)NSString *addGroupRequestID;
@property (nonatomic, copy)NSString *getGroupUserListByGroupIdRequestID;
@property (nonatomic, copy)NSString *getAllRCMessageSettingRequestID;
@property (nonatomic, copy)NSString *uploadRCMessageSettingRemindTypeRequestID;
//@property (nonatomic, copy)NSString *getNotificationSettingRequestID;
@property (nonatomic, assign)long long readedGroupNotificationTimestamp; // 已读的群系统消息时间戳
@property (nonatomic, strong)dispatch_queue_t serialQueue;

- (void)addMessageOperation:(XMPPMessage *)message;

@property (nonatomic, strong) NSMutableArray *customRemoteMsgArr;

@end

@implementation CMPChatManager

@synthesize xmppStream                          = _xmppStream;

+(BOOL)canRemoveRemoteMsg{
//    return YES;
    BOOL canRemoveRemoteMsg = CMPCore.sharedInstance.hasUcMsgServerDel;
    if([CMPServerVersionUtils serverIsLaterV9_0_730] || canRemoveRemoteMsg){
        return YES;
    }
    return NO;
}

+ (CMPChatManager*)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_xmppStream removeDelegate:self delegateQueue:dispatch_get_current_queue()];
    [_xmppStream removeDelegate:self];
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    _groupNotificationManager = nil;
    _userCacheManager = nil;
    [_groupInformations removeAllObjects];
    _groupInformations = nil;
    [_conversationAlertMap removeAllObjects];
    _conversationAlertMap = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.videoExpirationDays = -1;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:kNotificationName_UserLogout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNotificationName_NetworkStatusChange object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xiaozChatViewShow:) name:kNotificationName_XiaozViewShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xiaozChatViewHide:) name:kNotificationName_XiaozViewHide object:nil];

        
        
        if (!_groupNotificationManager) {
            _groupNotificationManager = [[CMPRCGroupNotificationManager alloc] init];
        }
        if (!_userCacheManager) {
            _userCacheManager = [[CMPRCUserCacheManager alloc] init];
        }
        if (!_groupInformations) {
            _groupInformations = [[CMPThreadSafeMutableDictionary alloc] init];
        }
        if (!_conversationAlertMap) {
            _conversationAlertMap = [[CMPThreadSafeMutableDictionary alloc] init];
        }
        
        self.serialQueue =  dispatch_queue_create("com.m3.cacheGroupInformation", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)begin {
    if ([NSString isNotNull:self.appKey] || [NSString isNotNull:self.token] || [NSString isNotNull:self.userId]) {
        [self stopRongCloud];
    }
    
    self.chatType = CMPChatType_null;
    [CMPCore sharedInstance].hasPermissionForZhixin = YES;
    [self connectSQLite3];
    if ([CMPCommonManager reachableNetwork]) {
        [self requestLoginInfo];
    }else{
        NSString *cacheUcConfig = [CMPCore sharedInstance].ucConfig;
        NSDictionary *responseDic = [cacheUcConfig JSONValue];
        NSDictionary *data = [responseDic objectForKey:@"data"];
        [self loginWithUserInfo:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_PermissionForZhixinChange object:nil];
    }
    [self initPushConfig];
    // 2.5.0版本异步更新applist
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appListDidRefresh) name:kNotificationName_AppListDidUpdate object:nil];
    }
}

- (void)userLogout
{
    self.extranetIp = nil;
    self.intranetIp = nil;
    if (self.chatType == CMPChatType_Xmpp) {
        [self logout];
    }
    else  if (self.chatType == CMPChatType_Rong) {
        [self stopRongCloud];
    }
    
    self.chatType = CMPChatType_null;
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_AppListDidUpdate object:nil];
    }
}

- (void)didApplicationDidBecomeActive
{
    [self reconnectWhenApplicationDidBecomeActive];
}

#pragma mark 获取登陆信息

- (void)requestLoginInfo
{
    NSString *url = [CMPCore fullUrlForPath:@"/rest/m3/config/uc"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    self.loginRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/**
 从缓存中获取消息推送设置
 */
- (void)initPushConfig {
    CMPCore *core = [CMPCore sharedInstance];
    NSString *pushConfig = core.pushConfig;
    CMPPushConfigResponse *pushConfigResponse = [CMPPushConfigResponse yy_modelWithJSON:pushConfig];
    if (pushConfigResponse) {
        core.pushAcceptInformation = pushConfigResponse.mainSwitch;
        core.pushSoundRemind = pushConfigResponse.ringSwitch;
        core.pushVibrationRemind = pushConfigResponse.shakeSwitch;
        core.startReceiveTime = pushConfigResponse.startDate;
        core.endReceiveTime = pushConfigResponse.endDate;
        core.multiLoginReceivesMessageState = pushConfigResponse.multiLoginReceivesMessageState;
    } else {
        core.pushAcceptInformation = YES;
        core.pushSoundRemind = YES;
        core.pushVibrationRemind = YES;
        core.startReceiveTime = @"00:00:00";
        core.endReceiveTime = @"23:59:00";
        core.multiLoginReceivesMessageState = YES;
    }
}

/**
 2.5.0版本服务器，Applist异步更新，更新后重新初始化融云
 */
- (void)appListDidRefresh {
    if ([[CMPMessageManager sharedManager] hasZhiXin] == [CMPCore sharedInstance].hasPermissionForZhixin) {
        return;
    }
    DDLogDebug(@"zl---appList异步刷新，致信权限变更，重新连接融云");
    NSString *response = [CMPCore sharedInstance].ucConfig;
    NSDictionary *responseDic = [response JSONValue];
    NSDictionary *data = [responseDic objectForKey:@"data"];
    [self loginWithUserInfo:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_PermissionForZhixinChange object:nil];
}
/**
 比较两个版本号的大小（2.0）
 
 @param v1 第一个版本号
 @param v2 第二个版本号
 @return 版本号相等,返回0; v1小于v2,返回-1; 否则返回1.
 */
+ (NSInteger)compareVersion2:(NSString *)v1 to:(NSString *)v2 {
    // 都为空，相等，返回0
    if (!v1 && !v2) {
        return 0;
    }
    
    // v1为空，v2不为空，返回-1
    if (!v1 && v2) {
        return -1;
    }
    
    // v2为空，v1不为空，返回1
    if (v1 && !v2) {
        return 1;
    }
    
    // 获取版本号字段
    NSArray *v1Array = [v1 componentsSeparatedByString:@"."];
    NSArray *v2Array = [v2 componentsSeparatedByString:@"."];
    // 取字段最大的，进行循环比较
    NSInteger bigCount = (v1Array.count > v2Array.count) ? v1Array.count : v2Array.count;
    
    for (int i = 0; i < bigCount; i++) {
        // 字段有值，取值；字段无值，置0。
        NSInteger value1 = (v1Array.count > i) ? [[v1Array objectAtIndex:i] integerValue] : 0;
        NSInteger value2 = (v2Array.count > i) ? [[v2Array objectAtIndex:i] integerValue] : 0;
        if (value1 > value2) {
            // v1版本字段大于v2版本字段，返回1
            return 1;
        } else if (value1 < value2) {
            // v2版本字段大于v1版本字段，返回-1
            return -1;
        }
        
        // 版本相等，继续循环。
    }

    // 版本号相等
    return 0;
}
#pragma -mark  接口代理方法 CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest
{
    
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    NSString *response = [aResponse responseStr];
    NSDictionary *responseDic = [response JSONValue];
    
    if ([aRequest.requestID isEqualToString:self.loginRequestID]) {
        [CMPCore sharedInstance].ucConfig = response;
        NSDictionary *data = [responseDic objectForKey:@"data"];
        NSString *versionStr = [responseDic objectForKey:@"version"];
        NSString *needEncode = [data objectForKey:@"needEncode"];
        NSInteger resultCompare = -1;
        if([versionStr isKindOfClass:NSString.class]){
            resultCompare = [self.class compareVersion2:versionStr to:@"4.2.9"];
        }
        //versionStr比4.2.9大或者相等，结果则为>=0
        if (resultCompare>=0 || [needEncode isEqual:@"1"]) {
            //需要对接口返回数据解密
            NSMutableDictionary *dicNew = [NSMutableDictionary new];
            [data.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *key = obj;
                id valueObj = data[key];
                if ([valueObj isKindOfClass:[NSString class]]) {
                    NSString *value = valueObj;
                    value = [GTMUtil decrypt:value];
                    [dicNew setObject:value forKey:key];
                }else{
                    [dicNew setObject:valueObj forKey:key];
                }
            }];
            data = dicNew;
            NSMutableDictionary *aDic = [NSMutableDictionary dictionary];
            [aDic addEntriesFromDictionary:responseDic];
            [aDic setObject:data forKey:@"data"];
            NSString *anewStr = [aDic JSONRepresentation];
            [CMPCore sharedInstance].ucConfig = anewStr;
        }
        
        [self loginWithUserInfo:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_PermissionForZhixinChange object:nil];
    }
    else if ([aRequest.requestID isEqualToString:self.addGroupRequestID]) {
        
        ReturnBlock a = [aRequest.userInfo objectForKey:@"success"];
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        [json addEntriesFromDictionary:responseDic];
        [json setObject:self.addGroupRequestID forKey:@"groupId"];
        a(json);
    }
    else if ([aRequest.requestID isEqualToString:self.getGroupUserListByGroupIdRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *status = responseDic[@"status"];
        if ([status isEqualToString:@"ok"]) {
            NSDictionary *groupDic = responseDic[@"group"];
            CMPRCGroupMemberObject *groupMember = [CMPRCGroupMemberObject yy_modelWithJSON:groupDic];
            CMPRCBlockObject *blockObject = userInfo[@"resultBlock"];
            blockObject.allMemberOfGroupResultBlock(groupMember,[groupMember allUserInfo]);
        }else{
            void(^failBlk)(NSError *,id) = userInfo[@"failBlk"];
            if (failBlk) {
                NSString *msg = [NSString stringWithFormat:@"%@",responseDic[@"message"]];
                NSInteger code = -1001;
                if (responseDic[@"code"]) {
                    code = [responseDic[@"code"] integerValue];
                }
                NSError *error = [NSError errorWithDomain:msg code:code userInfo:nil];
                failBlk(error,responseDic);
            }
        }
    }
    else if ([aRequest.requestID isEqualToString:self.getAllRCMessageSettingRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *status = responseDic[@"status"];
        NSArray *dataArray = responseDic[@"data"];
        void (^resultBlock) (NSArray *dataArray,NSError *error) = userInfo[@"resultBlock"];
        if ([status isEqualToString:@"successed"]) {
            resultBlock(dataArray,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"请求失败" code:200 userInfo:nil];
            resultBlock(nil,error);
        }
    }
    else if ([aRequest.requestID isEqualToString:self.uploadRCMessageSettingRemindTypeRequestID]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *status = responseDic[@"status"];
        void (^resultBlock) (BOOL isSeccess,NSError *error) = userInfo[@"resultBlock"];
        if ([status isEqualToString:@"successed"]) {
            resultBlock(YES,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"请求失败" code:200 userInfo:nil];
            resultBlock(NO,error);
        }
    }else if ([aRequest.requestID isEqualToString:@"cmprequestid_getpostshowstatus"]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *status = responseDic[@"status"];
        void (^resultBlock) (BOOL isShowPost,NSError *error) = userInfo[@"resultBlock"];
        if ([status isEqualToString:@"successed"]) {
            NSString *data = [NSString stringWithFormat:@"%@",responseDic[@"data"]];
            BOOL isShow = [data isEqualToString:@"1"];
            resultBlock(isShow,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"请求失败" code:200 userInfo:nil];
            resultBlock(NO,error);
        }
    }else if ([aRequest.requestID isEqualToString:@"cmprequestid_getmemberorgstatus"]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        NSString *status = responseDic[@"status"];
        void (^resultBlock) (id result,NSError *error) = userInfo[@"resultBlock"];
        if ([status isEqualToString:@"successed"]) {
            NSString *data = [NSString stringWithFormat:@"%@",responseDic[@"state"]];
            resultBlock(@{@"state":data,@"mid":userInfo[@"mid"]},nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"请求失败" code:200 userInfo:nil];
            resultBlock(nil,error);
        }
    }else if ([aRequest.requestID isEqualToString:@"cmprequestid_forwardfiletotarget"]) {
        NSString *response = [aResponse responseStr];
        NSDictionary *responseDic = [response JSONValue];
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (id result,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(responseDic,nil);
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
    if ([aRequest.requestID isEqualToString:self.loginRequestID]) {
        NSString *cacheUcConfig = [CMPCore sharedInstance].ucConfig;
        NSDictionary *responseDic = [cacheUcConfig JSONValue];
        NSDictionary *data = [responseDic objectForKey:@"data"];
        [self loginWithUserInfo:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_PermissionForZhixinChange object:nil];
    }
    else if ([aRequest.requestID isEqualToString:self.addGroupRequestID]) {
        NSDictionary *dic = aRequest.userInfo;
        ReturnBlock a = [dic objectForKey:@"fail"];
        a(error.domain);
    }
    else if ([aRequest.requestID isEqualToString:self.getAllRCMessageSettingRequestID]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (NSArray *dataArray,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(nil,error);
    }
    else if ([aRequest.requestID isEqualToString:self.uploadRCMessageSettingRemindTypeRequestID]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (BOOL isSeccess,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(NO,error);
    }
    else if ([aRequest.requestID isEqualToString:@"cmprequestid_getpostshowstatus"]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (BOOL isSeccess,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(NO,error);
    }
    else if ([aRequest.requestID isEqualToString:@"cmprequestid_getmemberorgstatus"]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (id result,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(nil,error);
    }else if ([aRequest.requestID isEqualToString:@"cmprequestid_forwardfiletotarget"]) {
        NSDictionary *userInfo = aRequest.userInfo;
        void (^resultBlock) (id result,NSError *error) = userInfo[@"resultBlock"];
        resultBlock(nil,error);
    }
}

#pragma mark 处理登陆信息

- (NSString *)checkIP:(NSString *)ip
{
    
    if (!ip || ip.length ==0 || ![ip isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *result  = [ip replaceCharacter:@"http://" withString:@""];
    result = [result replaceCharacter:@"https://" withString:@""];
    return result;
}

- (void)loginWithUserInfo:(NSDictionary *)info
{
    NSLog(@"__%s__%@",__func__,info);
    // 没有致信权限，不做致信初始化
    if (![[CMPMessageManager sharedManager] hasZhiXin]) {
        [CMPCore sharedInstance].hasPermissionForZhixin = NO;
        [CMPCore sharedInstance].isZhixinServerAvailable = NO;
        return;
    }
    
    // 没有致信服务
    if (!info) {
        [CMPCore sharedInstance].hasPermissionForZhixin = YES;
        [CMPCore sharedInstance].isZhixinServerAvailable = NO;
        return;
    }
    
    NSString *ucChannel = [info objectForKey:@"ucChannel"];
    
    if (![NSString isNull:ucChannel]&&[ucChannel.lowercaseString isEqualToString:@"rong"]) {
        self.chatType = CMPChatType_Rong;
        [CMPCore sharedInstance].hasPermissionForZhixin = YES;
        [CMPCore sharedInstance].isZhixinServerAvailable = YES;
        [self rongCloudInfo:info];
        return;
    } else {
        [CMPCore sharedInstance].hasPermissionForZhixin = YES;
        [CMPCore sharedInstance].isZhixinServerAvailable = NO;
    }
    
    [self xmppInfo:info];
}


///**
// 把通知的设置信息保存到CMPCore
// */
//- (void)saveNotificationSetting:(NSDictionary *)info {
//    if (!info) { // 账号第一次登陆的时候，取不到数据
//        [CMPCore sharedInstance].pushAcceptInformation = YES;
//        [CMPCore sharedInstance].pushSoundRemind = YES;
//        [CMPCore sharedInstance].pushVibrationRemind = YES;
//        [self onAcceptInformationChanged];
//        return;
//    }
//
//    CMPPushConfigResponse *object = [CMPPushConfigResponse yy_modelWithJSON:info];
//    [CMPCore sharedInstance].pushAcceptInformation = object.mainSwitch;
//    [CMPCore sharedInstance].pushSoundRemind = object.ringSwitch;
//    [CMPCore sharedInstance].pushVibrationRemind = object.shakeSwitch;
//    [CMPCore sharedInstance].startReceiveTime = object.startDate;
//    [CMPCore sharedInstance].endReceiveTime = object.endDate;
//    [self onAcceptInformationChanged];
//}

- (void)xmppInfo:(NSDictionary *)info
{
    [self logout];
    
    NSString *jidString = [info objectForKey:@"jid"];
    if ([NSString isNull:jidString]) {
        return;
    }
    NSString *extranetIp = [info objectForKey:@"extranetIp"];
    NSString *intranetIp = [info objectForKey:@"intranetIp"];
    self.extranetIp = [self checkIP:extranetIp];
    self.intranetIp = [self checkIP:intranetIp];
    if (!self.intranetIp && !self.extranetIp) {
        return;
    }
    self.chatType = CMPChatType_Xmpp;
    
    NSString *token = [info objectForKey:@"token"];
    NSString *port = [info objectForKey:@"port"];
    NSString *ucFilePort = [info objectForKey:@"ucFilePort"];
    NSString *ucServerStyle = [info objectForKey:@"ucServerStyle"];
    
    self.ucFilePort = [NSString isNull:ucFilePort] ?@"7777":ucFilePort;
    self.ucServerStyle = [NSString isNull:ucServerStyle] ?@"http":ucServerStyle;

    
    self.port = port;
    self.password = token;
    NSString *jsessionValue = [self checkIP:[info objectForKey:@"jsessionValue"]];
    NSString *secretValue = [self checkIP:[info objectForKey:@"secretValue"]];
    
    // 旧版登陆方式
    //    XMPPJID* ucJID = [XMPPJID jidWithString:jidString];
    //    self.myJid = [XMPPJID jidWithUser:ucJID.user domain:ucJID.domain resource:@"mobile"];
    
    //新版登陆方式  memberId_jsessionValue_secretValue
    NSString *jidStr = [NSString stringWithFormat:@"%@_%@_%@@localhost/mobile",[CMPCore sharedInstance].userID,jsessionValue,secretValue];
    self.myJid = [XMPPJID jidWithString:jidStr];
    
    [self login];
}


- (void)login
{
    _isConnecting = YES;
    // create a new XMPPStream
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
    }
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    BOOL result =  [self connectWithIP:self.intranetIp];
    if (!result) {
        [self connectWithIP:self.extranetIp];
    }
}


- (BOOL)connectWithIP:(NSString *)ip
{
    self.loginIP = ip;
    if ([_xmppStream isConnected]) {
        return YES;
    }
    if (!ip || ip.length ==0) {
        return NO;
    }
    //设置用户
    [_xmppStream setMyJID:self.myJid];
    [_xmppStream setHostName:ip];
    if (![NSString isNull:self.port]) {
        [_xmppStream setHostPort:self.port.intValue];
    }
    [_xmppStream setEnableBackgroundingOnSocket:YES];
    //连接服务器
    NSError *error = nil;
    if (![_xmppStream connect:&error] && !error) {
        NSLog(@"cant connect %@", error);
        return NO;
    }
    return YES;
}


#pragma mark 连接服务器
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    if (sender != _xmppStream) {
        return;
    }
    NSError *error = nil;
    //验证密码
    [_xmppStream authenticateWithPassword:@"seeyon" error:&error];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidDisConnected object:nil];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (sender != _xmppStream) {
        //退出登录的时候用
        return;
    }
    if ( [self.loginIP isEqualToString:self.extranetIp] || [NSString isNull:self.extranetIp]) {
        _isConnecting = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidDisConnected object:nil];
    }
    else {
         [self connectWithIP:self.extranetIp];
    }
}

#pragma mark 验证密码
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    if (sender != _xmppStream) {
        return;
    }
    [self goOnline];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidConnected object:nil];
    NSLog(@"xmppStreamDidAuthenticate");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    if (sender != _xmppStream) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidDisConnected object:nil];
    NSLog(@"xmppStreamDidNotAuthenticate");
}


#pragma mark 人员状态

-(void)goOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [_xmppStream sendElement:presence];
}

-(void)goOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"didReceivePresence -> %@",presence);
}


#pragma mark 退出
- (void)logout
{
    [self goOffline];

    [_xmppStream removeDelegate:self delegateQueue:dispatch_get_current_queue()];
    [_xmppStream removeDelegate:self];
    [_xmppStream disconnect];
    _xmppStream = nil;
    self.loginIP = nil;
}
//冲后台唤醒的时候 重连
- (void)reconnectWhenApplicationDidBecomeActive
{
    if (_xmppStream) {
        [self checkAndReconnect];
    }
}

#pragma mark IQ

// IQ
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"didReceiveIQ -> %@",iq);
    NSString *msgId = iq.elementID;
    NSString *value = [iq XMLString];
    NSString *notificationName = nil;
    if (iq.isResultIQ) {
        notificationName = kXmppDidReceiveIQ;
    }
    else  if (iq.isSetIQ) {
        //read  回执
        msgId =  @"";
        notificationName = kXmppDidReceiveMessage;
    }
    else if (iq.isErrorIQ){
        notificationName = kXmppDidReceiveErrorIQ;
    }
    if (notificationName) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",value,@"value", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:dic];
    }

    return NO;
}

#pragma mark Message

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    [self postNotificationWithName:kNotification2H5_UC_DidRecvieMess obj:[message XMLString]];

    NSLog(@"didReceiveMessage -> %@",message);
    if (message.isErrorMessage) {
        NSString *msgId = @"";
        NSString *value = [message XMLString];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",value,@"value", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidReceiveErrorMessage object:dic];
    }
    else{
        [self addMessageOperation:message];
    }
}
- (void)postNotificationWithName:(NSString *)aName obj:(id)aObj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:aObj];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"!!!!!!!!!! didReceiveError -> %@ ",error);
    DDXMLElement* textElement = [error elementForName:@"text"];
    if (textElement && [@"Replaced by new connection" isEqualToString:textElement.stringValue]) {
        //被踢下线后 _connectType = kConnectType_ExtranetIP  防止用内网地址登录的时候，会使用外网地址链接，导致一直连接中
        NSString *msgId = @"";
        NSString *value = [error XMLString];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"msgId",value,@"value", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidReceiveErrorMessage object:dic];

    }
}

#pragma mark 数据库

- (void)connectSQLite3
{
    if (self.localMsgDB) {
        if ([self.serverID isEqualToString:[CMPCore sharedInstance].serverID]) {
            return;
        }
    }
    self.serverID = [CMPCore sharedInstance].serverID;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSString *localContactsName = [NSString stringWithFormat:@"%@%@.sqlite",@"UC",self.serverID];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:localContactsName];
    [_localMsgDB close];
    self.localMsgDB = [FMDatabase databaseWithPath:dbPath];
    if (![_localMsgDB open]) {
        return ;
    }
    [_localMsgDB setShouldCacheStatements:YES];
    
    NSString *msgTableSql = @"CREATE TABLE IF NOT EXISTS  [msg_xml] (\
    [ID] TEXT, \
    [USERID] TEXT, \
    [MSG] TEXT)";
    [_localMsgDB executeUpdate:msgTableSql];
    
}

- (void)addMessageOperation:(XMPPMessage *)message
{
    NSString *messageid = [NSString uuid];
    NSString *messageStr = [message XMLString];
    NSString *memberid = [CMPCore sharedInstance].userID;
    NSString *sql = [NSString stringWithFormat:@"insert into msg_xml (ID,USERID,MSG) values ('%@','%@','%@')",messageid,memberid,messageStr];
    [_localMsgDB executeUpdate:sql];

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:messageid,@"msgId",messageStr,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidReceiveMessage object:dic];
    
    CMPMessageObject *obj = [self transformToCMPMessageObject:message];
    if (obj) {
        obj.msgId = messageid;
        //    obj.latestMessage = messageStr;
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidReceiveMessageToMsg object:obj];
        obj = nil;
    }
}


- (CMPMessageObject *)transformToCMPMessageObject :(NSXMLElement *)message {
//    NSString *targetId = @"";
    NSString *targetName = @"";
    NSString *content = @"";
    NSString * time = [message attributeStringValueForName:@"t"];
    if ([NSString isNull:time]) {
        time = [CMPDateHelper getCurrentDateStr];
    }
    else {
        time = [NSDate timetap:time];
    }

//    if ([from rangeOfString:[CMPCore sharedInstance].userID].location != NSNotFound) {
//        XMPPJID *jid = [XMPPJID jidWithString:to];
//        targetId = jid.bare;
//    }
//    else {
//        XMPPJID *jid = [XMPPJID jidWithString:from];
//        targetId = jid.bare;
//    }
    NSString* type = [message attributeStringValueForName:@"type"];
    targetName = [message elementForName:@"name"].stringValue;
    if ([@"chat" isEqualToString:type]) {
        content =[message elementForName:@"body"].stringValue;
        content = [content replaceCharacter:@"&nbsp;" withString:@" "];
        content = [content replaceCharacter:@"\n" withString:@" "];
    }
    else if([@"groupchat" isEqualToString:type]){
        content =[message elementForName:@"body"].stringValue;
        content = [content replaceCharacter:@"&nbsp;" withString:@" "];
        content = [content replaceCharacter:@"\n" withString:@" "];

    }
    else if([@"image" isEqualToString:type]){
        content = @"msg_image";
    }
    else if([@"microtalk" isEqualToString:type]){
        content = @"msg_voice";
    }
    else if([@"filetrans" isEqualToString:type]){
        content = @"msg_file";
    }
    else if([@"vcard" isEqualToString:type]){
        content = @"msg_vcard";
    }
    else {
        return nil;
    }
    
//    if ([@"groupchat" isEqualToString:type] || [from rangeOfString:@"group."].location != NSNotFound
//        || [to rangeOfString:@"group."].location != NSNotFound ) {
//        targetName= [message elementForName:@"groupname"].stringValue;
//    }
    
    CMPMessageObject *obj = [[CMPMessageObject alloc] init];

    obj.cId = @"UC";
    obj.topSort = kTopSort_Default;
    obj.type = CMPMessageTypeUC;
    obj.unreadCount = 0;
    obj.timeStamp = time;
    obj.content = content;
    obj.appName = targetName;
    obj.iconUrl = @"";
    obj.createTime = time;
    obj.senderName = @"";
    obj.sId = [CMPCore sharedInstance].serverID;
    obj.senderFaceUrl = @"";
    obj.isTop = NO;
    obj.receiveTime = time;
    obj.latestMessage = @"";
    obj.subtype = CMPRCConversationType_PRIVATE;
    obj.gotoParams = @"";
    return obj;
}


#pragma mark H5 接口

- (BOOL)sendMsg:(NSString *)msg
{
    BOOL connect = [self checkAndReconnect];
    if (connect) {
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:msg error:nil];

        [_xmppStream sendElement:element];
        CMPMessageObject *obj = [self transformToCMPMessageObject:element];
        if (obj) {
            obj.msgId = [NSString uuid];
            //    obj.latestMessage = messageStr;
            [[NSNotificationCenter defaultCenter] postNotificationName:kXmppDidReceiveMessageToMsg object:obj];
            obj = nil;
        }
        element = nil;
    }
    return  connect;
}

- (NSArray *)getLocalMessage{
    NSString *memberid = [CMPCore sharedInstance].userID;
    NSString *sql = [NSString stringWithFormat:@"select * from msg_xml  where USERID = '%@'",memberid];
    FMResultSet *set =  [_localMsgDB executeQuery:sql];
    NSMutableArray *result = [NSMutableArray array];
    while ([set next]) {
        NSString *msgId = [set stringForColumn:@"ID"];
        NSString *msg = [set stringForColumn:@"MSG"];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"id",msg,@"data", nil];
        [result addObject:dic];
    }
    return result;
}

- (void)deleteMsgWithID:(NSString *)msgId
{
    NSString *memberid = [CMPCore sharedInstance].userID;
    NSString *sql = [NSString stringWithFormat:@"delete * from msg_xml  where USERID = '%@' and ID = '%@' ",memberid,msgId];
    [_localMsgDB executeQuery:sql];
}

- (NSString *)ip {
   
    if (_xmppStream.hostName) {
        return _xmppStream.hostName;
    }
    else if (self.loginIP) {
        return self.loginIP;
    }
    return  @"";
}
- (NSString *)port {
    return  _port;
}

- (BOOL)checkAndReconnect{
    if (!_xmppStream.isConnected) {
        if (!_isConnecting) {
            [self logout];
            [self login];
        }
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark network check

/// 当网络状态发生变化时调用
- (void)networkChanged:(NSNotification *)notification{
    NSInteger status = [CMPCommonManager networkReachabilityStatus]; //[notification.object integerValue];
    // 两种检测:路由与服务器是否可达  三种状态:手机流量联网、WiFi联网、没有联网
    if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //网络可用
        [self checkAndReconnect];
    }
}

#pragma mark Rong Cloud

- (void)rongCloudInfo:(NSDictionary *)data {
    [self saveRongConfig:data];
    NSString *ucRongServiceIp = [data objectForKey:@"uc_rongservice_ip"];
    NSString *ucRongAppKey = [data objectForKey:@"ucRongAppKey"];
    NSString *ucRongServiceport = [data objectForKey:@"uc_rongservice_navi_port"];
    NSString *token = [data objectForKey:@"token"];
    NSString *deployment = [data objectForKey:@"uc_deployment"];
    NSString * isShowlittleBroad = [data objectForKey:@"littleBroadcastPlugin"];
    NSString *video_enable = [data objectForKey:@"video_enable"];
    NSString *video_status = [data objectForKey:@"video_status"];
    NSString *videoExpirationDays = [data objectForKey:@"videoExpirationDays"];
    NSString *videoExpirationRemindSet = [data objectForKey:@"videoExpirationRemindSet"];
    NSString *videoExpirationRemindMsg = [data objectForKey:@"videoExpirationRemindMsg"];
    
    //是否可以上传附件与图片，默认YES，
    NSString *fileUploadEnable = data[@"fileUploadEnable"];
    if ([NSString isNull:fileUploadEnable]) {
        self.fileUploadEnable = YES;
    }
    else {
        self.fileUploadEnable = [fileUploadEnable boolValue];
    }

    if (![NSString isNull:ucRongAppKey]) {
        self.appKey = ucRongAppKey;
    }
    if (![NSString isNull:token]) {
        self.token = token;
    }
    if (![NSString isNull:isShowlittleBroad]) {
        _isShowlittleBroad = [isShowlittleBroad boolValue];
    }
    if (![NSString isNull:video_enable]) {
        _isVideoEnable = [video_enable boolValue];
    }
    if (![NSString isNull:video_status]) {
        _videoStatus = [video_status boolValue];
    }
    if (![NSString isNull:videoExpirationDays]) {
        _videoExpirationDays  = [videoExpirationDays integerValue];
    }
    
    if (![NSString isNull:videoExpirationRemindSet]) {
        _isRemindVideoExpire = [videoExpirationRemindSet boolValue];
    }
    
    if (![NSString isNull:videoExpirationRemindMsg]) {
        _videoExpirationRemindMsg = videoExpirationRemindMsg;
    }

    
    if ([CMPCore sharedInstance].serverIsLaterV7_1) {

        CMPMessageObject *littleBroadObjc = [[CMPMessageManager sharedManager] messageWithAppID:kMessageType_MassNotificationMessage];
        if (!littleBroadObjc) {//预置小广播
            littleBroadObjc = [[CMPMessageObject alloc] initNoneMassNotificationMessage];
        }
        
        if (self.isShowlittleBroad) {
            [[CMPMessageManager sharedManager] saveMessages:@[littleBroadObjc] isChat:YES];
        } else {
            [[CMPMessageManager sharedManager] deleteMessageWithAppId:littleBroadObjc];
        }
        
        CMPMessageObject *fileAssistantObjc = [[CMPMessageManager sharedManager] messageWithAppID:[CMPCore sharedInstance].userID];
        if (!fileAssistantObjc) {//预置文件助手
            fileAssistantObjc = [[CMPMessageObject alloc] initFileAssistantMessageWithAppID:[CMPCore sharedInstance].userID];
            [[CMPMessageManager sharedManager] saveMessages:@[fileAssistantObjc] isChat:YES];
        }
        
    }
    
    /*
     * 	ucChannel：服务器方式：local本地致信服务，rong融云服务
     * 	ucRongServiceIp：融云的服务地址（私有云）
     *  ucRongServiceport：融云的服务端口（私有云）
     *  ucRongAppKye：融云的key
     *  token：用户认证token
     */
    
    if (![NSString isNull:self.appKey] && ![NSString isNull:self.token]) {
        [self initAppKey:ucRongServiceIp port:ucRongServiceport deployment:deployment];
        [self setRCDelegate:self];
        [self RCGlobalSettings];
        [self connectRongCloud];
        if (CMPFeatureSupportControl.isNeedUpdateRCMessageSetting) {
            [self updateRCMessageSetting];
        }
    }
}

- (void)saveRongConfig:(NSDictionary *)data {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:data];
    [dic removeObjectForKey:@"ucRongAppKey"];
    [dic removeObjectForKey:@"token"];
    self.rongConfig = [dic copy];
}

#pragma mark 初始化 AppKey
- (void)initAppKey:(NSString *)serviceIp port:(NSString *)port deployment:(NSString *)deployment
{
    if ([deployment isEqualToString:@"private"]) { // 判断是不是私有云
        NSString *server = nil;
        if (![NSString isNull:port]) {
            server = [NSString stringWithFormat:@"%@:%@", serviceIp, port];
        } else {
            server = serviceIp;
        }
        [[RCIMClient sharedRCIMClient] setServerInfo:server fileServer:nil];
    } else {
        [[RCIMClient sharedRCIMClient] setServerInfo:@"https://nav.cn.ronghub.com" fileServer:nil];
    }
    
    [[RCIM sharedRCIM] initWithAppKey:self.appKey];
    [[RCIM sharedRCIM] registerMessageType:[CMPUCSystemMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPReadedMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPOAMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPFileStatusReceiptMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCV5Message class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCTransmitMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCSystemImMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCShakeWinMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCUrgeMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPMassNotificationMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPBusinessCardMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPCombineMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPGeneralBusinessMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPFolderMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRCFolderMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRobotMsg class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPRobotAtMsg class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPClearMsg class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPVideoMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPSignMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPPCCreateGroupMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPSettingMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPQuoteMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[CMPClearMsgRemoteTextMessage class]];
    
}
- (void)setRCDelegate:(id)delegate
{
    //消息
    [[RCIM sharedRCIM] setReceiveMessageDelegate:delegate];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:delegate];
    //data source
    [[RCIM sharedRCIM] setUserInfoDataSource:delegate];
    [[RCIM sharedRCIM] setGroupInfoDataSource:delegate];

   // [[RCIM sharedRCIM] setGroupMemberDataSource:delegate];
    //是否在发送的所有消息中携带当前登录的用户信息
    [[RCIM sharedRCIM] setEnableMessageAttachUserInfo:YES];
    //是否将用户信息和群组信息在本地持久化存储
    [[RCIM sharedRCIM] setEnablePersistentUserInfoCache:YES];
}

// rong cloud 全局设置
- (void)RCGlobalSettings {
    RCIM *shareRCIM = [RCIM sharedRCIM];
    
    //SDK中全局的导航按钮字体颜色
    [shareRCIM setGlobalNavigationBarTintColor:UIColorFromRGB(0x3eb0ff)];
    //头像设置成圆形  貌似不管用啊
    [shareRCIM setGlobalConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    //SDK会话页面中显示的头像形状，矩形或者圆形
    [shareRCIM setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    //消息回撤
    [shareRCIM setEnableMessageRecall:YES];
    [shareRCIM setEnableSyncReadStatus:YES];
    // 打开@人功能
    [shareRCIM setEnableMessageMentioned:YES];
    // 打开已读状态回执
    [shareRCIM setEnabledReadReceiptConversationTypeList:@[@(ConversationType_PRIVATE)]];
    // 打开合并转发功能
    [shareRCIM setEnableSendCombineMessage:YES];
    // gif 10兆以内自动下载
    shareRCIM.GIFMsgAutoDownloadSize = 10*1024;
    // 支持暗黑模式
    shareRCIM.enableDarkMode = YES;
    //消息撤回后可重新编辑的时间，单位是秒，默认值是 300s。
    shareRCIM.reeditDuration = 60;//1分钟
    
    shareRCIM.embeddedWebViewPreferred = YES;
    
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Error];
    // 判断是否开关本地通知、前台提示音
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMyIconChanged) name:kNotificationName_ChangeIcon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAcceptInformationChanged) name:kNotificationName_AcceptInformationChange object:nil];

    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
}

#pragma mark 连接融云
- (void)connectRongCloud
{
    [self onMyIconChanged];//设置离线状态下的user信息
    __weak typeof(self) weakself = self;
    [[RCIM sharedRCIM] connectWithToken:self.token dbOpened:^(RCDBErrorCode code) {
        NSLog(@"ks log --- %s -- RCDBErrorCode: %ld",__func__,code);
        } success:^(NSString *userId) {
            weakself.userId = userId;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self
                                                    selector:@selector(onReceiveRecallMessage:)
                                                        name:RCKitDispatchRecallMessageNotification
                                                      object:nil];
            [weakself onAcceptInformationChanged];
            [weakself onMyIconChanged];
        } error:^(RCConnectErrorCode errorCode) {
            switch (errorCode) {
                case RC_CONN_TOKEN_INCORRECT:
                {
                    weakself.token = nil;
                }
                    break;
                    
                default:
                    break;
            }
        }];
    //ks fix for rc update
//    [[RCIM sharedRCIM] connectWithToken:self.token success:^(NSString *userId) {
//        weakself.userId = userId;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self
//                                                selector:@selector(onReceiveRecallMessage:)
//                                                    name:RCKitDispatchRecallMessageNotification
//                                                  object:nil];
//        [weakself onAcceptInformationChanged];
//        [weakself onMyIconChanged];
//    } error:^(RCConnectErrorCode status) {
//
//    } tokenIncorrect:^{
//        weakself.token = nil;
//        //token过期或者不正确。
//        //如果设置了token有效期并且token过期，请重新请求你的服务器获取新的token
//        //如果没有设置token有效期却提示token错误，请检查你客户端和服务器的appkey是否匹配，还有检查你获取token的流程。
//
//    }];
    
}

#pragma mark 断开融云
- (void)stopRongCloud
{
    self.appKey = nil;
    self.token = nil;
    self.userId = nil;
    _readedGroupNotificationTimestamp = 0;
    [self setRCDelegate:nil];
    [[RCIM sharedRCIM] logout];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_ChangeIcon object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_AcceptInformationChange object:nil];
    [_groupInformations removeAllObjects];
    [_conversationAlertMap removeAllObjects];
}

#pragma mark 新建一个聊天会话
- (void)showChatView:(CMPRCTargetObject *)obj {
    [self showChatView:obj isShowShareTips:NO filePaths:nil];
}

- (void)showChatView:(CMPRCTargetObject *)obj isShowShareTips:(BOOL)isShowShareTips {
    
    [self showChatView:obj isShowShareTips:isShowShareTips filePaths:nil];
}

- (void)showChatView:(CMPRCTargetObject *)obj isShowShareTips:(BOOL)isShowShareTips filePaths:(NSArray *)filePaths {
    
    if (!CMPMessageManager.sharedManager.hasZhiXinPermissionAndServerAvailable) {
        [self cmp_showHUDWithText:SY_STRING(@"msg_zhixin_notHasPermission")];
        return;
    }
    
    // 不支持横屏
    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
    //V7_1过后强制竖屏必须设置该属性为yes
    //aAppDelegate.onlyPortrait = YES;
    aAppDelegate.allowRotation = NO;
    if (!aAppDelegate.allowRotation) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
    
    CMPRCChatViewController *chat = [[CMPRCChatViewController alloc] initWithConversationType:(RCConversationType)obj.type
                                                                                     targetId:obj.targetId];
    if (obj.locatedMessageSentTime) {
        chat.locatedMessageSentTime = obj.locatedMessageSentTime;
    }
    
    if (obj.type == ConversationType_PRIVATE) {
        //如果是单聊，不显示发送方昵称
        chat.displayUserNameInCell = NO;
        //更新人员新信息
        __weak typeof(chat) weakChatVc = chat;
        [[CMPContactsManager defaultManager] memberNamefromServerForId:obj.targetId completion:^(NSString *name) {
            if ([NSString isNotNull:name]) {
                [[RCIM sharedRCIM] refreshUserNameCache:name withUserId:obj.targetId];
                [weakChatVc resetTitle:name];
            }
        }];
        
    } else if (obj.type == ConversationType_GROUP) {
        [[RCIM sharedRCIM] refreshGroupNameCache:obj.title withGroupId:obj.targetId];
        chat.displayUserNameInCell = YES;
        CMPRCGroupMemberObject *groupMemberInfo = obj.messageObject.extradDataModel.groupInfo;
        chat.groupInfo = groupMemberInfo;
        [self getGroupUserListByGroupId:obj.targetId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList) {
            [CMPMessageManager.sharedManager setGroupInfoWithMessage:obj.messageObject groupInfo:groupInfo];
            chat.groupInfo = groupInfo;
            NSString *groupName = groupInfo.name;
            if ([NSString isNotNull:groupName]) {
                [[RCIM sharedRCIM] refreshGroupNameCache:groupName withGroupId:obj.targetId];
                [chat resetTitle:groupInfo.name];
            }
        } fail:^(NSError *error, id ext) {}];
    }
    
    chat.title = obj.title;
    
    if (filePaths.count > 0) {
        chat.filePaths = filePaths;
    }
    
    if (obj.navigationController) {
        if (CMP_IPAD_MODE &&
            [obj.navigationController.topViewController cmp_canPushInDetail]) {
            [obj.navigationController.topViewController cmp_clearDetailViewController];
            [obj.navigationController.topViewController cmp_showDetailViewController:chat];
        } else {
            [obj.navigationController pushViewController:chat animated:YES];
        }
    }
    else {
        CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:chat];
        [[UIViewController currentViewController] presentViewController:nav animated:YES completion:nil];
    }
    
    if (isShowShareTips) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CMPPopOverManager.sharedManager showShareToUCFinishedViewWithVc:chat];
        });
        
    }
}

- (void)onReceiveRecallMessage:(NSNotification *)notification {
    if (!isReceiving) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
    }
}

#pragma mark -
#pragma mark - 融云Delegate

- (BOOL)needPlaySystemSound:(RCMessage *)message {
    __block AppDelegate *appDelegate = nil;
    [self dispatchSyncToMain:^{
        appDelegate = [AppDelegate shareAppDelegate];
    }];
    
    if (appDelegate.launchFromNotification) {
        NSDate *now = [NSDate date];
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:appDelegate.launchFromNotificationStartTime];
        if (timeInterval < 5) {
            return NO;
        }
    }
    if (([message.content isMemberOfClass:[CMPMassNotificationMessage class]])) {//小广播要提醒
        return YES;
    }
    if ([message.content isSpecialMessage]) {
        return NO;
    }
    if ([message.content isKindOfClass:[RCGroupNotificationMessage class]] &&
        ![self needSaveGroupNotificationWithMessage:message]) { // 不计数的群系统消息不提醒
        return NO;
    }
    return YES;
}


/*!
 接收消息的回调方法
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message
                        left:(int)left {
    
    isReceiving = YES;
    [self cacheGroupInformation:message];
    [self updateGroupChatTitle:message];
    // 多端未读消息条数同步
    if ([message.content isKindOfClass:[CMPReadedMessage class]]) {
        CMPReadedMessage *readedMessage = (CMPReadedMessage *)message.content;
        NSString *targetId = readedMessage.itemId;
        if ([targetId isEqualToString:kRCGroupNotificationTargetID]) { // 群系统消息
            if (readedMessage.timestamp > _readedGroupNotificationTimestamp) {
                _readedGroupNotificationTimestamp = readedMessage.timestamp;
                [[CMPMessageManager sharedManager] readMessageWithAppID:targetId];
            }
        } else {
           [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:readedMessage.conversationType
                                                            targetId:targetId
                                                                time:readedMessage.timestamp];
        }
    }
    else if ([message.content isKindOfClass:[CMPUCSystemMessage class]]) { // 在后台收到V5消息弹出本地通知
//        CMPUCSystemMessage *systemMessage = (CMPUCSystemMessage *)message.content;
//        NSLog(@"RC---收到V5消息：%@", systemMessage.content);
    }
    else if ([message.content isKindOfClass:[CMPOAMessage class]]) {
        CMPOAMessage *oaMessage = (CMPOAMessage *)message.content;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                NSLog(@"RC---在后台收到V5消息");
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = oaMessage.content;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                if (![RCIM sharedRCIM].pushVibrationRemind) {
                }
                if (![NSString isNull:oaMessage.extra]) {
                    NSDictionary *optionsDic = @{@"options" : oaMessage.extra};
                    localNotification.userInfo = @{@"rc" : optionsDic};
                }
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                [CMPCore sharedInstance].applicationIconBadgeNumber = count;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
            }
        });
    }
    else if ([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
        // 存储群系统消息
        RCConversation *conversation = [[RCConversation alloc] init];
        conversation.lastestMessage = message.content;
        if ([self needSaveGroupNotificationWithConversation:conversation]) {
            CMPRCGroupNotificationObject *notificationObject = [[CMPRCGroupNotificationObject alloc] initWithRCMessage:message];
            [_groupNotificationManager insertNotifications:@[notificationObject]];
        }
        RCMessageContent *lastestMessage = message.content;
        if ([lastestMessage respondsToSelector:@selector(extra)]) {
            NSString *extra = [lastestMessage performSelector:@selector(extra)];
            NSDictionary *extraDic = [extra JSONValue];
            //ks add --- department group flag
            NSString *operation = [NSString stringWithFormat:@"%@",((RCGroupNotificationMessage *)lastestMessage).operation];
            if ([@"Create" isEqualToString:operation]) {
                NSString *groupType = extraDic[@"groupType"];
                if ([NSString isNotNull:groupType]) {
                    CMPMessageObject *object = [CMPMessageManager.sharedManager messageWithAppID:message.targetId];
                    if (object) {
                        CMPRCGroupMemberObject *groupInfo = object.extradDataModel.groupInfo;
                        if (groupInfo) {
                            groupInfo.groupType = groupType;
                            [CMPMessageManager.sharedManager setGroupInfoWithMessage:object groupInfo:groupInfo];
                        }
                    }
                }
            } else if ([@"convertDept2SimpleGroup" isEqualToString:operation]
                       ||[@"convertSimple2DeptGroup" isEqualToString:operation]) {
                NSString *groupId = [NSString stringWithFormat:@"%@",extraDic[@"groupId"]];
                CMPMessageObject *object = [CMPMessageManager.sharedManager messageWithAppID:groupId];
                if (object) {
                    CMPRCGroupMemberObject *groupInfo = object.extradDataModel.groupInfo;
                    if (groupInfo) {
                        NSMutableDictionary *dbResultDic = [NSMutableDictionary dictionary];
                        NSDictionary *finalVal = @{@"tag":@"0",@"val":@{@"groupType":([@"convertSimple2DeptGroup" isEqualToString:operation] ? @"DEPARTMENT" : @"ORDINARY")}};
                        [dbResultDic setObject:[finalVal JSONRepresentation] forKey:groupId];
                        [[CMPMessageManager sharedManager] updateGroupConversationTypeInfo:dbResultDic];
                        //ks add -- V5-45133【致信】iosM3-部门群已经转成普通群，聊天列表中部门群的标识没有消失
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_departmentGroupInfoChanged" object:nil];
                        });
                        //end
                    }
                }
            }
            //end
        }
    }
    else if ([message.content isKindOfClass:[CMPFileStatusReceiptMessage class]]) { // 收到文件已下载消息
        CMPFileStatusReceiptMessage *fileStatusMessage = (CMPFileStatusReceiptMessage *)message.content;
        [CMPFileStatusProvider fileDownloadedWithMsgUId:fileStatusMessage.msgUId];
    }
    else if ([message.content isKindOfClass:[CMPMassNotificationMessage class]] && [CMPCore sharedInstance].serverIsLaterV7_1) {
        
        CMPMessageObject *objc = [[CMPMessageObject alloc] initMassNotificationMessageeWithMessage:message.content];
        [[CMPMessageManager sharedManager]saveMessages:@[objc] isChat:YES];
        
    }
    else if ([message.content isKindOfClass:[CMPSettingMessage class]] && CMPFeatureSupportControl.isNeedUpdateRCMessageSetting) {
        CMPSettingMessage *settingMessage = (CMPSettingMessage *)message.content;
        NSString *talkId = settingMessage.talkId;
        int recordType = settingMessage.recordType;
        int recordValue = settingMessage.recordValue;
        int talkType = settingMessage.talkType;
       
        NSString *conversationType = (talkType == 0) ? kChatManagerRCChatTypePrivate : kChatManagerRCChatTypeGroup;
        if (recordType == 0) {
            NSString *alertStatus = (recordValue == 0) ? @"1" : @"0";
            [self setChatAlertStatus:alertStatus targetId:talkId type:conversationType];
        }else if (recordType == 1) {
            NSString *status = (recordValue != 0) ? @"1" : @"0";
            [self setChatTopStatus:status targetId:talkId type:conversationType ext:@{@"serverTopTime":@(recordValue)}];
        }else if (recordType == 2) {//未读
            //对在未登录期间标为未读的消息不处理，根据时间戳，在登录成功以前时间的不处理
//            if (message.sentTime < [CMPCore sharedInstance].loginSuccessTime.timeIntervalSince1970*1000) {
//                return;
//            }
            __weak typeof(self) weakSelf = self;
            [self dispatchAsyncToChild:^{
                [[CMPMessageManager sharedManager] messageList:^(NSArray<CMPMessageObject *> *msgList) {
                    for (CMPMessageObject *msg in msgList) {
                        if ([msg.cId isEqualToString:talkId]) {
                            if ((talkType == 1 && msg.subtype == CMPRCConversationType_GROUP)
                                ||(talkType == 0 && msg.subtype == CMPRCConversationType_PRIVATE)) {
                                [weakSelf dispatchAsyncToMain:^{
                                    [[CMPMessageManager sharedManager] markUnreadWithMessage:msg isMarkUnread:recordValue == 1];
                                }];
                                break;
                            }
                        }
                    }
                }];
            }];
        }else if (recordType == 3) {//移除
            //对在未登录期间标为未读的消息不处理，根据时间戳，在登录成功以前时间的不处理
//            if (message.sentTime < [CMPCore sharedInstance].loginSuccessTime.timeIntervalSince1970*1000) {
//                return;
//            }
            [[CMPMessageManager sharedManager] messageList:^(NSArray<CMPMessageObject *> *msgList) {
                [msgList enumerateObjectsUsingBlock:^(CMPMessageObject * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([msg.cId isEqualToString:talkId]) {
                        if ((talkType == 1 && msg.subtype == CMPRCConversationType_GROUP)
                            ||(talkType == 0 && msg.subtype == CMPRCConversationType_PRIVATE)) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [[CMPMessageManager sharedManager] deleteMessageWithAppId:msg];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageUpdate object:@{@"action":@"removeCon",@"cid":talkId,@"index":@(idx)}];
                            });
                            *stop = YES;
                        }
                    }
                }];
            }];
        }
    }
    //ks add -- otm -- 即时会议消息
    else if ([message.content isKindOfClass:CMPGeneralBusinessMessage.class]) {
        CMPGeneralBusinessMessage *businessMessage = (CMPGeneralBusinessMessage *)message.content;
        NSString *messageCategory = businessMessage.messageCategory;
        if ([@"109" isEqualToString:messageCategory]) {
            NSDictionary *notiObj = [message yy_modelToJSONObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_OtmMessageRecieved" object:notiObj];
        }
        //pc端创建会触发一条消息，其它端不会，BUG2023081162411
        if (([@"-1" isEqualToString:message.targetId]
             ||[@"0" isEqualToString:message.targetId])
            && [[CMPCore sharedInstance].userID isEqualToString:message.senderUserId]) {
            return;
        }
        //end
    }
    
    // 屏蔽掉特殊类型消息
    if ([message.content isSpecialMessage]) {
        BOOL result = [[RCIMClient sharedRCIMClient] deleteMessages:@[[NSNumber numberWithLongLong:message.messageId]]];
        NSLog(@"RC---删除特殊类型消息。消息ID：%ld。删除结果：%d", message.messageId, result);
    }
    //
    
    //handleClearRemoteMessage
    if ([CMPChatManager canRemoveRemoteMsg]
        && [message.content isKindOfClass:CMPClearMsgRemoteTextMessage.class]
        && [message.senderUserId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.customRemoteMsgArr addObject:message];
    }
    
    if (left == 0) {
        isReceiving = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
        
        //处理远程消息-CMPClearMsgRemoteTextMessage
        [self handleClearRemoteMessage];
    }

}

- (void)handleClearRemoteMessage{
    if ([CMPChatManager canRemoveRemoteMsg]) {
        NSMutableArray *tmpArr = [self.customRemoteMsgArr mutableCopy];
        [self.customRemoteMsgArr removeAllObjects];
        
        //先去除多余的数据
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        for (RCMessage *msg in tmpArr) {
            NSString *key = msg.targetId;
            if (key) {
                RCMessage *m = [mDict objectForKey:key];
                if (!m) {
                    [mDict setValue:msg forKey:key];//没有值，则存一份
                }else{
                    if (msg.sentTime>m.sentTime) {
                        [mDict setValue:msg forKey:key];//时间更近，则替换value
                    }
                }
            }
        }
        
        //处理删除
        for (RCMessage *msg in [mDict allValues]) {
            [self removeRemoteMsg:msg];
        }
    }
}

- (void)removeRemoteMsg:(RCMessage *)message{
    long long time = message.sentTime;
    NSString *targetId = message.targetId;
    
    //从服务器端清除历史消息
    [[RCIMClient sharedRCIMClient] clearHistoryMessages:message.conversationType targetId:message.targetId recordTime:time clearRemote:YES success:^{
        NSLog(@"clearHistoryMessages-删除成功-%lld",message.sentTime);
        NSArray *latestMessageArray = [[RCIMClient sharedRCIMClient] getLatestMessages:message.conversationType targetId:message.targetId count:1];
        RCMessage *latestMessage = [latestMessageArray lastObject];
        //如果接收消息的最后一条消息的时间比清空消息的时间早，则清空列表的最近一条消息状态
        //latestMessage为空则最近一条消息也删除了 || 最后一条消息时间比清空历史消息早
        if ( !latestMessage || (latestMessage.sentTime>0 && latestMessage.sentTime<time)) {
            //清空列表数据
            if (message.conversationType == ConversationType_GROUP) {
                [[CMPMessageManager sharedManager] clearRCGroupChatMsgWithGroupId:targetId];
            }else if (message.conversationType == ConversationType_PRIVATE){
                [[CMPMessageManager sharedManager] clearRCChatMsgWithTargetId:targetId type:message.conversationType];
            }
        }
    } error:^(RCErrorCode status) {
        NSLog(@"clearHistoryMessages-删除失败");
    }];
}

/*!
 拦截消息的回调方法
 */
- (BOOL)interceptMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCGroupNotificationMessage class]]) {
        // 拦截踢人消息,只有群主和踢自己的消息不拦截
        RCConversation *conversation = [[RCConversation alloc] init];
        conversation.targetId = message.targetId;
        conversation.lastestMessage = message.content;
        CMPRCGroupNotificationObject *notificationObject = [[CMPRCGroupNotificationObject alloc] initWithRCConversation:conversation];
        [self postGroupMemberChange:notificationObject];
        BOOL isIntercept = [self needInterceptGroupNotification:notificationObject];
        if (isIntercept) {
            BOOL result = [[RCIMClient sharedRCIMClient] deleteMessages:@[[NSNumber numberWithLongLong:message.messageId]]];
            NSLog(@"RC---拦截踢人消息。消息ID：%ld。删除结果：%d", message.messageId, result);
            
            if ([self needSaveGroupNotificationWithConversation:conversation]) {
               CMPRCGroupNotificationObject *notificationObject = [[CMPRCGroupNotificationObject alloc] initWithRCMessage:message];
               [_groupNotificationManager insertNotifications:@[notificationObject]];

               NSMutableArray *array = [NSMutableArray array];
               RCMessageContent *lastestMessage = conversation.lastestMessage;
               CMPMessageObject *notificationObjc = [[CMPMessageObject alloc] initWithRCConversation:conversation];
               notificationObjc.createTime = [CMPDateHelper dateStrFromLongLong:message.sentTime];
               notificationObjc.receiveTime = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
               notificationObjc.timeStamp = [CMPDateHelper dateStrFromLongLong:conversation.receivedTime];
               notificationObjc.content = [(RCGroupNotificationMessage *)lastestMessage groupNotification];
               notificationObjc.cId = kRCGroupNotificationTargetID;
               notificationObjc.type = CMPMessageTypeRCGroupNotification;
               notificationObjc.iconUrl = [NSString stringWithFormat:@"image:msg_groupnotification.png:3179255"];
               notificationObjc.subtype = CMPRCConversationType_GROUP;
               notificationObjc.appName = @"msg_groupNotification";
               [array addObject:notificationObjc];
               [[CMPMessageManager sharedManager] saveMessages:[array copy] isChat:YES];

                [[RCSystemSoundPlayer defaultPlayer] playSoundByMessage:message completeBlock:^(BOOL complete) {
                    
                }];
            }
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)onRCIMCustomLocalNotification:(RCMessage *)message withSenderName:(NSString *)senderName {
    
    CMPCore *core = [CMPCore sharedInstance];
    BOOL notPushLocalNotification = core.isMultiOnline && !core.multiLoginReceivesMessageState;
    
    if (notPushLocalNotification) {
        return YES;
    }
    
   if ([message.content isKindOfClass:[CMPMassNotificationMessage class]]) {
        
        CMPMassNotificationMessage *msg = (CMPMassNotificationMessage*)message.content;
        NSString *pushStr = @"";
        
        if (msg.broadcastType.integerValue == 0) {
            pushStr = [NSString stringWithFormat:@"%@%@:%@",msg.sendMemberName ,SY_STRING(@"msg_xgbnewtip"),msg.content];
        }if (msg.broadcastType.integerValue == 1) {
            return NO;
        } else if(msg.broadcastType.integerValue == 2) {
            pushStr = [NSString stringWithFormat:@"%@%@",msg.sendMemberName, SY_STRING(@"msg_xgbrecalltip")];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertTitle = msg.sendMemberName;
                localNotification.alertBody = pushStr;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            }
        });
        return YES;
    }
    return NO;
}

-(void)onRCIMMessageRecalled:(long)messageId
{
    
}


/*!
 IMKit连接状态的的监听器
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    NSLog(@"%s:%ld",__func__,status);
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) { // 被踢下线
        [[CMPMessageManager sharedManager] stop];
        NSError *newError = [NSError errorWithDomain:SY_STRING(@"common_kikedByOther") code:401 userInfo:nil];
        [[AppDelegate shareAppDelegate] handleError:newError];
    }
}

-(void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *))resultBlock{
    
    
}

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    [self memberNameForId:userId completion:^(NSString *userName) {
        if (![NSString isNull:userName]) { // 离线通讯录有，直接返回
            RCUserInfo *userInfo = [[RCIM sharedRCIM] refreshUserNameCache:userName withUserId:userId];
            completion(userInfo);
            return;
        }
        
        [self->_userCacheManager getUserName:userId groupId:self->_currentGroupId done:^(NSString *name) {
            RCUserInfo *userInfo = [[RCIM sharedRCIM] refreshUserNameCache:name withUserId:userId];
            completion(userInfo);
        }];
    }];
}

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion {
    RCGroup *group = [[RCGroup alloc] init];
    group.groupName = [self getGroupNameWithID:groupId];
    group.groupId = groupId;
    group.portraitUri = nil;
    completion(group);
}

#pragma mark -
#pragma mark -获取融云消息

- (void)getRCMessageList:(void (^)(NSArray *))completion
{
    if ([NSString isNull:self.token]) {
        return;
    }
    
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION),
                                                       @(ConversationType_GROUP)]];
    NSMutableArray *array = [NSMutableArray array];

    for (RCConversation *conversation in conversationList) {

        if (conversation.lastestMessageId == -1) { // 该聊天的所有聊天记录都被删除掉了
            [[CMPMessageManager sharedManager] clearRCChatMsgWithTargetId:conversation.targetId type:conversation.conversationType];
            continue;
        }
        
        if ([conversation.lastestMessage isSpecialMessage]) { // 特殊类型消息不处理
            continue;
        }
        
        [self cacheAlertStatus:conversation];
        [self cacheGroupInformationWithConversasion:conversation];
        [self cacheUserInformation:conversation];
        
        RCMessageContent *lastestMessage = conversation.lastestMessage;
        
        if ([lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) { // 添加一个条目，“群系统消息”
            if ([self needSaveGroupNotificationWithConversation:conversation]) { // 过滤群系统消息
                CMPMessageObject *notificationObjc = [[CMPMessageObject alloc] initWithRCConversation:conversation];
                notificationObjc.content = [(RCGroupNotificationMessage *)lastestMessage groupNotification];
                notificationObjc.cId = kRCGroupNotificationTargetID;
                notificationObjc.type = CMPMessageTypeRCGroupNotification;
                notificationObjc.subtype = CMPRCConversationType_GROUP;
                notificationObjc.iconUrl = [NSString stringWithFormat:@"image:msg_groupnotification.png:3179255"];
                notificationObjc.appName = @"msg_groupNotification";
                [array addObject:notificationObjc];
            }
        }
        
        if ([self needDeleteMessage:conversation]) {
            continue;
        }
        
        if ([lastestMessage isKindOfClass:[RCRecallNotificationMessage class]]) { // 处理消息撤回
            CMPMessageObject *objc = [self handleRecallMessage:conversation];
            [array addObject:objc];
            continue;
        }
        
        CMPMessageObject *objc = [[CMPMessageObject alloc] initWithRCConversation:conversation];
        
        if (objc.type == CMPMessageTypeRC && [objc.cId containsString:@"null"]){//如果RC消息的cid为(null)字符串则不保存到本地数据库->解决V5-56468【暂无数据】问题
            continue;
        }else{
            [array addObject:objc];
        }

        //查不到消息，则不显示
        if (conversation.conversationType == ConversationType_PRIVATE
            || conversation.conversationType == ConversationType_GROUP) {
            RCMessage *message = [[RCIMClient sharedRCIMClient] getMessageByUId:objc.msgId];
            if (!message) {
                continue;
            }
        }
        
    }
    
    [_groupNotificationManager readNotificationBefore:_readedGroupNotificationTimestamp];
    completion(array);
}

/**
 判断是否需要存储该群系统消息
 */
- (BOOL)needSaveGroupNotificationWithConversation:(RCConversation *)conversation {
    RCMessageContent *lastestMessage = conversation.lastestMessage;
    if ([lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
        CMPRCGroupNotificationObject *notificationObject = [[CMPRCGroupNotificationObject alloc] initWithRCConversation:conversation];
        return  [self needSaveGroupNotification:notificationObject];
    } else {
        return NO;
    }
}

- (BOOL)needSaveGroupNotificationWithMessage:(RCMessage *)message {
    RCMessageContent *lastestMessage = message.content;
    if ([lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
        return [self needSaveGroupNotification:[[CMPRCGroupNotificationObject alloc] initWithRCMessage:message]];
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)needSaveGroupNotification:(CMPRCGroupNotificationObject *)object {
    CMPRCGroupNotificationObject *notificationObject = object;
    
    NSString *extraStr = notificationObject.extra1;
    NSDictionary *extraDic = [extraStr JSONValue];
    NSString *operation = notificationObject.operation;
    NSArray *targetUserIds = extraDic[@"targetUserIds"]; // 操作的目标id
    NSString *creatrorId = extraDic[@"creatorId"]; // 群主ID
    NSString *groupName = extraDic[@"groupName"]; // 群名
    NSString *targetId = extraDic[@"groupId"]; // 群ID
    NSString *userId = [CMPCore sharedInstance].userID;
    
    if ([operation isEqualToString:CMPRCGroupNotificationOperationAdd]) { // 邀请
        if (![targetUserIds containsObject:[CMPCore sharedInstance].userID]) { // 添加群成员后，群成员没有群系统通知
            return NO;
        }
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationKicked]) { // 踢人
        if ([targetUserIds containsObject:userId]) { // 踢人，其它群成员没有群系统通知
            return YES;
        }
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationRename]) {
        [self refreshRCGroupInfoCacheWithGroupName:groupName targetId:targetId];
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationQuit]) { // 主动退出
        if (![creatrorId isEqualToString:[CMPCore sharedInstance].userID]) { // 不是群主收不到主动退出的群系统消息
            return NO;
        }
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationCreate]) { // 创建群组
        [self refreshRCGroupInfoCacheWithGroupName:groupName targetId:targetId];
        if ([notificationObject.operatorUserId isEqualToString:userId]) { // 创建群群主收不到群系统消息
            return NO;
        }
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationReplacement]) { // 群主转移
        if ([creatrorId isEqualToString:userId]) { // 转移群主，只有新群主才收到群系统通知
            return YES;
        }
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationDismiss]) { //解散群组
        return YES;
    } else if ([operation isEqualToString:CMPRCGroupNotificationOperationSetAdmin] ||
               [operation isEqualToString:CMPRCGroupNotificationOperationUnSetAdmin]) { //被设置为群管理员
        if ([targetUserIds containsObject:[CMPCore sharedInstance].userID]) { // 管理员权限变更,只有被更改的人才收到群系统通知
            return YES;
        }
    }  else {
        return NO;
    }
    return NO;
}

- (BOOL)needInterceptGroupNotification:(CMPRCGroupNotificationObject *)object {
    CMPRCGroupNotificationObject *notificationObject = object;
    
    NSString *extraStr = notificationObject.extra1;
    NSDictionary *extraDic = [extraStr JSONValue];
    NSString *operation = notificationObject.operation;
    NSString *operatorUserId = notificationObject.operatorUserId;
    NSArray *targetUserIds = extraDic[@"targetUserIds"]; // 操作的目标id
    NSString *creatrorId = extraDic[@"creatorId"]; // 群主ID
    NSString *userId = [CMPCore sharedInstance].userID;
    
    if ([operation isEqualToString:CMPRCGroupNotificationOperationKicked]) { // 踢人
        if ([creatrorId isEqualToString:userId]) { // 收到踢人消息的是群主 不拦截
            return NO;
        }else if ([targetUserIds containsObject:[CMPCore sharedInstance].userID]) { //自己被踢 不拦截
            return NO;
        } else {
            return YES;
        }
    }
    else if ([operation isEqualToString:CMPRCGroupNotificationOperationSetAdmin] ||
             [operation isEqualToString:CMPRCGroupNotificationOperationUnSetAdmin]) {
        if ([targetUserIds containsObject:userId] || [operatorUserId isEqualToString:userId] == NO) { // 管理员权限变更,被更改的人群内群消息不显示,只显示群系统
            return YES;
        }
    }
    return NO;
}

- (void)postGroupMemberChange:(CMPRCGroupNotificationObject *)object {
    CMPRCGroupNotificationObject *notificationObject = object;
    NSString *operation = notificationObject.operation;
    
    if ([operation isEqualToString:CMPRCGroupNotificationOperationKicked] ||
        [operation isEqualToString:CMPRCGroupNotificationOperationAdd] ||
        [operation isEqualToString:CMPRCGroupNotificationOperationQuit]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CMPRCGroupNotificationNameMembersChanged object:object.targetId];
    }
   
}

/**
 根据通知消息判断，是否需要删除该条消息
 */
- (BOOL)needDeleteMessage:(RCConversation *)conversation {
    RCMessageContent *lastestMessage = conversation.lastestMessage;
    if ([lastestMessage isKindOfClass:[RCGroupNotificationMessage class]]) {
        CMPRCGroupNotificationObject *notificationObject = [[CMPRCGroupNotificationObject alloc] initWithRCConversation:conversation];
        NSString *extraStr = notificationObject.extra1;
        NSDictionary *extraDic = [extraStr JSONValue];
        NSString *operation = notificationObject.operation;
        NSArray *targetUserIds = extraDic[@"targetUserIds"];
        
        if ([operation isEqualToString:CMPRCGroupNotificationOperationKicked]) { // 踢人
            if ([targetUserIds containsObject:[CMPCore sharedInstance].userID]) {
                // 被踢的人，移除消息记录
                [self deleteMessageFromList:conversation];
                return YES;
            }
        } else if ([operation isEqualToString:CMPRCGroupNotificationOperationQuit]) { // 主动退出
            NSString *userId = extraDic[@"userId"];
            if ([userId isEqualToString:[CMPCore sharedInstance].userID]) { // 如果是本人退出群，删除群相关信息
                [self deleteMessageFromList:conversation];
                return YES;
            }
        } else if ([operation isEqualToString:CMPRCGroupNotificationOperationDismiss]) { // 解散群组
            [self deleteMessageFromList:conversation];
            return YES;
        } else if ([operation isEqualToString:@"Filedelete"] ||
                   [operation isEqualToString:@"Rebulletin"]) {
            return YES;
        }
    } else if ([lastestMessage isKindOfClass:[RCInformationNotificationMessage class]]) {
        return YES;
    }
    //pc端创建任务和会议会触发一条无用消息，需要过滤掉。 BUG2023081162411
    else if ([lastestMessage isKindOfClass:[CMPGeneralBusinessMessage class]]
               && ([conversation.targetId isEqualToString:@"-1"] || [conversation.targetId isEqualToString:@"0"])
               && [conversation.senderUserId isEqualToString:[CMPCore sharedInstance].userID]) {
        [self deleteMessageFromList:conversation];
        return YES;
    }
    //end
    return NO;
}

/**
 处理消息撤回类型消息
 */
- (CMPMessageObject *)handleRecallMessage:(RCConversation *)conversation {
    CMPMessageObject *objc = [[CMPMessageObject alloc] initWithRCConversation:conversation];
    objc.msgId = @"";
    RCRecallNotificationMessage *recallMessage = (RCRecallNotificationMessage *)conversation.lastestMessage;
    NSString *operatorId = recallMessage.operatorId;
    RCUserInfo *userInfo =[[RCIM sharedRCIM] getUserInfoCache:recallMessage.operatorId];
    NSString *userName = @"";
    
    if (userInfo) {
        userName = userInfo.name;
    }
    
    if ([[CMPCore sharedInstance].userID isEqualToString:operatorId]) { // 自己撤回的消息
        objc.content = [NSString stringWithFormat:@"%@", SY_STRING(@"msg_recall_me")];
    } else { // 别人撤回的消息
        objc.content = [NSString stringWithFormat:@"%@%@", userName, SY_STRING(@"msg_recall")];
    }
    
    if (conversation.conversationType == ConversationType_GROUP) {
        //RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:conversation.targetId];
        RCGroup *groupInfo = [self syncCreateRCGroupObject:conversation.targetId];
        objc.appName = groupInfo.groupName;
    } else if (conversation.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:conversation.targetId];
        objc.appName = userInfo.name;
        if ([conversation.targetId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {//文件助手聊天页标题国际化
            objc.appName  = @"msg_fileass";
        }
    }
    return objc;
}

/**
 从消息列表中删除一条记录
 */
- (void)deleteMessageFromList:(RCConversation *)conversation {
    CMPMessageObject *objc = [[CMPMessageObject alloc] initWithRCConversation:conversation];
    [[CMPMessageManager sharedManager] deleteMessageWithAppId:objc];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageUpdate object:nil];
}

-(void)deleteMessageObjects:(NSArray<CMPMessageObject *> *)objs {
    [[CMPMessageManager sharedManager] deleteMessagesWithObjs:objs];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_MessageUpdate object:nil];
}

/**
 缓存群组信息，使用融云缓存，每次getlist的时候触发
 缓存策略：
 1.getGroupInfoCache,如果没有，所有类型的消息都缓存
 2.如果有缓存，只有收到Rename才更新缓存
 */
- (void)cacheGroupInformation:(RCMessage *)message {
    if (message.conversationType != ConversationType_GROUP) {
        return;
    }
    
//    RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:message.targetId];
    RCGroup *group = [self syncCreateRCGroupObject:message.targetId];
    if (!group) {
        RCMessageContent *lastestMessage = message.content;
        NSString *groupName = @"";
        if ([lastestMessage respondsToSelector:@selector(extra)]) {
            NSString *extra = [lastestMessage performSelector:@selector(extra)];
            NSDictionary *extraDic = [extra JSONValue];
            groupName = [extraDic objectForKey:@"toName"] ? [extraDic objectForKey:@"toName"] : [extraDic objectForKey:@"groupName"];
            [self refreshRCGroupInfoCacheWithGroupName:groupName targetId:message.targetId];
        }
    }
}

- (void)cacheGroupInformationWithConversasion:(RCConversation *)conversation {
    if (conversation.conversationType != ConversationType_GROUP) {
        return;
    }
    //RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:conversation.targetId];
    RCGroup *group = [self syncCreateRCGroupObject:conversation.targetId];
    if (!group) {
        RCMessageContent *lastestMessage = conversation.lastestMessage;
        NSString *groupName = @"";
        if ([lastestMessage respondsToSelector:@selector(extra)]) {
            NSString *extra = [lastestMessage performSelector:@selector(extra)];
            NSDictionary *extraDic = [extra JSONValue];
            groupName = [extraDic objectForKey:@"toName"] ? [extraDic objectForKey:@"toName"] : [extraDic objectForKey:@"groupName"];
            [self refreshRCGroupInfoCacheWithGroupName:groupName targetId:conversation.targetId];
        }
    }
}

- (RCGroup *)syncCreateRCGroupObject:(NSString *)groupId {
    __block RCGroup *group = nil;
    dispatch_sync(self.serialQueue, ^{
        group = [[RCIM sharedRCIM] getGroupInfoCache:groupId];
    });
    return group;
}

/**
 缓存群组信息到融云+内存
 */
- (void)refreshRCGroupInfoCacheWithGroupName:(NSString *)groupName targetId:(NSString *)targetId {
    if ([NSString isNull:groupName] ||
        [NSString isNull:targetId]) {
        return;
    }
    
    [_groupInformations setObject:groupName forKey:targetId];
    NSLog(@"RC---缓存群组，ID：%@, NAME:%@", targetId, groupName);
    [[RCIM sharedRCIM] refreshGroupNameCache:groupName withGroupId:targetId];
}

/**
 缓存人员信息：融云+本地数据库
 */
- (void)cacheUserInformation:(RCConversation *)conversation {
    RCMessageContent *lastestMessage = conversation.lastestMessage;
    if (![lastestMessage respondsToSelector:@selector(extra)]) { // 没有extra字段
        return;
    }
    
    NSString *extra = [lastestMessage performSelector:@selector(extra)];
    NSDictionary *extraDic = [extra JSONValue];
    
    if(!extraDic ||
       ![extraDic isKindOfClass:[NSDictionary class]]) {
        extraDic = nil;
        return;
    }
    
    NSString *userId = extraDic[@"userId"];
    NSString *userName = extraDic[@"userName"];
    extraDic = nil;
    
    if ([NSString isNull:userId] ||
        [NSString isNull:userName]) {
        return;
    }
    
    if ([userId isEqualToString:[CMPCore sharedInstance].userID]) {
        return;
    }
    
    CMPRCUserCacheObject *user = [[CMPRCUserCacheObject alloc] initWithRCConversation:conversation];
    user.userId = userId;
    user.name = userName;
    [_userCacheManager setCache:@[user]];
}

- (NSString *)getGroupNameWithID:(NSString *)groupId {
    return _groupInformations[groupId];
}

- (void)cacheAlertStatus:(RCConversation *)conversation {
    [[RCIMClient sharedRCIMClient]
     getConversationNotificationStatus:conversation.conversationType
     targetId:conversation.targetId
     success:^(RCConversationNotificationStatus nStatus) {
         BOOL isBlocked = NO;
         if (nStatus == DO_NOT_DISTURB) {
             isBlocked = YES;
         }
         [self->_conversationAlertMap setObject:[NSNumber numberWithBool:isBlocked] forKey:conversation.targetId];
     } error:nil];
}

/*!
 设置消息的附加信息
 
 @param messageId   消息ID
 @param value       附加信息
 @return            是否设置成功
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value{
    
   BOOL isSuccess =  [[RCIMClient sharedRCIMClient]setMessageExtra:messageId value:value];
   return isSuccess;
    
}

/**
 在聊天界面收到群名称更改通知
 */
- (void)updateGroupChatTitle:(RCMessage *)message {
    RCMessageContent *messageContent =  message.content;
    if ([messageContent isKindOfClass:[RCGroupNotificationMessage class]]) {
        RCGroupNotificationMessage *groupMessage = (RCGroupNotificationMessage *)messageContent;
        if ([groupMessage.operation isEqualToString:GroupNotificationMessage_GroupOperationRename]) {
            NSDictionary *extraDic = [groupMessage.extra JSONValue];
            NSString *groupName = extraDic[@"groupName"];
            if([NSString isNotNull:groupName]) {
                NSString *targetId = message.targetId;
                CMPMessageObject *object = [CMPMessageManager.sharedManager messageWithAppID:targetId];
                CMPRCGroupMemberObject *groupMember = object.extradDataModel.groupInfo;
                groupMember.name = groupName;
                [[CMPMessageManager sharedManager] setGroupInfoWithMessage:object groupInfo:groupMember];
                // 缓存到融云
                [[RCIM sharedRCIM] refreshGroupNameCache:groupName withGroupId:targetId];
            }
        }
    }
}

#pragma mark -
#pragma mark -融云

//是否使用融云
- (BOOL)useRongCloud
{
    return self.chatType == CMPChatType_Rong;
}

//删除对应的消息
- (BOOL)removeConversation:(NSInteger)conversationType targetId:(NSString *)targetId{
    [[RCIMClient sharedRCIMClient] deleteMessages:conversationType targetId:targetId success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    return YES;
}

//对应的消息未读为0
- (BOOL)clearMessagesUnreadStatus:(NSInteger)conversationType targetId:(NSString *)targetId {
    return [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:conversationType targetId:targetId];
}

//所有的未读数
- (NSInteger)totalRongUnreadCount {
    return [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
}

//单人聊天 根据 targetId  获取 名称
- (void)memberNameForId:(NSString *)targetId completion:(void (^)(NSString *))completion {
    if ([NSString isNull:targetId]) {
        completion(@"");
        return;
    }
    [[CMPContactsManager defaultManager] memberNameForId:targetId completion:completion];
}


//获取融云群设置
- (void)rcGroupChatSettingWithGroupId:(NSString *)groupId completion:(void (^)(NSDictionary *))completion
{
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_GROUP targetId:groupId success:^(RCConversationNotificationStatus nStatus) {
        [[CMPMessageManager sharedManager] getRCChatTopStatusWithTargetId:groupId type:ConversationType_GROUP completion:^(BOOL isTop) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:nStatus == NOTIFY?@"0":@"1",@"alertStatus",isTop?@"1":@"0",@"topStatus", nil];
            completion(dic);
        }];
    } error:^(RCErrorCode status) {
        
    }];
}

//设置融云群置顶状态
- (void)setGroupChatTopStatus:(NSString *)topStatus groupId:(NSString *)groupId {
    //RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:groupId];
    RCGroup *groupInfo = [self syncCreateRCGroupObject:groupId];
    groupInfo.groupId = groupId;
    CMPMessageObject *obj = [[CMPMessageObject alloc] initWithGroup:groupInfo istop:[topStatus isEqualToString:@"1"]];
    [[CMPMessageManager sharedManager] setRCChatTopStatus:obj type:ConversationType_GROUP ext:nil];
    obj = nil;
}

//设置融云群消息提醒状态
- (void)setGroupChatAlertStatus:(NSString *)topStatus groupId:(NSString *)groupId {
    BOOL isBlocked = [topStatus isEqualToString:@"0"] ?NO:YES;
    [_conversationAlertMap setObject:[NSNumber numberWithBool:isBlocked] forKey:groupId];
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_GROUP targetId:groupId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
        
    } error:^(RCErrorCode status) {
        
    }];
    [self postAlertStatus:topStatus targetId:groupId];
}

//获取融云聊天设置
- (void)rcChatSettingWithType:(NSString *)type targetId:(NSString *)targetId completion:(void (^)(NSDictionary *))completion
{
    RCConversationType chatType;
    if ([type isEqualToString:kChatManagerRCChatTypeGroup]) {
        chatType = ConversationType_GROUP;
    } else {
        chatType = ConversationType_PRIVATE;
    }
    
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:chatType targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
        [[CMPMessageManager sharedManager] getRCChatTopStatusWithTargetId:targetId type:chatType completion:^(BOOL isTop) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:nStatus == NOTIFY?@"0":@"1",@"alertStatus",isTop?@"1":@"0",@"topStatus", nil];
            completion(dic);
        }];
        
    } error:^(RCErrorCode status) {
        
    }];
}

//设置融云群置顶状态
- (void)setChatTopStatus:(NSString *)topStatus targetId:(NSString *)targetId type:(NSString *)type ext:(NSDictionary *)ext
{
    if ([type isEqualToString:kChatManagerRCChatTypeGroup]) {
        //RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:targetId];
        RCGroup *groupInfo = [self syncCreateRCGroupObject:targetId];
        groupInfo.groupId = targetId;
        CMPMessageObject *obj = [[CMPMessageObject alloc] initWithGroup:groupInfo istop:[topStatus isEqualToString:@"1"]];
        [[CMPMessageManager sharedManager] setRCChatTopStatus:obj type:ConversationType_GROUP ext:ext];
        obj = nil;
    } else if ([type isEqualToString:kChatManagerRCChatTypePrivate]) {
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:targetId];
        CMPMessageObject *obj = [[CMPMessageObject alloc] initWithUserInfo:userInfo istop:[topStatus isEqualToString:@"1"]];
        [[CMPMessageManager sharedManager] setRCChatTopStatus:obj type:ConversationType_PRIVATE ext:ext];
    }

}

//设置融云群消息提醒状态
- (void)setChatAlertStatus:(NSString *)topStatus targetId:(NSString *)targetId type:(NSString *)type
{
    RCConversationType chatType;
    if ([type isEqualToString:kChatManagerRCChatTypeGroup]) {
        chatType = ConversationType_GROUP;
    } else {
        chatType = ConversationType_PRIVATE;
    }
    
    BOOL isBlocked = [topStatus isEqualToString:@"0"] ?NO:YES;
    [_conversationAlertMap setObject:[NSNumber numberWithBool:isBlocked] forKey:targetId];
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:chatType targetId:targetId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
        
    } error:^(RCErrorCode status) {
        
    }];
    [self postAlertStatus:topStatus targetId:targetId];
}

//把融云消息提醒状态 发送给 消息中心
- (void)postAlertStatus:(NSString *)status targetId:(NSString *)targetId {
    NSString *msgStatue = [status isEqualToString:@"1"]? @"0":@"1";
    CMPMessageObject *obj = [[CMPMessageObject alloc] init];
    obj.cId = targetId;
    obj.extra2 = msgStatue;
    [[CMPMessageManager sharedManager] remindRCMessage:obj];
}

- (BOOL)getChatAlertStatus:(NSString *)targetId {
    if (!_conversationAlertMap) {
        return NO;
    }
    
    NSNumber *isAlert = _conversationAlertMap[targetId];
    if (!isAlert) {
        return NO;
    }
    
    return [isAlert boolValue];
}

//清空融云消息
- (void)clearRCMsgWithTargetId:(NSString *)targetId type:(NSString *)type
{
    RCConversationType chatType;
    if ([type isEqualToString:kChatManagerRCChatTypeGroup]) {
        chatType = ConversationType_GROUP;
    } else {
        chatType = ConversationType_PRIVATE;
    }
    [[RCIMClient sharedRCIMClient] clearMessages:chatType targetId:targetId];
    [[CMPMessageManager sharedManager] clearRCChatMsgWithTargetId:targetId type:chatType];
}

//清空融云群消息
- (void)clearRCGroupMsgWithGroupId:(NSString *)groupId
{
    [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_GROUP targetId:groupId];
    [[CMPMessageManager sharedManager] clearRCGroupChatMsgWithGroupId:groupId];
}

- (void)clearRCGroupNotification {
    [_groupNotificationManager deleteAllNotification];
    [[CMPMessageManager sharedManager] clearRCGroupNotification];
}

- (void)readRCGroupNotification {
    [_groupNotificationManager readAllNotifications];
}

- (void)refreshGroupUserInfo:(NSString *)groupId {
    [_userCacheManager refreshCache:groupId];
}

/**
 更换自己头像刷新缓存
 */
- (void)onMyIconChanged {
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    userInfo.userId = [CMPCore sharedInstance].userID;
    userInfo.name = [CMPCore sharedInstance].userName;
    NSString *portrait =[CMPCore memberIconUrlWithId:userInfo.userId];
    userInfo.portraitUri = [portrait appendHtmlUrlParam:@"time" value:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000]];
    [RCIM sharedRCIM].currentUserInfo = userInfo;
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
}

/**
 接收新消息设置变更
 */
- (void)onAcceptInformationChanged {
    CMPCore *core = [CMPCore sharedInstance];
    
    if (!core.pushAcceptInformation) { // 总开关关闭了
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:nil error:nil];
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:@"00:00:00"                                                                                                                                 spanMins:1439 success:nil error:^(RCErrorCode status) {
            NSLog(@"RC---setNotificationQuietHours error:%d", (int)status);
        }];
        NSLog(@"RC---消息总开关关闭");
    } else {
        // 设置提示语、震动
        BOOL pushSoundRemind = core.isMultiOnline ? (core.multiLoginReceivesMessageState && core.pushSoundRemind): core.pushSoundRemind;
        BOOL pushVibrationRemind = core.isMultiOnline ? (core.multiLoginReceivesMessageState && core.pushVibrationRemind): core.pushVibrationRemind;;
        [[RCIM sharedRCIM] setPushSoundRemind:pushSoundRemind];
        [[RCIM sharedRCIM] setPushVibrationRemind:pushVibrationRemind];
        NSString *startTime = [CMPCore sharedInstance].startReceiveTime;
        NSString *endTime = [CMPCore sharedInstance].endReceiveTime;
        long long intervalTime = [CMPDateHelper intervalOfStartTime:endTime andEndTime:startTime];
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:nil error:nil];
        if (intervalTime / 60 > 1) {
            [[RCIMClient sharedRCIMClient] setNotificationQuietHours:endTime                                                                                                                                 spanMins:intervalTime / 60 success:nil error:^(RCErrorCode status) {
                NSLog(@"RC---setNotificationQuietHours error:%d", (int)status);
            }];
        }
        NSLog(@"RC---消息总开关：%d,铃声：%d,震动：%d,开始时间：%@, 结束时间：%@", [CMPCore sharedInstance].pushAcceptInformation, [CMPCore sharedInstance].pushSoundRemind, [CMPCore sharedInstance].pushVibrationRemind, startTime, endTime);
    }
}

/**
 多端消息阅读状态同步，点击消息，发送自定义消息类型CMPReadedMessage，其它端接收到标记该消息为已读。
 */
- (void)sendReadedMessageWithType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    RCMessage *lastMessage = [[[RCIMClient sharedRCIMClient] getLatestMessages:conversationType targetId:targetId count:1] lastObject];
    CMPReadedMessage *message = [[CMPReadedMessage alloc] init];
    NSDictionary *extraDic = @{@"itemId" : targetId,
                               @"conversationType" : [NSString stringWithFormat:@"%ld", conversationType],
                               @"timestamp" : [NSString stringWithFormat:@"%lld", lastMessage.sentTime]};
    message.extra = [extraDic JSONRepresentation];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:[CMPCore sharedInstance].userID content:message pushContent:nil pushData:nil success:^(long messageId) {
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"RC---发送CMPReadedMessage失败nErrorCode=%ld", nErrorCode);
    }];
    message = nil;
}

- (void)sendGroupNotificationReadedMessage {
    [[CMPChatManager sharedManager].groupNotificationManager getLatestNotification:^(CMPRCGroupNotificationObject *object) {
        NSDate *date = [CMPDateHelper dateFromStr:object.receiveTime dateFormat:@"yyyy-MM-dd HH:mm:ss"];
        long long timestamp = [date timeIntervalSince1970];
        CMPReadedMessage *message = [[CMPReadedMessage alloc] init];
        NSDictionary *extraDic = @{@"itemId" : kRCGroupNotificationTargetID,
                                   @"conversationType" : @"-1",
                                   @"timestamp" : [NSString stringWithFormat:@"%lld", timestamp * 1000]};
        message.extra = [extraDic JSONRepresentation];
        
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:[CMPCore sharedInstance].userID content:message pushContent:nil pushData:nil success:^(long messageId) {
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"RC---发送CMPReadedMessage失败nErrorCode=%ld", nErrorCode);
        }];
    }];
}

- (void)openAccDoc:(NSString*)param {
    
    if (param.length == 0) {
        return;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:param];
    
//    [CMPNativeH5transferParamsPlugin getSrcParams:arr];

    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:@"http://cmp/v/page/cmp-transfer-page.html?pageKey=penetrateAccDoc"]];
    aCMPBannerViewController.startPage = localHref;
    aCMPBannerViewController.hideBannerNavBar = YES;
    aCMPBannerViewController.backBarButtonItemHidden = YES;
    [[UIViewController currentViewController].navigationController pushViewController:aCMPBannerViewController animated:YES];
}

- (void)requestAddGroup:(NSString*)groupId start:(void(^)(void))start success:(void(^)(id info))success fail:(void(^)(id error))fail
{
    NSString *url = [CMPCore fullUrlForPath:@"/rest/uc/rong/groups/joinforqr"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.headers =  [CMPDataProvider headers];;
    aDataRequest.timeout = 10;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:groupId forKey:@"groupId"];
    aDataRequest.requestParam = [params JSONRepresentation];
    aDataRequest.requestID = groupId;
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    [tempDic setObject:success forKey:@"success"];
    [tempDic setObject:fail forKey:@"fail"];

    aDataRequest.userInfo = tempDic;
    
    self.addGroupRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    start();
}

- (void)chatToMember:(CMPOfflineContactMember *)member content:(NSString *)content completion:(void (^)(NSError *))completion {
   
    if (CMPChatType_null == self.chatType) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:SY_STRING(@"msg_zhixinInitError") code:DATABASE_ERROR userInfo:nil];
            completion(error);
        }
        return;
    }
    RCTextMessage *textMsg = [RCTextMessage messageWithContent:content];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:member.name, @"toName", [NSString uuid], @"msgId", member.orgID, @"toId", [CMPCore sharedInstance].userID, @"userId", [CMPCore sharedInstance].currentUser.name, @"userName" ,nil];
    textMsg.extra = [dic JSONRepresentation];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:member.orgID content:textMsg pushContent:@"" pushData:@"" success:^(long messageId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRongCloudReceiveMessage object:nil];
        if (completion) {
            completion(nil);
        }
    } error:^(RCErrorCode nErrorCode, long messageId) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"" code:nErrorCode userInfo:nil];
            completion(error);
        }
    }];
}

#pragma mark - 更新融云消息设置

- (void)updateRCMessageSetting {
    [self getAllRCMessageSettingWithCompletion:^(NSArray *dataArray, NSError *error) {
        if (!error) {
            [dataArray enumerateObjectsUsingBlock:^(NSDictionary *settingDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *talkId = settingDic[@"talkId"];
                NSString *recordValue = [NSString stringWithFormat:@"%@",settingDic[@"recordValue"]];
                NSString *talkType = [NSString stringWithFormat:@"%@",settingDic[@"talkType"]];
                
                NSString *alertStatus = [recordValue isEqualToString:@"0"] ? @"1" : @"0";
                NSString *conversationType = [talkType isEqualToString:@"0"] ? kChatManagerRCChatTypePrivate : kChatManagerRCChatTypeGroup;
                [self setChatAlertStatus:alertStatus targetId:talkId type:conversationType];
            }];
        }
    }];
}

#pragma mark - 网络请求

/**
  根据groupId获取群成员列表
 */
- (void)getGroupUserListByGroupId:(NSString *)groupId completion:(AllMembersOfGroupResultBlock)completion fail:(void(^)(NSError *error,id ext))failBlk {
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/groups/bygid/%@",groupId];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    CMPRCBlockObject *blockObj = [[CMPRCBlockObject alloc] init];
    blockObj.allMemberOfGroupResultBlock = completion;
    aDataRequest.userInfo = @{@"resultBlock" : blockObj,@"failBlk":failBlk};
    aDataRequest.requestType = kDataRequestType_Url;
    self.getGroupUserListByGroupIdRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)getAllRCMessageSettingWithCompletion:(void (^)(NSArray *dataArray,NSError *error))completion {
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/messageRemind/getall"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"resultBlock" : completion};
    self.getAllRCMessageSettingRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

//上传融云消息免打扰设置
- (void)uploadRCMessageSettingRemindType:(NSString *)remindType targetId:(NSString *)targetId completion:(void (^)(BOOL isSeccess,NSError *error))completion {
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/messageRemind/save"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *aParamDict = @{@"talkId" : targetId,
                                 @"recordValue" : remindType
                                };
    aDataRequest.requestParam = [aParamDict JSONRepresentation];
    aDataRequest.userInfo = @{@"resultBlock" : completion};
    self.uploadRCMessageSettingRemindTypeRequestID = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

/**
 转化融云推送消息为可穿透格式
 */
- (NSDictionary *)handleUserInfo:(NSDictionary *)userInfo {
    NSDictionary *remoteNotifiData = nil;
    NSDictionary *rcInfo = userInfo[@"rc"];
    if (rcInfo && [rcInfo isKindOfClass:[NSDictionary class]]) { // 融云消息
        NSString *appData = userInfo[@"appData"];
        if (!appData) {
            return nil;
        }
        NSDictionary *dic = @{@"options" : appData};
        remoteNotifiData = dic;
    } else {
        remoteNotifiData = userInfo;
    }
    return remoteNotifiData;
}


- (void)xiaozChatViewShow:(NSNotification *)notif {
    //小致界面打开，震动和声音提醒关闭，避免影响小致的识别
    [[RCIM sharedRCIM] setPushSoundRemind:NO];
    [[RCIM sharedRCIM] setPushVibrationRemind:NO];
}

- (void)xiaozChatViewHide:(NSNotification *)notif {
       //小致界面关闭，震动和声音提醒恢复
    [self onAcceptInformationChanged];
}



- (void)getPostShowStatusByTalkId:(NSString *)talkId completion:(void (^)(BOOL isShow,NSError *error))completion {
    if (!talkId) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/displayPostSetting/get"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"resultBlock" : completion};
    aDataRequest.requestParam = [@{@"talkId":talkId} JSONRepresentation];
    aDataRequest.requestID = @"cmprequestid_getpostshowstatus";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)getMemberOrgStatusByMid:(NSString *)mid completion:(void (^)(id result,NSError *error))completion {
    if (!mid) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/rest/uc/rong/groups/memberstate/"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [url stringByAppendingString:mid];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"resultBlock" : completion,@"mid":mid};
    aDataRequest.requestID = @"cmprequestid_getmemberorgstatus";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

-(void)forwardFile:(NSString *)fileId
              type:(int)type
            target:(NSString *)targetId
        completion:(void (^)(id result,NSError *error))completion
{
    if (!fileId || !targetId) {
        return;
    }
    NSString *url = [CMPCore fullUrlForPathFormat:@"/uc/rest.do?method=forwardFile"];
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [url stringByAppendingFormat:@"&fileId=%@&type=%d&reference=%@",fileId,type,targetId];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_GET;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.userInfo = @{@"resultBlock" : completion};
    aDataRequest.requestID = @"cmprequestid_forwardfiletotarget";
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark - getter
- (NSMutableArray *)customRemoteMsgArr{
    if (!_customRemoteMsgArr) {
        _customRemoteMsgArr = [NSMutableArray new];
    }
    return _customRemoteMsgArr;
}
@end
