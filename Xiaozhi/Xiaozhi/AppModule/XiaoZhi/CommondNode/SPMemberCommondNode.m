//
//  SPMemberCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/13.
//
//

#import "SPMemberCommondNode.h"
#import "SPTools.h"
#import "XZMainProjectBridge.h"
#import <CMPLib/CMPOfflineContactMember.h>

@interface SPMemberCommondNode()

/* 人员ID数组  */
@property (nonatomic, strong) NSMutableArray *memberIDList;
/* 联系错误录入同一个人员次数  */
@property (nonatomic) NSInteger errorTime;

/* 带选择数组 */
@property (nonatomic, strong) NSArray *optionArray;

/* 存储上一个错误的名字 */
@property (nonatomic, strong) NSString *lastErrName;

/* 是否正在选人流程(同名) */
@property (nonatomic) BOOL isSelectPeople;

/* 是否在异常流程 */
@property (nonatomic) BOOL isException;

@end

@implementation SPMemberCommondNode

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    if (_isSelectPeople) {
        question.type = SPAnswerSelectPeople;
    } else {
        question.type = SPAnswerMember;
    }
    question.content = self.word;
    question.isRead = YES;
    question.eos = VAD_MEMBER_EOS;
    question.bos = VAD_TIMEOUT;
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerMember) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"zl---SPMemberCommondNode Answer type error!");
#endif
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPMemberCommondNode Answer content is nil!");
#endif
        block(nil, nil, NO);
        return;
    }
    if ([answer.content  isEqualToString:@"取消"]) {
        _isSelectPeople = NO;
        SPQuestion *question = [[SPQuestion alloc] init];
        question.type = SPAnswerMember;
        question.content = nil;
        question.isRead = NO;
        question.eos = VAD_MEMBER_EOS;
        question.bos = VAD_TIMEOUT;
        block(nil, question, YES);
        return;
    }
    // 智能引擎不断的通过这个接口给流程节点喂数据
    // 1.如果流程节点判断还需要数据，就在anotherquestion里面把问题给到智能引擎
    // 2.如果流程节点判断人员输入完毕（收到“下一步”命令），把数据抛出给智能引擎
    
    NSString *answerStr = [NSString stringWithFormat:@"%@", answer.content];
    NSArray *answerArr = [answerStr componentsSeparatedByString:@","];
    
    // 识别到“下一步” 且 用户录入了一个人了，把数据返回回去，进入下一步。
    if ([answerStr isEqualToString:SPEECH_END_MEMBER] &&
        self.memberIDList.count != 0) {
        [self nextStep:block];
        return;
    }
    
    if ([answerStr isEqualToString:@""]) {
        [self sleep:block];
//        if (self.memberIDList.count == 0) { // 1.输入第一个人的时候触发前置时间-小致睡眠
//            [self sleep:block];
//        } else if (_isSelectPeople) { // 选人流程中，n秒不说话进入睡眠
//            [self sleep:block];
//        } else if (_isException) {  // 异常处理之后，n秒不说话进入睡眠
//            [self sleep:block];
//        } else {
//            [self nextStep:block]; // 2.输入第二个及以后人时触发后置时间-下一步
//        }
        return;
    }
    
    // 如果人员存在争议，选人
    if (_isSelectPeople) {
        NSInteger selecteOption = [SPTools getOptionNumber:[answerArr firstObject]];
        if (selecteOption != 0 && _optionArray && _optionArray.count >= selecteOption) {
            CMPOfflineContactMember *member = [_optionArray objectAtIndex:([SPTools getOptionNumber:[answerArr firstObject]] - 1) ];
            
            if (![self.memberIDList containsObject:member.orgID]) { // 如果该人没有被选择过，加上
                [self.memberIDList addObject:member.orgID];
                [self.memberNameList addObject:member.name];
            }

            SPQuestion *question = [[SPQuestion alloc] init];
            question.type = SPAnswerMember;
            question.isRead = YES;
            question.eos = VAD_MEMBER_EOS; // 第二次及以后输入前置时间恢复正常
            question.bos = VAD_MEMBER_BOS;
            question.content = @"已选择， 请继续选人或命令“##下一步##”。";
            _isSelectPeople = NO;
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [result setObject:member.name forKey:ANSWERRESULTBLOCK_KEY_NAMES];
            [result setObject:[self memberNames] forKey:ANSWERRESULTBLOCK_KEY_MEMBER_SELECTED];
            block(result, question, NO);
        } else { // 选人失败
            [self selectPeopleFail:block];
        }
        return;
    }
    
    [XZMainProjectBridge memberListForNameArray:answerArr isFlow:YES completion:^(NSArray *result) {
        if (result.count == 0) {
            self->_isException = YES;
            SPQuestion *question = [[SPQuestion alloc] init];
            question.type = SPAnswerMember;
            question.isRead = YES;
            question.eos = VAD_MEMBER_EOS; // 第二次及以后输入前置时间恢复正常
            question.bos = VAD_TIMEOUT;
            if (self.memberIDList.count == 0) {
                question.content = [NSString stringWithFormat:@"对不起，我没有找到%@，请继续选人。", [answerArr firstObject]];
            } else {
                question.content = [NSString stringWithFormat:@"对不起，我没有找到%@，请继续选人或命令##下一步##。", [answerArr firstObject]];
            }
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [result setObject:[answerArr firstObject] forKey:ANSWERRESULTBLOCK_KEY_NAMES];
            [result setObject:@"1" forKey:ANSWERRESULTBLOCK_KEY_NEWLINE];
            block(nil, question, NO);
        } else if (result.count == 1) {
            self->_isException = YES;//OA-128057  M3-IOS端：语音小致发协同，录入流程，录入下一步后未有灰色小字显示已经选择的人员
            CMPOfflineContactMember *member = [result lastObject];
            if (![self.memberIDList containsObject:member.orgID]) { // 如果该人没有被选择过，加上
                [self.memberIDList addObject:member.orgID];
                [self.memberNameList addObject:member.name];
            }
            SPQuestion *question = [[SPQuestion alloc] init];
            question.type = SPAnswerMember;
            question.isRead = NO;
            question.eos = VAD_MEMBER_EOS; // 第二次及以后输入前置时间恢复正常
            question.bos = VAD_MEMBER_BOS;
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [result setObject:member.name forKey:ANSWERRESULTBLOCK_KEY_NAMES];
            [result setObject:@"0" forKey:ANSWERRESULTBLOCK_KEY_NEWLINE];
            [result setObject:[self memberNames] forKey:ANSWERRESULTBLOCK_KEY_MEMBER_SELECTED];
            block(result, question, NO);
        } else if (result.count > 1) { // 进入选人模式
            [self stepInSelectPeople:block result:result memberName:[answerArr firstObject]];
        }
    }];
}


- (void)handleMembers:(NSArray *)array option:(BOOL)option onResult:(AnswerResultBlock)block
{
    _isSelectPeople = NO;
    _isException = YES;
    NSString *name = @"";
    for (CMPOfflineContactMember *member in array) {
        if (![self.memberIDList containsObject:member.orgID]) { // 如果该人没有被选择过，加上
            [self.memberIDList addObject:member.orgID];
            [self.memberNameList addObject:member.name];
            NSString *memberName = option ? [NSString stringWithFormat:@"%@%@",member.department,member.name]: member.name;
            if (name.length == 0) {
                name = memberName;
            }
            else {
                name = [NSString stringWithFormat:@"%@、%@",memberName,name];
            }
        }
    }
   
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerMember;
    question.isRead = YES;
    question.eos = VAD_MEMBER_EOS; // 第二次及以后输入前置时间恢复正常
    question.bos = VAD_MEMBER_BOS;
    question.content = @"已选择， 请继续选人或命令“##下一步##”。";
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:name forKey:ANSWERRESULTBLOCK_KEY_NAMES];
//    [result setObject:@"0" forKey:ANSWERRESULTBLOCK_KEY_NEWLINE];
    [result setObject:[self memberNames] forKey:ANSWERRESULTBLOCK_KEY_MEMBER_SELECTED];
    block(result, question, NO);
}

/**
 下一步
 */
- (void)nextStep:(AnswerResultBlock)block {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:self.key forKey:ANSWERRESULTBLOCK_KEY_KEY];
    [result setObject:[self memberListStr] forKey:ANSWERRESULTBLOCK_KEY_VALUE];
    [result setObject:[self memberNames] forKey:ANSWERRESULTBLOCK_KEY_NAMES];
    [result setObject:[NSString stringWithBool:_isException] forKey:ANSWERRESULTBLOCK_KEY_MEMBER_PROMT];
    block(result, nil, YES);
}


/**
 选人模式下，用户输入命令有误
 */
- (void)selectPeopleFail:(AnswerResultBlock)block {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = _optionArray&&_optionArray.count >0 ?SPAnswerSelectPeopleOption: SPAnswerSelectPeople;
    question.isRead = YES;
    question.content = @"很抱歉，我没有明白，你能再重复一下吗？";
    question.eos = VAD_MEMBER_EOS;
    question.bos = VAD_TIMEOUT;
    _isSelectPeople = YES;
    block(nil, question, NO);
}


/**
 进入选人模式

 @param block 代码块
 @param result 返回结果
 @param memberName 人名
 */
- (void)stepInSelectPeople:(AnswerResultBlock)block result:(NSArray *)result memberName:(NSString *)memberName {
    _isException = YES;
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerSelectPeopleOption;
    question.isRead = YES;
    question.eos = VAD_MEMBER_EOS; // 第二次及以后输入前置时间恢复正常
    question.bos = VAD_TIMEOUT;
    NSString *questionContent = [NSString stringWithFormat:@"第几位%@？ 我为你找到%ld位相关联系人。如无需选择，请“##取消##”", memberName, (unsigned long)result.count];
//    int i = 1;
//    for (CMPOfflineContactMember *member in result) {
//        questionContent = [NSString stringWithFormat:@"%@\n  %d.%@  %@", questionContent, i, member.department, member.name];
//        i++;
//    }
    question.content = questionContent;
    _isSelectPeople = YES;
    _optionArray = [result copy];
    question.optionMembers = [NSArray arrayWithArray:result];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [resultDic setObject:memberName forKey:ANSWERRESULTBLOCK_KEY_NAMES];
    [resultDic setObject:@"1" forKey:ANSWERRESULTBLOCK_KEY_NEWLINE];
    block(resultDic, question, NO);
}

#pragma mark - Getter&Setter

- (NSMutableArray *)memberIDList {
    if (!_memberIDList) {
        _memberIDList = [NSMutableArray array];
    }
    return _memberIDList;
}

- (NSMutableArray *)memberNameList {
    if (!_memberNameList) {
        _memberNameList = [NSMutableArray array];
    }
    return _memberNameList;
}


/**
 把人员ID拼装成显示所需格式
 张三，李四，王五
*/
- (NSString *)memberNames {
    if (self.memberNameList.count == 0 ||
        ![self.memberNameList isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"speech---SPMemberCommondNode:memberListStr err memberList count is 0");
        return @"";
    }
    
    NSString *result = @"";
    for (NSString *member in self.memberNameList) {
        if ([result isEqualToString:@""]) {
            result = [NSString stringWithFormat:@"%@", member];
        } else {
            result = [NSString stringWithFormat:@"%@、%@", result, member];
        }
    }
    return result;
}


/**
 把人员ID拼装成发送数据所需格式
 Member|-113167743872841219,
 */
- (NSString *)memberListStr {
    if (self.memberIDList.count == 0 ||
        ![self.memberIDList isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"speech---SPMemberCommondNode:memberListStr err memberList count is 0");
        return @"";
    }
    
    NSString *result = @"";
    for (NSString *member in self.memberIDList) {
        result = [NSString stringWithFormat:@"%@Member|%@,", result, member];
    }
    // 去掉多余的逗号
    if ([result characterAtIndex:(result.length - 1)] == ',') {
        result = [result substringToIndex:(result.length - 1)];
    }
    return result;
}

- (BOOL)canNextStep {
    return _memberIDList.count >0;
}
- (void)addDefaultMember:(CMPOfflineContactMember *)member {
    if (!member) {
        return;
    }
    [self.memberIDList addObject:member.orgID];
    [self.memberNameList addObject:member.name];
}
@end
