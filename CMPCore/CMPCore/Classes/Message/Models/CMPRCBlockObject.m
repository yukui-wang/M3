//
//  CMPRCGetUserNameBlockObj.m
//  CMPCore
//
//  Created by CRMO on 2017/8/22.
//
//

#import "CMPRCBlockObject.h"

@implementation CMPRCBlockObject

- (void)dealloc {
    [_userNameDoneBlock release];
    _userNameDoneBlock = nil;
    [_allMemberOfGroupResultBlock release];
    _allMemberOfGroupResultBlock = nil;
    [super dealloc];
}

@end
