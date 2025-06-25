//
//  CMPMeetingManager.m
//  M3
//
//  Created by Kaku Songu on 11/25/22.
//

#import "CMPMeetingManager.h"
#import "CMPOnTimeMeetHelper.h"
#import "M3-Swift.h"
#import "CustomDefine.h"
#import "CMPMessageManager.h"
#import <CMPLib/CMPCommonTool.h>

@interface CMPMeetingManager()<CMPChatChooseBusinessControllerDelegate>
{
    MeetingOtmCreateFrom _selectFrom;
    void(^_selectMembersResultBlk)(NSArray *members,NSError *err,id ext);
}
@property (nonatomic,strong) CMPOnTimeMeetHelper *onTimeMeetHelper;
@end

@implementation CMPMeetingManager

static CMPMeetingManager *meetingManager ;
static dispatch_once_t onceTokenMeet;

+(instancetype)shareInstance
{
    dispatch_once(&onceTokenMeet, ^{
        meetingManager = [[[self class] alloc] init];
    });
    return meetingManager;
}

+(void)ready
{
    [[CMPMeetingManager shareInstance].onTimeMeetHelper ready];
}

+ (BOOL)otmIfServerSupport
{
    return [CMPOnTimeMeetHelper ifServerSupport];
}

+ (NSDictionary *)otmQuickItemConfig
{
    return [CMPOnTimeMeetHelper quickItemConfig];
}

- (BOOL)otmIfServerOpen
{
    return [self.onTimeMeetHelper.viewModel ifOpen];
}

- (BOOL)otmIfPersonalConfig
{
    return [self.onTimeMeetHelper.viewModel ifConfig];
}

-(CMPOnTimeMeetHelper *)onTimeMeetHelper
{
    if (!_onTimeMeetHelper) {
        _onTimeMeetHelper = [[CMPOnTimeMeetHelper alloc] init];
    }
    return _onTimeMeetHelper;
}

-(void)selectJoinMeetingPersonFrom:(MeetingOtmCreateFrom)from byVC:(UIViewController *)vc result:(void(^)(NSArray *members,NSError *err,id ext))result
{
    if (!vc) {
        return;
    }
    _selectFrom = from;
    _selectMembersResultBlk = result;
    CMPChatChooseBusinessController *controller = [[CMPChatChooseBusinessController alloc] init];
    controller.delegate = self;
    controller.type = @"meetingSelectMember";
    controller.max = 10000;
    [vc presentViewController:controller animated:YES completion:^{
            
    }];
}

-(void)didSelectWithMembers:(NSArray<NSDictionary<NSString *,id> *> *)members
{
    if (_selectMembersResultBlk) {
        _selectMembersResultBlk(members,nil,nil);
    }
    _selectFrom = -1;
    _selectMembersResultBlk = nil;
}


-(void)otmBeginMeetingWithMids:(NSArray *)mids onVC:(UIViewController *)vc from:(MeetingOtmCreateFrom)from ext:(id)ext completion:(void(^)(id rslt, NSError *err, id ext,NSInteger step))compl
{
    if (!compl) return;
    if (![CMPOnTimeMeetHelper ifServerSupport]) {
        compl(nil,[NSError errorWithDomain:@"server version low" code:-1001 userInfo:nil],nil,0);
        return;
    }

    weakify(self);
    void(^createBlk)(NSArray *) = ^(NSArray *fmids){
        switch (from) {
            case MeetingOtmCreateFrom_Zx:
            case MeetingOtmCreateFrom_ZxInvite:
            {
                NSString *sid, *type, *link, *pwd;
                if (ext && ext[@"sid"]) {
                    sid = ext[@"sid"];
                }
                if (ext && ext[@"type"]) {
                    type = ext[@"type"];
                }else if (from == MeetingOtmCreateFrom_ZxInvite) {
                    type = MeetingOtmCreateFromZxType_Personal;
                }
                if (from == MeetingOtmCreateFrom_ZxInvite) {
                    link = ext[@"link"];
                    pwd = ext[@"pwd"];
                }
                [self.onTimeMeetHelper.viewModel zxCreateOnTimeMeetingBySenderId:sid receiverIds:fmids type:type link:link password:pwd completion:^(NSDictionary * _Nonnull meetInfo, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        if (from != MeetingOtmCreateFrom_ZxInvite) {
                            [self otmOpenPersonalMeeting];
                        }
                    }
                    compl(meetInfo,error,ext,error?0:2);
                }];
            }
                break;
                
            default:
            {
                [self.onTimeMeetHelper.viewModel createMeetingByMids:fmids completion:^(NSDictionary * _Nonnull meetInfo, NSError * _Nonnull error, id  _Nonnull ext) {
                    if (!error) {
                        if (from != MeetingOtmCreateFrom_ZxInvite) {
                            [self otmOpenPersonalMeeting];
                        }
                    }
                    compl(meetInfo,error,ext,error?0:2);
                }];
            }
                break;
        }
    };
    
    //ks add -- 新增直接跳转到h5选择并创建会议
    void(^openNewBeginPageBlk)(NSString *) = ^(NSString *beginUrl){
        NSString *queryStr = @"?type=instant";
        if (ext && from == MeetingOtmCreateFrom_Zx) {
            NSString *sid, *type, *name;
            if (ext && ext[@"tid"]) {
                sid = ext[@"tid"];
            }
            if (ext && ext[@"type"]) {
                type = ext[@"type"];
            }
            if (ext && ext[@"tname"]) {
                name = ext[@"tname"];
            }
            queryStr = [NSString stringWithFormat:@"?type=conversation&conversationType=%@&receiverId=%@&conversationName=%@",type,sid,name];
        }
        NSString *finalUrl = [[beginUrl stringByAppendingString:queryStr] urlCFEncoded];
        [[CMPMessageManager sharedManager] showWebviewWithUrl:finalUrl viewController:vc params:ext actionBlk:^(id params, NSError *error, NSInteger act) {
            
        }];
    };
    //end
    
    void(^personInfoConfigedBlk)(void) = ^{
        strongify(self);
        NSDictionary *item = [CMPMeetingManager otmQuickItemConfig];
        NSString *newBeginUrl = item[@"aurl"];
        if (newBeginUrl && from != MeetingOtmCreateFrom_ZxInvite) {
            openNewBeginPageBlk(newBeginUrl);
            return;
        }
        if (!mids || !mids.count) {
            [self selectJoinMeetingPersonFrom:from byVC:vc result:^(NSArray *members, NSError *err, id ext) {
                if (!err) {
                    if (!members || members.count == 0) {
                        compl(nil,[NSError errorWithDomain:@"select nobody" code:-1104 userInfo:nil],ext,0);
                        return;
                    }
                    NSString *curId = [CMPCore sharedInstance].userID;
                    NSMutableArray *tmpmids = [NSMutableArray array];
                    for (NSDictionary *memb in members) {
                        NSString *mid = memb[@"id"];
                        if (mid && ![mid isEqualToString:curId]) {
                            [tmpmids addObject:mid];
                        }
                    }
                    createBlk(tmpmids);
                    
                }else{
                    compl(nil,err,ext,0);
                }
            }];
        }else{
            createBlk(mids);
        }
    };
    
    void(^personInfoNotConfigBlk)(void) = ^{
        NSDictionary *item = [CMPMeetingManager otmQuickItemConfig];
        NSString *url = item[@"url"];
        [[CMPMessageManager sharedManager] showWebviewWithUrl:url viewController:vc params:nil actionBlk:^(id params, NSError *error, NSInteger act) {
            if (act == 1) {//save success
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    personInfoConfigedBlk();
                });
                strongify(self);
                [self.onTimeMeetHelper.viewModel fetchPersonalMeetingConfigInfoWithCompletion:^(CMPOnTimeMeetingPersonalConfigModel * _Nonnull configInfo, NSError * _Nonnull error, id  _Nonnull ext) {
                                    
                }];
            }
        }];
    };
    
    void(^bBlk)(void) = ^{
        strongify(self);
        if ([self.onTimeMeetHelper.viewModel ifConfig]){
            personInfoConfigedBlk();
        }else{
            personInfoNotConfigBlk();
        }
    };
    
    void(^serverNotOpenBlk)(void) = ^{
        compl(nil,[NSError errorWithDomain:@"server not open" code:-1003 userInfo:nil],nil,0);
    };
    void(^serverOpenBlk)(void) = ^{
        if (![self.onTimeMeetHelper.viewModel ifConfigLoaded]){
            [self.onTimeMeetHelper.viewModel fetchPersonalMeetingConfigInfoWithCompletion:^(CMPOnTimeMeetingPersonalConfigModel * _Nonnull configInfo, NSError * _Nonnull error, id  _Nonnull ext) {
                bBlk();
            }];
        }else{
            bBlk();
        }
    };
    void(^aBlk)(void) = ^{
        strongify(self);
        if ([self.onTimeMeetHelper.viewModel ifOpen]){
            serverOpenBlk();
        }else{
            serverNotOpenBlk();
        }
    };
    if (![self.onTimeMeetHelper.viewModel ifOpenLoaded]){
        [self.onTimeMeetHelper.viewModel checkQuickMeetingEnableWithCompletion:^(BOOL ifEnable, NSError * _Nonnull error, id  _Nonnull ext) {
            aBlk();
        }];
    }else{
        aBlk();
    }
}

-(void)otmVerifyMeetingValidWithInfo:(NSDictionary *)meetInfo completion:(void(^)(BOOL validable,NSError *error, id ext))completion
{
    [self.onTimeMeetHelper.viewModel verifyOnTimeMeetingValidWithInfo:meetInfo completion:completion];
}

-(void)otmOpenPersonalMeeting
{
    [self.onTimeMeetHelper openPersonalMeeting];
}

+ (void)otmOpenWithNumb:(NSString *)numb pwd:(NSString *)pwd link:(NSString *)link  result:(void (^ __nullable)(BOOL success,NSError *error))result
{
    if (pwd && pwd.length) {
        BOOL toast = YES;
        CMPOnTimeMeetingPersonalConfigModel *curConfig = [CMPMeetingManager shareInstance].onTimeMeetHelper.viewModel.personalConfigModel;
        if (curConfig) {
            if (numb && curConfig.meetingNumber && [numb isEqualToString:curConfig.meetingNumber]) {
                toast = NO;
            }
            if (toast && link && curConfig.meetingNumber && [link containsString:[@"/" stringByAppendingString:curConfig.meetingNumber]]) {
                toast = NO;
            }
            if (toast && link && curConfig.link && [link isEqualToString:curConfig.link]) {
                toast = NO;
            }
        }
        if (toast) {
            [[UIPasteboard generalPasteboard] setString:pwd];
            UIViewController *vc = [CMPCommonTool getCurrentShowViewController];
            [vc cmp_showHUDWithText:SY_STRING(@"meeting_pwdCopied")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [CMPOnTimeMeetHelper openMeetingWithNumb:numb pwd:pwd link:link result:result];
            });
            return;
        }
    }
    [CMPOnTimeMeetHelper openMeetingWithNumb:numb pwd:pwd link:link result:result];
}

+ (BOOL)isDateValidWithin30MinituesByTimestramp:(long long)createTime
{
    return [CMPOnTimeMeetHelper isMsgValidWithTimestramp:createTime];
}

@end
