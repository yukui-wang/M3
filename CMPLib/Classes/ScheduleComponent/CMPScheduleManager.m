//
//  CMPScheduleManager.m
//  CMPCore
//
//  Created by yang on 2017/2/22.
//
//

#import "CMPScheduleManager.h"
#import "CMPCore.h"
#import "CMPDataProvider.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CMPTimeCalEvent.h"
#import "CMPScheduleEventRcord.h"
#import "CMPDateHelper.h"
#import "AFNetworkReachabilityManager.h"
#import "CMPCommonDBProvider.h"

#define kCmpRequestIDSchedule @"CmpRequestIDSchedule"

@interface CMPScheduleManager ()<CMPDataProviderDelegate>
{
}

@property (nonatomic,retain) NSTimer  *scheduleSyncTimer;
@property (nonatomic,retain) EKEventStore *eventStore;

@end

@implementation CMPScheduleManager

- (void)initGlobleManager {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSync) name:kNotificationName_UserLogout object:nil];
}

+ (CMPScheduleManager*)sharedManager
{
    static dispatch_once_t once;
    static CMPScheduleManager *instance = nil;
    dispatch_once(&once, ^{
        instance = [[super allocWithZone:NULL] init];
        [instance initGlobleManager];
        instance.scheduleSyncTimer = nil;
    });
    return instance;
}

- (NSString *)lastSyncTime
{
    NSString *configIdentifier = [self configIdentifier];
    NSString *lastSyncTime = [NSString stringWithFormat:@"%@_lastTime",configIdentifier];
    NSString *lt = [[NSUserDefaults standardUserDefaults] objectForKey:lastSyncTime];
    return lt;
}

- (void)setLastSyncTime:(NSString *)lastTime
{
    NSString *configIdentifier = [self configIdentifier];
    NSString *lastSyncTime = [NSString stringWithFormat:@"%@_lastTime",configIdentifier];
    
    [[NSUserDefaults standardUserDefaults] setObject:lastTime forKey:lastSyncTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)configIdentifier
{
    CMPCore *cmpCore = [CMPCore sharedInstance];
    NSString *userID = [cmpCore userID];
    NSString *serverID = [cmpCore serverID];
    return  [NSString stringWithFormat:@"serverID_%@_userID_%@_%@",serverID,userID,@"cmp_plugin_schedule_config"];
}

//读取当前登录人的日程配置信息
- (NSDictionary *)readConfig
{
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    NSString *iden = [self configIdentifier];
    NSDictionary *dict = [userDefualt objectForKey:iden];
    return  dict;
}

//保存日程配置信息到当前登录人
- (void)writeConfig:(NSDictionary *)config
{
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    NSString *iden = [self configIdentifier];
    [userDefualt setObject:config forKey:iden];
    [userDefualt synchronize];
}

//从配置信息中判断是否为自动同步
- (BOOL)fetchAutoSyncFromConfig:(NSDictionary *)dict
{
    BOOL autoSync = false;
    autoSync = [[dict objectForKey:@"autoSync"] boolValue];
    return autoSync;
}

- (BOOL)checkSyncEnvironmentIgnoreNet:(BOOL)aIgnoreNet
{
    NSString *jsessionId =[[CMPCore sharedInstance] jsessionId];
    if(!jsessionId || [jsessionId isEqualToString:@""]) {
        return NO;
    }
    //非wifi不同步
//    if(![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi] && !aIgnoreNet) {
//        return NO;
//    }
    //判断app时候有访问本地日历的权限
    EKAuthorizationStatus status =  [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    if(status != EKAuthorizationStatusAuthorized){
        return NO;
    }
    //如果本地没有存储日程同步的配置信息或者未开启自动同步，直接return
    NSDictionary *config = [self readConfig];
    if(config == nil || config.allKeys.count == 0) {
        return NO;
    }
    //配置文件中如果apps的数组为空也不同步
    NSArray *apps = [config objectForKey:@"apps"];
    if(apps == nil || apps.count == 0) {
        return NO;
    }
    return YES;
}

- (void)forceSync
{
    if ([self checkSyncEnvironmentIgnoreNet:YES]) {
        [self requestScheduleEventFromServer];
    }
}

//开始同步
- (void)startSync
{
    NSDictionary *config = [self readConfig];
    BOOL autoSync = [self fetchAutoSyncFromConfig:config];
    
    if(!autoSync)
        return;
    
    [self startTimer];
}

- (void)stopSync
{
    [self stopTimer];
    //如果当前下载队列有，立即停止
    [[CMPDataProvider sharedInstance] cancelWithRequestId:kCmpRequestIDSchedule];
}

//定时器开启
- (void)startTimer
{
    [self stopTimer];
    long long interval = 1800;
    NSDictionary *config = [self readConfig];
    NSNumber *intervalUser =[config objectForKey:@"interval"];
    
    if(intervalUser){
        interval = [intervalUser longLongValue];
    }
    NSLog(@"日历同步:同步时间间隔%lld s",interval);
    self.scheduleSyncTimer = [NSTimer scheduledTimerWithTimeInterval:(double)interval target:self selector:@selector(requestScheduleEventFromServer) userInfo:nil repeats:YES];
    [_scheduleSyncTimer fire];
    NSLog(@"~~~~~~~~~~~~~同步日程定时器开始");
}

//关闭定时器
- (void)stopTimer
{
    if(_scheduleSyncTimer){
        [_scheduleSyncTimer invalidate];
        SY_RELEASE_SAFELY(_scheduleSyncTimer);
        NSLog(@"日程同步:同步定时器关闭");
    }
}

- (void)requestScheduleEventFromServer
{
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    NSString *url = [CMPCore sharedInstance].serverurl;
    if (![NSString isNull:url]) {
        NSString *urlStr = [CMPCore fullUrlForPath:@"/rest/events/sync/arrangetimes"];
        aDataRequest.requestUrl = urlStr;
    }
    aDataRequest.delegate = self;
    aDataRequest.requestID = kCmpRequestIDSchedule;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    NSDictionary *config = [self readConfig];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *apps = [config objectForKey:@"apps"];
    NSString *lastTime = [self lastSyncTime];
    if (lastTime) {
        [params setObject:lastTime forKey:@"preSyncTime"];
    }
    [params setObject:apps forKey:@"apps"];
    [params setObject:[NSNumber numberWithLongLong:545583600000] forKey:@"startTime"];
    [params setObject:[NSNumber numberWithLongLong:LONG_LONG_MAX] forKey:@"endTime"];
    aDataRequest.requestParam = [params JSONRepresentation];
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    [aDataRequest release];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error
{
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse
{
    [self handleData:aResponse.responseStr];
}

- (void)handleData:(NSString *)jsonStr
{
    NSDictionary *dict = [jsonStr JSONValue];
    NSArray *eventArr = [dict objectForKey:@"datas"];
    NSMutableArray *calEvents = [NSMutableArray array];
    for (int i = 0;  i < eventArr.count; i++) {
        NSDictionary *d = eventArr[i];
        CMPTimeCalEvent *event = [[CMPTimeCalEvent alloc] init];
        event.timeCalEventID = [[d objectForKey:@"timeCalEventID"] longLongValue];
        
        long long beginDate = [[d objectForKey:@"beginDate"] longLongValue];
        event.beginDate = [NSString stringWithLongLong:beginDate];
        
        long long endDate = [[d objectForKey:@"endDate"] longLongValue];
        event.endDate = [NSString stringWithLongLong:endDate];
        
        event.type = [d objectForKey:@"type"];
        event.subject = [d objectForKey:@"subject"];
        event.addedEvent = [[d objectForKey:@"addedEvent"] boolValue];
        [calEvents addObject:event];
        [event release];
    }
    [self updateLocalDB:calEvents];
    // 设置同步本次同步时间
    NSNumber *lastTime = [dict objectForKey:@"syncTime"];
    [self setLastSyncTime:[lastTime stringValue]];
}

//同步日程事件到手机
- (void)updateLocalDB:(NSArray *)array
{
    if (array.count == 0) {
        return;
    }
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    BOOL result = YES;
    NSString *serverIdentifier = [[CMPCore sharedInstance] serverID];
    NSString *userID = [[CMPCore sharedInstance] userID];
    NSInteger count = array.count;
    for (int i = 0; i < count; i++) {
        CMPTimeCalEvent *mTimeCalEvent = (CMPTimeCalEvent *)[array objectAtIndex:i];
        NSMutableArray *eventIDList = [[[NSMutableArray alloc] init] autorelease];
        NSString *scheduleID = [NSString stringWithLongLong:mTimeCalEvent.timeCalEventID];
        
        CMPCommonDBProvider *provider = [CMPCommonDBProvider sharedInstance];
        __block BOOL isExist = NO;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [provider isExistsScheduleWithID:scheduleID serverID:serverIdentifier userID:userID onCompletion:^(NSArray *result) {
            if (!result || result.count == 0) {
                dispatch_semaphore_signal(semaphore);
                return;
            }
            isExist = YES;
            [eventIDList addObjectsFromArray:result];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 如果存在，1）、判断是否更新，如果更新了，需要删除重新添加；2）、如果没有更新，不做任何操作
        if (isExist) {
            // 修改本地日程
            /* 修改客户bug，直接删除本地，然后同步到本地 BUG_普通_V7.1sp1__江苏明鹿物联技术股份有限公司_ios创建会议同步到本地日历，但修改会议时间或取消会议，有严重的延迟。本地回显，安卓正常。_BUG2020052604134*/
            [provider deleteScheduleRecordWithID:scheduleID
                                            serverID:serverIdentifier
                                              userID:userID
                                        onCompletion:nil];
            for (NSString *aEventID in eventIDList) {
                EKEvent *tmpEvent = [_eventStore eventWithIdentifier:aEventID];
                if (tmpEvent) {
                    [_eventStore removeEvent:tmpEvent
                                        span:EKSpanFutureEvents
                                        error:nil];
                }
            }
        }
        result = [self save2MobileCalendarWithCalEvent:mTimeCalEvent ekEvent:nil];

    }
    SY_RELEASE_SAFELY(_eventStore);
}

- (BOOL)save2MobileCalendarWithCalEvent:(CMPTimeCalEvent *)mTimeCalEvent ekEvent:(EKEvent *)aEvent
{
    NSError *error;
    BOOL clearResult = YES;
    //  修改后要保存的 先移除原来的日程
    if (aEvent) {
       clearResult = [_eventStore removeEvent:aEvent
                            span:EKSpanFutureEvents
                           error:&error];
    }
    EKEvent *event = [EKEvent eventWithEventStore:_eventStore];
    event.title = mTimeCalEvent.subject;
    double startTime = [mTimeCalEvent.beginDate longLongValue]/1000.0;
    double endTime = [mTimeCalEvent.endDate longLongValue]/1000.0;
    
    event.startDate = [NSDate dateWithTimeIntervalSince1970:startTime ];
    event.endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    event.location = @""; //mTimeCalEvent.address;
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:-mTimeCalEvent.alarmDate*60]];
    event.allDay = NO;
    event.availability = EKEventAvailabilityFree;
    [event setCalendar:[_eventStore defaultCalendarForNewEvents]];
    BOOL result = [_eventStore saveEvent:event
                                    span:EKSpanFutureEvents
                                   error:&error];
    //  保存日程同步记录
    CMPScheduleEventRcord *record = [[CMPScheduleEventRcord alloc] initWithMTimeCalEvent:mTimeCalEvent];
    record.scheduleLocalID = event.eventIdentifier;
    record.syncDate = [CMPDateHelper strFromDate:[NSDate date]
                                         formatter:kDateFormate_YYYY_MM_DD_HH_MM_SS];
    __block BOOL dbResult = NO;
    [[CMPCommonDBProvider sharedInstance]
     insertScheduleRecordItem:record
     onCompletion:^(BOOL success) {
         dbResult = success;
     }];
    SY_RELEASE_SAFELY(record);
    
    if (result && dbResult && clearResult) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

- (void)dealloc {
    
    if(_scheduleSyncTimer){
        [_scheduleSyncTimer invalidate];
        [_scheduleSyncTimer release];
        _scheduleSyncTimer = nil;
    }
    [super dealloc];
}

@end
