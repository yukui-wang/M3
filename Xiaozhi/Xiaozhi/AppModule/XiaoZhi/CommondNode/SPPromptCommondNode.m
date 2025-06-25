//
//  SPPromptCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/13.
//
//

#import "SPPromptCommondNode.h"

@implementation SPPromptCommondNode

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerPrompt;
    question.content = self.word;
    question.isRead = YES;
    return question;
}


@end
