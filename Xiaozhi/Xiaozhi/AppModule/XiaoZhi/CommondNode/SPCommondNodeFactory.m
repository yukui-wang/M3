//
//  SPCommondNodeFactory.m
//  MSCDemo
//
//  Created by CRMO on 2017/2/12.
//
//

#import "SPCommondNodeFactory.h"

@implementation SPCommondNodeFactory

+ (SPBaseCommondNode *)initCommondNode:(NSDictionary *)commondDic {
    if (commondDic == nil) {
        return nil;
    }
    if (![commondDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *type = [commondDic objectForKey:COMMOND_KEY_TYPE];
    if (type == nil) {
        return nil;
    }
    SPBaseCommondNode *commondNode;
    if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerShortText) {
        commondNode = [[SPShortTextCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerLongText) {
        commondNode = [[SPLongTextCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerMember) {
        commondNode = [[SPMemberCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerOption) {
        commondNode = [[SPOptionCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerPrompt) {
        commondNode = [[SPPromptCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerSubmit) {
        commondNode = [[SPSubmitCommondNode alloc] initWithDic:commondDic];
    }
    else if ([SPCommondNodeFactory getAnswerTypeWithType:type] == SPAnswerView) {
        commondNode = [[SPViewCommondNode alloc] initWithDic:commondDic];
    }
    else {
        commondNode = [[SPBaseCommondNode alloc] init];
    }
    return commondNode;
}

+ (SPAnswerType)getAnswerTypeWithType:(NSString *)type {
    if ([type isEqualToString:COMMOND_VALUE_TYPE_SHORTTEXT]) {
        return SPAnswerShortText;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_LONGTEXT]) {
        return SPAnswerLongText;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_MEMBER]) {
        return SPAnswerMember;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_OPTION]) {
        return SPAnswerOption;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_PROMPT]) {
        return SPAnswerPrompt;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_SUBMIT]) {
        return SPAnswerSubmit;
    }
    else if([type isEqualToString:COMMOND_VALUE_TYPE_VIEW]) {
        return SPAnswerView;
    }
    else {
        return SPAnswerUnknown;
    }
}

@end
