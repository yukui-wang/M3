//
//  SPSubmitCommondNode.m
//  CMPCore
//
//  Created by CRMO on 2017/2/18.
//
//

#import "SPSubmitCommondNode.h"



@implementation SPSubmitCommondNode

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
    
    if (self = [super initWithDic:commondDic]) {
        // TODO 初始化地址
    }
    
    return self;
}

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerSubmit;
    question.isRead = NO;
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerSubmit) {
        NSLog(@"speech---SPSubmitCommondNode Answer type error!");
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
        NSLog(@"speech---SPSubmitCommondNode Answer content is nil!");
        block(nil, nil, NO);
        return;
    }
    
    // 识别到空字符串，说明触发了前置时间，休眠
    if ([answer.content isEqualToString:@"success"]) {
        block(nil, nil, YES);
    } else {
        block(nil, nil, NO);
    }
}


@end
