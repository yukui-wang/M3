//
//  CMPDateHelper.m
//  CMPLib
//
//  Created by youlin on 2017/2/21.
//  Copyright © 2017年 CMPCore. All rights reserved.
//
#define kNumberOfCellInCalendarView  42

#import "CMPDateHelper.h"
#import "CMPConstant.h"
#import "NSDate+CMPDate.h"

@implementation CMPDateHelper

+ (NSString *)getCurrentDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formt = [[NSDateFormatter alloc] init];
    [formt setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateStr = [formt stringFromDate:date];
    return dateStr;
}

+ (NSString *)getCurrentDateStr
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formt = [[NSDateFormatter alloc] init];
    [formt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formt stringFromDate:date];
    return dateStr;
}

+ (NSDate *)dateFromStr:(NSString *)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:aStr];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    NSLog(@"%@", localeDate);
    return localeDate;
}

+ (long long)localeDateTimeInterval
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return [localeDate timeIntervalSince1970];
}

+ (NSTimeInterval)getNowTimeTimestamp3
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    NSTimeInterval result = [localeDate timeIntervalSince1970]*1000;
    return result;
}

static NSDateFormatter *_dateFormatter;

+ (NSDate *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"EEE, d MMM yyyy HH:mm:ss Z";
        NSLocale *aLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _dateFormatter.locale = aLocale;
    });
    NSDate *date = [_dateFormatter dateFromString:utcDate];
    return date;
}

+ (long long)longLongFromDate:(NSDate*)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return [localeDate timeIntervalSince1970];
}

+ (NSString*)dateStrFromLongLong:(long long)msSince1970{
    
    NSDate *date =[NSDate dateWithTimeIntervalSince1970:msSince1970 / 1000];
    NSDateFormatter *formt = [[NSDateFormatter alloc] init];
    [formt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [formt stringFromDate:date];
    return str;
}

+ (NSString *)currentDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    return stringFromDate;
}

+ (NSString *)currentDateNumberFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];//hh表示12小时制的小时。这样，返回的时间字符串将不包含下午或上午的标识。
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    return stringFromDate;
}

+ (NSNumber *)currentNumberDate {
    long long time = [[NSDate date] timeIntervalSince1970];
    NSNumber *number = [NSNumber numberWithLongLong:time];
    return number;
}

+ (int)getWeekday:(CFGregorianDate)date
{
    CFTimeZoneRef tz = CFTimeZoneCopyDefault();
    date.hour=0;
    date.minute=0;
    date.second=1;
    int result = (int)CFAbsoluteTimeGetDayOfWeek(CFGregorianDateGetAbsoluteTime(date,tz),tz);
    CFRelease(tz);
    return result;
}

+(NSString *)getWeekdayString:(CFGregorianDate)date
{
    NSInteger week = [CMPDateHelper getWeekday:date];
    NSArray *weekArray = [NSArray arrayWithObjects:SY_STRING(@"week_one"),SY_STRING(@"week_two"),SY_STRING(@"week_three"),SY_STRING(@"week_four"),SY_STRING(@"week_five"),SY_STRING(@"week_six"),SY_STRING(@"week_seven"), nil];
    NSString *retStr = [weekArray objectAtIndex:week-1];
    return retStr;
}


+ (CFGregorianDate)stringToCFGregorianDate2:(NSString*)aStr
{
    CFGregorianDate date;
    if (aStr.length == 0) {
        CFTimeZoneRef zf = CFTimeZoneCopySystem();
        date = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), zf);
        CFRelease(zf);
        return date;
    }
    NSMutableString* tempStr = [[NSMutableString alloc] initWithFormat:@"%@", aStr];
    NSMutableString* valueStr = [[NSMutableString alloc] initWithFormat:@"%@", aStr];
    NSRange range;
    
    range = [tempStr rangeOfString:@"-"];
    [valueStr setString:[tempStr substringWithRange:NSMakeRange(0, range.location)]];
    date.year = [valueStr intValue];
    [tempStr deleteCharactersInRange:NSMakeRange(0, range.location + 1)];
    
    range = [tempStr rangeOfString:@"-"];
    [valueStr setString:[tempStr substringWithRange:NSMakeRange(0, range.location)]];
    date.month = [valueStr intValue];
    [tempStr deleteCharactersInRange:NSMakeRange(0, range.location + 1)];
    
    [valueStr setString:tempStr];
    date.day = [valueStr intValue];
    
    date.hour = 0;
    date.minute = 0;
    date.second = 0;
    
    return date;
}


+ (int)getDayCountOfaMonth:(CFGregorianDate)date
{
    switch ( date.month ) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
            
        case 2:
            if ( date.year%4 == 0 ) {
                if ( date.year % 100 != 0 )
                    return 29;
                else {
                    if ( date.year % 400 == 0 )
                        return 29;
                    else
                        return 28;
                }
            }
            else
                return 28;
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
        default:
            return 31;
    }
}

+ (CFGregorianDate)preMonth:(CFGregorianDate)date
{
    if ( date.month == 1 ){
        date.year--;
        date.month = 12;
    }
    else
        date.month--;
    
    if ( date.day > [CMPDateHelper getDayCountOfaMonth:date] )
        date.day = [CMPDateHelper getDayCountOfaMonth:date];
    
    return date;
}

+ (CFGregorianDate)nextMonth:(CFGregorianDate)date
{
    if ( date.month == 12 ){
        date.year++;
        date.month = 1;
    }
    else
        date.month++;
    
    if ( date.day > [CMPDateHelper getDayCountOfaMonth:date] )
        date.day = [CMPDateHelper getDayCountOfaMonth:date];
    
    return date;
}

+ (CFGregorianDate)preDay:(CFGregorianDate)date
{
    if ( date.day == 1 ) {
        date = [CMPDateHelper preMonth:date];
        date.day = [self getDayCountOfaMonth:date];
    }
    else
        date.day--;
    
    return date;
}

+ (CFGregorianDate)nextDay:(CFGregorianDate)date
{
    int daysCount = [self getDayCountOfaMonth:date];
    if ( date.day == daysCount ) {
        date = [CMPDateHelper nextMonth:date];
        date.day = 1;
    }
    else
        date.day++;
    
    return date;
}

+ (NSInteger)dateCompareByDay:(CFGregorianDate)aDate1 Date2:(CFGregorianDate)aDate2
{
    if ( aDate1.year > aDate2.year )
        return 1;
    else if ( aDate1.year < aDate2.year )
        return -1;
    
    if ( aDate1.month > aDate2.month )
        return 1;
    else if ( aDate1.month < aDate2.month )
        return -1;
    
    if ( aDate1.day > aDate2.day )
        return 1;
    else if ( aDate1.day < aDate2.day )
        return -1;
    
    return 0;
}


+ (NSString *)localDateByDay:(NSString *)dateStr hasTime:(BOOL)hasTime
{
    if (![dateStr isKindOfClass:[NSString class]]) {
        return nil;
    }
    if(dateStr.length < 10 || (dateStr.length < 16 && hasTime)) return dateStr;
    CFTimeZoneRef zf = CFTimeZoneCopySystem();
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), zf);
    CFRelease(zf);
    CFGregorianDate refDate = [CMPDateHelper stringToCFGregorianDate2:dateStr];
    
    CFGregorianDate yesterday = [CMPDateHelper preDay:currentDate];
    CFGregorianDate tomorrow = [CMPDateHelper nextDay:currentDate];
    NSString *result = @"";
    if ([CMPDateHelper dateCompareByDay:refDate Date2:yesterday] == 0) {
        result = SY_STRING(@"Common_Yesterday");
    }
    else if ([CMPDateHelper dateCompareByDay:refDate Date2:currentDate] == 0) {
        result = [NSString stringWithFormat:@"%@:%@",[dateStr substringWithRange:NSMakeRange(11, 2)],[dateStr substringWithRange:NSMakeRange(14, 2)]];
    }
    else if ([CMPDateHelper dateCompareByDay:refDate Date2:tomorrow] == 0) {
        result = SY_STRING(@"Common_Tomorrow");
    }
    else {
        result = [NSString stringWithFormat:@"%d-%d-%d",(int)refDate.year,refDate.month,refDate.day];
    }
    return result;
}

+ (NSDate *)dateFromString:(NSString *)dataStr {
    if (dataStr.length == 0) {
        return [NSDate date];
    }
    NSString *format = @"yyyy-MM-dd HH:mm:ss";
    if (dataStr.length == 10) {
        format = @"yyyy-MM-dd";
    }
    else if (dataStr.length == 16) {
       format = @"yyyy-MM-dd HH:mm";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale systemLocale];
    [formatter setDateFormat:format];
    
    NSDate *d = [formatter dateFromString:dataStr];
    if(!d){//处理字符串中包含：上午、下午、AM、PM等情况(dataStr会出现非规定格式时间字符串)
        NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789:- "];
        NSCharacterSet *nonAllowedCharacterSet = [allowedCharacterSet invertedSet];
        NSString *cleanedString = [[dataStr componentsSeparatedByCharactersInSet:nonAllowedCharacterSet] componentsJoinedByString:@""];
        format = @"yyyy-MM-dd h:mm:ss";
        [formatter setDateFormat:format];
        d = [formatter dateFromString:cleanedString];
    }
    
    return d;
}

+ (NSString *)messageDateByDay:(NSString *)dateStr hasTime:(BOOL)hasTime
{
    if (![dateStr isKindOfClass:[NSString class]]) {
        return nil;
    }
    if(dateStr.length < 10 || (dateStr.length < 16 && hasTime)) return dateStr;
    
    NSCalendarUnit unitFlags =NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitWeekday;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *yesterdayComponents = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSinceNow:-24*60*60]];
    NSDateComponents *tomorrowComponents = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSinceNow:24*60*60]];
    NSDateComponents *components = [calendar components:unitFlags fromDate:[CMPDateHelper dateFromString:dateStr]];
    NSString *result = @"";
    if (components.year == yesterdayComponents.year &&
        components.month == yesterdayComponents.month &&
        components.day == yesterdayComponents.day) {
        result = SY_STRING(@"Common_Yesterday");
        result = [NSString stringWithFormat:@"%@ %02ld:%02ld",result,(long)components.hour,(long)components.minute];
    }
    else if (components.year == currentComponents.year &&
             components.month == currentComponents.month &&
             components.day == currentComponents.day) {
        result = [NSString stringWithFormat:@"%ld:%02ld",(long)components.hour,(long)components.minute];
    }
    else if (components.year == tomorrowComponents.year &&
             components.month == tomorrowComponents.month &&
             components.day == tomorrowComponents.day) {
        result = SY_STRING(@"Common_Tomorrow");
    }
    else if (components.year == currentComponents.year) {
        result = [NSString stringWithFormat:@"%ld-%02ld",(long)components.month,(long)components.day];
    }
    else {
        result = [NSString stringWithFormat:@"%ld-%02ld-%02ld",(long)components.year,(long)components.month,(long)components.day];
    }
    return result;
}


+ (NSString *)strFromDate:(NSDate *)aDate formatter:(NSString *)aFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    if (aFormat == kDateFormate_YYYY_MM_DD_HH_MM) {
    //        aFormat = kDateFormate_YYYY_MM_DD_HH_MM_PM;
    //    }
    //待修改
    [dateFormatter setDateFormat:aFormat];
    NSString *dateStr = [dateFormatter stringFromDate:aDate];
    //    if ([dateStr hasSuffix:@"PM"]) {
    //        <#statements#>
    //    }
    return dateStr;
}

+ (NSDate *)dateFromStr:(NSString *)aStr dateFormat:(NSString *)aFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:aFormat];
    NSDate *date = [dateFormatter dateFromString:aStr];
    return date;
}

+ (long long)intervalOfStartTime:(NSString *)startTime andEndTime:(NSString *)endTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSDate *zeroDate = [formatter dateFromString:@"00:00:00"];
    NSDate *startDate = [formatter dateFromString:startTime];
    NSDate *endDate = [formatter dateFromString:endTime];
    formatter = nil;
    
    NSTimeInterval start = [startDate timeIntervalSinceDate:zeroDate];
    NSTimeInterval end = [endDate timeIntervalSinceDate:zeroDate];
    if (start <= end) {
        return end - start;
    } else {
        return 24 * 60 * 60 + end - start;
    }
}

+ (BOOL)isNowInPeriodWithStart:(NSString *)startTime end:(NSString *)endTime {
    BOOL result = NO;
    
    if ([NSString isNull:startTime] ||
        [NSString isNull:endTime]) {
        return result;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    //解决手机时间设置为12小时制情况下，返回date为nil的情况
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDate *start = [dateFormatter dateFromString:startTime];
    NSDate *end = [dateFormatter dateFromString:endTime];
    
    if (!start ||
        !end) {
        return result;
    }
    
    NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *nowDate = [dateFormatter dateFromString:nowDateString];
    NSDate *earDate = [start earlierDate:nowDate];
    NSDate *laterDate = [end laterDate:nowDate];
    if (([start isEqualToDate:earDate] && [end isEqualToDate:laterDate]) ||
        [nowDate isEqualToDate:start] ||
        [nowDate isEqualToDate:end]) {
        result = YES;
    }
    
    return result;
}

+ (NSString *)nowMillisecondStr {
    return [[NSDate date] cmp_millisecondStr];
}

+ (NSString *)tomorrowMillisecondStr {
    NSDate *tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:24*60*60];
    return [tomorrow cmp_millisecondStr];
}

+ (NSString *)timeZoneAbbreviation {
    NSInteger offset = [NSTimeZone localTimeZone].secondsFromGMT;
    NSString *str = @"+";
    if (offset<0) {
        offset = -offset;
        str = @"-";
    }
    NSInteger hour = offset/3600;
    NSInteger minute = offset%3600;
    NSString *tzStr = [NSString stringWithFormat:@"GMT%@%02ld:%02ld",str,(long)hour,(long)minute];
    return tzStr;
}
@end
