//
//  CMPRCUserCacheObject.m
//  CMPCore
//
//  Created by CRMO on 2017/8/22.
//
//

#import "CMPRCUserCacheObject.h"
#import <RongIMKit/RongIMKit.h>
#import <CMPLib/CMPCore.h>
#import <CMPLib/CMPDateHelper.h>

@implementation CMPRCUserCacheObject

- (void)dealloc {
    SY_RELEASE_SAFELY(_sId);
    SY_RELEASE_SAFELY(_mId);
    SY_RELEASE_SAFELY(_groupId);
    SY_RELEASE_SAFELY(_userId);
    SY_RELEASE_SAFELY(_name);
    SY_RELEASE_SAFELY(_updateTime);
    SY_RELEASE_SAFELY(_extra1);
    SY_RELEASE_SAFELY(_extra2);
    SY_RELEASE_SAFELY(_extra3);
    SY_RELEASE_SAFELY(_extra4);
    SY_RELEASE_SAFELY(_extra5);
    SY_RELEASE_SAFELY(_extra6);
    SY_RELEASE_SAFELY(_extra7);
    SY_RELEASE_SAFELY(_extra8);
    SY_RELEASE_SAFELY(_extra9);
    SY_RELEASE_SAFELY(_extra10);
    SY_RELEASE_SAFELY(_extra11);
    SY_RELEASE_SAFELY(_extra12);
    SY_RELEASE_SAFELY(_extra13);
    SY_RELEASE_SAFELY(_extra14);
    SY_RELEASE_SAFELY(_extra15);
    [super dealloc];
}

- (instancetype)initWithRCConversation:(RCConversation *)conversation {
    if (self = [super init]) {
        _sId = [[CMPCore sharedInstance].serverID copy];
        _mId = [[CMPCore sharedInstance].userID copy];
        _groupId = [conversation.targetId copy];
        _userId = @"";
        _name = @"";
        _type = conversation.conversationType;
        NSString *receiveTimeStr = [CMPDateHelper dateStrFromLongLong:conversation.sentTime];
        _updateTime = [receiveTimeStr copy];
    }
    return self;
}

@end
