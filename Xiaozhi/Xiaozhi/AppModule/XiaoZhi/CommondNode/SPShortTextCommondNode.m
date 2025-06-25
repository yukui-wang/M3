//
//  SPShortTextCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import "SPShortTextCommondNode.h"
#import "XZCore.h"
@interface SPShortTextCommondNode (){
    NSInteger _textLenghtLimit;
}
@end

@implementation SPShortTextCommondNode

- (SPBaseCommondNode *)initWithDic:(NSDictionary *)commondDic {
    if (self = [super initWithDic:commondDic]) {
        _textLenghtLimit = [[commondDic objectForKey:@"textLenghtLimit"] integerValue];
        [XZCore sharedInstance].textLenghtLimit = _textLenghtLimit;
    }
    return self;
}

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerShortText;
    question.content = self.word;
    question.isRead = YES;
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerShortText) {
        NSLog(@"zl---SPShortTextCommondNode Answer type error!");
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
        NSLog(@"zl---SPShortTextCommondNode Answer content is nil!");
        block(nil, nil, NO);
        return;
    }
    
    NSString *shortText = answer.content;
    if (_textLenghtLimit>0 && shortText.length > _textLenghtLimit) {
        SPQuestion *question = [[SPQuestion alloc] init];
        question.type = SPAnswerShortText;
        question.isRead = YES;
        question.content = [NSString stringWithFormat:@"对不起，你录入的标题已超出%ld字，请重新录入。", (long)_textLenghtLimit];
        block(nil, question, NO);
        return;
    }
    
    if (shortText.length == 0) {
        [self sleep:block];
        return;
    }

    [XZCore sharedInstance].textLenghtLimit = 0;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:self.key forKey:ANSWERRESULTBLOCK_KEY_KEY];
    [result setObject:answer.content forKey:ANSWERRESULTBLOCK_KEY_VALUE];
    block(result, nil, YES);
}

@end
