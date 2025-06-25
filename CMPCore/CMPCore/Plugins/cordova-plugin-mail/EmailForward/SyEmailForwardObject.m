//
//  SyEmailForwardObject.m
//  M1Core
//
//  Created by kaku_songu on 14-11-4.
//
//

#import "SyEmailForwardObject.h"

@implementation SyEmailForwardObject

- (void)dealloc
{
    [_attaName release];
    _attaName = nil;
    [_subjectString release];
    [_messageBodyString release];
    [_attachmentData release];
    [_attachmentType release];
    [_receiver release];
    [super dealloc];
}

@end
