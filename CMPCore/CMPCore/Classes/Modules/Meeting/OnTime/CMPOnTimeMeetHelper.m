//
//  CMPOnTimeMeetHelper.m
//  M3
//
//  Created by Kaku Songu on 11/25/22.
//

#import "CMPOnTimeMeetHelper.h"
#import "CMPMeetingConstant.h"
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPWindowAlertManager.h"
#import "CMPOnTimeMeetingTopView.h"
#import <CMPLib/CMPCore.h>
#import <RongIMKit/RCIM.h>
#import <UserNotifications/UserNotifications.h>
#import "CMPContactsManager.h"

@interface CMPOnTimeMeetHelper()
{
    CMPWindowAlertManager *_alertManager;
    NSString *_curUid;
    BOOL _isBackground;
}
@end

@implementation CMPOnTimeMeetHelper

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)ifServerSupport
{
    return [CMPServerVersionUtils serverIsLaterV8_2];
}

+ (NSDictionary *)quickItemConfig
{
    if ([self ifServerSupport]) {
        
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        item[@"appName"] = @"quick_ontimemeet";
        item[@"icon"] = IMAGE(@"qc_intimemeet");
        item[@"color"] = UIColorFromRGB(0x111111);
        item[@"sortNum"] = @101;
        item[@"url"] = @"http://collaboration.v5.cmp/v1.0.0/html/meeting.html";
        item[@"appID"] = CMPMeeting_AppId;
        /*
        //type=instant / conversation ;
        conversationType = group / persons ;
        receiverId = 人员ID/群ID
         */
        item[@"aurl"] = @"http://collaboration.v5.cmp/v1.0.0/html/quickMeeting.html";//发起页面，即时或预约,?type=conversation&conversationType=persons&receiverId=80130341894703852
        
        return item;
    }
    return nil;
}

+ (BOOL)isMsgValidWithTimestramp:(long long)createTime
{
    if (createTime) {
        long long nowStramp = [[NSDate date] timeIntervalSince1970] *1000;
        long long sp = nowStramp - createTime;
        if (sp <= 30*60*1000) {
            return YES;
        }
    }
    return NO;
}

-(instancetype)init
{
    if (self = [super init]) {
        _curUid = [CMPCore sharedInstance].userID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_recieveInviteMsg:) name:@"kNotificationName_OtmMessageRecieved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:kNotificationName_ApplicationDidEnterBackground object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:kNotificationName_ApplicationWillEnterForeground object:nil];
    }
    return self;
}

- (void)ready
{
    if (![CMPOnTimeMeetHelper ifServerSupport]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.viewModel checkQuickMeetingEnableWithCompletion:^(BOOL ifEnable, NSError * _Nonnull error, id  _Nonnull ext) {
                
        }];
        [self.viewModel fetchPersonalMeetingConfigInfoWithCompletion:^(CMPOnTimeMeetingPersonalConfigModel * _Nonnull configInfo, NSError * _Nonnull error, id  _Nonnull ext) {
                            
        }];
    });
}

-(void)_recieveInviteMsg:(NSNotification *)noti
{
    @synchronized (self) {
        id msgDic = noti.object;
        if (msgDic) {
            if ([@"OA:OACardMsg" isEqualToString:msgDic[@"objectName"]]) {
                NSString *senderId = msgDic[@"senderUserId"];
                _curUid = [CMPCore sharedInstance].userID;
                if (![_curUid isEqualToString:senderId]) {
                    NSDictionary *content = msgDic[@"content"];
                    if (content && [content isKindOfClass:NSDictionary.class]) {
                        NSDictionary *messageCard = content[@"messageCard"];
                        NSNumber *n = messageCard[@"createDate"] ? : msgDic[@"sentTime"];
                        if (messageCard && n) {
                            if ([n isKindOfClass:NSNull.class]) return;
                            long long createTime = [n longLongValue];
                            if ([CMPOnTimeMeetHelper isMsgValidWithTimestramp:createTime]) {
                                RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:senderId];
                                __block NSString *creatorName = nil;
                                if (!userInfo || [NSString isNull:creatorName]) {
                                    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                                    [[CMPContactsManager defaultManager] memberNamefromServerForId:senderId completion:^(NSString *name) {
                                        creatorName = name;
                                        dispatch_semaphore_signal(sem);
                                    }];
                                    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC));
                                }
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    CMPOnTimeMeetingTopModel *topModel = [[CMPOnTimeMeetingTopModel alloc] init];
                                    topModel.iconUrl = [CMPCore memberIconUrlWithId:senderId];
                                    topModel.creatorName = creatorName ? : senderId;
                                    topModel.content = [NSString stringWithFormat:@"%@",messageCard[@"messageContent"]];
                                    topModel.numb = [NSString stringWithFormat:@"%@",messageCard[@"meetingNum"]];
                                    topModel.pwd = [NSString stringWithFormat:@"%@",messageCard[@"meetingPassword"]];
                                    topModel.creatorId = senderId;
                                    topModel.createTime = createTime;
                                    topModel.link = messageCard[@"meetingLink"];
                                    if (!_alertManager) {
                                        _alertManager = [[CMPWindowAlertManager alloc] init];
                                    }
                                    CMPOnTimeMeetingTopView *topView = [[CMPOnTimeMeetingTopView alloc] initWithMeetingInfo:topModel];
                                    [_alertManager showBehind:topView];
                                    
                                    /*
                                    if (_isBackground) {
                                        if (@available(iOS 10.0,*)) {
                                            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                                            content.title = [NSString localizedUserNotificationStringForKey:topModel.creatorName arguments:nil];
                                            content.body = [NSString localizedUserNotificationStringForKey:topModel.content arguments:nil];;
                                            content.sound = [UNNotificationSound defaultSound];
                                            content.userInfo = @{@"creatorId":senderId,@"numb":topModel.numb,@"pwd":topModel.pwd,@"createTime":@(topModel.createTime)};
                                            
                                            UNNotificationRequest *localReq = [UNNotificationRequest requestWithIdentifier:@"cmp.local.meeting" content:content trigger:nil];
                                            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:localReq withCompletionHandler:^(NSError * _Nullable error) {}];
                                        }else{
                                            //tengxun support 11 later,so not impl
//                                            UILocalNotification *local = [[UILocalNotification alloc] init];
                                        }
                                    }
                                    */
                                });
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)enterBackground
{
    _isBackground = YES;
}

-(void)enterForeground
{
    _isBackground = NO;
}

-(void)openPersonalMeeting
{
    NSString *numb = self.viewModel.personalConfigModel.meetingNumber;
    NSString *pwd = self.viewModel.personalConfigModel.meetingPassword;
    NSString *link = self.viewModel.personalConfigModel.link;
    [CMPOnTimeMeetHelper openMeetingWithNumb:numb pwd:pwd link:link result:nil];
}

+(void)openMeetingWithNumb:(NSString *)numb pwd:(NSString *)pwd link:(NSString *)link  result:(void (^ __nullable)(BOOL success,NSError *error))result
{
    if (numb && numb.length) {
        __block NSString *url = [NSString stringWithFormat:@"wemeet://page/inmeeting?meeting_code=%@",numb];
        [CMPOnTimeMeetHelper openMeetingLink:url result:^(BOOL success, NSError *error) {
            if (!success) {
                if (error && error.code == -103) {
                    if (result) result(NO,error);
                }else{
                    url = [NSString isNotNull:link] ? link : [NSString stringWithFormat:@"https://meeting.tencent.com/p/%@",numb];
                    [CMPOnTimeMeetHelper openMeetingLink:url result:result];
                }
            }else{
                if (result) result(YES,nil);
            }
        }];
    }else{
        [CMPOnTimeMeetHelper openMeetingLink:link result:result];
    }
}

+(void)openMeetingLink:(NSString *)url result:(void (^ __nullable)(BOOL success,NSError *error))result
{
    if ([NSString isNotNull:url]) {
        if (![url containsString:@"://"]) {
            if (result) result(NO,[NSError errorWithDomain:@"url no scheme" code:-104 userInfo:nil]);
            return;
        }
        NSURL *link = [NSURL URLWithString:url];
        if (link) {
            if ([[UIApplication sharedApplication] canOpenURL:link]) {
                if (@available(iOS 10.0,*)) {
                    [[UIApplication sharedApplication] openURL:link options:nil completionHandler:^(BOOL success) {
                        if (result) result(success,success ? nil : [NSError errorWithDomain:@"cancel action" code:-103 userInfo:nil]);
                    }];
                    return;
                }else{
                    [[UIApplication sharedApplication] openURL:link];
                    if (result) result(YES,nil);
                    return;
                }
            }else{
                //不能打开（未安装）
                if (result) result(NO,[NSError errorWithDomain:@"cannot open link" code:-102 userInfo:nil]);
                return;
            }
        }
    }
    if (result) result(NO,[NSError errorWithDomain:@"url null" code:-101 userInfo:nil]);
}

-(CMPOnTimeMeetViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOnTimeMeetViewModel alloc] init];
    }
    return _viewModel;
}

@end
