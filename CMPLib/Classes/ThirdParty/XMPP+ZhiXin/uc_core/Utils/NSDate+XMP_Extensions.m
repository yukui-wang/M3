//
//  NSDate+XMP_Extensions.m
//  XmppDemo
//
//  Created by weitong on 13-2-3.
//  Copyright (c) 2013年 weit. All rights reserved.
//

#import "NSDate+XMP_Extensions.h"
#import "RegexKitLite.h"

@implementation NSDate (XMP_Extensions)

//  2013-02-02T22:25:50.246189+08:00
+ (NSDate *)dateFromUTC:(NSString *)utc
{
    __autoreleasing NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'+08:00'"];
    return [dateFormatter dateFromString:utc];
}

+ (NSString *)utcStringFromDate:(NSDate *)date
{
    __autoreleasing NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'+08:00'"];
    return [dateFormatter stringFromDate:date];
}

static NSString* kRegexUTC = @"\\d{4}\\-\\d{2}\\-\\d{2}T\\d{2}\\:\\d{2}:\\d{2}\\.\\d{6}\\+\\d{2}\\:\\d{2}";
+ (NSString *)timetap:(NSString *)time
{
    if (!time || [time rangeOfRegex:kRegexUTC].location == NSNotFound) {
        return time;
    }
    
    NSDate* targetDate = [NSDate dateFromUTC:time];
    __autoreleasing NSCalendar* clendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unit = NSYearCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents* targetComponents = [clendar components:unit fromDate:targetDate];
    NSDateComponents* currentComponents = [clendar components:unit fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",(long)targetComponents.year,(long)targetComponents.month,(long)targetComponents.day,(long)targetComponents.hour,(long)targetComponents.minute,(long)targetComponents.second];

//    if (targetComponents.year < currentComponents.year) {   // 跨年
//        return [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%02ld",(long)targetComponents.year,(long)targetComponents.month,(long)targetComponents.day,(long)targetComponents.hour,(long)targetComponents.minute];
//    }else if(targetComponents.month == currentComponents.month && targetComponents.day == currentComponents.day){   // 今天
//        return [NSString stringWithFormat:@"%@ %ld:%02ld",SY_STRING(@"UC_Today"),(long)targetComponents.hour,(long)targetComponents.minute];
//    }else if(targetComponents.month == currentComponents.month && targetComponents.day == (currentComponents.day - 1)){ // 昨天
//        return [NSString stringWithFormat:@"%@ %ld:%02ld",SY_STRING(@"UC_Yesterday"),(long)targetComponents.hour,(long)targetComponents.minute];
//    }else if(targetComponents.year == currentComponents.year){  // 今年
//        return [NSString stringWithFormat:@"%ld-%ld %ld:%02ld",(long)targetComponents.month,(long)targetComponents.day,(long)targetComponents.hour,(long)targetComponents.minute];
//    }
//    return SY_STRING(@"Common_unKnown");
    
    

}

+ (NSString*)nextStringValueForFileName
{
    __autoreleasing NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)memberIconText
{
    __autoreleasing NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (BOOL)timeIntervalMoreWithMinite:(NSUInteger)minite withUTC1:(NSString *)utc1 withUTC2:(NSString *)utc2
{
    XMPDate* date1 = [[XMPDate alloc] initWithUTC:utc1];
    XMPDate* date2 = [[XMPDate alloc] initWithUTC:utc2];
    
    int second = [date1.date timeIntervalSinceDate:date2.date];
    if (abs(second) > 60 * minite){
        
    }
        
    if (date1.year.intValue == date2.year.intValue && date1.month.intValue == date2.month.intValue) {
        
    }
    
    NSString* s1 = [utc1 stringByMatching:kRegexUTC];
    NSString* s2 = [utc2 stringByMatching:kRegexUTC];
    NSLog(@"%@ %@",s1,s2);
    return YES;
}


@end



static NSString* kRegexUTCSearch = @"(\\d{4})\\-(\\d{2})\\-(\\d{2})T(\\d{2})\\:(\\d{2})\\:(\\d{2})\\.(\\d{6})\\+(\\d{2})\\:(\\d{2})";

@implementation XMPDate

@synthesize year                = _year;
@synthesize month               = _month;
@synthesize day                 = _day;
@synthesize hour                = _hour;
@synthesize minite              = _minite;
@synthesize second              = _second;
@synthesize date                = _date;
@synthesize dateString          = _dateString;
- (id)init
{
    self = [super init];
    if (self) {
        NSString* utc = [NSDate utcStringFromDate:[NSDate date]];
        if (utc) {
            NSDictionary* dictionary = [utc dictionaryByMatchingRegex:kRegexUTCSearch
                                                  withKeysAndCaptures:@"year",1
                                        ,@"month",2
                                        ,@"day",3
                                        ,@"hour",4
                                        ,@"minite",5
                                        ,@"second",6, nil];
            if (dictionary) {
                self.year = [dictionary objectForKey:@"year"];
                self.month = [dictionary objectForKey:@"month"];
                self.day = [dictionary objectForKey:@"day"];
                self.hour = [dictionary objectForKey:@"hour"];
                self.minite = [dictionary objectForKey:@"minite"];
                self.second = [dictionary objectForKey:@"second"];
            }
            
            self.date = [NSDate dateFromUTC:utc];
            self.dateString = utc;
        }
    }
    return self;
}

- (id)initWithUTC:(NSString *)utc
{
    self = [super init];
    if (self) {
        
        if (utc) {
            NSDictionary* dictionary = [utc dictionaryByMatchingRegex:kRegexUTCSearch
                                                  withKeysAndCaptures:@"year",1
                                        ,@"month",2
                                        ,@"day",3
                                        ,@"hour",4
                                        ,@"minite",5
                                        ,@"second",6, nil];
            if (dictionary) {
                self.year = [dictionary objectForKey:@"year"];
                self.month = [dictionary objectForKey:@"month"];
                self.day = [dictionary objectForKey:@"day"];
                self.hour = [dictionary objectForKey:@"hour"];
                self.minite = [dictionary objectForKey:@"minite"];
                self.second = [dictionary objectForKey:@"second"];
            }
            
            self.date = [NSDate dateFromUTC:utc];
            self.dateString = utc;
        }
    }
    return self;
}

- (BOOL)isSameDay:(XMPDate *)toDate
{
    return (self.year.intValue == toDate.year.intValue && self.month.intValue == toDate.month.intValue && self.day.intValue == toDate.day.intValue);
}

- (BOOL)isSameMinite:(XMPDate *)toDate
{
    //时间间隔 5 minite
    NSTimeInterval compare = [self.date timeIntervalSinceDate:toDate.date];
//    NSLog(@"NSTimeInterval compare = %f",compare);
    if (fabs(compare) >= 300 ) {
        return NO;
    }
    return YES;
    
    //时间间隔 1 minite
//    return [self isSameDay:toDate] && self.hour.intValue == toDate.hour.intValue && self.minite.intValue == toDate.minite.intValue ;
}


@end


