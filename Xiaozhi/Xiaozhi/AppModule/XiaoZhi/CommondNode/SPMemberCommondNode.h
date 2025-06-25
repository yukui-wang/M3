//
//  SPMemberCommondNode.h
//  MSCDemo
//
//  Created by CRMO on 2017/2/13.
//
//

#import "SPBaseCommondNode.h"
@class CMPOfflineContactMember;
@interface SPMemberCommondNode : SPBaseCommondNode
/* 人员名字数组  */
@property (nonatomic, strong) NSMutableArray *memberNameList;

- (BOOL)canNextStep;
- (void)addDefaultMember:(CMPOfflineContactMember *)member;
@end
