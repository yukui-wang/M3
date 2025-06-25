//
//  SPSmartEngine.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import "SPSmartEngine.h"
#import "SPMemberCommondNode.h"
#import "SPSearchStatisticsHelper.h"
#import "XZCreateScheduleModel.h"
#import "XZCreateFormModel.h"
#import "XZSmartEngine.h"
#import "XZCore.h"

typedef NS_ENUM(NSUInteger, SPSmartEngineState) {
    SPSmartEngineStop,
    SPSmartEngineStart,
    SPSmartEngineErr,
};
@interface SPSmartEngine() {
    
}
@property (nonatomic, strong) BUnitManager *unitSDK;
/** 保存当前指令插件 **/
@property (strong, nonatomic) NSDictionary *commondDic;
/** 保存当前指令节点集 **/
@property (strong, nonatomic) NSArray *commondNodes;

/** 请假类型 **/
@property (nonatomic, strong) NSArray *leaveTypes;


@end


@implementation SPSmartEngine
@synthesize currentLeaveTypeModel = _currentLeaveTypeModel;
@synthesize currentLeaveModel = _currentLeaveModel;
@synthesize currentCreateModel = _currentCreateModel;
@synthesize m3AppInfo = _m3AppInfo;
@synthesize currentNode= _currentNode;
@synthesize currentCellModel= _currentCellModel;

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

#pragma mark - Open Interface

- (NSString *)handleTitle:(NSString *)title {
    //干掉标题开头和结尾的"的"
    NSString  *result = [title stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"的"]];
    return result;
}

- (BOOL)setResult:(NSString *)result {
    
    if (self.useUnit) {
        [self needAnalysisText:result];
        return NO;
    }
    
    if (self.currentCreateModel &&[self.currentCreateModel isKindOfClass:[XZCreateFormModel class]]) {
        [self.currentCreateModel setSpeechString:result];
        return YES;
    }
    
    if ([self isInSearchColl]) {
        if (_delegate && [_delegate respondsToSelector:@selector(needSearchCollWithParam:)]) {
            NSString *state = self.currentResult[@"state"];
            if (![NSString isNull:result] && ![NSString isNull:state]) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:result forKey:@"subject"];
                [param setObject:state forKey:@"state"];
                [_delegate needSearchCollWithParam:param];
            }
        }
        return NO;
    }
    if ([self isInSearchBul]) {
        if (_delegate && [_delegate respondsToSelector:@selector(needSearchBul:)]) {
            [_delegate needSearchBul:result];
        }
        self.currentResult = nil;
        [self needResetUnitDialogueState];
        return NO;
    }
    if ([self isInSearchDoc]) {
        if (_delegate && [_delegate respondsToSelector:@selector(needSearchDoc:)]) {
            [_delegate needSearchDoc:result];
        }
        self.currentResult = nil;
        [self needResetUnitDialogueState];
        return NO;
    }
    if ([self isInSearchStatistics]) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(needSearchStatistics:)]) {
            [_delegate needSearchStatistics:[self handleTitle:result]];
        }
        self.currentResult = nil;
        [self needResetUnitDialogueState];
        return NO;
    }
    if ([self isInSearchNews]) {
        if (_delegate && [_delegate respondsToSelector:@selector(needSearchNews:)]) {
            [_delegate needSearchNews:[self handleTitle:result]];
        }
        self.currentResult = nil;
        [self needResetUnitDialogueState];
        return NO;
    }
    
    if (!_currentNode) {
        if (_delegate && [_delegate respondsToSelector:@selector(stepDidEnd:)]) {
            [_delegate stepDidEnd:NO];
        }
        return NO;
    }
    
    if ([result isEqualToString:@"下一步"] && [_currentNode isKindOfClass:[SPMemberCommondNode class]]) {
        //特殊处理 ，如果没有人员，不能 “下一步”
        SPMemberCommondNode *node = (SPMemberCommondNode *)_currentNode;
        BOOL canNextStep = [node canNextStep];
        if (_delegate && [_delegate respondsToSelector:@selector(memberNodeWillNextStep:)]) {
            [_delegate memberNodeWillNextStep:canNextStep];
        }
        if (!canNextStep) {
            return NO;
        }
    }
    
    NSString *currentInput = result;
    SPAnswer *answer = [[SPAnswer alloc] init];
    answer.type = [SPCommondNodeFactory getAnswerTypeWithType:_currentNode.type];
    answer.content = result;
    answer.currentResult = self.currentResult;
    __weak typeof(self) weakSelf = self;
    
    [_currentNode Answer:answer onResult:^(NSDictionary *result, SPQuestion *anotherQuestion, BOOL isSuccess) {
        [weakSelf handleResult:result question:anotherQuestion isSuccess:isSuccess currentInput:currentInput];
    }];
    return NO;
}

- (void)handleResult:(NSDictionary *)result
            question:(SPQuestion *)anotherQuestion
           isSuccess:(BOOL)isSuccess
        currentInput:(NSString *)currentInput {
    
    // 处理选项节点，仅做跳转不做数据封装
    if ([_currentNode.type isEqualToString:COMMOND_VALUE_TYPE_OPTION]) {
        if (!anotherQuestion || (anotherQuestion.type != SPAnswerSleep && anotherQuestion.type != SPAnswerUnknown)) {
            NSString *nextStepIndex = [result objectForKey:ANSWERRESULTBLOCK_KEY_STEPINDEX];
            SPBaseCommondNode *nextCommondNode = [self getCommondNodeWithIndex:nextStepIndex];
            _currentNode = nextCommondNode;
            [self handleQuestion:[nextCommondNode getQuestion]];
            if ([nextStepIndex isEqualToString:@"-1"]) {
                [self stepDidEnd:[_currentNode needRestart]];
            }
            return;
        }
    }
    // 封装数据
    if (result) {
        NSString *key = [result objectForKey:ANSWERRESULTBLOCK_KEY_KEY];
        NSArray *value = [result objectForKey:ANSWERRESULTBLOCK_KEY_VALUE];
        if (key && value) {
            [self.currentResult setObject:value forKey:key];
        }
        
        if ([result objectForKey:ANSWERRESULTBLOCK_KEY_MEMBER_SELECTED]) {
            if (_delegate && [_delegate respondsToSelector:@selector(needShowCloseAlert)]) {
                [_delegate needShowCloseAlert];
            }
        }
    }
    
    if ([_currentNode.type isEqualToString:COMMOND_VALUE_TYPE_MEMBER]) {
        NSString *memberNmaes = [result objectForKey:ANSWERRESULTBLOCK_KEY_NAMES];
        if (memberNmaes) {
            _isColHasMember = YES;
        }
        NSString *newLine = [result objectForKey:ANSWERRESULTBLOCK_KEY_NEWLINE];
        if (memberNmaes && newLine) {
            if (memberNmaes.length >0 &&_delegate && [_delegate respondsToSelector:@selector(needShowHumanWord:newLine:)]) {
                [_delegate needShowHumanWord:memberNmaes newLine:[newLine boolValue]];
            }
        }
        BOOL needPromt = [[result objectForKey:ANSWERRESULTBLOCK_KEY_MEMBER_PROMT] boolValue];
        if (needPromt) {
            if (_delegate && [_delegate respondsToSelector:@selector(needShowMemberPromt:)]) {
                [_delegate needShowMemberPromt:memberNmaes];
            }
        }
        else {
            if (_delegate && [_delegate respondsToSelector:@selector(needSleep)]) {
                [_delegate needSleep];
            }
            if(!anotherQuestion || (anotherQuestion && !anotherQuestion.optionMembers)) {
                //这个地放连续监听会宇重复人选显示时的连续监听冲突
                [self needContinueRecognize];
            }
        }
    }
    
    // 优先处理该节点的其它问题
    if (anotherQuestion) {
        // 判断打电话发短信是否重复两次错误
        [self handleQuestion:anotherQuestion];
        if (anotherQuestion.isEnd) {
            [self stepDidEnd:NO];
        }
        return;
    }
    // 处理长文本结束回调
    if ([_currentNode.type isEqualToString:COMMOND_VALUE_TYPE_LONGTEXT]) {
        if (_delegate && [_delegate respondsToSelector:@selector(didCompleteLongText)]) {
            [_delegate didCompleteLongText];
        }
    }
    // 如果该节点问题处理完成，根据是否成功，进入下一节点处理流程
    SPBaseCommondNode *nextCommondNode;
    if (isSuccess) {
        NSString *nextStepIndex = _currentNode.successStepIndex;
        if ([nextStepIndex isEqualToString:@"-1"]) {
            [self stepDidEnd:[_currentNode needRestart]];
            return;
        }
        nextCommondNode = [self getCommondNodeWithIndex:_currentNode.successStepIndex];
    } else {
        NSString *nextStepIndex = _currentNode.failStepIndex;
        if ([nextStepIndex isEqualToString:@"-1"]) {
            [self stepDidEnd:[_currentNode needRestart]];
            return;
        }
        nextCommondNode = [self getCommondNodeWithIndex:_currentNode.failStepIndex];
    }
    if (!nextCommondNode) {
        return;
    }
    _currentNode = nextCommondNode;
    if (_delegate && [_delegate respondsToSelector:@selector(needHumanSpeakNewLine)]) {
        [_delegate needHumanSpeakNewLine];
    }
    [self handleQuestion:[nextCommondNode getQuestion]];
    /*人员卡片后发协同*/
    if ([self isInCreateColl] && [nextCommondNode isKindOfClass:[SPMemberCommondNode class]]) {
        SPMemberCommondNode *node = (SPMemberCommondNode *) nextCommondNode;
        if (node.memberNameList.count >0) {
            if (_delegate && [_delegate respondsToSelector:@selector(needShowMemberPromt:)]) {
                [_delegate needShowMemberPromt:[node.memberNameList firstObject]];
            }
        }
    }
    if (_currentNode) {
        [self needContinueRecognize];
    }
}

- (void)memberPrompt:(NSTimer *)timer {
    if (_delegate && [_delegate respondsToSelector:@selector(needSleep)]) {
        [_delegate needSleep];
    }
    [self needSpeakContent:@"小致将持续为你服务 ，请继续选人或者命令“##下一步##”。"];
    
    if (_delegate && [_delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
        [_delegate needAnswerMemberIsShow:NO isSelect:NO];
    }
    [self needContinueRecognize];
    if (_delegate && [_delegate respondsToSelector:@selector(needHumanSpeakNewLine)]) {
        [_delegate needHumanSpeakNewLine];
    }
}

- (void)wakeUp {
    if (!_currentNode) {
        if (_delegate && [_delegate respondsToSelector:@selector(needAnswerFirstCommond)]) {
            [_delegate needAnswerFirstCommond];
        }
        return;
    }
    SPQuestion *question = [_currentNode getQuestion];
    question.isRead = NO;
    [self handleQuestion:question];
}

- (void)resetSmartEngine {
    [self needResetUnitDialogueState];
    self.searchTitleInfo = nil;
    [self.currentResult removeAllObjects];
    self.currentNode = nil;
    self.commondNodes = nil;
    self.commondDic = nil;
    _isColHasMember = NO;
    self.currentCellModel = nil;
    self.currentLeaveTypeModel = nil;
    self.useUnit = YES;
    self.currentLeaveModel = nil;
    self.currentCreateModel = nil;
    self.m3AppInfo = nil;
    self.currentMember = nil;
}

- (BOOL)isInCol {
    if ([[_commondDic objectForKey:COMMOND_KEY_COMMONDID] integerValue] == 1) {
        return YES;
    }
    return NO;
}


/* 人员名称处理，暂时用不到
 + (NSString *)getMainName:(NSString *)name {
 NSError *error = nil;
 NSString *result = name;
 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\（)[^\\(]*(\\)|\\）)" options:NSRegularExpressionCaseInsensitive error:&error];
 NSArray<NSTextCheckingResult *> *regexResult = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
 if (regexResult.count > 0) {
 for (int i = 0; i<regexResult.count; i++) {
 NSTextCheckingResult *res = regexResult[i];
 result = [result stringByReplacingOccurrencesOfString:[name substringWithRange:res.range] withString:@""];
 }
 }
 
 return result;
 }
 */

#pragma mark - Inner Method
/**
 初始化命令节点数组
 
 @param commondDic 命令节点字典
 @return 命令节点数组
 */
- (NSArray *)getCommondNodesWithCommondDic:(NSDictionary *)commondDic {
    NSMutableArray *commondNodeTmp = [NSMutableArray array];
    
    NSArray *commondSteps = [commondDic objectForKey:COMMOND_KEY_STEPS];
    NSString *commondID = [commondDic objectForKey:COMMOND_KEY_COMMONDID];
    for (NSDictionary *commondStep in commondSteps) {
        SPBaseCommondNode *commondNode = [SPCommondNodeFactory initCommondNode:commondStep];
        commondNode.commondID = commondID;
        if (!commondNode) {
            continue;
        }
        [commondNodeTmp addObject:commondNode];
    }
    
    return [commondNodeTmp copy];
}

- (SPBaseCommondNode *)getCommondNodeWithIndex:(NSString *)index {
    if (!_commondNodes ||
        _commondNodes.count == 0) {
        return nil;
    }
    
    for (SPBaseCommondNode *commondNode in _commondNodes) {
        if ([commondNode.stepIndex isEqualToString:index]) {
            return commondNode;
        }
    }
    
    return nil;
}

- (void)stepDidEnd:(BOOL)isRestart {
    [self resetSmartEngine];
    if (_delegate && [_delegate respondsToSelector:@selector(stepDidEnd:)]) {
        [_delegate stepDidEnd:isRestart];
    }
    [self needResetUnitDialogueState];
}

/**
 根据问题type，处理问题
 @param question 问题
 */
- (void)handleQuestion:(SPQuestion *)question {
    switch (question.type) {
        case SPAnswerShortText:
            [self readQuestion:question];
            
            if (_delegate && [_delegate respondsToSelector:@selector(needAnswerShortText)]) {
                [_delegate needAnswerShortText];
            }
            break;
        case SPAnswerLongText:
            [self readQuestion:question];
            if (_delegate && [_delegate respondsToSelector:@selector(needAnswerLongText)]) {
                [_delegate needAnswerLongText];
            }
            break;
        case SPAnswerMember: {
            [self readQuestion:question];
            __weak typeof(SPBaseCommondNode) *weakNode = _currentNode;
            __weak typeof(self) weakSelf = self;
            self.membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
                if (!cancel) {
                    [weakNode handleMembers:members  option:NO onResult:^(NSDictionary *result, SPQuestion *anotherQuestion, BOOL isSuccess) {
                        [weakSelf handleResult:result question:anotherQuestion isSuccess:isSuccess currentInput:nil];
                    }];
                }
            };
            if (_delegate && [_delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
                [_delegate needAnswerMemberIsShow:NO isSelect:NO];
            }}
            break;
        case SPAnswerOption:
            [self readQuestion:question];
            if (_delegate && [_delegate respondsToSelector:@selector(needAnswerOption)]) {
                [_delegate needAnswerOption];
            }
            break;
        case SPAnswerPrompt:
            [self readQuestion:question];
            [self skipStep:YES];
            break;
        case SPAnswerSelectPeople:
            [self readQuestion:question];
            if (_delegate && [_delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
                [_delegate needAnswerMemberIsShow:YES isSelect:YES];
            }
            break;
        case SPAnswerSelectPeopleOption:
            if (question.optionMembers) {
                if (_delegate && [_delegate respondsToSelector:@selector(needChooseFormOptionMembers:block:)]) {
                    NSString *content = question.content;
                    NSArray *strArr = [content componentsSeparatedByString:@" "];
                    NSString *needReadStr = [strArr firstObject];
                    content = [content replaceCharacter:@" " withString:@""];
                    __weak typeof(self) weakSelf = self;
                    XZOptionMemberParam *param = [[XZOptionMemberParam alloc] init];
                    param.speakContent = needReadStr;
                    param.showContent = content;
                    param.members = question.optionMembers;
                    [_delegate needChooseFormOptionMembers:param block:^(NSArray *members, BOOL cancel,NSString *extData) {
                        if (!cancel) {
                            [self->_currentNode handleMembers:members  option:YES onResult:^(NSDictionary *result, SPQuestion *anotherQuestion, BOOL isSuccess) {
                                [weakSelf handleResult:result question:anotherQuestion isSuccess:isSuccess currentInput:nil];
                            }];
                        }
                    }];
                }
            }
            else {
                [self readQuestion:question];
            }
            break;
            
        case SPAnswerSleep:
            if (_delegate && [_delegate respondsToSelector:@selector(needSleep)]) {
                [_delegate needSleep];
            }
            break;
            
        case SPAnswerSubmit:
            if (self.currentCreateModel) {
                self.currentCreateModel.subject = self.currentResult[@"subject"];
                self.currentCreateModel.content = self.currentResult[@"content"];
                if (_delegate && [_delegate respondsToSelector:@selector(needCreateObject:)]) {
                    [_delegate needCreateObject:self.currentCreateModel];
                }
            }
            else if (_delegate && [_delegate respondsToSelector:@selector(needSendColl:)]) {
                [_delegate needSendColl:self.currentResult];
            }
            break;
            
        case SPAnswerView:
            if (self.currentCreateModel) {
                self.currentCreateModel.subject = self.currentResult[@"subject"];
                self.currentCreateModel.content = self.currentResult[@"content"];
                if (_delegate && [_delegate respondsToSelector:@selector(needShowObject:)]) {
                    [_delegate needShowObject:self.currentCreateModel];
                }
            }
            else if (_delegate && [_delegate respondsToSelector:@selector(needJumpToColl:)]) {
                [_delegate needJumpToColl:self.currentResult];
            }
            [self skipStep:YES];
            break;
        case SPAnswerExit:
            [self readQuestion:question];
            [self stepDidEnd:YES];
            break;
            
        case SPAnswerUnknown:
            if (_delegate && [_delegate respondsToSelector:@selector(needUnknownCommond)]) {
                [_delegate needUnknownCommond];
            }
            break;
            
        default:
            break;
    }
}

- (void)skipStep:(BOOL)isSuccess {
    SPBaseCommondNode *nextCommondNode;
    NSString *nextStepIndex;
    if (isSuccess) {
        nextStepIndex = _currentNode.successStepIndex;
    } else {
        nextStepIndex = _currentNode.failStepIndex;
    }
    
    if ([nextStepIndex isEqualToString:@"-1"]) {
        [self stepDidEnd:[_currentNode needRestart]];
        return;
    }
    nextCommondNode = [self getCommondNodeWithIndex:nextStepIndex];
    _currentNode = nextCommondNode;
    [self handleQuestion:[nextCommondNode getQuestion]];
    
}

- (void)readQuestion:(SPQuestion *)question {
    if (!question.isRead) {
        return;
    }
    
    NSString *str = question.content;
    [self needSpeakContent:str];
}

- (NSMutableDictionary *)currentResult {
    if (!_currentResult || ![_currentResult isKindOfClass:[NSMutableDictionary class]]) {
        _currentResult = [NSMutableDictionary dictionary];
    }
    return _currentResult;
}

- (SPBaseCommondNode *)getCurrentNode {
    return _currentNode;
}

//是否是多选人员
- (BOOL)isMultiSelectMember
{
    if (self.currentCreateModel && [self.currentCreateModel isKindOfClass:[XZCreateFormModel class]]) {
        return YES;
    }
    return [SPCommondNodeFactory getAnswerTypeWithType:_currentNode.type] == SPAnswerMember;
}


- (void)needContinueRecognize {
    if (_delegate && [_delegate respondsToSelector:@selector(needContinueRecognize)]) {
        [_delegate needContinueRecognize];
    }
}
- (void)needStartWakeup {
    if (_delegate && [_delegate respondsToSelector:@selector(needStartWakeup)]) {
        [_delegate needStartWakeup];
    }
}
- (void)needSpeakContent:(NSString *)content {
    if (_delegate && [_delegate respondsToSelector:@selector(needReadWord:speakContent:)]) {
        NSArray *strArr = [content componentsSeparatedByString:@" "];
        NSString *needReadStr = [strArr firstObject];
        NSString *readWord = [content replaceCharacter:@" " withString:@""];
        [_delegate needReadWord:readWord speakContent:needReadStr];
    }
}
- (void)needHideMemberView {
    if (_delegate && [_delegate respondsToSelector:@selector(needHideMemberView)]) {
        [_delegate needHideMemberView];
    }
}

- (BOOL)needOpenM3AppWithAppId:(NSString *)appId  result:(void(^)(BOOL sucess))result{
    if (_delegate && [_delegate respondsToSelector:@selector(needOpenM3AppWithAppId:result:)]) {
        [_delegate needOpenM3AppWithAppId:appId result:result];
    }
    return NO;
}



- (void)showMemberCard:(CMPOfflineContactMember *)member showOK:(BOOL)ok {
    self.currentMember = member;
    if (_delegate && [_delegate respondsToSelector:@selector(needShowMemberCard:showOK:)]) {
        [_delegate needShowMemberCard:member showOK:ok];
    }
}
- (void)setupBaseInfo:(SPBaiduUnitInfo *)info  {
    self.useUnit = YES;
    //unit
    if (!_unitSDK) {
        _unitSDK = [BUnitManager sharedInstance];
    }
    _unitSDK.version = info.unitVersion;
    _unitSDK.logId = info.logId;
    _unitSDK.userId = info.userId;
    [_unitSDK getAccessTokenWithAK:info.baiduUnitApiKey SK:info.baiduUnitSecretKey completion:^(NSError *error, NSString *token) {
    }];
    [_unitSDK setSceneID:[info.baiduUnitSceneID integerValue]];
    _intentErrorCount = 0;
    _unitFailureCount = 0;

}

#pragma mark unit begin


- (void)handleTextWithUnit:(NSString *)string
                completion:(void (^)(NSError *error, BUnitResult *resultObject))completionBlock  {
    [_unitSDK askWord:string
           completion:^(NSError *error, BUnitResult *resultDict) {
        completionBlock(error,resultDict);
    }];
}


- (void)needResetUnitDialogueState {
    [_unitSDK resetDialogueState];
}
#pragma mark unit end


- (void)setCurrentCellModel:(XZCellModel *)currentCellModel {
    [_currentCellModel disableOperate];
    _currentCellModel = currentCellModel;
}
- (BOOL)isInCallPhone {
    return self.intentState == XZIntentState_Call;
}
- (BOOL)isInSendMessage {
    return self.intentState == XZIntentState_SendMessage;
}
- (BOOL)isInSendIMMessage {
    return self.intentState == XZIntentState_SendIMMessage;
}

- (BOOL)isInFindMan {
    return self.intentState == XZIntentState_FindMan;
}
- (BOOL)isInSearchSchedule {
    return self.intentState == XZIntentState_SearchSchedule;
}
- (BOOL)isInSearchColl {
    return self.intentState == XZIntentState_SearchCol;
}
- (BOOL)isInSearchDoc {
    return self.intentState == XZIntentState_SearchDoc;
}
- (BOOL)isInSearchBul {
    return self.intentState == XZIntentState_SearchBul;
}


- (BOOL)isInSearchStatistics {
    /*查查报表*/
    return self.intentState == XZIntentState_SearchStatistics;
}
- (BOOL)isInSearchNews {
    /*查查报表*/
    return self.intentState == XZIntentState_SearchNews;
}

- (BOOL)isInSearchIntent {
    //是否是在搜索意图
    if ([self isInSearchDoc]) {
        return YES;
    }
    if ([self isInSearchBul]) {
        return YES;
    }
    if ([self isInSearchStatistics]) {
        return YES;
    }
    if ([self isInSearchNews]) {
        return YES;
    }
    if ([self isInSearchColl]&& self.currentResult[@"state"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInCreateColl{
    return self.intentState == XZIntentState_InCreateColl;
}
- (BOOL)unavailableTitle:(NSString *)title {
    if (!title) {
        return YES;
    }
    int i = 6;
    NSString *str2 = [NSString stringWithFormat:@"%C",(unichar)i];
    if ([title isEqualToString:str2]) {
        return YES;
    }
    return NO;
}
- (void)needAnalysisText:(NSString *)text {
    
}
- (void)createColl {
//    self.intentState = XZIntentState_Call;
    self.useUnit = NO;
    [self startCommond:@"collaboration" index:@"1"];
    SPMemberCommondNode *node = (SPMemberCommondNode *)[self getCommondNodeWithIndex:@"2"];
    [node addDefaultMember:self.currentMember];
    self.currentMember = nil;
}


- (void)startCommond:(NSString *)commond index:(NSString *)index {
    NSString *commondName = XZ_NAME(commond);
    NSString *aPath = [[NSBundle mainBundle] pathForResource:commondName ofType:@"json"];
    NSString *aValue = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *commondStepDic = [SPTools dictionaryWithJsonString:aValue];
    _commondDic = commondStepDic;
    _commondNodes = [self getCommondNodesWithCommondDic:commondStepDic];
    _currentNode = [self getCommondNodeWithIndex:index];
    SPQuestion *question = [_currentNode getQuestion];
    [self handleQuestion:question];
}

- (void)showUnitSay:(BUnitResult *) result{
    NSString *say = result.say;
    if (![NSString isNull:say]) {
        say = [say replaceCharacter:@"<USER-NAME>" withString:[XZCore userName]];
        say = [say replaceCharacter:@"&nbsp;" withString:@" "];
        [self needSpeakContent:say];
    }
}

- (void)showLeaveTypes {
    if (!self.leaveTypes) {
        self.leaveTypes = [NSArray arrayWithObjects:@"事假",@"病假",@"婚假",@"产假",@"年假",@"调休",@"陪产假",@"丧假",@"产检假", nil];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(needShowLeaveTypes:)]) {
        _currentLeaveTypeModel.canOperate = NO;//前一个设置为不可操作了
        _currentLeaveTypeModel = [[XZLeaveTypesModel alloc] init];
        _currentLeaveTypeModel.leaveTypes = self.leaveTypes;
        [_delegate needShowLeaveTypes:_currentLeaveTypeModel];
    }
}

- (void)LeaveFinishWithInfo:(NSDictionary *)info {
    if (_delegate && [_delegate respondsToSelector:@selector(needSendLeaveForm:)]) {
        [self.currentLeaveModel handleUintResult:info];
        [_delegate needSendLeaveForm:self.currentLeaveModel];
        self.currentLeaveModel = nil;
    }
    [self needResetUnitDialogueState];
}

#pragma mark   Handle Search  Result
- (void)needShowSearch:(SPSearchHelper *) helper {
    if (_delegate && [_delegate respondsToSelector:@selector(needShowSearch:)]) {
        [_delegate needShowSearch:helper];
    }
}

- (void)handleSearchColResult:(NSString *)result info:(NSDictionary *)info{
    NSString *subject = info[@"subject"];
    BOOL searchTitle = ![NSString isNull:subject];
    if (![NSString isNull:result] ) {
        SPSearchColHelper *helper = [[SPSearchColHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            if (searchTitle) {
                helper.info = [NSDictionary dictionaryWithObjectsAndKeys:subject,@"value",@"subject",@"key", nil];
            }
            else {
                NSString *startMemberName = info[@"startMemberName"];
                helper.info = [NSDictionary dictionaryWithObjectsAndKeys:startMemberName,@"value",@"startMemberName",@"key", nil];
                [self needResetUnitDialogueState];
            }
            helper.max = 5;
            helper.isOption = YES;
            [self needShowSearch:helper];
            [self needStartWakeup];
            return;
        }
    }
    NSString *startMemberName = info[@"startMemberName"];
    NSString *state = [self collSateStrWithState:info[@"state"]];
    if ([[XZCore sharedInstance] isXiaozVersionLater2_2]) {
        NSString *say = searchTitle?[NSString stringWithFormat:@"我没能找到《%@》相关协同",subject]:[NSString stringWithFormat:@"很抱歉，我没能找到%@发的%@协同。",startMemberName,state];
        [self needSpeakContent:say];
        [self needResetUnitDialogueState];
        [self needStartWakeup];
        return;
    }
    
    if (searchTitle ) {
        self.searchTitleInfo = [NSString stringWithFormat:@"我没能找到《%@》相关协同,即将为你",subject];
        [self needResetUnitDialogueState];
        [self needAnalysisText:subject];
    }
    else {
        [self needSpeakContent:[NSString stringWithFormat:@"很抱歉，我没能找到%@发的%@协同。",startMemberName,state]];
        [self needResetUnitDialogueState];
        [self needStartWakeup];
    }
}

- (void)handleSearchExpenseResult:(NSString *)result info:(NSDictionary *)info {
    
    if (![NSString isNull:result] ) {
        SPSearchColHelper *helper = [[SPSearchColHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            helper.max = 100;
            helper.isOption = YES;
            helper.isExpense = YES;
            [self needShowSearch:helper];
            [self needStartWakeup];
            return;
        }
    }
    [self needSpeakContent:@"很抱歉，我没能找到报销单。"];
    [self needStartWakeup];
}

- (void)handleSearchStatisticsResult:(NSString *)result title:(NSString *)title {
    if (![NSString isNull:result] ) {
        SPSearchStatisticsHelper *helper = [[SPSearchStatisticsHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            [self needShowSearch:helper];
            [self needStartWakeup];
            self.useUnit = NO;
        }
    }
    self.searchTitleInfo = [NSString stringWithFormat:@"我没能找到《%@》相关报表,即将为你",title];
    [self needResetUnitDialogueState];
    [self needAnalysisText:title];
}

- (void)handleScheduleResult:(NSString *)result {
    
    if (![NSString isNull:result]) {
        SPScheduleHelper *helper = [[SPScheduleHelper alloc] initWithJson:result];
        if (helper) {
            if (helper.plans.count > 10) {
                // 今日安排太多，询问是否读
                NSString *speak = [NSString stringWithFormat:@"你的今日安排较多，共%ld项，需要为你播报吗？ ##需要##或##不需要##",(unsigned long)helper.plans.count];
                [self needSpeakContent:speak];
                self.currentResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:helper,COMMOND_VALUE_TYPE_SCHEDULE, nil];
                [self needContinueRecognize];
                return;
            }
            if (helper.plans.count > 0 || helper.willDones.count > 0) {
                if (_delegate && [_delegate respondsToSelector:@selector(needShowSchedule:)]) {
                    [_delegate needShowSchedule:helper];
                }
                [self needStartWakeup];
                return;
            }
        }
    }
    [self needSpeakContent:@"对不起，你今天还未有日程安排。"];
    [self needStartWakeup];
}

- (void)handleSearchDocResult:(NSString *)result title:(NSString *)title{
    if (![NSString isNull:result]) {
        SPSearchDocHelper *helper = [[SPSearchDocHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            helper.searchTitle = title;
            helper.isOption = YES;
            [self needShowSearch:helper];
            [self needStartWakeup];
            self.useUnit = NO;
            return;
        }
    }
    self.searchTitleInfo = [NSString stringWithFormat:@"我没能找到《%@》相关文档,即将为你",title];
    [self needResetUnitDialogueState];
    [self needAnalysisText:title];
}

- (void)handleSearchBulResult:(NSString *)result title:(NSString *)title{
    if (![NSString isNull:result]) {
        SPSearchBulHelper *helper = [[SPSearchBulHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            helper.searchTitle = title;
            helper.isOption = YES;
            [self needShowSearch:helper];
            [self needStartWakeup];
            self.useUnit = NO;
            return;
        }
    }
    self.searchTitleInfo = [NSString stringWithFormat:@"我没能找到《%@》相关公告,即将为你",title];
    [self needResetUnitDialogueState];
    [self needAnalysisText:title];
}

- (void)handleSearchNewsResult:(NSString *)result title:(NSString *)title {
    if (![NSString isNull:result]) {
        SPSearchNewsHelper *helper = [[SPSearchNewsHelper alloc] initWithJson:result];
        if (helper && helper.total > 0) {
            helper.searchTitle = title;
            helper.isOption = YES;
            [self needShowSearch:helper];
            [self needStartWakeup];
            self.useUnit = NO;
            return;
        }
    }
    if ([[XZCore sharedInstance] isXiaozVersionLater2_2]) {
        [self needSpeakContent:[NSString stringWithFormat:@"对不起，我没能找到《%@》相关新闻",title]];
        [self needResetUnitDialogueState];
        [self needStartWakeup];
        self.useUnit = YES;
        self.intentState = XZIntentState_Normal;
        return;
    }
    self.searchTitleInfo = [NSString stringWithFormat:@"我没能找到《%@》相关新闻,即将为你",title];
    [self needResetUnitDialogueState];
    [self needAnalysisText:title];
}

- (void)showSearchTitleInfo:(NSString *)string {
    if (![NSString isNull:self.searchTitleInfo]) {
        NSString *say = [NSString stringWithFormat:@"%@%@",self.searchTitleInfo,string];
        if (_delegate && [_delegate respondsToSelector:@selector(needReadWord:speakContent:)]) {
            [_delegate needReadWord:say speakContent:nil];
        }
    }
}

- (NSString *)collStateWithString:(NSString *)str {
    if ([str isEqualToString:kBUnit_LOOKUPFLOW_STATE_DONE]) {
        return @"4";
    }
    else  if ([str isEqualToString:kBUnit_LOOKUPFLOW_STATE_TODO]) {
        return @"3";
    }
    else if ([str isEqualToString:kBUnit_LOOKUPFLOW_STATE_SEND]) {
        return @"2";
    }
    else {
        return @"3";
    }
}

- (NSString *)collSateStrWithState:(NSString *)str {
    if ([str isEqualToString:@"4"]) {
        return kBUnit_LOOKUPFLOW_STATE_DONE;
    }
    else  if ([str isEqualToString:@"3"]) {
        return kBUnit_LOOKUPFLOW_STATE_TODO;
    }
    else  if ([str isEqualToString:@"2"]) {
        return kBUnit_LOOKUPFLOW_STATE_SEND;
    }
    else {
        return kBUnit_LOOKUPFLOW_STATE_TODO;
    }
}

- (BOOL)xzhandleCreateForm:(BUnitResult *)result {
    if (result.isEnd ) {
        // unit先完成
        [self showUnitSay:result];
        return YES;
    }
    if (!_currentCreateModel) {
        NSString *action = result.intentName;
        NSDictionary *commondStepDic = [[XZCore sharedInstance] formJson];
        XZCreateFormModel *model = [[XZCreateFormModel alloc] initWithJsonFile:commondStepDic[action]];
        __weak typeof(self) weakSelf = self;
        model.needSayBlock = ^(NSString *say) {
            [weakSelf needSpeakContent:say];
        };
        model.needUnitBlock = ^(BOOL unit) {
            weakSelf.useUnit = unit;
        };
        model.needShortTextBlock = ^(NSString *say) {
            [weakSelf needSpeakContent:say];
            weakSelf.useUnit = NO;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needAnswerShortText)]) {
                [weakSelf.delegate needAnswerShortText];
            }
        };
        model.needLongTextBlock = ^(NSString *say) {
            [weakSelf needSpeakContent:say];
            weakSelf.useUnit = NO;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needAnswerLongText)]) {
                [weakSelf.delegate needAnswerLongText];
            }
        };
        SmartMembersBlock membersBlock = ^(NSArray *members, BOOL cancel,NSString *extData) {
            if (!cancel) {
                [self.currentCreateModel setSpeechMembers:members];
                [self needContinueRecognize];
            }
        };
        model.needMembersBlock = ^(NSString *say) {
            [weakSelf needSpeakContent:say];
            weakSelf.useUnit = NO;
            self.membersBlock = membersBlock;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needAnswerMemberIsShow:isSelect:)]) {
                [weakSelf.delegate needAnswerMemberIsShow:NO isSelect:NO];
            }
        };
        model.needChooseFormOptionMembersBlock = ^(XZOptionMemberParam *param) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needChooseFormOptionMembers:block:)]) {
                [weakSelf.delegate needChooseFormOptionMembers:param block:membersBlock];
            }
        };
        
        model.needChooseMembersFinishBlock = ^(NSString *allNames){
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needShowMemberPromt:)]) {
                [weakSelf.delegate needShowMemberPromt:allNames];
            }
            [weakSelf needHideMemberView];
        };
        model.needCreateFormBlock = ^(NSDictionary *param) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needCreateObject:)]) {
                [weakSelf.delegate needCreateObject:weakSelf.currentCreateModel];
            }
        };
        model.needShowFormBlock = ^(NSDictionary *param) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needShowObject:)]) {
                [weakSelf.delegate needShowObject:weakSelf.currentCreateModel];
            }
            weakSelf.useUnit = YES;
            [weakSelf resetSmartEngine];
        };
        model.needCancelBlock = ^(NSString *say) {
            [weakSelf needSpeakContent:say];
            weakSelf.useUnit = YES;
            [weakSelf resetSmartEngine];
        };
        model.needShowChoosedMembersBlock = ^(NSString *names) {
            if (![NSString isNull:names] &&weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needShowHumanWord:newLine:)]) {
                [weakSelf.delegate needShowHumanWord:names newLine:YES];
            }
            [weakSelf needResetUnitDialogueState];
        };
        model.needSleepBlock = ^ {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(needSleep)]) {
                [weakSelf.delegate needSleep];
            }
        };
        model.needContinueRecognizeBlock = ^ {
            [weakSelf needContinueRecognize];
        };
        self.currentCreateModel = model;
        
    }
    [self.currentCreateModel setupWithUnitResult: result];
    return YES;
}

@end


