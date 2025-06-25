//
//  SPViewCommondNode.m
//  查看节点
//
//  Created by CRMO on 2017/2/20.
//
//

#import "SPViewCommondNode.h"

@interface SPViewCommondNode()

@end

@implementation SPViewCommondNode

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerView;
    question.content = self.word;
    question.isRead = NO;
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerView) {
        NSLog(@"zl---SPViewCommondNode Answer type error!");
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
        NSLog(@"zl---SPViewCommondNode Answer content is nil!");
        block(nil, nil, NO);
        return;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:self.key forKey:ANSWERRESULTBLOCK_KEY_KEY];
    [result setObject:answer.content forKey:ANSWERRESULTBLOCK_KEY_VALUE];
    
    block(result, nil, YES);
}



@end
