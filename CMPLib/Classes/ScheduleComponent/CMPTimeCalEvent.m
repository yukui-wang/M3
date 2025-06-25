//
//  CMPTimeCalEvent.m
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import "CMPTimeCalEvent.h"

@implementation CMPTimeCalEvent
- (void)dealloc
{
    [_subject release];
    [_beginDate release];
    [_endDate release];
    [_type release];
    [_status release];
    [_senderName release];
    
    [super dealloc];
}

@end
