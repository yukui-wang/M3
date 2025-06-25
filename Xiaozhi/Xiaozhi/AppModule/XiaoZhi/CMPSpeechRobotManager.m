//
//  CMPSpeechRobotManager.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/21.
//
//

#import "CMPSpeechRobotManager.h"
#import "XZMainController.h"
#import "XZPreMainController.h"
#import "SPConstant.h"
#import "SPBaiduSpeechInfo.h"
#import "SPTools.h"
#import "XZCore.h"
#import "XZMsgRemindRule.h"
#import "XZM3RequestManager.h"
#import <CMPLib/CMPCore.h>

@interface CMPSpeechRobotManager() {
    XZMainController *_mainController;
}

@end

@implementation CMPSpeechRobotManager
#pragma mark 单例

+ (instancetype)sharedInstance{
    static CMPSpeechRobotManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMPSpeechRobotManager alloc] init];
        [instance registeNotification];
    });
    return instance;
}


#pragma mark 小致权限及绑定

//开启语音机器人
- (void)openSpeechRobot {
    XiaozhiMessageRequestStatus xzMsgRequestStatus = [XZCore sharedInstance].xzMsgRequestStatus;
    if (xzMsgRequestStatus == XiaozhiMessageRequestStatus_normal) {
        [self initXiaozhiInfo];
    }
    else  if (xzMsgRequestStatus == XiaozhiMessageRequestStatus_success) {
        [_mainController reShowInWindow];
    }
}

- (void)reloadSpeechRobot {
    [self openSpeechRobot];
}

- (void)initXiaozhiInfo {
    [[XZCore sharedInstance] clearData];
    if ([[CMPCore sharedInstance] serverIsLaterV1_8_0]) {
        [self requestXiaoZhiTicket];
    }
    else {
        [self closeXiaoZhi];
    }
}


- (void)showQAWithIntentId:(NSString *)intentId {
    [_mainController showQAWithIntentId:intentId];
}

- (void)defaultShowXiaoZhi {
    
    [XZCore sharedInstance].showInSetting = YES;
    [XZCore sharedInstance].baiduSpeechInfo = [SPBaiduSpeechInfo defaultInfo];
    [XZCore sharedInstance].baiduUnitInfo = [SPBaiduUnitInfo defaultInfo];
    if (![XZCore sharedInstance].msgRemindRule) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:7200000],@"remindStep",@"22:00",@"serviceEndTime",@"7:00",@"serviceStartTime", nil];
        [XZCore sharedInstance].msgRemindRule = [XZMsgRemindRule remindRuleWithDic:dic];
    }
//    self.msgRemindRule.remindStep = 60;
    [self showXiaoZhi];
}

//语音机器人小致权限
- (void)requestXiaoZhiTicket {
    NSString *url = [XZCore fullUrlForPath:kGetXiaozhiMessage];
    __weak typeof(self) weakSelf = self;
    XZCore *xzcore =  [XZCore sharedInstance];
    xzcore.xzMsgRequestStatus = XiaozhiMessageRequestStatus_start;
    
    NSDictionary *paramDic = nil;
    NSString *method = @"GET";
    if ([xzcore isM3ServerIsLater8]) {
        method = @"POST";
        paramDic = @{
            @"appMd5": xzcore.intentMd5,//配置单的md5
            @"speechErrorMd5": xzcore.spErrorCorrectionMd5,//语音纠错的md5
            @"rosterPinyinMd5": xzcore.pinyinRegularMd5,//人员拼音的md5
        };
    }
   
    
    [[XZM3RequestManager sharedInstance] requestWithUrl:url params:paramDic userInfo:nil handleCookies:YES method:method success:^(NSString *response, NSDictionary *userInfo) {
        XZCore *core = [XZCore sharedInstance];
        core.xzMsgRequestStatus = XiaozhiMessageRequestStatus_success;
        NSDictionary *result = [response JSONValue];
        NSString *ticket = result[@"ticket"];
        core.showInSetting = [result[@"switchButton"] boolValue];
        NSDictionary *searchParams = result[@"messageRemindRule"];
        core.msgRemindRule = [XZMsgRemindRule remindRuleWithDic:searchParams];
        if ([result.allKeys containsObject:@"baiduAppKey"]) {
            [core setupBaiduInfo:result];
            if ([core xiaozAvailable]) {
                [weakSelf showXiaoZhi];
                core.showInSetting = YES;
            }
            else {
                [weakSelf closeXiaoZhi];
            }
            if ([core.baiduSpeechInfo isUnavailableCode]) {
                core.showInSetting = NO;
            }
        }
        else if (![NSString isNull:ticket]) {
            [weakSelf requestXiaoZhiPermissionWithTicket:ticket url:result[@"robotCheckUrl"]];
        }
        else {
            [core setupBaiduInfo:result];
            core.showInSetting = NO;
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        //语音机器人小致权限
        [XZCore sharedInstance].xzMsgRequestStatus = XiaozhiMessageRequestStatus_RequestFailed;
        [XZCore sharedInstance].showInSetting = NO;
        [weakSelf closeXiaoZhi];
    }];
}

- (void)requestXiaoZhiPermissionWithTicket:(NSString *)ticket  url:(NSString *)urlStr {
    NSString *url = urlStr;
    if ([NSString isNull:url]) {
        url = @"https://mplus.seeyon.com/svr/robot/check";//正式环境
//        NSString *url = @"https://mplus.test.seeyon.com/svr/robot/check";//测试环境
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:ticket,@"ticket", nil];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance]postRequestWithUrl:url params:param success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *result = [response  JSONValue];
        XZCore *core = [XZCore sharedInstance];
        SPBaiduUnitInfo *unitInfo = [[SPBaiduUnitInfo alloc] initWithResult:result];
        core.baiduUnitInfo = unitInfo;
        
        SPBaiduSpeechInfo *info = [[SPBaiduSpeechInfo alloc] initWithResult:result];
        core.baiduSpeechInfo = info;
        if ([core xiaozAvailable]) {
            [weakSelf showXiaoZhi];
            core.showInSetting = YES;
        }
        else {
            [weakSelf closeXiaoZhi];
        }
        if ([info isUnavailableCode]) {
            core.showInSetting = NO;
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        //语音机器人小致权限
        [XZCore sharedInstance].showInSetting = NO;
        [weakSelf closeXiaoZhi];
    }];
}

- (void)showXiaoZhi {
    // 小致悬浮按钮
    _mainController = [self mainController];
    [_mainController showInWindow];
    [[XZCore sharedInstance] saveAppListId];
}

- (void)closeXiaoZhi {
    [[self mainController] closeInWindow];
}
- (XZMainController *)mainController {
    if ([[XZCore sharedInstance] isXiaozVersionLater2_2]) {
        return [XZMainController sharedInstance];
    }
    return (XZMainController *)[XZPreMainController sharedInstance];
}



- (void)registeNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:kNotificationName_UserLogout
                                                object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willLogout)
                                                 name:kNotificationName_UserWillLogout
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:kNotificationName_SessionInvalid
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:kNotificationName_GestureShowLoginView
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabbarChangeSelectedViewController:)
                                                 name:kNotificationName_TabbarSelectedViewControllerChanged
                                               object:nil];

}

- (void)logout {
    [_mainController logout];
    [XZCore sharedInstance].xzMsgRequestStatus = XiaozhiMessageRequestStatus_normal;
}
- (void)willLogout {
    [_mainController willLogout];
}
- (void)tabbarChangeSelectedViewController:(NSNotification *)notif {
    if (INTERFACE_IS_PHONE) {
        UIViewController *controller = notif.object;
        self.xzIconInViewController = controller;
        [_mainController needShowXiaozIconInViewController:self.xzIconInViewController];
    }
}

@end


