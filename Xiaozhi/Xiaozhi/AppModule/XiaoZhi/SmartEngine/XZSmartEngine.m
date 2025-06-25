//
//  SPSmartEngine.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//
#define kIntentFail @"fail_action"

#import "XZSmartEngine.h"
#import "SPMemberCommondNode.h"
#import "SPSearchStatisticsHelper.h"
#import "XZCreateScheduleModel.h"
#import "XZCreateFormModel.h"
#import "BUnitManager.h"
#import "XZCore.h"
#import "XZMainProjectBridge.h"
#import "XZDateUtils.h"
#import "XZPinyinTool.h"

@implementation XZSmartEngine

#pragma mark - Init

static id shareInstance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [super allocWithZone:zone];
            }
        }
    }
    return shareInstance;
}

+ (instancetype)sharedInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}

- (BOOL)isMultiSelectMember {
    if (self.intent && !self.intent.isEnd) {
        return [self.intent isMultiSelectMember];
    }
    return [super isMultiSelectMember];
}

#pragma mark - Open Interface

- (void)showUnitErrorWords {
    _unitFailureCount ++;
    NSString *say = @"对不起，我没明白，请再说一遍。";
    if (_unitFailureCount > 2) {
        say = @"对不起，我还要再学习。我可以帮你打电话、找人、查数据、查报表、快速新建、打开应用等。";
        _unitFailureCount = 0;
    }
    [self needSpeakContent:say];
}

- (void)handleTextWithUnit:(NSString *)string {
    __weak typeof(self) weakSelf = self;
    [self handleTextWithUnit:string completion:^(NSError *error, BUnitResult *resultDict) {
        if (error.code != -999 &&!resultDict) {
            // Code=-999 "已取消"
//            [weakSelf needSpeakContent:kBUnitErrorInfo];
            [weakSelf showUnitErrorWords];
            NSLog(@"[unit error] =[%@]\n [%@]",[XZCore sharedInstance].baiduUnitInfo.baiduUnitSceneID,error);
            return ;
        }
        [weakSelf handleBaiduUnitResult:resultDict];
    }];
}

- (void)chooseMemberWithUnitResult:(BUnitResult *)unitResult speakInfo:(NSString *)speakInfo block:(SmartMembersBlock)block{
    
    __weak typeof(self) weakSelf = self;
    if ([XZCore sharedInstance].isM3ServerIsLater8) {
        NSDictionary *infoListDict = unitResult.infoListDict;
        [XZPinyinTool obtainMembersWithNameArray:infoListDict[kBUnitIntent_UserPerson] memberType:XZSearchMemberType_Contact_BUnit complete:^(NSArray* memberArray, NSArray *defSelectArray) {
            [weakSelf handleMembers:memberArray name:nil speakInfo:speakInfo block:block];
        }];
        return;
    }
    NSDictionary *info = unitResult.infoDict;
    NSString *userName = info[kBUnitIntent_UserName];
    if ([NSString isNull:userName]) {
        userName = info[kBUnitIntent_UserPerson];
    }
    [XZMainProjectBridge memberListForPinYin:userName completion:^(NSArray *memberArray) {
        [weakSelf handleMembers:memberArray name:userName speakInfo:speakInfo block:block];
    }];
}

- (void)handleMembers:(NSArray *)memberArray name:(NSString *)userName speakInfo:(NSString *)speakInfo block:(SmartMembersBlock)block {
    if (memberArray.count == 0) {
        NSString *speak = @"我没找到这个人";
        NSString *showString = [NSString isNull:speakInfo]?speak: [NSString stringWithFormat:@"%@,%@", speak,speakInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needReadWord:speakContent:)]) {
            [self.delegate needReadWord:showString speakContent:speak];
        }
        [self needStartWakeup];
        block(nil,NO,nil);
        
    }
    else if (memberArray.count == 1) {
        if (block) {
            block(memberArray,NO,nil);
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needChooseFormOptionMembers:block:)]) {
            NSString *speak = nil;
            if (userName) {
                speak = [NSString stringWithFormat:@"第几位%@？", userName];
            }
            else {
                speak = @"请确认是哪位？";
            }
            NSString *info = [[XZCore sharedInstance] isXiaozVersionLater2_2] ? speak: [NSString stringWithFormat:@"%@我为你找到%ld位相关联系人。如无需选择，请“##取消##”", speak, (unsigned long)memberArray.count];
            XZOptionMemberParam *param = [[XZOptionMemberParam alloc] init];
            param.speakContent = speak;
            param.showContent = info;
            param.members = memberArray;
            [self.delegate needChooseFormOptionMembers:param block:block];
        }
    }
}
- (BOOL)checkContactAvaiable:(NSString *)action {
    NSArray *array = [NSArray arrayWithObjects:kBUnitIntent_LOOKUPPERSON,kBUnitIntent_CALL,kBUnitIntent_SENDMESSAGE,kBUnitIntent_SENDIMMESSAGE, nil];
    if(![XZCore sharedInstance].privilege.hasAddressBookAuth && [array containsObject:action]){
        //没有通讯录权限
        [self needSpeakContent:kXZContactsUnavailable];
        [self needResetUnitDialogueState];
        [self needStartWakeup];
        return NO;
    }
    array = [NSArray arrayWithObjects:kBUnitIntent_LOOKUPPERSON,kBUnitIntent_CALL,kBUnitIntent_SENDMESSAGE,kBUnitIntent_CREATEFLOW,kBUnitIntent_SENDIMMESSAGE, nil];
    if ([XZMainProjectBridge contactsIsUpdating]) {
        /*
         离线通讯录 未下载完成时,不能使用 发协同 、查协同、找人、打电话、发短信功能。请假、播报今日安排、查报表、查进行中的报销流程、查文档、查公告、打开应用场景可以正常使用。
         */
        if ([array containsObject:action]) {
            [self needSpeakContent:kXZContactsDowloading];
            [self needResetUnitDialogueState];
            [self needStartWakeup];
            return NO;
        }
    }
    return YES;
}

- (void)needAnalysisText:(NSString *)text {
    [self handleTextWithUnit:text];
}


/*退出*/
- (BOOL)xzhandleFoQuit:(BUnitResult *)dic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(needClose)]) {
        [self.delegate needClose];
    }
    return NO;
}

/*时间安排*/
- (BOOL)xzhandleForSchedule:(BUnitResult *)dic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(needGetTodayArrange)]) {
        [self.delegate needGetTodayArrange];
    }
    return NO;
}
/*发请假单*/
- (BOOL)xzhandleForLeave:(BUnitResult *)result{
    [self showSearchTitleInfo:@"请假"];
    
    NSString *successKey = @"checkLeaveSucess";
    NSString *msgKey = @"checkLeaveMsg";
    if (self.currentResult[successKey]) {
        BOOL success = [self.currentResult[successKey] boolValue];
        if (success) {
            [self handleLeave:result];
        }
        else {
            [self needSpeakContent:self.currentResult[msgKey]];
            [self needResetUnitDialogueState];
        }
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(needCheckLeaveForm:)]) {
        //优化下 第一次请求
        [self.delegate needCheckLeaveForm:^(BOOL success,NSString *msg) {
            [weakSelf.currentResult setObject:[NSNumber numberWithBool:success] forKey:successKey];
            if (msg) {
                [weakSelf.currentResult setObject:msg forKey:msgKey];
            }
            if (success) {
                [weakSelf handleLeave:result];
            }
            else {
                [weakSelf needSpeakContent:msg];
                [weakSelf needResetUnitDialogueState];
            }
        }];
    }
   
    return NO;
}

- (void)handleLeave:(BUnitResult *)result {
    //请假事由判断
    NSString *actionId = result.intentId;
    NSDictionary *info = result.infoDict;

    if ([result isEnd]) {
        if (!self.currentLeaveModel) {
            self.currentLeaveModel = [[XZLeaveModel alloc] init];
            self.currentLeaveModel.leaveReason = result.currentText;
        }
        [self showUnitSay:result];
        [self LeaveFinishWithInfo:info];
    }
    else {
        if (!self.currentLeaveModel) {
            self.currentLeaveModel = [[XZLeaveModel alloc] init];
        }
        if([actionId isEqualToString:@"leave_user_leave_type_clarify"]) {
            [self showUnitSay:result];
            //请假澄清请假类型
            [self showLeaveTypes];
        }
        else {
            self.currentLeaveTypeModel.canOperate = NO;
            self.currentLeaveTypeModel.selectType = info[@"user_leave_type"];
            [self showUnitSay:result];
        }
        [self needContinueRecognize];
    }
    [self needHideMemberView];
}

/*查人员*/
- (BOOL)xzhandleForSearchPerson:(BUnitResult *)result {
    NSDictionary *info = result.infoDict;
    NSString *userName = info[kBUnitIntent_UserName];
    if ([NSString isNull:userName]) {
        userName = info[kBUnitIntent_UserPerson];
    }
    __weak typeof(self) weakSelf = self;
    SmartMembersBlock membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
        if (!cancel) {
            if (members.count >0) {
                CMPOfflineContactMember *member = [members firstObject];
                [weakSelf showMemberCard:member showOK:YES];
                [weakSelf needResetUnitDialogueState];
                [weakSelf needHideMemberView];
                [weakSelf needStartWakeup];
            }
            else {
//                [weakSelf.delegate needAnswerMemberIsShow:NO isSelect:NO];
                [weakSelf needResetUnitDialogueState];
                [weakSelf needHideMemberView];
                [weakSelf needStartWakeup];

            }
            
        }
    };
    self.membersBlock = membersBlock;
    if ([NSString isNull:userName]) {
        [self showSearchTitleInfo:@"查人员"];
        [self needSpeakContent:@"请问你要找谁？ 比如“##小明##”。"];
        [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        return YES;
    }
    else {
        [self showSearchTitleInfo:[NSString stringWithFormat:@"查找%@",userName]];
        [self chooseMemberWithUnitResult:result speakInfo:@"" block:membersBlock];
        return NO;
    }
}
/*打电话*/
- (BOOL)xzhandleForCall:(BUnitResult *)result {
    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        [self showSearchTitleInfo:@"打电话"];
        [self needSpeakContent:@"对不起，该设备不支持打电话"];
        [self needResetUnitDialogueState];
        return NO;
    }
    if ([self.currentCellModel isKindOfClass:[XZMemberModel class]]) {
        //特殊处理人员卡片
        XZMemberModel *model =  (XZMemberModel *)self.currentCellModel;
        NSString *actionTarget = result.intentTarget;
        if ([actionTarget isEqualToString:kBUnitIntent_UserName]||
            [actionTarget isEqualToString:kBUnitIntent_UserPerson]) {
            if (model.canOperate && model.hasPhone) {
                [model call];
                self.currentCellModel = nil;
                [self needResetUnitDialogueState];
                [self needHideMemberView];
                return NO;
            }
        }
        model.canOperate = NO;
        self.currentCellModel = nil;
    }
    
    NSDictionary *info = result.infoDict;
    NSString *userName = info[kBUnitIntent_UserName];
    if ([NSString isNull:userName]) {
        userName = info[kBUnitIntent_UserPerson];
    }
    __weak typeof(self) weakSelf = self;
    SmartMembersBlock membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
        if (!cancel) {
            if (members.count >0) {
                CMPOfflineContactMember *member = [members firstObject];
                NSString *name = [NSString stringWithFormat:@"%@%@",member.department,member.name];
                if (![member mobilePhoneAvailable]) {
                    [weakSelf needSpeakContent:[NSString stringWithFormat:@"很抱歉，我没能找到%@的手机号。", name]];
                    [weakSelf showMemberCard:member showOK:NO];
                }
                else {
                    [weakSelf needSpeakContent:@"好的"];
                    if (weakSelf.delegate && [self.delegate respondsToSelector:@selector(needCallPhone:)]) {
                        [weakSelf.delegate needCallPhone:member.mobilePhone];
                    }
                }
            }
            [weakSelf needResetUnitDialogueState];
            [weakSelf needHideMemberView];

        }
    };
    
    self.membersBlock = membersBlock;
    if ([NSString isNull:userName]) {
        [self showSearchTitleInfo:@"打电话"];
        [self needSpeakContent:@"好的，请问你希望和谁通话？ 比如“##小明##”。"];
        [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        return YES;
    }
    else {
        [self showSearchTitleInfo:[NSString stringWithFormat:@"打电话给%@",userName]];
        [self chooseMemberWithUnitResult:result speakInfo:@"" block:membersBlock];
        return NO;
    }
}

/*发短信*/
- (BOOL)xzhandleForSendSMS:(BUnitResult *)result {
    if (![self.delegate canSendSMS]) {
        [self showSearchTitleInfo:@"发短信"];
        [self needSpeakContent:@"对不起，该设备不支持发短信"];
        [self needResetUnitDialogueState];
        return NO;
    }
    if ([self.currentCellModel isKindOfClass:[XZMemberModel class]]) {
        XZMemberModel *model =  (XZMemberModel *)self.currentCellModel;
        //特殊处理人员卡片
        NSString *actionTarget = result.intentTarget;
        if ([actionTarget isEqualToString:kBUnitIntent_UserName]||
            [actionTarget isEqualToString:kBUnitIntent_UserPerson]) {
            if (model.canOperate  && model.hasPhone) {
                [model sendMessage];
                self.currentCellModel = nil;
                [self needResetUnitDialogueState];
                [self needHideMemberView];
                return NO;
            }
        }
        model.canOperate = NO;
        self.currentCellModel = nil;
    }
    NSDictionary *info = result.infoDict;
    NSString *userName = info[kBUnitIntent_UserName];
    if ([NSString isNull:userName]) {
        userName = info[kBUnitIntent_UserPerson];
    }
    __weak typeof(self) weakSelf = self;

    SmartMembersBlock membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
        if (!cancel) {
            if (members.count > 0) {
                CMPOfflineContactMember *member = [members firstObject];
                if (![member mobilePhoneAvailable]) {
                    [weakSelf needSpeakContent:[NSString stringWithFormat:@"很抱歉，我没能找到%@的手机号。", member.name]];
                    [weakSelf showMemberCard:member showOK:NO];
                }
                else {
                    [weakSelf needSpeakContent:@"好的"];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needSendSMS:)]) {
                        [weakSelf.delegate needSendSMS:member.mobilePhone];
                    }
                }
            }
            [weakSelf needResetUnitDialogueState];
            [weakSelf needHideMemberView];
        }
    };
    self.membersBlock = membersBlock;
    if ([NSString isNull:userName]) {
        [self showSearchTitleInfo:@"发短信"];
        [self needSpeakContent:@"好的，请问你希望发短信给谁？ 比如“##小明##”。"];
        [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        return YES;
    }
    else {
        [self showSearchTitleInfo:[NSString stringWithFormat:@"发短信给%@",userName]];
        [self chooseMemberWithUnitResult:result speakInfo:@"" block:membersBlock];
        return NO;
    }
}

/*发致信消息*/
- (BOOL)xzhandleForSendIMMsg:(BUnitResult *)result {
    if ([[XZCore sharedInstance] isXiaozVersionLater2_2]) {
        NSDictionary *info = result.infoDict;
        NSString *userName = info[kBUnitIntent_UserPerson];//人员
        NSString *content = info[kBUnit_Key_Title];//内容
        CMPOfflineContactMember *currentMember = nil;
        if (self.currentMember && !userName) {
            currentMember = self.currentMember;
            self.currentMember = nil;
        }
        if (!self.sendIMMsgintent) {
            self.sendIMMsgintent =  [[XZSendIMMsgIntent alloc]init];
            self.sendIMMsgintent.delegate = self;
        }
        [self.sendIMMsgintent handleMember:currentMember memberName:userName content:content];
        return NO;
    }
    //老版本
    
    if ([self.currentCellModel isKindOfClass:[XZMemberModel class]]) {
        XZMemberModel *model =  (XZMemberModel *)self.currentCellModel;
        //特殊处理人员卡片
        NSString *actionTarget = result.intentTarget;
        if ([actionTarget isEqualToString:kBUnitIntent_UserName]||
            [actionTarget isEqualToString:kBUnitIntent_UserPerson]) {
            if (model.canOperate && model.canIM) {
                [model sendIMMessage];
                self.currentCellModel = nil;
                [self needResetUnitDialogueState];
                return NO;
            }
        }
        model.canOperate = NO;
        self.currentCellModel = nil;
    }
    NSDictionary *info = result.infoDict;
    NSString *userName = info[kBUnitIntent_UserName];
    if ([NSString isNull:userName]) {
        userName = info[kBUnitIntent_UserPerson];
    }
    __weak typeof(self) weakSelf = self;
    SmartMembersBlock membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
        if (!cancel) {
            if (members.count > 0) {
                [weakSelf needResetUnitDialogueState];
                [weakSelf needHideMemberView];
                CMPOfflineContactMember *member = [members firstObject];
                if ([member.orgID isEqualToString:[XZCore userID]]) {
                    [weakSelf needSpeakContent:@"不能给自己发消息"];
                }
                else {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needSendIMMsg:content:)]) {
                        [weakSelf.delegate needSendIMMsg:member content:nil];
                    }
                }
            }
            [weakSelf needResetUnitDialogueState];
            [weakSelf needHideMemberView];
        }
    };
    self.membersBlock = membersBlock;
    if ([NSString isNull:userName]) {
        [self showSearchTitleInfo:@"发信息"];
        [self needSpeakContent:@"好的，请问你希望发信息给谁？ 比如“##小明##”。"];
        [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        return YES;
    }
    else {
        [self showSearchTitleInfo:[NSString stringWithFormat:@"发信息给%@",userName]];
        [self chooseMemberWithUnitResult:result speakInfo:@"" block:membersBlock];
        return NO;
    }
}
#pragma mark send IM Message start
- (void)intentSendIMMsg:(CMPOfflineContactMember *)member content:(NSString *)content {
    [self needResetUnitDialogueState];
    if (self.delegate && [self.delegate respondsToSelector:@selector(needSendIMMsg:content:)]) {
        [self.delegate needSendIMMsg:member content:content];
    }
}

- (void)intentSendIMMsgClarifyMembers:(XZOptionMemberParam *)param {
    __weak typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(needChooseFormOptionMembers:block:)]) {
        [self.delegate needChooseFormOptionMembers:param block:^(NSArray *members, BOOL cancel, NSString *extData) {
            if (!cancel) {
                [weakSelf needHideMemberView];
                CMPOfflineContactMember *member = [members firstObject];
                if ([member.orgID isEqualToString:[XZCore userID]]) {
                    [weakSelf needSpeakContent:@"不能给自己发消息"];
                    [weakSelf resetSmartEngine];
                }
                else {
                    [weakSelf.sendIMMsgintent handleMember:member memberName:nil content:nil];
                }
            }
        }];
        [self needContinueRecognize];
    }
}

- (void)intentSendIMMsgClarifyText:(NSString *)text {
    [self needSpeakContent:text];
    [self needContinueRecognize];
}

- (void)intentSendIMMsgShowMember:(BOOL)show {
    if (show) {
        __weak typeof(self) weakSelf = self;
        [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        self.membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
            if (!cancel) {
                [weakSelf needHideMemberView];
                CMPOfflineContactMember *member = [members firstObject];
                if ([member.orgID isEqualToString:[XZCore userID]]) {
                    [weakSelf needSpeakContent:@"不能给自己发消息"];
                    [weakSelf resetSmartEngine];
                }
                else {
                    [weakSelf.sendIMMsgintent handleMember:member memberName:nil content:nil];
                }
            }
        };
    }
    else {
        self.membersBlock = nil;
        [self.delegate needAnswerShortText];
    }
}

#pragma mark send IM Message end


/*帮助*/
- (BOOL)xzhandleForHelp:(BUnitResult *)dic{
    if (self.delegate && [self.delegate respondsToSelector:@selector(needShowHelpInfo)]) {
        [self.delegate needShowHelpInfo];
    }
    [self needStartWakeup];
    return NO;
}

/*同意*/
- (BOOL)xzhandleForAgree:(BUnitResult *)result {
    //同意 发送、、、、、、
    if ([self.currentCellModel isKindOfClass:[XZLeaveModel class]]) {
        //请假单 发送
        XZLeaveModel *model =  (XZLeaveModel *)self.currentCellModel;
        [model sendLeave];
    }
    else if([self isInSearchSchedule]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needShowSchedule:)]) {
            SPScheduleHelper *schedule = [self.currentResult objectForKey:COMMOND_VALUE_TYPE_SCHEDULE];
            schedule.noReadPlan = NO;
            [self.delegate needShowSchedule:schedule];
            self.currentNode  = nil;
        }
    }
    else {
        NSString *say = @"很抱歉，我没有明白，你能再重复一下吗？";
        [self needSpeakContent:say];
    }
    self.currentCellModel = nil;
    [self needStartWakeup];

    return NO;
}

/*不同意*/
- (BOOL)xzhandleForDisagree:(BUnitResult *)result {
    //不同意 取消、、、、、、
    if ([self.currentCellModel isKindOfClass:[XZLeaveModel class]]) {
        //请假单 取消
        XZLeaveModel *model =  (XZLeaveModel *)self.currentCellModel;
        [model cancelLeave];
    }
    else if ([self.currentCellModel isKindOfClass:[XZOptionMemberModel class]]) {
        //重名人员 取消
        XZOptionMemberModel *model =  (XZOptionMemberModel *)self.currentCellModel;
        if( model.canOperate && model.clickTextBlock) {
            model.clickTextBlock(@"");
        }
        model.canOperate = NO;
        self.isClarifyMembers = NO;
    }
    else if ([self.currentCellModel isKindOfClass:[XZLeaveErrorModel class]]) {
        //请假报错 取消
        XZLeaveErrorModel *model =  (XZLeaveErrorModel *)self.currentCellModel;
        [model cancel];
    }
    else if([self isInSearchSchedule]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needShowSchedule:)]) {
            SPScheduleHelper *schedule = [self.currentResult objectForKey:COMMOND_VALUE_TYPE_SCHEDULE];
            schedule.noReadPlan = YES;
            [self.delegate needShowSchedule:schedule];
            self.currentNode  = nil;
        }
    }
    else {
        NSString *say = @"好的";
        [self needSpeakContent:say];
    }
    self.currentCellModel = nil;
    [self needHideMemberView];
    [self needResetUnitDialogueState];
    [self needStartWakeup];
    return YES;
}
/*修改*/
- (BOOL)xzhandleForModify:(BUnitResult *)result {
    //修改、、、、
    if ([self.currentCellModel isKindOfClass:[XZLeaveModel class]]) {
        //请假单修改
        XZLeaveModel *model =  (XZLeaveModel *)self.currentCellModel;
        [model modifyLeave];
    }
    else if ([self.currentCellModel isKindOfClass:[XZLeaveErrorModel class]]) {
        //请假单发送出错后的打开请假单操作
        XZLeaveErrorModel *model =  (XZLeaveErrorModel *)self.currentCellModel;
        [model showLeave];
    }
    else {
        NSString *say = @"很抱歉，我没有明白，你能再重复一下吗？";
        [self needSpeakContent:say];
    }
    self.currentCellModel = nil;
    return NO;
}

/*第几位*/
- (BOOL)xzhandleForIndex:(BUnitResult *)result {
    NSDictionary *info = result.infoDict;
    BOOL operate = NO;
    if (self.isClarifyMembers/*[self.currentCellModel isKindOfClass:[XZOptionMemberModel class]]*/) {
        //第几位 重名人员选择第几个
        self.isClarifyMembers = NO;
        XZOptionMemberModel *model =  (XZOptionMemberModel *)self.currentCellModel;
        if (model.canOperate) {
            if (model.didChoosedMembersBlock) {
                NSString *user_select_number = info[@"user_select_number"];
                NSInteger number = [SPTools getOptionNumber:user_select_number]-1;
                NSArray *memberArray = model.param.members;
                if (number >=0  && number < memberArray.count) {
                    self.currentCellModel = nil;
                    model.didChoosedMembersBlock(@[memberArray[number]], NO);
                    model.canOperate = NO;
                    operate = YES;
                }
            }
        }
    }
    else if ([self.currentCellModel isKindOfClass:[XZTextModel class]]){
        XZTextModel *model = (XZTextModel *) self.currentCellModel;
        NSString *user_select_number = info[@"user_select_number"];
        NSInteger number = [SPTools getOptionNumber:user_select_number]-1;
        operate = [model canClickAtIndex:number];
        if (operate) {
            [self needSpeakContent:@"好的"];
            if ([self isInSearchColl]) {
                [model clickAtIndex:number];
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [model clickAtIndex:number];
                });
            }
        }
    }
    if (!operate) {
        NSString *say = @"很抱歉，我没有明白，你能再重复一下吗？";
        [self needSpeakContent:say];
    }
    return NO;
}

/*加载、打开 更多*/
- (BOOL)xzhandleForMore:(BUnitResult *)result {
    BOOL operate = NO;
    if ([self.currentCellModel isKindOfClass:[XZTextModel class]]){
        XZTextModel *model = (XZTextModel *) self.currentCellModel;
        if (model.showMoreBtn) {
            operate = YES;
            [self needSpeakContent:@"好的"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (model.moreBtnClickAction) {
                    model.moreBtnClickAction(model);
                }
            });
        }
    }
    if (!operate) {
        NSString *say = @"很抱歉，我没有明白，你能再重复一下吗？";
        [self needSpeakContent:say];
    }
    return NO;
}
/*打开*/
- (BOOL)xzhandleForOpen:(BUnitResult *)result {
    [self showSearchTitleInfo:@"打开应用"];
    [self showUnitSay:result];
    return YES;
}

/*打开M3标准应用*/
- (NSDictionary *)m3AppInfo {
    if (!_m3AppInfo) {
        NSString *aPath = [[NSBundle mainBundle] pathForResource:XZ_NAME(@"M3AppInfo") ofType:@"plist"];
        _m3AppInfo = [[NSDictionary alloc] initWithContentsOfFile:aPath];
    }
    return _m3AppInfo;
}
- (BOOL)isOpenM3StandardApp:(NSString *)action {
    if ([self.m3AppInfo.allKeys containsObject:action]) {
        return YES;
    }
    return NO;
}
- (BOOL)xzopenM3StandardApp:(BUnitResult *)result {
    NSString *action = result.intentName;
    NSDictionary *info = [self.m3AppInfo objectForKey:action];
    [self showSearchTitleInfo:info[@"info"]];
    BOOL value = [self needOpenM3AppWithAppId:info[@"appId"] result:^(BOOL sucess) {
        [self needSpeakContent:sucess ?result.say:kIntentUnavailable];
    }];
    return value;
}


/*查询*/
- (BOOL)xzhandleForSearch:(BUnitResult *)result {
    if (result.isEnd) {
        [self needResetUnitDialogueState];
        NSDictionary *info = result.infoDict;
        NSString *appName = info[@"user_search_app"];
        if ([NSString isNull:appName]) {
            appName = info[@"user_all_name"];
        }
        if (![NSString isNull:appName]) {
            NSString *resultSting = [NSString stringWithFormat:@"查找%@",appName];
            [self needAnalysisText:resultSting];
        }
        return NO;
    }
    else {
        [self needSpeakContent:@"好的，请问你希望查找什么？ 比如：查文档、查公告、查协同、查人员、查找张三"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needShoWOrHideSearchType:)]) {
            [self.delegate needShoWOrHideSearchType:YES];
        }
    }
    return YES;
}
/*创建协同*/
- (BOOL)xzhandleForCreateColl:(BUnitResult *)result {
    [self showSearchTitleInfo:@"发起协同"];
    if (![XZCore sharedInstance].privilege.hasColNewAuth) {
        [self needSpeakContent:@"对不起，你没有新建协同权限 ，请联系管理员进行授权。"];
        [self stepDidEnd:YES];
        return NO;
    }
    [self createColl];
    return YES;
}

/*查协同*/
- (BOOL)xzhandleForSearchColl:(BUnitResult *)result {
    NSString *actionTarget = result.intentTarget;
    NSDictionary *info = result.infoDict;
    if ([actionTarget isEqualToString:kBUnitIntent_UserName]||
        [actionTarget isEqualToString:kBUnitIntent_UserPerson]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
            [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        }
    }
    [_currentCellModel disableOperate];
    if (result.isEnd) {
        NSString *sender = info[kBUnitIntent_UserName];
        if ([NSString isNull:sender]) {
            sender = info[kBUnitIntent_UserPerson];
        }
        NSString *state = [self collStateWithString:info[@"user_flow_state"]];
        self.currentResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:state,@"state", nil];
    
        if ([NSString isNull:sender]) {
            //没有发起人，说明是按标题查找
            
            NSDictionary *info = result.infoDict;
            NSString *title = info[kBUnit_Key_Title];
            if ([NSString isNull:title]) {
                [self needSpeakContent:@"好的，请你告知协同标题"];
                self.useUnit = NO;
            }
            else {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:title forKey:@"subject"];
                [param setObject:state forKey:@"state"];
                [self.delegate needSearchCollWithParam:param];
            }
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(needSearchCollWithParam:)]) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                if (![NSString isNull:sender]) {
                    [param setObject:sender forKey:@"startMemberName"];
                    [param setObject:state forKey:@"state"];
                    [self.delegate needSearchCollWithParam:param];
                    self.useUnit = YES;
                }
            }
            return NO;
        }
    }
    else {
        if ([NSString isNull:info[@"user_flow_state"] ]) {
            NSString *state = [self collStateWithString:info[@"user_flow_state"]];
            self.currentResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:state,@"state", nil];
        }
        [self showUnitSay:result];
    }
    return YES;
}

/*查公告*/
- (BOOL)xzhandleForSearchBul:(BUnitResult *)result {
    if (result.isEnd) {
        NSDictionary *info = result.infoDict;
        NSString *title = info[kBUnit_Key_Title];
        if ([NSString isNull:title]) {
            [self showSearchTitleInfo:@"查公告"];
            self.useUnit = NO;
            [self needSpeakContent:@"好的，请你告知公告标题"];
            return YES;
        }
        if([self unavailableTitle:title]) {
            [self needSpeakContent:@"好的，请你告知公告标题"];
            return YES;
        }
        else {
            [self.delegate needSearchBul:title];
            return NO;
        }
    }
    else {
        [self showUnitSay:result];
        return YES;
    }
    
}
/*查文档*/
- (BOOL)xzhandleForSearchDoc:(BUnitResult *)result {
    if (result.isEnd) {
        NSDictionary *info = result.infoDict;
        NSString *title = info[kBUnit_Key_Title];
        if ([NSString isNull:title]) {
            [self showSearchTitleInfo:@"查文档"];
            self.useUnit = NO;
            [self needSpeakContent:@"好的，请你告知文档标题"];
            return YES;
        }
        if([self unavailableTitle:title]) {
            [self needSpeakContent:@"好的，请你告知文档标题"];
            return YES;
        }
        else {
            [self.delegate needSearchDoc:title];
            return NO;
        }
    }
    else {
        [self showUnitSay:result];
        return YES;
    }
    
}

/*查找报销单*/
- (BOOL)xzhandleForSearchExpense:(BUnitResult *)result {
    [self showSearchTitleInfo:@"查找报销单"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"报销" forKey:@"subject"];
    [param setObject:@"20" forKey:@"bodyType"];
    [param setObject:@"0" forKey:@"workflowState"];
    [param setObject:@"2" forKey:@"state"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(needSearchExpenseWithParam:)]) {
        [self.delegate needSearchExpenseWithParam:param];
    }
    self.useUnit = YES;
    return YES;
}
/*查查报表*/
- (BOOL)xzhandleForSearchStatistics:(BUnitResult *)result {
    if (result.isEnd) {
        NSDictionary *info = result.infoDict;
        NSString *title = info[kBUnit_Key_Title];
        if ([NSString isNull:title]) {
            [self showSearchTitleInfo:@"查找报表"];
            self.useUnit = NO;
            [self needSpeakContent:@"好的，请你告知报表标题"];
            return YES;
        }
        if([self unavailableTitle:title]) {
            [self needSpeakContent:@"好的，请你告知报表标题"];
            return YES;
        }
        else {
            [self.delegate needSearchStatistics:[self handleTitle:title]];
            return NO;
        }
    }
    else {
        [self showUnitSay:result];
        return YES;
    }
    
}

/*查新闻*/
- (BOOL)xzhandleForSearchNews:(BUnitResult *)result {
    if (result.isEnd) {
        NSDictionary *info = result.infoDict;
        NSString *title = info[kBUnit_Key_Title];
        if([self unavailableTitle:title]) {
            [self needSpeakContent:@"好的，请你告知新闻标题"];
            return YES;
        }
        else {
            [self.delegate needSearchNews:[self handleTitle:title]];
            return NO;
        }
    }
    else {
        [self showUnitSay:result];
        return YES;
    }
}


/*新建日程*/
- (BOOL)xzhandleForCreateSchedule:(BUnitResult *)result {
    if(![XZCore sharedInstance].privilege.hasCalEventAuth) {
        [self needResetUnitDialogueState];
        [self needSpeakContent:@"对不起，你没有新建日程权限 ，请联系管理员进行授权。"];
        return NO;
    }
    if (result.isEnd ) {
        if ([self.currentCellModel isKindOfClass:[XZTextModel class]]) {
            XZTextModel *model = (XZTextModel *)self.currentCellModel;
            [model disableTapText];
        }
        self.currentCreateModel = [[XZCreateScheduleModel alloc] initWithUnitResult:result.infoDict];
        self.useUnit = NO;
        [self startCommond:@"createSchedule" index:@"1"];
    }
    else {
        [self showUnitSay:result];
    }
    return YES;
}

- (NSString *)handleUnitDate:(NSString *)unitDate {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formt = [[NSDateFormatter alloc] init];
    formt.timeZone = [NSTimeZone systemTimeZone];
    [formt setDateFormat:@"yyyy-MM-dd"];
    NSString *current = [formt stringFromDate:currentDate];
    formt = nil;
    if ([unitDate rangeOfString:@"-"].location == NSNotFound) {
        //只有时间，没有日期 如05:00:00
        return current;
    }
    unitDate = [unitDate replaceCharacter:@"-00" withString:@"-01"];
    NSString *uDate = unitDate;
    if (unitDate.length >10) {
        uDate = [unitDate substringToIndex:10];
    }
    NSInteger u = [[uDate replaceCharacter:@"-" withString:@""] integerValue];
    NSInteger c = [[current replaceCharacter:@"-" withString:@""] integerValue];
    if (u > c ) {
        return @"2";
    }
    //最开头的h时间
    NSInteger before = 20000101;
    if (before > u ) {
        return @"0";
    }
    return uDate;
}

/*智能消息*/
- (BOOL)xzhandleForSearchSmartMsg:(BUnitResult *)result {
    if (result.isEnd) {
        NSDictionary *info = result.infoDict;
        NSString *dateStr = info[@"user_date"] ? info[@"user_date"]:info[@"user_time"];
        if ([[XZCore sharedInstance] isXiaozVersionLater3_1]) {
            //3.1返回的时间是服务器端没有处理的原始时间
            dateStr = [XZDateUtils obtainFormatDateTime:dateStr hasTime:NO interval:NO];
        }
        NSString *date = [self handleUnitDate:dateStr];
        if ([date isEqualToString:@"0"]) {
            [self needSpeakContent:@"亲，我们当时还不认识哦"];
        }
        else if ([date isEqualToString:@"2"]) {
            [self needSpeakContent:@"亲，时间还没到哦"];
        }
        else {
            [self.delegate needSearchSmartMsg:dateStr];
        }
    }
    else {
        [self showUnitSay:result];
    }
    return NO;
}

- (BOOL)xzhandleQARssult:(BUnitResult *)result {
    self.useUnit = YES;
    [self showUnitSay:result];
    [self needStartWakeup];
    return NO;
}



- (BOOL)isCreateForm:(NSString *)actionId {
    NSDictionary *commondStepDic = [[XZCore sharedInstance] formJson];
    if (!commondStepDic) {
        return NO;
    }
    if ([[commondStepDic allKeys] containsObject:actionId]) {
        return YES;
    }
    return NO;
}

- (BOOL)isQAAction:(NSString *)action {
    if ([NSString isNull:action]) {
        return NO;
    }
    if ([action isEqualToString:kFAQ_OPEN]||[action isEqualToString:kFAQ_PROCESS] || [action isEqualToString:kFAQ_OPENTEMPLAT]) {
        return NO;
    }
    if ([action rangeOfString:@"FAQ_"].location == NSNotFound) {
        return NO;
    }
    return YES;
}

- (BOOL)xzhandleQA:(BUnitResult *)result {
    NSString *action = result.intentName;
    if ([action rangeOfString:kFAQ_KB].location != NSNotFound) {
        if ([[XZCore sharedInstance].qaPermissions containsObject:action]) {
            //智能QA有权限
            NSString *say = result.say;
            if (![NSString isNull:say]) {
                NSString *name = [XZCore userName];
                say = [say replaceCharacter:@"<USER-NAME>" withString:name];
                say = [say replaceCharacter:@"<USER-PERSON>" withString:name];
                say = [say replaceCharacter:@"&nbsp;" withString:@" "];
            }
            [self.delegate needShowQAAnswer:say];
        }
        else {
            //智能QA 当前action 不在权限内，从QAExtra 中获取答案  但是没权限
            NSArray *QAExtraArray = result.QAExtra;
            CGFloat confidence = 0.0f;
            NSString *say = nil;
            for (BUnitQAExtra *extra in QAExtraArray) {
                NSString *eAction = extra.intentName;
                if (![NSString isNull:eAction] &&[[XZCore sharedInstance].qaPermissions containsObject:eAction]) {
                    CGFloat eConfidence = [extra.confidence floatValue];
                    if (confidence < eConfidence) {
                        confidence = eConfidence;
                        say = extra.say;
                    }
                }
            }
            if (confidence > 0.0) {
                [self.delegate needShowQAAnswer:say];
            }
            else {
                [self needSpeakContent:kBUnitErrorInfo];
            }
        }
    }
    else {
        //一般QA
        NSString *say = result.say;
        if (![NSString isNull:say]) {
            NSString *name = [XZCore userName];
            say = [say replaceCharacter:@"<USER-NAME>" withString:name];
            say = [say replaceCharacter:@"<USER-PERSON>" withString:name];
            say = [say replaceCharacter:@"&nbsp;" withString:@" "];
        }
        [self needSpeakContent:say];
    }
    return NO;
}

- (NSString *)relatedTitle {
    if ([self isInSearchDoc]) {
        return @"相关文档";
    }
    else if ([self isInSearchBul]) {
        return @"相关公告";
    }
    else if ([self isInSearchColl]) {
        return @"相关协同";
    }
    else if ([self isInSearchStatistics]) {
        return @"相关报表";
    }
    else if ([self isInSearchNews]) {
        return @"相关新闻";
    }
    return @"";
}


//处理意图、自定义意图
- (BOOL)xzhandleAppIntent:(BUnitResult *)result {
    NSString *action = result.intentName;
    if (self.intent && (![self.intent.intentName isEqualToString:action] || self.intent.isEnd ) ) {
        //意图不一致  或者之前的意图已经结束了
        [self needShowCancelCardInHistory];
        self.intent = nil;
        self.cancelBlock = nil;
        self.sendBlock = nil;
        self.modifyBlock = nil;
    }
    
    if (!self.intent) {
        XZAppIntent *intent = [XZAppIntent IntentWithName:action];
        self.intent = intent;
        __weak typeof(XZAppIntent) *weakIntent = self.intent;
        __weak typeof(self) weakSelf = self;
        if (self.delegate && [self.delegate respondsToSelector:@selector(needHandleIntent:)]) {
            [self.delegate needHandleIntent:_intent];
        }
        SmartMembersBlock membersBlock = ^(NSArray *result, BOOL cancel,NSString *extData) {
            if (result) {
                BOOL needAnalysis = weakIntent.useUnit;
                [weakIntent handleMembers:result target:extData next:!needAnalysis];
                if (needAnalysis) {
                    CMPOfflineContactMember *member = [result firstObject];
                    [weakSelf needAnalysisText:[SPTools memberNameWithName:member.name]];
                }
            }
        };
        self.membersBlock = membersBlock;
        if ([self.intent isCreateIntent]) {
            self.sendBlock = ^{
                if ([weakIntent checkParams_url]) {
                    weakIntent.checkParamsBlock(weakIntent);
                }
                else {
                    weakIntent.createBlock(weakIntent);
                }
            };
        }
        self.modifyBlock = ^{
            if (weakIntent.openBlock) {
                weakIntent.openBlock(weakIntent);
            }
        };
        self.cancelBlock = ^{
            if (weakIntent.cancelBlock) {
                weakIntent.cancelBlock(weakIntent);
            }
        };
    }
    _intent.intentStepTarget = result.say;
    if (self.currentMember) {
        [_intent handleRelatePreIntent:self.currentMember];
        self.currentMember = nil;
    }

    [_intent handleUnitResult:result];
    self.currentMember = nil;
    if (_intent.isEnd || result.isEnd) {
        [self needResetUnitDialogueState];
        return NO;
    }
    return YES;
}

//打开应用
- (BOOL)xzhandleOpenApp:(BUnitResult *)result {
    self.currentMember = nil;
    
    if (result.optionalOpenIntentList.count > 0) {
        //多个意图需要选择
        NSMutableArray *intentList = [[NSMutableArray alloc] init];
        for (BUnitOptionalOpenIntent *obj in result.optionalOpenIntentList) {
            XZOpenAppIntent *intent = [[XZOpenAppIntent alloc] initWithJsonStr:obj.say];
            intent.appName = obj.displayName;
            if ([[XZCore sharedInstance].intentPrivilege isAvailableIntentName:intent.intentName]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(needHandleIntent:)]) {
                    [self.delegate needHandleIntent:intent];
                }
                [intentList addObject:intent];
            }
        }
        if (intentList.count == 0) {
            [self needSpeakContent:kIntentUnavailable];
            [self needResetUnitDialogueState];
            [self needStartWakeup];
        }
        else if (intentList.count == 1) {
            XZOpenAppIntent *intent = intentList[0];
            intent.openBlock(intent);
            [self needResetUnitDialogueState];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(needShowOptionIntents:)]) {
                [self.delegate needShowOptionIntents:intentList];
            }
        }
        return NO;
    }
    
    XZOpenAppIntent *intent = [[XZOpenAppIntent alloc] initWithJsonStr:result.say];
    if ([self filterUnitIntent:intent.intentName]) {
        return NO;//命令过滤掉了
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(needHandleIntent:)]) {
        [self.delegate needHandleIntent:intent];
    }
    intent.openBlock(intent);
    
    [self needResetUnitDialogueState];
    return NO;
}

- (BOOL)xzhandleAppFormIntent:(BUnitResult *)result {
    self.currentMember = nil;
//    NSDictionary *info = result.infoDict;
//    NSString *faqResult = result.say;
  //  { "fileName":"FAQ_PROCESS_FILL_BLANKS_appId_reference","intentName":"APP_appId_reference_C" }
    //todo
    return YES;
}

#pragma mark   Handle Search  Result

- (BOOL)isInDialogue {
    return self.intentState != XZIntentState_Normal;
}
- (NSArray *)localCommandForKey:(NSString *)key {
    if (!_localCommandDic) {
        NSString *path = [[NSBundle mainBundle] pathForResource:XZ_NAME(@"XZLocalCommand") ofType:@"plist"];
        _localCommandDic = [[NSDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    }
    return _localCommandDic[key];
}

#pragma mark 过滤器 start
/************************************************ 过滤器 start **************************************************/

//取消类：取消类：直接取消正在对话的操作，并回答"好的"；如果并没有正在对话的操作，反问"我现在什么都没有做哦"，就不继续监听用户语音。
- (BOOL)filterCancelWords:(NSString *)result {
    NSArray *cancelWords = [self localCommandForKey:@"CANCEL"];
    if ([cancelWords containsObject:result]) {
        if (self.cancelBlock) {
            self.cancelBlock();
            return YES;
        }
        if (self.intentState == XZIntentState_PWaiting ||
            self.intentState == XZIntentState_CWaiting||
            self.intentState == XZIntentState_LWaiting ||
            self.isClarifyMembers) {
            [self xzhandleForDisagree:nil];
        }
        [self needSpeakContent:[self isInDialogue]?@"好的":@"我现在什么都没有做哦"];
        [self needResetUnitDialogueState];//   多选人员 todo
        return YES;
    }
    return NO;
}

//离开类：如果正在进行对话意图的操作，需要反问"真的要离开吗？"，回答是的（确认类操作）则直接退出小致；如果没有其他对话意图，则直接回答"拜拜"，然后退出小致；
- (BOOL)filterLeaveWords:(NSString *)result {
    NSArray *leaveWords = [self localCommandForKey:@"QUIT"];
    if ([leaveWords containsObject:result]) {
        if (self.intent && [self.intent isCreateIntent]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(needShowCloseAlertView)]) {
                [self.delegate needShowCloseAlertView];
            }
            return YES;
        }
        [self needSpeakContent:@"拜拜"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needClose)]) {
            [self.delegate needClose];
        }
        return YES;
    }
    return NO;
}

//如果是正在进行对话意图操作，而流程还没有完的情况，反问"你想要查看什么"，此时取消正在进行的意图对话，等待用户新的意图指令，新的意图指令来了后切换意图；如果没有对话意图操作， 则还是反问"你想要查看什么"，等待新的指令
- (BOOL)filterSearchWords:(NSString *)result {
    return NO;
//    NSArray *searchWords = [self localCommandForKey:@"SEARCH"];
//    if ([searchWords containsObject:result]) {
//        [self needResetUnitDialogueState];
//        [self needSpeakContent:@"你想要查看什么"];
//        return YES;
//    }
//    return NO;
}
//过滤文本：发送
- (BOOL)filterSendWords:(NSString *)result {
    if ((self.intent && self.intent.isRequiredEnd) || !self.intent) {
        NSArray *sendWords = [self localCommandForKey:@"SEND"];
        if ([sendWords containsObject:result]) {
            if (self.sendBlock) {
                self.sendBlock();
                return YES;
            }
            [self needResetUnitDialogueState];
        }
    }
    return NO;
}
//过滤文本：修改 打开
- (BOOL)filterOpenWords:(NSString *)result {
  
    if ((self.intent && self.intent.isRequiredEnd) || !self.intent) {
        //!self.inten : 请假
        NSArray *openWords = [self localCommandForKey:@"OPEN"];
        if ([openWords containsObject:result]) {
            if (self.modifyBlock) {
                self.modifyBlock();
                return YES;
            }
//            else if (self.intentState == XZIntentState_Normal) {
//                [self needSpeakContent:@"你需要我为你打开什么?"];
//                return YES;
//            }
        }
    }
    return NO;
}
//过滤文本：第几个、第几位   用于重复人员选择
- (BOOL)filterIndexWords:(NSString *)result {
    if ([self.currentCellModel isKindOfClass:[XZOptionMemberModel class]]) {
        XZOptionMemberModel *aModel = (XZOptionMemberModel *)self.currentCellModel;
        NSInteger index = [XZDateUtils convertChineseNumberToIndexNumber:result];
        if (aModel.param.isMultipleSelection && index > 0) {
            //多选 不支持第几位选择
            if (self.delegate && [self.delegate respondsToSelector:@selector(needChooseFormOptionMembers:block:)]) {
                [self.delegate needChooseFormOptionMembers:aModel.param block:aModel.param.membersChoosedBlock];
            }
            return YES;
        }
        NSArray *memberArray = aModel.param.members;
        if (aModel.canOperate && index > 0 && index < memberArray.count +1) {
            aModel.didChoosedMembersBlock(@[memberArray[index-1]], NO);
            return YES;
        }
        return NO;
    }
    return NO;
}

//过滤文本：确认
- (BOOL)filterDetermineWords:(NSString *)result {
    if ([self.currentCellModel isKindOfClass:[XZOptionMemberModel class]]) {
        XZOptionMemberModel *aModel = (XZOptionMemberModel *)self.currentCellModel;
        if (aModel.param.isMultipleSelection && aModel.clickOKButtonBlock) {
            NSArray *determineWords = [self localCommandForKey:@"DETERMINE"];
            if ([determineWords containsObject:result]) {
                if (aModel.clickOKButtonBlock) {
                    aModel.clickOKButtonBlock();
                    return YES;
                }
            }
        }
    }
    return NO;
}

//过滤文本：取消、退出、搜索
- (BOOL)filterText:(NSString *)result {
    if ([self filterCancelWords:result]) {
        // 人员多选
        return YES;
    }
    if ([self filterLeaveWords:result]) {
        return YES;
    }
    if ([self filterSearchWords:result]) {
        return YES;
    }
    if ([self filterSendWords:result]) {
        return YES;
    }
    if ([self filterOpenWords:result]) {
        return YES;
    }
    if ([self filterDetermineWords:result]) {
        return YES;
    }
    if ([self filterIndexWords:result]) {
        return YES;
    }
    return NO;
}
//过滤unit意图：权限判断
- (BOOL)filterUnitIntent:(NSString *)action {
    if ([NSString isNull:action]) {
        return NO;
    }
    NSString *say = nil;
    if (![[XZCore sharedInstance].intentPrivilege isAvailableIntentName:action]) {
        say = kIntentUnavailable;
    }
    else {
        NSArray *array = [NSArray arrayWithObjects:
                          kBUnitIntent_LOOKUPPERSON,
                          kBUnitIntent_CALL,
                          kBUnitIntent_SENDMESSAGE,
                          kBUnitIntent_SENDIMMESSAGE, nil];
        NSMutableArray *array1 = [NSMutableArray arrayWithArray:array];
        [array1 addObject:kBUnitIntent_CREATEFLOW];
        if (![XZCore sharedInstance].privilege.hasAddressBookAuth
            && [array containsObject:action]) {
            say = kXZContactsUnavailable;
        }
        else if ([XZMainProjectBridge contactsIsUpdating] &&
                 [array1 containsObject:action]) {
          /*离线通讯录未下载完成时,不能使用 "发协同 、查协同、找人、打电话、发短信"功能。
           "请假、播报今日安排、查报表、查进行中的报销流程、查文档、查公告、打开应用场景"可以正常使用。*/
            say = kXZContactsDowloading;
        }
    }
    if (say) {
        [self needSpeakContent:say];
        [self needResetUnitDialogueState];
        [self needStartWakeup];
        return YES;
    }
    return NO;
}

- (BOOL)filterCommands:(NSString *)result {
    
    /*****************命令词处理  start********************/
    NSDictionary *tempDic = self.commandsDic;
    NSArray *allKeys = tempDic.allKeys;
    if (tempDic && allKeys.count >0 && self.commandsBlock) {
        NSString *commandKey = nil;
        for (NSString *key in allKeys) {
            NSArray *array = tempDic[key];
            if ([array containsObject:result]) {
                //todo
                commandKey = key;
                break;
            }
        }
        if ([self.intent isCreateIntent]) {
            //新建类,多次处理
            if (commandKey) {
                //识别到才回调并清空
                self.commandsBlock(commandKey, result);
                self.commandsBlock = nil;
                self.commandsDic = nil;
            }
            else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(needReadWord:speakContent:)]) {
                    NSString *speak = @"我不明白，是否继续选择";
                    [self.delegate needReadWord:speak speakContent:speak];
                }
            }
            return YES;
        }
        else {
            //查询类一次就好了，不管是否识别到，都回调并清空
            self.commandsBlock(commandKey, result);
            self.commandsBlock = nil;
            self.commandsDic = nil;
            if (commandKey) {
                return YES;
            }
        }
    }
    return NO;

    /*****************命令词处理  end********************/
}


/************************************************ 过滤器end **************************************************/
#pragma mark 过滤器 end

- (BOOL)filterResult:(NSString *)result {
    //去掉标点
      NSString *filterText = [result stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
      if ([self filterText:filterText]) {
          return YES;//文本被过滤掉了
      }
      if ([self filterCommands:result]) {
          return YES;
      }
      if (self.intent && !self.intent.useUnit) {
          [self.intent handleNativeResult:result];
          return YES;
      }
      if (self.sendIMMsgintent && ! [self.sendIMMsgintent useUnit]) {
          [self.sendIMMsgintent handleText:result];
          return YES;
      }
    return NO;
}

- (BOOL)setResult:(NSString *)result {
  
   return [super setResult:result];
}

- (NSString *)intentForAction:(NSString *)action {
    if ([self isOpenM3StandardApp:action]) {
        return @"OpenM3APP"; //打开应用模块
    }
    else if ([self isCreateForm:action]) {
        return @"CreateForm";//新建表单
    }
    else if ([self isQAAction:action]) {
        return @"QAAction";// QA问答
    }
    else if ([XZAppIntent isAppIntent:action]) {
        return @"AppIntent";
    }
    return action;
}

- (NSDictionary *)selectorDic {
    if (!_selectorDic) {
        NSString *path = [[NSBundle mainBundle] pathForResource:XZ_NAME(@"XZIntentHandle") ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        _selectorDic = [[NSDictionary alloc] initWithDictionary:dic];
    }
    return _selectorDic;
}

- (BOOL)filterAppIntent:(BUnitResult *)result{
    if (![result.intentId isEqualToString:kIntentFail] ) {
        _intentErrorCount = 0;
    }
    if (![[self intentForAction:result.intentName] isEqualToString:@"AppIntent"] ) {
        if (self.intent) {
            if ([result.intentId isEqualToString:kIntentFail]) {
                if ([self.intent isCreateIntent] && self.intent.isRequiredEnd) {
                    _intentErrorCount ++;
                    if (_intentErrorCount > 2) {
                        [self needSpeakContent:@"不好意思，没明白什么意思"];
                        [self needShowCancelCardInHistory];
                        self.intent = nil;
                    }
                    else {
                        [self needSpeakContent:@"没明白什么意思，是否继续发送？"];
                        if (self.intent.showCardBlock) {
                            self.intent.showCardBlock(self.intent);
                        }
                    }
                    return YES;
                }
            }
            else {
                [self needShowCancelCardInHistory];
                self.intent = nil;
            }
        }
    }
    return NO;
}

- (void)handleBaiduUnitResult:(BUnitResult *)result {
    NSLog(@"!!!!!!!!!!!!!handleBaiduUnitResult:\n%@",result.JSONRepresentation);
    if ([self filterAppIntent:result]) {
        return;//处理app intent  发送节点识别失败
    }
    NSString *action = result.intentName;
    if ([self filterUnitIntent:action]) {
        return;//命令过滤掉了
    }
    self.targetSlot = result.intentTarget;
    self.useUnit = YES;
    BOOL isContinue = YES;
    NSString *intent = [self intentForAction:action];
    NSDictionary *intentDic = self.selectorDic[intent];
    NSString *selectorStr = intentDic[@"selector"];
    BOOL changeAction = [intentDic[@"changeAction"] boolValue];
    BOOL shouldReturn = [intentDic[@"break"] boolValue];//单独处理，不走后面的代码
    if ([intentDic.allKeys containsObject:@"state"]) {
        self.intentState = [intentDic[@"state"] integerValue];
    }
    if (![NSString isNull:selectorStr]) {
        _unitFailureCount = 0;
        selectorStr = [NSString stringWithFormat:@"xz%@:",selectorStr];
        SEL selector = NSSelectorFromString(selectorStr);
        if ([self respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            BOOL (*func)(id, SEL,BUnitResult*) = (void *)imp;
            isContinue = func(self, selector,result);
        }
        if (shouldReturn) {
            return;
        }
    }
    else {
        changeAction = NO;
        if ([result.intentId isEqualToString:kIntentFail]) {
            if ([self isInSearchIntent]) {
                /*这儿处理查询标题没结果，unit 有没有对应意图的，说明这个是没有查询到数据。*/
                [self needSpeakContent:[NSString stringWithFormat:@"很抱歉，我没能找到《%@》%@。",result.currentText,[self relatedTitle]]];
                self.useUnit = NO;
                [self needStartWakeup];
                return;
            }
            [self showUnitErrorWords];
        }
        else  {
            _unitFailureCount = 0;
            [self showUnitSay:result];
        }
        self.useUnit = YES;
        isContinue = NO;
        [self needStartWakeup];
    }
    self.searchTitleInfo = nil;
    if (changeAction) {
        self.currentMember = nil;
    }
    
    NSString *actionTarget = result.intentTarget;
    NSString *actionType = result.intentType;
    
    if (![action isEqualToString: kBUnitIntent_LOOKUP]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needShoWOrHideSearchType:)]) {
            [self.delegate needShoWOrHideSearchType:NO];
        }
    }
    if (([actionTarget isEqualToString:kBUnitIntent_UserName] ||
         [actionTarget isEqualToString:kBUnitIntent_UserPerson])&& isContinue) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
            [self.delegate needAnswerMemberIsShow:NO isSelect:NO];
        }
    }
    else {
        if (![actionType isEqualToString:kBUnitResult_Fail]) {
            //不是选人节点，隐藏选人相关
            [self needHideMemberView];
            self.membersBlock = nil;
        }
    }
    if (isContinue) {
        //连续语音 ---- 待修改
        [self needContinueRecognize];
    }
    else if (result.isEnd){
        //场景结束了，重置场景
        [self needResetUnitDialogueState];
    }
}

- (void)nextIntent:(NSString *)intentName data:(NSDictionary *)data {
    if ([self filterUnitIntent:intentName]) {
        return;//命令过滤掉了
    }

    XZAppIntent *intent = [XZAppIntent IntentWithName:intentName];
    self.intent = intent;
    __weak typeof(XZAppIntent) *weakIntent = self.intent;
    __weak typeof(self) weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(needHandleIntent:)]) {
        [self.delegate needHandleIntent:_intent];
    }
    SmartMembersBlock membersBlock = ^(NSArray *result, BOOL cancel,NSString *extData) {
        if (result) {
            BOOL needAnalysis = weakIntent.useUnit;
            [weakIntent handleMembers:result target:extData next:!needAnalysis];
            if (needAnalysis) {
                CMPOfflineContactMember *member = [result firstObject];
                [weakSelf needAnalysisText:[SPTools memberNameWithName:member.name]];
            }
        }
    };
    self.membersBlock = membersBlock;
    if ([self.intent isCreateIntent]) {
        self.sendBlock = ^{
            if ([weakIntent checkParams_url]) {
                weakIntent.checkParamsBlock(weakIntent);
            }
            else {
                weakIntent.createBlock(weakIntent);
            }
        };
    }
    self.modifyBlock = ^{
        if (weakIntent.openBlock) {
            weakIntent.openBlock(weakIntent);
        }
    };
    self.cancelBlock = ^{
        if (weakIntent.cancelBlock) {
            weakIntent.cancelBlock(weakIntent);
        }
    };
    [intent handlePreIntentData:data];
}

- (void)needShowCancelCardInHistory {
    if (self.delegate && [self.delegate respondsToSelector:@selector(needShowCancelCardInHistory)]) {
        [self.delegate needShowCancelCardInHistory];
    }
}

- (void)resetSmartEngine {
    [super resetSmartEngine];
    self.sendBlock = nil;
    self.modifyBlock = nil;
    self.cancelBlock = nil;
    self.intent = nil;
    self.intentState = XZIntentState_Normal;
    _selectorDic = nil;
    self.membersBlock = nil;
    self.targetSlot = nil;
    [XZCore sharedInstance].textLenghtLimit = -1;
    self.sendIMMsgintent = nil;
    self.commandsBlock = nil;
    self.commandsDic = nil;
    self.unitSessionId = nil;
}

- (BOOL)needAnalysisByServer:(NSString *)result {

    if ([NSString isNull:result] ) {
        return NO;
    }
    if (![[XZCore sharedInstance] isXiaozVersionLater3_1]) {
        return NO;
    }
    if (!self.useUnit) {
        return NO;
    }
    if (self.intent && !self.intent.useUnit) {
        return NO;
    }
    return YES;
}
@end



