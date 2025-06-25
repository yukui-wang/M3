//
//  SPOptionCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/13.
//
//

#import "SPOptionCommondNode.h"

@implementation SPOptionCommondNode

- (SPOptionCommondNode *)initWithDic:(NSDictionary *)commondDic {
    if (self = [super initWithDic:commondDic]) {
        self.optionSteps = [commondDic objectForKey:COMMOND_KEY_OPTIONSTEPS];
        self.alertInfo = [commondDic objectForKey:COMMOND_KEY_ALERTINFO];
    }
    return self;
}


- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerOption;
    question.content = self.word;
    question.isRead = [self isRead];
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerOption) {
        NSLog(@"speech---SPOptionCommondNode Answer type error!");
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
        NSLog(@"speech---SPOptionCommondNode Answer content is nil!");
        block(nil, nil, NO);
        return;
    }
    
    // 识别到空字符串，说明触发了前置时间，休眠
    if ([answer.content isEqualToString:@""]) {
        [self sleep:block];
        return;
    }
    
    for (NSDictionary *option in _optionSteps) {
        if ([[option objectForKey:COMMOND_KEY_OPTIONKEY] isEqualToString:answer.content]) {
            NSDictionary *dic = @{ANSWERRESULTBLOCK_KEY_STEPINDEX : [option objectForKey:COMMOND_KEY_OPTION_STEPINDEX]};
            block(dic, nil, NO);
            return;
        }
    }
    
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerUnknown;
    question.isRead = NO;
    block(nil, question, NO);
    
}

@end
