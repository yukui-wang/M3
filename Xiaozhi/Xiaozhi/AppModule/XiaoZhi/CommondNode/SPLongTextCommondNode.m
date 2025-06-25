//
//  SPLongTextCommondNode.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/13.
//
//

#import "SPLongTextCommondNode.h"
#import "SPTools.h"
@interface SPLongTextCommondNode() {
    BOOL _must;//必填
}

@property (nonatomic, strong) NSMutableString *longtext;
@property (nonatomic, strong) NSString *mustWord;

@end

@implementation SPLongTextCommondNode
- (SPBaseCommondNode *)initWithDic:(NSDictionary *)commondDic {
    if (self = [super initWithDic:commondDic]) {
        _must = [[commondDic objectForKey:@"must"] boolValue];
        self.mustWord =  [commondDic objectForKey:@"mustWord"];
    }
    return self;
}

- (SPQuestion *)getQuestion {
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerLongText;
    question.content = self.word;
    question.isRead = YES;
    return question;
}

- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block {
    if (answer.type != SPAnswerLongText) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPLongTextCommondNode Answer type error!");
#endif
        block(nil, nil, NO);
        return;
    }
    
    if (answer.content == nil) {
#ifdef SPEECH_DEBUG_MODE
        NSLog(@"speech---SPLongTextCommondNode Answer content is nil!");
#endif
        block(nil, nil, NO);
        return;
    }
    
    NSString *text = answer.content;
    
    // 识别到空字符串，说明触发了前置时间，休眠
    if ([text isEqualToString:@""]) {
        [self sleep:block];
        return;
    }
    
    [self.longtext appendString:text];
    
    NSString *tmpStr = [SPTools deletePunc:self.longtext];
    if (tmpStr.length > 3) {
        NSString *subfixString = [tmpStr substringFromIndex:(tmpStr.length - 4)];
        if ([SPTools stringCodeCompare:subfixString withString:@"好了小致" distence:5]) {
            NSInteger length = [SPTools getMainText:self.longtext].length;
            if (_must && length == 0) {
                self.longtext = [NSMutableString string];
                SPQuestion *question = [[SPQuestion alloc] init];
                question.type = SPAnswerLongText;
                question.content = self.mustWord;
                question.isRead = YES;
                block(nil, question, NO);
            }
            else {
                [self endOfLongText:block];
            }
            return;
        }
    }
    [self moreText:block];
}

- (NSMutableString *)longtext {
    if (!_longtext) {
        _longtext = [NSMutableString string];
    }
    return _longtext;
}

- (void)moreText:(AnswerResultBlock)block {
    NSLog(@"speech---没有识别到长文本结束词,继续识别");
    SPQuestion *question = [[SPQuestion alloc] init];
    question.type = SPAnswerLongText;
    question.isRead = NO;
    block(nil, question, NO);
}

- (void)endOfLongText:(AnswerResultBlock)block {
    NSLog(@"speech---识别到长文本结束词,结束识别");
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:self.key forKey:ANSWERRESULTBLOCK_KEY_KEY];
    [result setObject:[SPTools getMainText:self.longtext] forKey:ANSWERRESULTBLOCK_KEY_VALUE];
    block(result, nil, YES);
}



@end
