//
//  CMPScheduleEventRcord.m
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import "CMPScheduleEventRcord.h"
#import "CMPTimeCalEvent.h"
#import "NSString+CMPString.h"
#import "CMPCore.h"

@implementation CMPScheduleEventRcord
- (void)dealloc
{
    [_scheduleLocalID release];
    _scheduleLocalID = nil;
    [_serverIdentifier release];
    _serverIdentifier = nil;
    [_userID release];
    _userID = nil;
    [_syncDate release];
    _syncDate = nil;
    
    [_timeCalEventID release];
    _timeCalEventID= nil;
    [_subject release];
    _subject= nil;
    [_beginDate release];
    _beginDate= nil;
    [_endDate release];
    _endDate= nil;
    [_type release];
    _type= nil;
    [_status release];
    _status= nil;
    [_account release];
    _account= nil;
    [_alarmDate release];
    _alarmDate= nil;
    [_address release];
    _address= nil;
    [_hasRemindFlag release];
    _hasRemindFlag= nil;
    [_addedEvent release];
    _addedEvent= nil;
    
    [_extend1 release];
    _extend1= nil;
    [_extend2 release];
    _extend2= nil;
    [_extend3 release];
    _extend3= nil;
    
    [_extend4 release];
    _extend4= nil;
    [_extend5 release];
    _extend5= nil;
    [_extend6 release];
    _extend6= nil;
    [_extend7 release];
    _extend7= nil;
    
    [_extend8 release];
    _extend8= nil;
    [_extend9 release];
    _extend9= nil;
    [_extend10 release];
    _extend10= nil;
    
    [super dealloc];
}
- (id)initWithMTimeCalEvent:(CMPTimeCalEvent *)mTimeCalEvent
{
    self = [super init];
    if (self) {
        self.timeCalEventID = [NSString stringWithLongLong:mTimeCalEvent.timeCalEventID];
        self.subject = mTimeCalEvent.subject;
        self.beginDate = mTimeCalEvent.beginDate;
        self.endDate = mTimeCalEvent.endDate;
        self.type = mTimeCalEvent.type;
        self.status = mTimeCalEvent.status;
        self.account = @"";
        self.alarmDate = [NSString stringWithLongLong:mTimeCalEvent.alarmDate];
        self.address = @"";
        self.hasRemindFlag = @"no";
        self.repeatType = 0;//mTimeCalEvent.repeatType;
        self.addedEvent = mTimeCalEvent.addedEvent? @"yes" : @"no";
        
        self.serverIdentifier = [[CMPCore sharedInstance] serverID];
        self.userID = [[CMPCore sharedInstance]  userID];
        self.extend1 = @"";
        self.extend2 = @"";
        self.extend3 = @"";
        self.extend4 = @"";
        self.extend5 = @"";
        self.extend6 = @"";
        self.extend7 = @"";
        self.extend8 = @"";
        self.extend9 = @"";
        self.extend10 = @"";
        
    }
    return self;
}


@end
