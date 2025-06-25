//
//  XZCreateFormModel.m
//  M3
//
//  Created by wujiansheng on 2018/8/10.
//



#define kTimeType_Date @"date" //日期类型；（yyyy-MM-dd）；
#define kTimeType_DateTime @"datetime" //日期时间类型（yyyy-MM-dd HH:mm:ss）；
#define kTimeType_Time @"time" //时间类型（HH:mm:ss）；
#define kTimeType_Timestamp @"timestamp" //timestamp:时间戳类型（1212121212212）；
#import "XZCreateFormModel.h"
#import "SPTools.h"
#import "XZMainProjectBridge.h"

@interface XZCreateFormModel () {
    BOOL _inputEnd;//内容录入完成了
    BOOL _isSelectPeople;    /* 是否正在选人流程(同名) */


}

@property(nonatomic, retain)NSDictionary *extData;
@property(nonatomic, retain)NSDictionary *steps;
@property(nonatomic, retain)NSDictionary *currentStep;
@property(nonatomic, retain)NSMutableArray *resultList;
@property(nonatomic, retain)NSMutableString *longtext;
@property(nonatomic, retain)NSMutableArray *members;

@property(nonatomic, retain)BUnitResult *currentUnitValue;
@property(nonatomic, retain)NSArray *optionMembers;


@end

@implementation XZCreateFormModel


- (void)dealloc {
    self.extData = nil;
    self.steps = nil;
    self.currentStep = nil;
    self.resultList = nil;
    self.longtext = nil;
    self.needSayBlock = nil;
    self.needLongTextBlock = nil;
    self.needShortTextBlock = nil;
    self.needMembersBlock = nil;
    self.needCancelBlock = nil;
    self.needCreateFormBlock = nil;
    self.needShowFormBlock = nil;
    self.needChooseFormOptionMembersBlock = nil;
    self.needShowChoosedMembersBlock = nil;
    self.needChooseMembersFinishBlock = nil;
    self.needSleepBlock = nil;
    self.needContinueRecognizeBlock = nil;

    self.members = nil;
    self.needUnitBlock = nil;
    self.currentUnitValue = nil;
    self.optionMembers = nil;
}

- (id)initWithJsonFile:(NSDictionary *)dic {
    if (self = [super initWithJsonFile:dic]) {
        self.extData = dic[@"extData"];
        self.steps = dic[@"steps"];
        self.currentStep = self.steps[@"1"];
        self.longtext = [NSMutableString stringWithString:@""];
        _inputEnd = NO;
        _isSelectPeople = NO;
    }
    return self;
}

- (void)handleUnitResult:(BUnitResult *)dic {
    self.longtext = [NSMutableString stringWithString:@""];
    NSString *type = self.currentStep[@"type"];
    NSString *next = self.currentStep[@"next"];
    if ([type isEqualToString:@"unit"] ) {
        NSString *key = self.currentStep[@"key"];
        NSString *name = self.currentStep[@"name"];
        NSString *display = self.currentStep[@"display"];
        NSString *value = nil;
        NSDictionary *info =  dic.infoDict;
        
        if ([key isEqualToString:@"options"]) {
//            NSDictionary *keyValue = self.currentStep[@"keyValue"];
//            for (NSString *keyS in keyValue.allKeys) {
//                if([dic.allKeys containsObject:keyS]) {
//                    info = dic[keyS];
//                }
//            }
        }
        else {
            if([key isEqualToString:@"user_begintime"]) {
                value = [self timeValueWithTime:info[key] appendStr:@"08:30:00"];
            }
            else if([key isEqualToString:@"user_endtime"]) {
                value = [self timeValueWithTime:info[key] appendStr:@"17:30:00"];
            }
            else {
               value = info[key];
            }
        }
        if (name&&display&&value) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",display,@"display",value,@"value", nil];
            [_resultList addObject:dic];
            if ( next.integerValue != -1) {
                self.currentStep = self.steps[next];
                [self handleUnitResult:self.currentUnitValue];
            }
            else {
                [self endStep];
            }
        }
        else {
            self.needSayBlock(dic.say);
            self.needUnitBlock(YES);
        }
    }
    else {
        [self handleStep];
    }
}
- (NSString *)timeValueWithTime:(NSString *)time appendStr:(NSString *)appdStr{
    if (!time) {
        return nil;
    }
    NSDictionary *attr = self.currentStep[@"attr"];
    NSString *timeType = attr[@"type"];
    if ([NSString isNull:timeType]) {
        timeType = kTimeType_Timestamp;
    }
    NSString *result = [time replaceCharacter:@"|" withString:@" "];
    result = [result replaceCharacter:@"-00" withString:@"-01"];
    if ([result rangeOfString:@"-"].location == NSNotFound &&[result rangeOfString:@":"].location != NSNotFound) {
        //只有时间
        if ([timeType isEqualToString:kTimeType_Time]) {
            return result;
        }
        else if ([timeType isEqualToString:kTimeType_Date]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
            return dateStr;
        }
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
            result = [NSString stringWithFormat:@"%@ %@",dateStr,result];
        }
    }
    if (result.length ==10 && ![timeType isEqualToString:kTimeType_Date]) {
        //这个代表只有日期，没有时间
        result = [NSString stringWithFormat:@"%@ %@",time,appdStr];
    }
    if ([timeType isEqualToString:kTimeType_Date]) {
        return [result substringToIndex:10];
    }
    else if ([timeType isEqualToString:kTimeType_DateTime]) {
        return result;
    }
    else if ([timeType isEqualToString:kTimeType_Time]) {
        return [result substringFromIndex:11];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (result.length >16) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else if (result.length == 16) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormatter dateFromString:result];
    long long timeInterval = [date timeIntervalSince1970] *1000;
    return [NSString stringWithLongLong:timeInterval];
}

- (void)setupWithUnitResult:(BUnitResult *)dic {
    if (!_resultList ) {
        _resultList = [[NSMutableArray alloc] init];
    }
    self.currentUnitValue  = dic;
    [self handleUnitResult:self.currentUnitValue];
}

- (void)setSpeechString:(NSString *)str {
    if (_inputEnd) {
        [self handleFinishString:str];
        return;
    }
    NSString *key = self.currentStep[@"key"];
    
    if ([key isEqualToString:@"subject"]) {
        NSString *name = self.currentStep[@"name"];
        NSString *display = self.currentStep[@"display"];
        NSString *value = str;
        if (name&&display&&value) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",display,@"display",value,@"value", nil];
            [_resultList addObject:dic];
        }
        [self nextStep];
    }
    else if ([key isEqualToString:@"content"]) {
        [self.longtext appendString:str];
        NSString *tmpStr = [SPTools deletePunc:self.longtext];
        if (tmpStr.length > 3) {
            NSString *subfixString = [tmpStr substringFromIndex:(tmpStr.length - 4)];
            if ([SPTools stringCodeCompare:subfixString withString:@"好了小致" distence:5]) {
                NSString *value = [SPTools getMainText:self.longtext];
                if(value && value.length >0) {
                    NSString *name = self.currentStep[@"name"];
                    NSString *display = self.currentStep[@"display"];
                    if (name&&display&&value) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",display,@"display",value,@"value", nil];
                        [_resultList addObject:dic];
                    }
                    [self nextStep];
                }
                else {
                    self.longtext = [NSMutableString string];
                    NSString *display = self.currentStep[@"display"];
                    NSString *say = [NSString stringWithFormat:@"请录入%@， 完成后说出命令“##好了小致##”。",display];
                    self.needLongTextBlock(say);
                    self.needContinueRecognizeBlock();
                }
                return;
            }
        }
        
    }
    else if ([key isEqualToString:@"members"]) {
        if ([str isEqualToString:@"下一步"]) {
            if (_members.count >0) {
                NSMutableString *nameStr = [NSMutableString string];

                NSMutableArray *memberValue = [NSMutableArray array];
                for (NSInteger i = 0; i < _members.count; i++) {
                    CMPOfflineContactMember *member = [_members objectAtIndex:i];
                    if (i == 0 ) {
                        [nameStr appendString:member.name];
                    }
                    else  {
                        [nameStr appendFormat:@"、%@",member.name];
                    }
                    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:member.orgID,@"id",member.name,@"name",@"Member",@"type", nil];
                    [memberValue addObject:d];
                }
                NSString *name = self.currentStep[@"name"];
                NSString *display = self.currentStep[@"display"];
                if (name&&display) {
                    NSString *value = [memberValue JSONRepresentation];
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",display,@"display",value,@"value", nil];
                    [_resultList addObject:dic];
                }
                self.needChooseMembersFinishBlock(nameStr);
                [self nextStep];
            }
            else {
                NSString *display = self.currentStep[@"display"];
                NSString *say = [NSString stringWithFormat:@"对不起，你还没有告诉我%@是谁?",display];
                self.needMembersBlock(say);
            }
        }
        else {
            [self checkMember:str];
        }
    }
}

- (void)checkMember:(NSString *)name {
    if ([name isEqualToString:@"取消"]) {
        _isSelectPeople = NO;
        return;
    }
    if (_isSelectPeople) {
        NSInteger selecteOption = [SPTools getOptionNumber:name];
        if (selecteOption != 0 && self.optionMembers && self.optionMembers.count >= selecteOption) {
            CMPOfflineContactMember *member = [self.optionMembers objectAtIndex:(selecteOption - 1) ];
            [self setSpeechMembers:[NSArray arrayWithObject:member] showNames:NO];
            self.optionMembers = nil;
            self.needSayBlock(@"已选择， 请继续选人或命令“##下一步##”。");
        } else { // 选人失败
            self.needSayBlock(@"很抱歉，我没有明白，你能再重复一下吗？");
        }
        return;
    }
     __weak typeof(self) weakSelf = self;
    [XZMainProjectBridge memberListForPinYin:name completion:^(NSArray *result) {
        if (result.count == 0) {
            self->_isSelectPeople = NO;
            NSString *speak = [NSString stringWithFormat:@"对不起，我没有找到%@，请继续选人或命令##下一步##。", name];
            weakSelf.needSayBlock(speak);
            weakSelf.needContinueRecognizeBlock();
        }
        else if (result.count == 1) {
            self->_isSelectPeople = NO;
            [weakSelf setSpeechMembers:result showNames:NO];
            weakSelf.needSleepBlock();
            weakSelf.needMembersBlock(@"小致将持续为你服务 ,请继续选人或者命令“##下一步##”。");
            weakSelf.needContinueRecognizeBlock();
        }
        else {
            weakSelf.optionMembers = result;
            self->_isSelectPeople = YES;
            NSString *speak = [NSString stringWithFormat:@"第几位%@？", name];
            NSString *info = [NSString stringWithFormat:@"%@我为你找到%ld位相关联系人。 如无需选择，请“##取消##”", speak, (unsigned long)result.count];
            XZOptionMemberParam *param = [[XZOptionMemberParam alloc] init];
            param.speakContent = speak;
            param.showContent = info;
            param.members = result;
            weakSelf.needChooseFormOptionMembersBlock(param);
        }
    }];
}

- (void)setSpeechMembers:(NSArray *)members{
    [self setSpeechMembers:members showNames:YES];
    self.needMembersBlock(@"小致将持续为你服务 ,请继续选人或者命令“##下一步##”。");
}

- (void)setSpeechMembers:(NSArray *)members showNames:(BOOL)show{
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
    }
    [_members addObjectsFromArray:members];
    if (show) {
        NSMutableString *names = [NSMutableString string];
        for (NSInteger i = 0; i < members.count; i++) {
            CMPOfflineContactMember *member = [members objectAtIndex:i];
            if (i == 0 ) {
                [names appendFormat:@"%@",member.name];
            }
            else  {
                [names appendFormat:@"、%@",member.name];
            }
        }
        self.needShowChoosedMembersBlock(names);
    }
}


- (void)nextStep {
    NSString *next = self.currentStep[@"next"];
    if (next.integerValue == -1) {
        //结束了
        [self endStep];
        return;
    }
    self.currentStep = self.steps[next];
    self.longtext = [NSMutableString stringWithString:@""];
    [self handleStep];

}
- (void)handleStep {
    NSString *display = self.currentStep[@"display"];
    NSString *key = self.currentStep[@"key"];
    NSString *type = self.currentStep[@"type"];
    if ([key isEqualToString:@"subject"]) {
        NSString *say = [NSString stringWithFormat:@"好的，%@是？",display];
        self.needShortTextBlock(say);
    }
    else if ([key isEqualToString:@"content"]) {
        NSString *say = [NSString stringWithFormat:@"好的，请录入%@， 完成后说出命令“##好了小致##”。",display];
        self.needLongTextBlock(say);
    }
    else if ([key isEqualToString:@"members"]) {
        NSString *say = [NSString stringWithFormat:@"好的，请录入%@， 完成后说出命令“##下一步##”。",display];
        self.needMembersBlock(say);
    }
    else if ([type isEqualToString:@"unit"]) {
        [self handleUnitResult:self.currentUnitValue];
        self.needContinueRecognizeBlock();
    }
}


- (void)endStep {
    _inputEnd = YES;
    self.needSayBlock(@"好的，需要现在发送吗？ 你可以命令“##查看##”、“##发送##”或“##取消##”。");
    self.needUnitBlock(NO);
}

- (void)handleFinishString:(NSString *)str {
    NSArray *cancel = [NSArray arrayWithObjects:@"取消",@"放弃", nil];
    NSArray *create = [NSArray arrayWithObjects:@"发送",@"提交", nil];
    NSArray *show = [NSArray arrayWithObjects:@"查看",@"浏览",@"看看", nil];
    if ([cancel containsObject:str]) {
        self.needCancelBlock(@"好的，已经取消。");
    }
    else if ([create containsObject:str]) {
        self.needCreateFormBlock(self.requestParam);
    }
    else if ([show containsObject:str]) {
        self.needShowFormBlock(self.requestParam);
    }
    else {
        self.needSayBlock(@"很抱歉，我没有明白，你能再重复一下吗？");
    }
}


- (NSString *)submitUrl {
    return @"/rest/xiaozhi/createAppData";
}

- (NSString *)showUrl {
    return @"http://application.m3.cmp/v/layout/xiaozhi-transit-page.html";
}

- (NSDictionary *)requestParam {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.extData forKey:@"extData"];
    [dic setObject:_resultList forKey:@"sendParms"];
    return dic;
}

- (NSDictionary *)speechInput {
    return [self requestParam];
}
@end
