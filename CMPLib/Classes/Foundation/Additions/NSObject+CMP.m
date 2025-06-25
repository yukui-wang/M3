//
//  NSObject+CMP.m
//  CMPLib
//
//  Created by SeeyonMobileM3MacMini2 on 2021/9/1.
//  Copyright © 2021 crmo. All rights reserved.
//

#import "NSObject+CMP.h"
#import <objc/runtime.h>

static char kNSObjectCMPIdentifierKey;

@implementation NSObject (CMP)

-(void)setCmpIdentifier:(NSString *)cmpIdentifier
{
    objc_setAssociatedObject(self, &kNSObjectCMPIdentifierKey, cmpIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)cmpIdentifier
{
    return objc_getAssociatedObject(self, &kNSObjectCMPIdentifierKey);
}

@end
