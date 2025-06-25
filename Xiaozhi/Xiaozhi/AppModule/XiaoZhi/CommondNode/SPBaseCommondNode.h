//
//  SPBaseCommondNode.h
//  MSCDemo
//  说明：命令节点的基类，命令节点分为两类
//  1.有用户交互类
//  2.无用户交互类
//
//  Created by CRMO on 2017/2/11.
//

#import <Foundation/Foundation.h>
#import "SPQuestion.h"
#import "SPAnswer.h"
#import "SPConstant.h"

typedef void(^AnswerResultBlock)(NSDictionary *result, SPQuestion *anotherQuestion, BOOL isSuccess);

@interface SPBaseCommondNode : NSObject

@property (nonatomic, strong) NSString *commondID;
@property (strong, nonatomic) NSString *stepIndex;
@property (strong, nonatomic) NSString *word;
@property (strong, nonatomic) NSString *isReadWord;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *successStepIndex;
@property (strong, nonatomic) NSString *failStepIndex;
@property (strong, nonatomic) NSString *isRestart;
@property (strong, nonatomic) SPBaseCommondNode *sucessStep;
@property (strong, nonatomic) SPBaseCommondNode *failStep;

- (SPBaseCommondNode *)initWithDic:(NSDictionary *)commondDic;

- (SPQuestion *)getQuestion;
- (void)Answer:(SPAnswer *)answer onResult:(AnswerResultBlock)block;
- (void)handleMembers:(NSArray *)array option:(BOOL)option onResult:(AnswerResultBlock)block;

- (BOOL)isRead;
- (BOOL)needRestart;
/**
 睡眠
*/
- (void)sleep:(AnswerResultBlock)block;

@end
