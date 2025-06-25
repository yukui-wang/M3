//
//  SPBaseCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/11.
//
//

#import "SPBaseCommondNode.h"

@implementation SPBaseCommondNode


- (SPBaseCommondNode *)initWithDic:(NSDictionary *)commondDic {
    if (commondDic == nil) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPBaseCommondNode:initWithDic err, commondDic is nil");
#endif
        return nil;
    }
    
    if (![commondDic isKindOfClass:[NSDictionary class]]) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPBaseCommondNode:initWithDic err, commondDic is not a dictionary");
#endif
        return nil;
    }
    
    if (self = [super init]) {
        self.stepIndex = [commondDic objectForKey:COMMOND_KEY_STEPINDEX];
        self.word = [commondDic objectForKey:COMMOND_KEY_WORD];
        self.isReadWord = [commondDic objectForKey:COMMOND_KEY_ISREADWORD];
        self.key = [commondDic objectForKey:COMMOND_KEY_KEY];
        self.type = [commondDic objectForKey:COMMOND_KEY_TYPE];
        self.successStepIndex = [commondDic objectForKey:COMMOND_KEY_SUCCESSSTEPINDEX];
        self.failStepIndex = [commondDic objectForKey:COMMOND_KEY_FAILSTEPINDEX];
        self.isRestart = [commondDic objectForKey:COMMOND_KEY_ISRESTART];
    }    
    return self;
}

- (SPQuestion *)getQuestion {
    return nil;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    return;
}
- (void)handleMembers:(NSArray *)array option:(BOOL)option onResult:(AnswerResultBlock)block{
    return;
}

- (void)sleep:(AnswerResultBlock)block {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerSleep;
    question.isRead = NO;
    block(nil, question, NO);
}


#pragma mark - Getter&Setter

- (BOOL)isRead {
    if ([_isReadWord isEqualToString:@"true"]) {
        return YES;
    } else if ([_isReadWord isEqualToString:@"false"]) {
        return NO;
    } else {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPBaseCommondNode:isRead err, isReadWord`s value is error!");
#endif
        return NO;
    }
}

- (BOOL)needRestart {
    if (!_isRestart) {
        return YES; // 默认重新开始监听
    }
    if ([_isRestart isEqualToString:@"true"]) {
        return YES;
    } else if ([_isRestart isEqualToString:@"false"]) {
        return NO;
    } else {
        NSLog(@"speech---SPBaseCommondNode:isRestart err, isRestart`s value is error!");
        return YES;
    }
}

@end
