//
//  CMPChatPlugin.m
//  CMPCore
//
//  Created by wujiansheng on 16/8/9.
//
//

#import "CMPChatPlugin.h"
#import "AppDelegate.h"
#import <CMPLib/CMPChatChooseMemberViewController.h>
#import "CMPChatManager.h"
#import "CMPWebviewListenerFirePlugin.h"
#import "CMPCommonManager.h"
#import "CMPSelectContactViewController.h"
#import "CMPRCTransmitMessage.h"
#import "M3-Swift.h"
#import "CMPShareToUcManager.h"
#import "CMPMessageManager.h"
#import <CMPLib/CMPReviewImagesTool.h>
#import <CMPLib/CMPPopOverManager.h>
#import <CMPLib/CMPCommonTool.h>
#import "RCIM+MediaMessages.h"
#import "CMPBusinessCardMessage.h"
#import <CMPLib/YBImageBrowserTipView.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPQuoteMessage.h"
#import "RCMessageModel+Type.h"
#import "CMPChatListViewModel.h"
#import "CMPClearMsg.h"
#import "CMPClearMsgRemoteTextMessage.h"
#import <CMPLib/CMPCustomAlertView.h>
NSNotificationName const CMPUcGroupBoardSettingDidChanged = @"CMPUcGroupBoardSettingDidChanged";

@interface CMPChatPlugin()  {
    NSMutableDictionary *_callbackIdDic;
}
@property (nonatomic, copy)NSString *callbackId;
@property (strong, nonatomic) CMPChatListViewModel *chatListViewModel;
@end

@implementation CMPChatPlugin
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.callbackId = nil;
}

- (void)loginChat:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)logoutChat:(CDVInvokedUrlCommand *)command
{
 
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openChat:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)chatToOther:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *memberid = [paramDict objectForKey:@"memberid"];
    if ([NSString isNull:memberid]) {
        NSDictionary *errorDic= [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:36005],@"code",SY_STRING(@"memberid_nil"),@"message",@"",@"detail", nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSString *name = [paramDict objectForKey:@"membername"];
    CMPRCTargetObject *object = [[CMPRCTargetObject alloc] init];
    object.targetId = memberid;
    object.title = name;
    object.navigationController = self.viewController.navigationController;
    object.type = 1;
    object.tabbar = [self.viewController rdv_tabBarController];
    [[CMPChatManager sharedManager] showChatView:object];
}

- (void)getSelectOrgParam:(CDVInvokedUrlCommand *)command
{
    CMPChatChooseMemberViewController *aController = (CMPChatChooseMemberViewController *)self.viewController;
    NSArray *fillBackData = aController.fillBackData ?aController.fillBackData:[NSArray array];
    NSDictionary *aDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)aController.maxSize], @"maxSize", @"1", @"minSize",fillBackData,@"fillBackData",@"1",@"type",@"true",@"notSelectAccount",@"true",@"notSelectSelfDepartment",@"2",@"flowType",[NSArray arrayWithObject:@"member"],@"choosableType", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:aDict];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)setSelectedOrgResult:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *result = [paramDict objectForKey:@"result"];
    NSDictionary *resultObj = [result JSONValue];
    NSArray *orgResult = [resultObj objectForKey:@"orgResult"];
    CMPChatChooseMemberViewController *aController = (CMPChatChooseMemberViewController *)self.viewController;
    if (aController.delegate && [aController.delegate respondsToSelector:@selector(chatChooseMemberViewController:didSelectMember:)]) {
        [aController.delegate chatChooseMemberViewController:aController didSelectMember:orgResult];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    if (aController.navigationController) {
       if (aController.navigationController.viewControllers[0] == aController) { // 是RootView
           [aController.navigationController dismissViewControllerAnimated:YES completion:nil];
       }
       else {
           [aController.navigationController popViewControllerAnimated:YES];
       }
    } else {
          [aController dismissViewControllerAnimated:YES completion:nil];
    }
//    [aController dismissViewControllerAnimated:YES completion:^{
//
//    }];
}

- (void)getUnreadChatNumber:(CDVInvokedUrlCommand *)command
{
    NSInteger count = 0;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:count];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/******************** h5   chat   ******************************/

- (void)chatInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[CMPChatManager sharedManager].ip,@"ip",[CMPChatManager sharedManager].port,@"port",[CMPChatManager sharedManager].ucFilePort,@"ucFilePort",[CMPChatManager sharedManager].ucServerStyle,@"ucServerStyle", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


//- (void)sendMessage:(CDVInvokedUrlCommand *)command {
- (void)sendPacket:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *msg = [paramDict objectForKey:@"data"];
    BOOL hasID = NO;
    if ([paramDict.allKeys containsObject:@"id"]) {
        NSString *msgId = [paramDict objectForKey:@"id"];
        if (![NSString isNull:msgId]) {
            hasID = YES;
            if (!_callbackIdDic) {
                _callbackIdDic = [[NSMutableDictionary alloc] init];
            }
            [_callbackIdDic setObject:command.callbackId forKey:msgId];
        }
    }
    BOOL result = [[CMPChatManager sharedManager] sendMsg:msg];
    if (!result) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR ];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else if (!hasID) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)confirmMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *msgId = [paramDict objectForKey:@"id"];
    [[CMPChatManager sharedManager] deleteMsgWithID:msgId];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getLocalMessage:(CDVInvokedUrlCommand *)command {
    
    NSArray *result = [[CMPChatManager sharedManager] getLocalMessage];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)checkChatState:(CDVInvokedUrlCommand *)command {
    
    //0 -- 未连接；1 -- 已连接； 2 -- 连接中，暂时不用
    NSInteger state = [[CMPChatManager sharedManager] checkAndReconnect] ? 1:0;
    NSInteger networkStatus = [CMPCommonManager networkReachabilityStatus];
    NSString *networkActive = @"false";
    if (networkStatus == AFNetworkReachabilityStatusReachableViaWiFi
        || networkStatus == AFNetworkReachabilityStatusReachableViaWWAN){
        networkActive = @"true";
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:state],@"state",networkActive,@"networkActive", nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)pluginInitialize {
    //致信连接上了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidConnected) name:kXmppDidConnected object:nil];
    //致信连接不上了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidDisConnected) name:kXmppDidDisConnected object:nil];
    //致信接收到请求返回值
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveIQ:) name:kXmppDidReceiveIQ object:nil];
    //致信接收到请求 error 返回值
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveErrorIQ:) name:kXmppDidReceiveErrorIQ object:nil];
    //致信接收到消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessage:) name:kXmppDidReceiveMessage object:nil];
    //致信接收到 error 消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveErrorMessage:) name:kXmppDidReceiveErrorMessage object:nil];
}

- (void)chatDidConnected{
    NSDictionary *f = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1],@"state", nil];
    NSString *aName = @"chatStateListener";
    NSString *aStr = [NSString stringWithFormat:@"cmp.event.trigger('%@','document', %@)", aName, [f JSONRepresentation]];;
    [self.commandDelegate evalJs:aStr];
}

- (void)chatDidDisConnected
{
    NSDictionary *f = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0],@"state", nil];
    NSString *aName = @"chatStateListener";
    NSString *aStr = [NSString stringWithFormat:@"cmp.event.trigger('%@','document', %@)", aName, [f JSONRepresentation]];;
    [self.commandDelegate evalJs:aStr];
}

- (void)chatDidReceiveIQ:(NSNotification *)notif
{
    NSDictionary *dic = (NSDictionary *)notif.object;
    NSString *msgId = [dic objectForKey:@"msgId"];
    NSString *value = [dic objectForKey:@"value"];

    NSString *callbackId = [_callbackIdDic objectForKey:msgId];
    if (callbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
    
}

- (void)chatDidReceiveErrorIQ:(NSNotification *)notif
{
    NSDictionary *dic = (NSDictionary *)notif.object;
    NSString *msgId = [dic objectForKey:@"msgId"];
    NSString *value = [dic objectForKey:@"value"];

    NSString *callbackId = [_callbackIdDic objectForKey:msgId];
    if (callbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:value];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}

- (void)chatDidReceiveMessage:(NSNotification *)notif
{
    NSDictionary *dic = (NSDictionary *)notif.object;
    NSString *msgId = [dic objectForKey:@"msgId"];
    NSString *value = [dic objectForKey:@"value"];

    //调用js 方法  receiveInfo CMPWebviewListenerFirePlugin
    NSDictionary *f = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"id",value,@"params",@"2",@"type", nil];
    NSString *aName = @"UC_getMessage";
    NSString *aStr = [NSString stringWithFormat:@"cmp.event.trigger('%@','document',%@)", aName, [f JSONRepresentation]];;
    [self.commandDelegate evalJs:aStr];
}

- (void)chatDidReceiveErrorMessage:(NSNotification *)notif
{
    
}

//
//致信前端接口定义：
//
//1：receiveInfo(id,packet,type),
//
//说明：致信留给CMP壳调用用来接收消息的接口。CMP壳收到消息后主动调用该接口进行通知。
//
//参数：id：由CMP壳生成的一个消息唯一的key。
//
//Packet：消息内容。
//
//Type：消息类型

- (void)startChat:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *type = [paramDict objectForKey:@"type"];
    NSString *targetId = [paramDict objectForKey:@"targetId"];
    NSString *title = [paramDict objectForKey:@"title"];
    NSString *url = [paramDict objectForKey:@"url"];
    
    BOOL clearPrePage =  [[paramDict objectForKey:@"clearPrePage"] boolValue];
    UINavigationController *nav = self.viewController.navigationController;
    RDVTabBarController *tabbar = [self.viewController rdv_tabBarController];
    if (clearPrePage) {
        [nav popViewControllerAnimated:NO];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    CMPRCTargetObject *obj = [[CMPRCTargetObject alloc] init];
    
    if ([type isEqualToString:@"private"]) {
        obj.type = 1;
    } else if ([type isEqualToString:@"group"]) {
        obj.type = 3;
    }
    
    obj.targetId = targetId;
    obj.title = title;
    obj.navigationController = nav;
    obj.tabbar = tabbar;
    obj.url = url;
    [[CMPChatManager sharedManager] showChatView:obj];
}

//单人
- (void)startPrivateChat:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //人员Id
    NSString *targetId = [paramDict objectForKey:@"targetUserId"];
    //人员名称
    NSString *title = [paramDict objectForKey:@"title"];
    
    //h5界面的url
    NSString *url = [paramDict objectForKey:@"url"];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	
    BOOL clearPrePage =  [[paramDict objectForKey:@"clearPrePage"] boolValue];
    UINavigationController *nav = self.viewController.navigationController;
    RDVTabBarController *tabbar = [self.viewController rdv_tabBarController];
    if (clearPrePage) {
        [nav popViewControllerAnimated:NO];
    }
	
	BOOL haveHandle = [CMPSelectContactViewController handleUCStartChatPage:targetId bGroup:NO chatTitle:title];
	//如果是转发界面处理了，直接返回
	if (haveHandle) {
		return;
	}
	
    CMPRCTargetObject *obj = [[CMPRCTargetObject alloc] init];
    obj.targetId = targetId;
    obj.title = title;
    obj.type = 1;
    obj.navigationController = nav;
    obj.tabbar = tabbar;
    obj.url = url;
    [[CMPChatManager sharedManager] showChatView:obj];
}
//群组
- (void)startGroupChat:(CDVInvokedUrlCommand *)command
{
    NSDictionary *paramDict = [[command arguments] firstObject];
    //群Id
    NSString *targetId = [paramDict objectForKey:@"targetGroupId"];
    //群名称
    NSString *title = [paramDict objectForKey:@"title"];
    //h5界面的url
    NSString *url = [paramDict objectForKey:@"url"];
        
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	
	BOOL clearPrePage =  [[paramDict objectForKey:@"clearPrePage"] boolValue];
	UINavigationController *nav = self.viewController.navigationController;
	RDVTabBarController *tabbar = [self.viewController rdv_tabBarController];
	if (clearPrePage) {
		[nav popViewControllerAnimated:NO];
	}
	
	BOOL haveHandle = [CMPSelectContactViewController handleUCStartChatPage:targetId bGroup:YES chatTitle:title];
	//如果是转发界面处理了，直接返回
	if (haveHandle) {
        if (![nav.topViewController isKindOfClass:[CMPSelectContactViewController class]]) {
            //从我的群聊界面选择群，不会返回CMPSelectContactViewController界面，会导致，转发卡片不弹出来
            [nav popViewControllerAnimated:NO];
        }
		return;
	}
    CMPRCTargetObject *obj = [[CMPRCTargetObject alloc] init];
    obj.targetId = targetId;
    obj.title = title;
    obj.type = 3;
    obj.navigationController = nav;
    obj.tabbar = tabbar;
    obj.url = url;
    [[CMPChatManager sharedManager] showChatView:obj];
}

//获取群组设置---置顶状态 、消息提醒状态
- (void)getGroupChatSettings:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //群Id
    NSString *targetId = [paramDict objectForKey:@"targetGroupId"];
    //消息提醒状态(alertStatus)  “1” == 提醒  “0” == 不提醒
    //置顶状态(topStatus) “1” == 置顶  “0” == 没有置顶
    [[CMPChatManager sharedManager] rcGroupChatSettingWithGroupId:targetId completion:^(NSDictionary * dic) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

//设置 群消息 是否置顶
- (void)setGroupChatTopStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //群Id
    NSString *targetId = [paramDict objectForKey:@"targetGroupId"];
    //置顶状态  “1” == 置顶  “0” == 没有置顶
    NSString *topStatus = [paramDict objectForKey:@"topStatus"];
    
    [self.chatListViewModel saveChatTopStateByCid:targetId state:topStatus.integerValue completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error||error.code == -1111) {
            [[CMPChatManager sharedManager] setGroupChatTopStatus:topStatus groupId:targetId];
        }else{
            
        }
    }];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//设置 群消息 提醒状态
- (void)setGroupChatAlertStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //群Id
    NSString *targetId = [paramDict objectForKey:@"targetGroupId"];
    //消息提醒状态  “1” == 提醒  “0” == 不提醒
    NSString *alertStatus = [paramDict objectForKey:@"alertStatus"];
    
    NSString *rimindTyoe = [alertStatus isEqualToString:@"0"] ? @"1" : @"0";
    void (^setChatAlertStatusBloack) (void) = ^ {
          [[CMPChatManager sharedManager] setGroupChatAlertStatus:alertStatus groupId:targetId];
    };
    
    if (CMPFeatureSupportControl.isNeedUploadRCMessageSetting) {
        [[CMPChatManager sharedManager] uploadRCMessageSettingRemindType:rimindTyoe targetId:targetId completion:^(BOOL isSeccess, NSError *error) {
            if (isSeccess) {
                setChatAlertStatusBloack();
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                NSDictionary *errorDic= @{@"code" : @0,
                                          @"message" : @"网络请求失败",
                                          @"detail" : @""};
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        setChatAlertStatusBloack();
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    //V5-13354【Xcode13 打版】设置消息免打扰后，消息列表内该人员/群组消息后无免打扰标识 下面代码多调了一次
//    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)getChatSettings:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *targetId = [paramDict objectForKey:@"targetId"];
    NSString *type = [paramDict objectForKey:@"type"];
    
    //消息提醒状态(alertStatus)  “1” == 不提醒  “0” == 提醒
    //置顶状态(topStatus) “1” == 置顶  “0” == 没有置顶
    [[CMPChatManager sharedManager] rcChatSettingWithType:type targetId:targetId completion:^(NSDictionary *dic) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
-(CMPChatListViewModel *)chatListViewModel
{
    if (!_chatListViewModel) {
        _chatListViewModel = [[CMPChatListViewModel alloc] init];
    }
    return _chatListViewModel;
}
//设置 群消息 是否置顶
- (void)setTopStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *targetId = [paramDict objectForKey:@"targetId"];
    //置顶状态  “1” == 置顶  “0” == 没有置顶
    NSString *topStatus = [paramDict objectForKey:@"topStatus"];
    NSString *type = [paramDict objectForKey:@"type"];
    
    [self.chatListViewModel saveChatTopStateByCid:targetId state:topStatus.integerValue completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (error.code == -1111) {
            [[CMPChatManager sharedManager] setChatTopStatus:topStatus targetId:targetId type:type ext:nil];
        }else{
            
        }
    }];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//设置 群消息 提醒状态
- (void)setChatAlertStatus:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *targetId = [paramDict objectForKey:@"targetId"];
    //消息提醒状态  “1” == 不提醒  “0” == 提醒
    NSString *alertStatus = [paramDict objectForKey:@"alertStatus"];
    NSString *type = [paramDict objectForKey:@"type"];
    
    NSString *rimindTyoe = [alertStatus isEqualToString:@"0"] ? @"1" : @"0";
    void (^setChatAlertStatusBloack) (void) = ^ {
         [[CMPChatManager sharedManager] setChatAlertStatus:alertStatus targetId:targetId type:type];
    };
    
    if (CMPFeatureSupportControl.isNeedUploadRCMessageSetting) {
        [[CMPChatManager sharedManager] uploadRCMessageSettingRemindType:rimindTyoe targetId:targetId completion:^(BOOL isSeccess, NSError *error) {
            if (isSeccess) {
                setChatAlertStatusBloack();
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                NSDictionary *errorDic= @{@"code" : @0,
                                          @"message" : @"网络请求失败",
                                          @"detail" : @""};
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        setChatAlertStatusBloack();
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

// 清空消息
- (void)clearChatMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSString *targetId = [paramDict objectForKey:@"targetId"];
    NSString *type = [paramDict objectForKey:@"type"];
    
    if (![CMPChatManager canRemoveRemoteMsg]) {//原逻辑
        [[CMPChatManager sharedManager] clearRCMsgWithTargetId:targetId type:type];
        //插入清空消息的自定义消息，插入本地数据库非远程
        CMPClearMsg *clearMsg = [CMPClearMsg new];
        long long timeNow = (long long)[[NSDate date]timeIntervalSince1970]*1000;
        [[RCIMClient sharedRCIMClient]insertIncomingMessage:ConversationType_PRIVATE targetId:targetId senderUserId:@"" receivedStatus:ReceivedStatus_READ content:clearMsg sentTime:timeNow];
        // 通知聊天详情页面清空消息
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ClearRCGroupMsg object:nil];
            
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        RCConversationType chatType = ConversationType_PRIVATE;
        if ([type isEqualToString:kChatManagerRCChatTypeGroup]) {
            chatType = ConversationType_GROUP;
        }
        //清除action
        [self clearMessageAction:command targetId:targetId chatType:chatType];
    }
    
}

//清空群消息
- (void)ClearGroupChat:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //群Id
    NSString *targetId = [paramDict objectForKey:@"targetGroupId"];
    
    if (![CMPChatManager canRemoveRemoteMsg]) {//原逻辑
        [[CMPChatManager sharedManager] clearRCGroupMsgWithGroupId:targetId];
        //插入清空消息的自定义消息
        CMPClearMsg *clearMsg = [CMPClearMsg new];
        long long timeNow = (long long)[[NSDate date]timeIntervalSince1970]*1000;
        [[RCIMClient sharedRCIMClient]insertIncomingMessage:ConversationType_GROUP targetId:targetId senderUserId:@"" receivedStatus:ReceivedStatus_READ content:clearMsg sentTime:timeNow];
        
        // 通知聊天详情页面清空消息
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ClearRCGroupMsg object:nil];
    }else{
        //清除action
        [self clearMessageAction:command targetId:targetId chatType:ConversationType_GROUP];
    }
}

- (void)clearMessageAction:(CDVInvokedUrlCommand *)command targetId:(NSString *)targetId chatType:(RCConversationType)chatType{
    if (!targetId.length) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"targetId cant be null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    //确认弹框
    __weak typeof(self) weakSelf = self;
    id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:SY_STRING(@"rc_remote_clear_confirm_text") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_confirm")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
        if (buttonIndex == 1) {
            //删除服务端历史消息
            [weakSelf removeRemoteMsgForTargetId:targetId type:chatType completion:^(BOOL success) {
                if (success) {
                    //通知清空消息
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ClearRCGroupMsg object:nil];
                    //插件回调
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }else{
                    //插件回调
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"clear message error"];
                    [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            }];
        }
    }];
    [alert setTheme:CMPTheme.new];
    [alert show];
}

//删除服务器历史消息&发送自定义消息(确保换手机后收到消息再去删除一次【服务器消息存储有备份】)
- (void)removeRemoteMsgForTargetId:(NSString *)targetId type:(RCConversationType)chatType completion:(void(^)(BOOL))completion{
    if (!targetId.length) {
        completion(NO);
        return;
    }
    //从服务器端清除历史消息
    long long timeNow = (long long)[[NSDate date]timeIntervalSince1970]*1000;
    [[RCIMClient sharedRCIMClient] clearHistoryMessages:chatType targetId:targetId recordTime:timeNow clearRemote:YES success:^{
        NSLog(@"clearHistoryMessages删除成功");
        completion(YES);
        //发送服务器备份消息补偿方案
        CMPClearMsgRemoteTextMessage *clearRemoteMsg = [CMPClearMsgRemoteTextMessage messageWithContent:@"CMP-ClearMsgRemoteTextMessage"];
        [[RCIMClient sharedRCIMClient] sendMessage:chatType targetId:targetId content:clearRemoteMsg pushContent:@"" pushData:nil success:^(long messageId) {
            NSLog(@"sendMessage-CMPClearMsgRemoteTextMessage成功");
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"sendMessage-CMPClearMsgRemoteTextMessage-%ld",nErrorCode);
        }];
    } error:^(RCErrorCode status) {
        completion(NO);
        NSLog(@"clearHistoryMessages删除失败-%ld",status);
    }];
}

//返回以前的界面
- (void)backToPreviousView:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    //返回层数
    NSInteger count = [[paramDict objectForKey:@"layerCount"] integerValue];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSArray *viewControllers = [self.viewController.navigationController viewControllers];
    NSInteger index = viewControllers.count- count-2;
   
    if (index < 0) {
        [self.viewController.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        UIViewController *vc = [viewControllers objectAtIndex:index];
        [self.viewController.navigationController popToViewController:vc animated:YES];
    }
}

// 获取致信版本信息
- (void)version:(CDVInvokedUrlCommand *)command {
    CMPChatType chatType = [CMPChatManager sharedManager].chatType;
    NSString *version = nil;
    
    switch (chatType) {
        case CMPChatType_Xmpp:
            version = @"2.0";
            break;
        case CMPChatType_Rong:
            version = @"3.0";
            break;
        default:
            break;
    }
    
    if (!version) { // 没有拿到版本号
        NSDictionary *errorDic= @{@"code" : @36006,
                                  @"message" : @"version获取失败",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                      messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *dic = @{@"version" : version};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getRongConfig:(CDVInvokedUrlCommand *)command {
    CMPChatType chatType = [CMPChatManager sharedManager].chatType;
    
    if (chatType != CMPChatType_Rong) {
        NSDictionary *errorDic= @{@"code" : @36007,
                                  @"message" : @"RongConfig获取失败",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                      messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:pluginResult
                                    callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *rongConfig = [CMPChatManager sharedManager].rongConfig;
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:rongConfig];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)forwardMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    CMPRCTransmitMessage *message = [[CMPRCTransmitMessage alloc] init] ;
    message.content = paramDict[@"content"];
    message.extra = paramDict[@"extra"];
    message.title = paramDict[@"title"];
    message.type = paramDict[@"type"];
    message.imgURL = paramDict[@"imgURL"];
    NSString *sendName = paramDict[@"sendName"];
    message.sendName = [NSString isNull:sendName] ? @"" : sendName;
    message.sendTime = paramDict[@"sendTime"];
    message.mobilePassURL = paramDict[@"mobilePassURL"];
    message.PCPassURL = paramDict[@"PCPassURL"];
    message.appId = paramDict[@"appId"];
    message.actionType = paramDict[@"actionType"];
    if ([message.sendTime isKindOfClass:[NSNumber class]]) {
        NSNumber *time = (NSNumber *)message.sendTime;
        message.sendTime = [NSString stringWithLongLong:time.longLongValue];
    }
    RCMessage *rcMessage = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                                   targetId:@"-1"
                                                  direction:MessageDirection_SEND
                                                  messageId:-1
                                                    content:message];
    RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
    CMPSelectContactViewController *selVC = [[CMPSelectContactViewController alloc] init];
    selVC.msgModel = model;
    selVC.targetId = nil;
    selVC.forwardSource = CMPForwardSourceTypeOnlySingleMessage;
    __weak typeof(self) weakSelf = self;
    selVC.forwardCancel = ^{
        NSDictionary *errorDic= @{@"code" :@36010,
                                  @"message" : @"转发取消",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsDictionary:errorDic];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    selVC.forwardSucess = ^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    selVC.forwardFail = ^(NSInteger errorCode) {
        NSNumber *code = [NSNumber numberWithInteger:errorCode];
        NSDictionary *errorDic= @{@"code" :code,
                                  @"message" : @"转发失败",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsDictionary:errorDic];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    [self.viewController.navigationController pushViewController:selVC animated:YES];
}

- (void)setSelectResult:(CDVInvokedUrlCommand *)command {
    NSDictionary *paramDict = [[command arguments] firstObject];
    NSArray *data = paramDict[@"data"];
    NSString *type = paramDict[@"type"];
    
    CMPChatChooseBusinessController *controller = (CMPChatChooseBusinessController *)self.viewController;
    
    if ([type isEqualToString:@"member"]) {
        [controller.delegate didSelectWithMembers:data];
    }else if ([type isEqualToString:@"meetingSelectMember"]) {
        [controller.delegate didSelectWithMembers:data];
    } else if ([type isEqualToString:@"accdoc"]) {
        [controller.delegate didSelectWithAccdocsAndh5Apps:data];
    } else if ([type isEqualToString:@"h5App"]) {
         [controller.delegate didSelectWithAccdocsAndh5Apps:data];
        //[controller.delegate didSelectWithH5Apps:data];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 {
    title:分享的内容标题
    params:{
    id:应用主键id
    messageCategory:appId
    messageForward:1、允许流程外人员查看  0、不允许
 }
 }
 */
- (void)setSelectContact:(CDVInvokedUrlCommand *)command {
    if (!command.arguments.lastObject) return;
    
    NSDictionary *param = command.arguments.lastObject;
    __weak typeof(self) weakSelf = self;
    [CMPShareToUcManager.manager showSelectContactViewInVC:self.viewController param:param willForwardMsg:^{
        
    } forwardSucess:^(CMPMessageObject * _Nonnull msgObj) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *vc =  weakSelf.viewController.navigationController.topViewController;
            if ([vc isKindOfClass:[CMPSelectContactViewController class]] == NO) {
                [weakSelf.viewController.navigationController dismissViewControllerAnimated:NO completion:^{
                    [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:nil filePaths:nil];
                }];
            } else {
                 [weakSelf.viewController.navigationController popViewControllerAnimated:NO];
                 [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:weakSelf.viewController filePaths:nil];
            }
            
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
        
    } forwardFailed:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
    
}

- (void)getGroupMemberById:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *groupId = param[@"id"];
    if ([NSString isNull:groupId]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[CMPChatManager sharedManager] getGroupUserListByGroupId:groupId completion:^(CMPRCGroupMemberObject *groupInfo, NSArray<RCUserInfo *> *userList){
        NSMutableArray *memberIds = [NSMutableArray array];
        for (RCUserInfo *userInfo in userList) {
            [memberIds addObject:userInfo.userId];
        }
        NSString *memberIdsStr = [memberIds componentsJoinedByString:@","];
        NSDictionary *menberDic = @{
            @"data" : [memberIdsStr copy]
        };
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:menberDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } fail:^(NSError *error, id ext) {}];
    
}

- (void)ucGroupBoardSettingChange:(CDVInvokedUrlCommand *)command {
    [[NSNotificationCenter defaultCenter] postNotificationName:CMPUcGroupBoardSettingDidChanged object:nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//搜索聊天记录
- (void)searchMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *conversationType = param[@"conversationType"];
    NSString *targetId = param[@"targetId"];
    NSString *keyword = param[@"keyword"];
    NSInteger count = [param[@"count"] integerValue];
    if (!count) {
        count = 20;
    }
    long long beginTime = [param[@"beginTime"] longLongValue];
    RCConversationType chatType;
    if ([conversationType isEqualToString:@"group"]) {
        chatType = ConversationType_GROUP;
    } else {
        chatType = ConversationType_PRIVATE;
    }
    
    NSArray<RCMessage *> *messageArr = [[RCIMClient sharedRCIMClient] searchMessages:chatType targetId:targetId keyword:keyword count:count startTime:beginTime];
    if (messageArr.count == 0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[NSArray array]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    NSMutableArray *resultArr = [NSMutableArray array];
    [messageArr enumerateObjectsUsingBlock:^(RCMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([message.content isMemberOfClass:[RCTextMessage class]]
            || [message.content isMemberOfClass:[CMPQuoteMessage class]]) {
            RCTextMessage *textMessage = (RCTextMessage *)message.content;
            NSDictionary *item = @{
                @"content":textMessage.content,
                @"name":textMessage.senderUserInfo.name ?: @"",
                @"headUrl":textMessage.senderUserInfo.portraitUri ?: @"",
                @"messageId":@(message.messageId).stringValue,
                @"senderUserId":textMessage.senderUserInfo.userId ?: @"",
                @"sendTime":@(message.sentTime).stringValue
            };
            [resultArr addObject:item];
        }
    }];
   
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[resultArr copy]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
//搜索全部聊天记录
- (void)searchMessageAll:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *keyword = param[@"keyword"];
    NSInteger count = [param[@"count"] integerValue];
    if (count<=0) {
        count = 20;
    }
    long long beginTime = [param[@"beginTime"] longLongValue];
    
    NSArray<RCSearchConversationResult *> *conversationArr = [[RCIMClient sharedRCIMClient] searchConversations:@[@(ConversationType_GROUP),@(ConversationType_PRIVATE)] messageType:@[@"RC:TxtMsg",@"RC:FileMsg",@"RC:QuoteMessage"] keyword:keyword];

    if (conversationArr.count == 0) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[NSArray array]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSMutableArray *resultArr = [NSMutableArray array];
    for (int i=0; i<conversationArr.count; i++) {
        RCSearchConversationResult *conversationResult = conversationArr[i];
        RCConversation *conversation = conversationResult.conversation;
        NSArray<RCMessage *> *messageArr = [[RCIMClient sharedRCIMClient] searchMessages:conversation.conversationType targetId:conversation.targetId keyword:keyword count:count startTime:beginTime];
        
        for (RCMessage *message in messageArr) {
            NSMutableDictionary *item = NSMutableDictionary.new;
            if ([message.content isMemberOfClass:[RCTextMessage class]]
                || [message.content isMemberOfClass:[CMPQuoteMessage class]]) {
                RCTextMessage *textMessage = (RCTextMessage *)message.content;
                [item setValue:textMessage.content?:@"" forKey:@"content"];
                [item setValue:@(NO) forKey:@"isFile"];
            }else if ([message.content isMemberOfClass:[RCFileMessage class]]){
                RCFileMessage *fileMessage = (RCFileMessage *)message.content;
                [item setValue:fileMessage.name?:@"" forKey:@"content"];
                [item setValue:@(YES) forKey:@"isFile"];
            }else{
                continue;
            }
            
            [item setValue:@(message.messageId).stringValue forKey:@"messageId"];
            [item setValue:@(message.sentTime) forKey:@"sendTime"];
            [item setValue:message.targetId?:@"" forKey:@"targetId"];
            if(message.conversationType == ConversationType_GROUP){
                [item setValue:@"GROUP" forKey:@"conversationType"];
            }else{
                [item setValue:@"PRIVATE" forKey:@"conversationType"];
            }

            RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:message.senderUserId];
            [item setValue:userInfo.name?:@"" forKey:@"name"];
            [item setValue:userInfo.portraitUri?:@"" forKey:@"headUrl"];
            [item setValue:userInfo.userId?:@"" forKey:@"senderUserId"];
            
            if (message.conversationType == ConversationType_GROUP) {
                RCGroup *groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:message.targetId];
                if (groupInfo) {
                    if (![NSString isNull:groupInfo.portraitUri]) {
                        [item setValue:groupInfo.portraitUri forKey:@"groupHeadUrl"];
                    }
                    NSString *imageUrl = [CMPCore rcGroupIconUrlWithGroupId:message.targetId];
                    if (![NSString isNull:imageUrl]) {
                        [item setValue:imageUrl forKey:@"groupHeadUrl"];
                    }
                    if (![NSString isNull:groupInfo.groupName]) {
                        [item setValue:groupInfo.groupName forKey:@"groupName"];
                    }
                }
            }
            [resultArr addObject:item];
        }
    }
   
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[resultArr copy]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//消息搜索之后点击进入页面
- (void)jumpToMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *conversationType = param[@"conversationType"];
    NSString *targetId = param[@"targetId"];
    BOOL isFullSearchNext = [param[@"isFullSearchNext"] boolValue];//全文检索
    long long beginTime = [param[@"beginTime"] longLongValue];
    CMPRCConversationType chatType;
    if ([conversationType isEqualToString:@"group"]||[conversationType isEqualToString:@"3"]) {
        chatType = CMPRCConversationType_GROUP;
    } else {
        chatType = CMPRCConversationType_PRIVATE;
    }
    
    CMPMessageObject  *messageObject = [[CMPMessageManager sharedManager] messageWithAppID:targetId];
    CMPRCTargetObject *object = [[CMPRCTargetObject alloc] init];
    object.targetId = targetId;
    object.title = messageObject.appName;
    object.navigationController = self.viewController.navigationController;
    object.type = chatType;
    object.tabbar = [self.viewController rdv_tabBarController];
    object.locatedMessageSentTime = beginTime;
    [[CMPChatManager sharedManager] showChatView:object];
    
    if (!isFullSearchNext) {//如果全文检索，不做跳转堆栈处理
        NSMutableArray *viewControllers = [self.viewController.navigationController.viewControllers mutableCopy];
        if (viewControllers.count >= 5) {//ks fix V5-1078【CMP组件适配】【iOS】搜索群聊天记录，点击搜索结果不应该新打开一个聊天窗口
            [viewControllers removeObjectsInRange:NSMakeRange(viewControllers.count - 4, 3)];
            self.viewController.navigationController.viewControllers = [viewControllers copy];
        }else if (viewControllers.count >= 3) {
            [viewControllers removeObjectsInRange:NSMakeRange(viewControllers.count - 3, 2)];
            self.viewController.navigationController.viewControllers = [viewControllers copy];
        }
    }
   
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取聊天文件记录
- (void)getFileMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *conversationType = param[@"conversationType"];
    NSString *targetId = param[@"targetId"];
    NSInteger count = [param[@"count"] integerValue];
    if (count == 0) {
        count = 20;
    }
    RCConversationType chatType;
    if ([conversationType isEqualToString:@"group"]) {
        chatType = ConversationType_GROUP;
    } else {
        chatType = ConversationType_PRIVATE;
    }
    long lastMessageId = [param[@"lastMessageId"] longValue];
    if (lastMessageId == 0 || lastMessageId == -1) {
        lastMessageId = [[RCIMClient sharedRCIMClient] getConversation:chatType targetId:targetId].lastestMessageId;
    }
    NSMutableArray *resultArr = [NSMutableArray array];
    NSArray<RCMessage *> *messages = [[RCIMClient sharedRCIMClient] getHistoryMessages:chatType
                                                                              targetId:targetId
                                                                            objectName:[RCFileMessage getObjectName]
                                                                       oldestMessageId:lastMessageId
                                                                                 count:count];
    [messages enumerateObjectsUsingBlock:^(RCMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        RCFileMessage *fileMessage = (RCFileMessage *)message.content;
        NSDictionary *itemDic = @{
            @"fileId" : fileMessage.fileUrl,
            @"fileName" : fileMessage.name,
            @"sendTime" : @(message.sentTime).stringValue,
            @"fileSize" : @(fileMessage.size).stringValue,
            @"messageId": @(message.messageId).stringValue,
            @"filePath" : fileMessage.localPath,
            @"senderName": fileMessage.senderUserInfo.name
        };
        [resultArr addObject:itemDic];
    }];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[resultArr copy]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取聊天文件记录
- (void)downloadFileMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    long messageId = [param[@"messageId"] longValue];
    [[RCIM sharedRCIM] downloadMediaMessage:messageId progress:^(int aProgress) {
        NSString *status = @"downloading";
        NSString *progress = @(aProgress).stringValue;
        NSDictionary *resultDic = @{
             @"status" : status,
             @"progress" : progress
        };
        CDVPluginResult *pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } success:^(NSString *mediaPath) {
        NSString *status = @"downloaded";
        NSString *progress = @(100).stringValue;
        NSDictionary *resultDic = @{
            @"status" : status,
            @"progress" : progress
        };
       CDVPluginResult *pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
       [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(RCErrorCode errorCode) {
        NSString *status = @"error";
        NSString *message = @"下载失败";
        NSString *code = @(errorCode).stringValue;
        NSDictionary *resultDic = @{
             @"status" : status,
             @"message" : message,
             @"code" : code
        };
        CDVPluginResult *pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } cancel:^{
        NSString *status = @"cancel";
        NSDictionary *resultDic = @{
             @"status" : status,
        };
        CDVPluginResult *pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//跳转到历史图片管理页面
- (void)showGroupPicture:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = command.arguments.lastObject;
    NSString *conversationType = param[@"conversationType"];
    NSString *targetId = param[@"targetId"];
    CMPRCConversationType chatType;
    if ([conversationType isEqualToString:@"group"]) {
        chatType = CMPRCConversationType_GROUP;
    } else {
        chatType = CMPRCConversationType_PRIVATE;
    }
    
    NSDictionary *imagesDic = [[RCIM sharedRCIM] getMediaMessagesWithTargetId:targetId conversationType:chatType];
    NSArray *imageUrlArr = imagesDic[@"imageUrlArr"];
    NSArray *rcImgModels = imagesDic[@"rcMessageModels"];
    CMPBaseWebViewController *controller = nil;
    if ([self.viewController isKindOfClass:[CMPBaseWebViewController class]]) {
        controller = (CMPBaseWebViewController *)self.viewController;
    }
    [CMPReviewImagesTool showPicListViewControllerWithDataModelArray:imageUrlArr rcImgModels:rcImgModels canSave:YES];
   
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendPeopleCard:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [[command arguments] lastObject];
    NSString *title = param[@"title"];
    NSString *aId = param[@"id"];
    NSString *post = param[@"post"];
    NSString *dept = param[@"dept"];
    
    CMPBusinessCardMessage *message = [[CMPBusinessCardMessage alloc] init];
    message.personnelId = aId;
    message.name = title;
    message.department = dept;;
    message.post = post;
    
    RCMessage *rcMessage = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                                   targetId:@"-1"
                                                  direction:MessageDirection_SEND
                                                  messageId:-1
                                                    content:message];
    RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
    CMPSelectContactViewController *selVC = [[CMPSelectContactViewController alloc] init];
    selVC.msgModel = model;
    selVC.targetId = nil;
    selVC.forwardSource = CMPForwardSourceTypeOnlySingleMessage;
    __weak typeof(self) weakSelf = self;
    __weak typeof(selVC) weakSelVc = selVC;
    selVC.forwardCancel = ^{
        NSDictionary *errorDic= @{@"code" :@36010,
                                  @"message" : @"转发取消",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsDictionary:errorDic];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    
    selVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
        UIViewController *vc =  [weakSelVc.navigationController popViewControllerAnimated:NO];
        if (vc == nil) {
            [weakSelVc.navigationController dismissViewControllerAnimated:NO completion:^{
                [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:nil filePaths:nil];
            }];
        } else {
             [CMPMessageManager.sharedManager showChatViewAfterShare:msgObj vc:[CMPCommonTool getCurrentShowViewController] filePaths:nil];
        }
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
    
    selVC.forwardFail = ^(NSInteger errorCode) {
        [[UIApplication sharedApplication].keyWindow yb_showForkTipView:SY_STRING(@"common_send_fail")];
        NSNumber *code = [NSNumber numberWithInteger:errorCode];
        NSDictionary *errorDic= @{@"code" :code,
                                  @"message" : @"转发失败",
                                  @"detail" : @""};
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsDictionary:errorDic];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };
   if (INTERFACE_IS_PAD) {
        CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selVC];
       [self.viewController presentViewController:nav animated:YES completion:nil];
    } else {
        [self.viewController.navigationController pushViewController:selVC animated:YES];
    }
}

//转发消息给某人，此处默认自带选人操作，选完后发送
- (void)msgSendTo:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = command.arguments.lastObject;
    NSArray *msgsArr = params[@"msgs"];
    if ([msgsArr isKindOfClass:[NSArray class]] && msgsArr.count >0 ) {
        
        NSString *identifier = params[@"identifier"] ? params[@"identifier"] : @"";
        NSMutableArray *msgModelArr = [NSMutableArray array];
        for (NSDictionary *oMsg in msgsArr) {
            if (oMsg[@"type"] && oMsg[@"obj"]) {
                NSString *typeStr = [NSString stringWithFormat:@"%@",oMsg[@"type"]];
                NSInteger type = [typeStr integerValue];
                NSDictionary *obj = oMsg[@"obj"];
                switch (type) {
                    case 4://文件
                    {
                        NSString *fileUrl = obj[@"remoteUrl"] ? obj[@"remoteUrl"] : @"";
                        NSString *fileName = obj[@"fileName"] ? obj[@"fileName"] : @"";
                        NSString *fileSizeStr = obj[@"size"] ? obj[@"size"] : @"";
                        NSString *fileTypeStr = obj[@"extName"] ? obj[@"extName"] : @"";
                        
                        if (fileUrl.length >0 ) {//服务器上面存在的文件
                            RCFileMessage *fileMsgContent = [[RCFileMessage alloc] init];
                            fileMsgContent.fileUrl = fileUrl;
                            fileMsgContent.name = fileName;
                            fileMsgContent.size = [fileSizeStr longLongValue];
                            fileMsgContent.type = fileTypeStr;
                            RCMessage *rcMessage = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                                                           targetId:@"-1"
                                                                          direction:MessageDirection_SEND
                                                                          messageId:-1
                                                                            content:fileMsgContent];
                            if (identifier.length >0) {
                                NSDictionary *dic = @{@"identifier":identifier};
                                rcMessage.extra = [dic yy_modelToJSONString];
                            }
                            RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
                            [msgModelArr addObject:model];
                        }else{
                            //
                        }
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
        }
        
        if (msgModelArr.count == 0) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"data format error"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        NSArray *selectedMessage = msgModelArr;
         CMPSelectContactViewController *selectVC = [[CMPSelectContactViewController alloc] init];
         selectVC.forwardSource = CMPForwardSourceTypeSingleMessages;
         selectVC.selectedMessages = selectedMessage;
         
        __weak typeof(selectVC) weakSelectVC = selectVC;
         selectVC.getSelectContactFinishBlock = ^(NSArray<RCConversation *> *conversationList) {
             if (conversationList) {
                 NSMutableArray *mutableConversationList = [conversationList mutableCopy];
                 [mutableConversationList removeLastObject];
                 conversationList = [mutableConversationList copy];
                
                 [MBProgressHUD cmp_showProgressHUD];
                 [[RCForwardManager sharedInstance] doForwardMessageList:selectedMessage conversationList:conversationList isCombine:NO forwardConversationType:ConversationType_PRIVATE completed:^(BOOL success) {
                     [MBProgressHUD cmp_hideProgressHUD];
                     if (success) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kDidOneByOneForwardSucess object:nil];
                         UIViewController *vc =  [weakSelectVC.navigationController popViewControllerAnimated:NO];
                         if (vc == nil) {
                             [weakSelectVC.navigationController dismissViewControllerAnimated:NO completion:nil];
                         }
                         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"data format success"];
                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                         
                         //ks fix V5-9969 iOS端M3的群文件，从A群转发到B群，B群的群文件里不显示该文件
                         if (selectedMessage) {
                             for (RCMessageModel *msgModel in selectedMessage) {
                                 if ([msgModel isFileMessage] || [msgModel isVideoMessage]) {
                                     RCFileMessage *fileMsg = (RCFileMessage *)(msgModel.content);
                                     for (RCConversation *con in conversationList) {
                                         [[CMPChatManager sharedManager] forwardFile:fileMsg.remoteUrl type:0 target:con.targetId completion:^(id result, NSError *error) {

                                         }];
                                     }
                                 }
                             }
                         }
                         
                     } else {
                         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"data format error"];
                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                     }
                 }];
             }
         };
        
         
         selectVC.forwardSucessWithMsgObj = ^(CMPMessageObject *msgObj, NSArray *fileList) {
             UIViewController *vc =  [weakSelectVC.navigationController popViewControllerAnimated:NO];
             if (vc == nil) {
                 [weakSelectVC.navigationController dismissViewControllerAnimated:NO completion:nil];
             }
             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"data format success"];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         };
        selectVC.forwardSucess = ^{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"data format success"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        };
         if (INTERFACE_IS_PAD) {
             CMPNavigationController *nav = [CMPNavigationController.alloc initWithRootViewController:selectVC];
             [[CMPCommonTool getCurrentShowViewController] presentViewController:nav animated:YES completion:nil];
         } else {
             [[CMPCommonTool getCurrentShowViewController].navigationController pushViewController:selectVC animated:YES];
         }
        
    }else{
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"data format error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

//前端判断目前是否能使用消息删除功能的插件
- (void)msgCanDelete:(CDVInvokedUrlCommand *)command{
    BOOL canRemoveRemoteMsg = [CMPChatManager canRemoveRemoteMsg];
    if (canRemoveRemoteMsg) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
