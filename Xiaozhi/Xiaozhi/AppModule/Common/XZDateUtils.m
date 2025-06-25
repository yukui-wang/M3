//
//  XZDateUtils.m
//  M3
//
//  Created by wujiansheng on 2019/2/13.
//

#import "XZDateUtils.h"
#import "CalendarHeader.h"
#import <CMPLib/NSString+CMPString.h>
#import "XZDateUtilsTool.h"


@interface  XZDateUtils()
@property(nonatomic, strong)NSMutableDictionary *dateMapping;
@property(nonatomic, assign)BOOL hasTime;

@end

@implementation XZDateUtils
static XZDateUtils *_instance;

+ (XZDateUtils *)sharedInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (void)clearData {
    [XZDateUtils sharedInstance].dateMapping = nil;
}

+ (NSString *)correctUnitTime:(NSString *)time {
    NSString *result = [time replaceCharacter:@"-00" withString:@"-01"];
    result = [result replaceCharacter:@"|" withString:@" "];
    return result;
}

- (NSTextCheckingResult *)firstMatchInString:(NSString *)command pattern:(NSString *)pattern {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *checkResult = [regex firstMatchInString:command options:NSMatchingReportProgress range:NSMakeRange(0, [command length])];
    return checkResult;
}

+ (NSString *)stringForYear:(NSInteger)y
                      month:(NSInteger)m
                        day:(NSInteger)d {
    return [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)y,(long)m,(long)d];
}

+ (NSString *)stringForYear:(NSInteger)y
                      month:(NSInteger)m
                        day:(NSInteger)d
                       hour:(NSInteger)h
                     minute:(NSInteger)mi {
    return [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld",(long)y,(long)m,(long)d,(long)h,(long)mi];
}

+ (NSString *)obtainFormatDateTime:(NSString *)command hasTime:(BOOL)hasTime interval:(BOOL)interval {
    //先处理百度时间
    NSString *result = [XZDateUtils handleBaiduUnitTime:command hasTime:hasTime interval:interval];
    if (result) {
        return result;
    }
    result = [XZDateUtilsTool obtainFormatDateTime:command];
    if (interval &&
        [result rangeOfString:@"#"].location == NSNotFound &&
        [result rangeOfString:@":"].location == NSNotFound
        ) {
        //特殊处理下 时间端但是result不是时间段并且不包含时分秒
        result = [NSString stringWithFormat:@"%@ 00:00#%@ 23:59",result,result];
    }
    return result;
}

+ (NSString *)obtainTimestamp:(NSString *)command hasTime:(BOOL)hasTime interval:(BOOL)interval {
    NSString *dameStr = [XZDateUtils obtainFormatDateTime:command hasTime:hasTime interval:interval];
    if ([NSString isNull:dameStr]) {
        return nil;
    }
    NSString *dameStr1 = dameStr;
    NSString *dameStr2 = nil;
    
    if ([dameStr rangeOfString:@"#"].location != NSNotFound) {
        NSArray *array = [dameStr componentsSeparatedByString:@"#"];
        dameStr1 = array[0];
        dameStr2 = array[1];
    }
    NSString *dateFormat = kDateFormate_YYYY_MM_DD_HHMMSS;
    if (dameStr1.length == 16) {
        dateFormat = kDateFormate_YYYY_MM_DD_HHMM;
    }
    else if (dameStr1.length == 10) {
        dateFormat = kDateFormate_YYYY_MM_DD;
    }
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSDate *date = [formatter dateFromString:dameStr1];
    long long timeInterval = [date timeIntervalSince1970] *1000;
    NSString *result = [NSString stringWithLongLong:timeInterval];
    if (dameStr2) {
        NSDate *date2 = [formatter dateFromString:dameStr2];
        long long timeInterval2 = [date2 timeIntervalSince1970] *1000;
        result = [NSString stringWithFormat:@"%@#%@",result,[NSString stringWithLongLong:timeInterval2]];
    }
    return result;
}


//处理百度时间
+ (NSString *)handleBaiduUnitTime:(NSString *)command hasTime:(BOOL)hasTime interval:(BOOL)interval {
    if ([command rangeOfString:@"~"].location != NSNotFound) {
        //百度时间段 "2019-06-18~2019-06-19|24:00:00"
        NSString *result = [XZDateUtils handleUnitTimeInterval:command hasTime:hasTime];
        return result;
    }
    NSString *result = [XZDateUtils handleUnitTime:command hasTime:hasTime type:interval?3:2];
    if (result) {
        return result;
    }
    return nil;
}

//处理百度时间 时间区间
+ (NSString *)handleUnitTimeInterval:(NSString *)command hasTime:(BOOL)hasTime {
    //百度时间段 "2019-06-18~2019-06-19|24:00:00"  "2019-09-20|09:00:00~15:00:00" "2019-10-01~2019-10-20"
    NSArray *array = [command componentsSeparatedByString:@"~"];
    NSString *begin = array[0];
    begin = [XZDateUtils handleUnitTime:begin hasTime:hasTime type:0];
    NSString *end = array[1];
    if ([end rangeOfString:@"-"].location == NSNotFound) {
        //没有日期用前面的
        end = [NSString stringWithFormat:@"%@|%@",[begin substringToIndex:10],end];
    }
    end = [XZDateUtils handleUnitTime:end hasTime:hasTime type:1];
    NSString *result = [NSString stringWithFormat:@"%@#%@",begin,end];
    return result;
}

//处理百度画一般时间
+ (NSString *)handleUnitTime:(NSString *)command hasTime:(BOOL)hasTime type:(NSInteger)type {
    /*type
     0-开始时间
     1-结束时间
     2-如果是时间段，返回时间段否者返回开始时间
     3-如果时分为0 取00:00～23:59，如果分为o0，取h:00~h:59
   */
     // 开始时间 如果hasTime = ture 并且 时分为空，拼接00:00
    // 结束时间 如果hasTime = ture 并且 时分为空，拼接23:59
    NSString * pattern_ymd_hm = @"(([0-9]{2,4})-)((0[0-9]|1[0-2])-)([0-2][0-9]|3[01])\\|([01][0-9]|2[0-4]):([0-5][0-9])";
    XZDateUtils *utils = [XZDateUtils sharedInstance];
    NSTextCheckingResult *checkResult = [utils firstMatchInString:command pattern:pattern_ymd_hm];
    if (checkResult) {
        NSString *yearStr = [command substringWithRange:[checkResult rangeAtIndex:2]];//年
        NSString *monthStr = [command substringWithRange:[checkResult rangeAtIndex:4]];//月
        NSString *dayStr = [command substringWithRange:[checkResult rangeAtIndex:5]];//月
        NSString *hourStr = [command substringWithRange:[checkResult rangeAtIndex:6]];//时
        NSString *minuteStr = [command substringWithRange:[checkResult rangeAtIndex:7]];//分
        NSInteger year = [yearStr integerValue];
        NSInteger month = [monthStr integerValue];
        NSInteger day = [dayStr integerValue];
        NSInteger hour = [hourStr integerValue];
        NSInteger minute = [minuteStr integerValue];
        //不考虑 month =0 day = 0，特殊处理hour = 24
        if (hour == 24) {
            if (month == 12 && day == 31) {
                year ++;
                month = 1;
                day = 1;
            }
            else {
                NSInteger maxDay = [XZDateUtilsTool daysfromYear:year andMonth:month];
                if (day == maxDay) {
                    month ++;
                    day = 1;
                }
                else {
                    day ++;
                }
            }
            hour = 0;
        }
        
        if (!hasTime) {
            return [XZDateUtils stringForYear:year month:month day:day];
        }
        if (type == 3) {
            if (minute == 0) {
                NSString *begin = [XZDateUtils stringForYear:year month:month day:day hour:hour minute:0];
                NSString *end = [XZDateUtils stringForYear:year month:month day:day hour:hour minute:59];;
                return [NSString stringWithFormat:@"%@#%@",begin,end];
            }
        }
        
        return [XZDateUtils stringForYear:year month:month day:day hour:hour minute:minute];
    }
    NSString *pattern_ymd = @"(([0-9]{2,4})-)((0[0-9]|1[0-2])-)([0-2][0-9]|3[01])";//
    checkResult = [utils firstMatchInString:command pattern:pattern_ymd];
    if (checkResult) {
        NSString *yearStr = [command substringWithRange:[checkResult rangeAtIndex:2]];//年
        NSString *monthStr = [command substringWithRange:[checkResult rangeAtIndex:4]];//月
        NSString *dayStr = [command substringWithRange:[checkResult rangeAtIndex:5]];//月
        
        NSInteger year = [yearStr integerValue];
        NSInteger month = [monthStr integerValue];
        
        if(month == 0) {
            NSString *result = nil;
            if (type == 0) {
                result  = hasTime?[XZDateUtils stringForYear:year month:1 day:1 hour:0 minute:0]:[XZDateUtils stringForYear:year month:1 day:1];
            }
            else if (type == 1) {
                result  = hasTime?[XZDateUtils stringForYear:year month:12 day:31 hour:23 minute:59]:[XZDateUtils stringForYear:year month:12 day:31];
            }
            else {
                NSString *begin = nil;
                NSString *end = nil;
                if (hasTime) {
                    begin = [XZDateUtils stringForYear:year month:1 day:1 hour:0 minute:0];
                    end = [XZDateUtils stringForYear:year month:12 day:31 hour:23 minute:59];
                }
                else {
                    begin = [XZDateUtils stringForYear:year month:1 day:1];
                    end = [XZDateUtils stringForYear:year month:12 day:31];
                }
                result = [NSString stringWithFormat:@"%@#%@",begin,end];
            }
            return result;
        }
        NSInteger day = [dayStr integerValue];
        if (day == 0) {
            NSInteger maxDay = [XZDateUtilsTool daysfromYear:year andMonth:month];
            NSString *result = nil;
            if (type == 0) {
                result  = hasTime?[XZDateUtils stringForYear:year month:month day:1 hour:0 minute:0]:[XZDateUtils stringForYear:year month:1 day:1];
            }
            else if (type == 1) {
                result  = hasTime?[XZDateUtils stringForYear:year month:month day:maxDay hour:23 minute:59]:[XZDateUtils stringForYear:year month:month day:maxDay];
            }
            else {
                NSString *begin = nil;
                NSString *end = nil;
                if (hasTime) {
                    begin = [XZDateUtils stringForYear:year month:month day:1 hour:0 minute:0];
                    end = [XZDateUtils stringForYear:year month:month day:maxDay hour:23 minute:59];
                }
                else {
                    begin = [XZDateUtils stringForYear:year month:month day:1];
                    end = [XZDateUtils stringForYear:year month:month day:maxDay];
                }
                result = [NSString stringWithFormat:@"%@#%@",begin,end];
            }
            return result;
        }
        if (!hasTime) {
            NSString *result = [XZDateUtils stringForYear:year month:month day:day];
            if (type == 3) {
                result = [NSString stringWithFormat:@"%@#%@",result,result];
            }
            return result;
        }
        if (type == 0 || type == 2)  {
            return [XZDateUtils stringForYear:year month:month day:day hour:0 minute:0];
        }
        else if (type == 1) {
            return [XZDateUtils stringForYear:year month:month day:day hour:23 minute:59];
        }
        else {
            NSString *begin = [XZDateUtils stringForYear:year month:month day:day hour:0 minute:0];
            NSString *end = [XZDateUtils stringForYear:year month:month day:day hour:23 minute:59];;
            return [NSString stringWithFormat:@"%@#%@",begin,end];
        }
    }
    
    NSString *pattern_hms = @"([01][0-9]|2[0-4]):([0-5][0-9]):([0-5][0-9])";
    checkResult = [utils firstMatchInString:command pattern:pattern_hms];
    if (checkResult) {
        //09:00:00
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger year = components.year;
        NSInteger month = components.month;
        NSInteger day = components.day;
        NSString *str = [XZDateUtils stringForYear:year month:month day:day];
        if (!hasTime) {
            return str;
        }
        NSString *rangeStr = [command substringWithRange:[checkResult rangeAtIndex:0]];
        NSArray *array = [rangeStr componentsSeparatedByString:@":"];
        NSInteger hour =  [array[0] integerValue];
        NSInteger mintue = [array[1] integerValue];
        if (type == 3 && mintue == 0) {
            NSString *begin = [XZDateUtils stringForYear:year month:month day:day hour:hour minute:0];
            NSString *end = [XZDateUtils stringForYear:year month:month day:day hour:hour minute:59];;
            return [NSString stringWithFormat:@"%@#%@",begin,end];

        }
        NSString *result =  [XZDateUtils stringForYear:year month:month day:day hour:hour minute:mintue];
        return result;
    }
    
    return nil;
}




//十五转15
- (NSInteger)numberFormString:(NSString *)string {
    NSString *str = string;
    NSString *sub = [str substringToIndex:1];
    if ([sub isEqualToString:@"十"]||[sub isEqualToString:@"百"]||[sub isEqualToString:@"千"]) {
        str = [NSString stringWithFormat:@"一%@",str];
    }
    str = [str replaceCharacter:@"十" withString:@""];
    str = [str replaceCharacter:@"百" withString:@""];
    str = [str replaceCharacter:@"千" withString:@""];
    NSMutableString *result = [NSMutableString string];
    NSInteger l = string.length;
    for(int i =0; i < l; i++) {
        NSString *temp = [str substringWithRange:NSMakeRange(i, 1)];
        [result appendString:self.dateMapping[temp]];
    }
    return [result integerValue];
}


+ (NSDictionary *)numberTransDic {
    NSDictionary *result = @{@"0" : @"0",
                             @"1" : @"1",
                             @"2" : @"2",
                             @"3" : @"3",
                             @"4" : @"4",
                             @"5" : @"5",
                             @"6" : @"6",
                             @"7" : @"7",
                             @"8" : @"8",
                             @"9" : @"9",
                             @"零" : @"0",
                             @"一" : @"1",
                             @"二" : @"2",
                             @"三" : @"3",
                             @"四" : @"4",
                             @"五" : @"5",
                             @"六" : @"6",
                             @"七" : @"7",
                             @"八" : @"8",
                             @"九" : @"9",
                             @"十" : @"10",
                             @"百" : @"100",
                             @"千" : @"1000",
                             @"万" : @"10000",
                             @"亿" : @"100000000",
                             @"壹" : @"1",
                             @"贰" : @"2",
                             @"叁" : @"3",
                             @"肆" : @"4",
                             @"伍" : @"5",
                             @"陆" : @"6",
                             @"柒" : @"7",
                             @"捌" : @"8",
                             @"玖" : @"9",
                             @"拾" : @"10",
                             @"佰" : @"100",
                             @"仟" : @"1000",
                             @"〇" : @"0",
                             @"幺" : @"1",
                             @"两" : @"2"};
    return result;
}

+ (NSArray *)ten_hundred_thousandArray {
    NSArray *array = @[@"十",
                       @"百",
                       @"千",
                       @"拾",
                       @"佰",
                       @"仟"];
    return array;
}

+ (NSArray *)numberUnitArray {
    NSArray *array = @[@"十",
                       @"百",
                       @"千",
                       @"拾",
                       @"佰",
                       @"仟",
                       @"万",
                       @"亿"];
    return array;
}

/**
 * 中文数字转阿拉伯数字 包含小数点
 */
+ (NSString *)convertChineseNumberToArabicNumber:(NSString *)str {
    
    if (!str || ![str isKindOfClass:[NSString class]] || str.length == 0) {
        //非空非Null判断
        return nil;
    }
    
    NSString *string = [str replaceCharacter:@"拾" withString:@"十"];
    string = [string replaceCharacter:@"佰" withString:@"百"];
    string = [string replaceCharacter:@"仟" withString:@"千"];
    string = [string replaceCharacter:@"萬" withString:@"万"];
    
    string = [string replaceCharacter:@"点" withString:@"."];
    string = [string replaceCharacter:@"點" withString:@"."];
    
    NSDictionary *numberDic = [XZDateUtils numberTransDic];
    NSArray *numberUnitArray = [XZDateUtils numberUnitArray];//十百千亿万
    long long pointVaule = 0;//小数点后数字扩展后的整数 防止float失真
    long long pointTime = 0;//小数点后数字扩展倍数
    long long customValue = 0;
    NSInteger customTime = 1;
    
    NSInteger lenth = string.length;
    for (NSInteger i = 0; i < lenth; i++) {
        NSString *subStr = [string substringWithRange:NSMakeRange(i, 1)];
        NSInteger subValue = [numberDic[subStr] integerValue];
        if ([subStr isEqualToString:@"."]) {
            pointTime = 1;
            continue;
        }
        BOOL isLast = NO;
        NSString *nextStr = @"";
        if (i == lenth-1) {
            isLast = YES;
        }
        else {
            nextStr = [string substringWithRange:NSMakeRange(i+1, 1)];
            if (![nextStr isEqualToString:@"."] && !numberDic[nextStr]) {
                isLast = YES;
            }
            if (isLast && customValue ==0 && pointTime == 0) {
                continue;
            }
        }
        
        if ([numberUnitArray containsObject:subStr]) {
            if (pointTime>0) {
                if (subValue >= pointTime) {
                    customValue = customValue*subValue + pointVaule*(subValue/pointTime);
                    pointVaule = 0;
                    pointTime = 1;
                }
                else {
                    customValue = customValue*subValue + pointVaule/(pointTime/subValue);
                    pointVaule = pointVaule%(pointTime/subValue);
                    pointTime = pointTime/subValue;
                }
            }
            else {
                if (isLast) {
                    customTime = customTime*subValue;
                    customValue = customValue*customTime;
                }
                else {
                    customTime = customTime*subValue;
                }
                if (pointTime == 0 && customValue == 0) {
                    customValue = 1;
                }
            }
        }
        else {
            if (pointTime > 0) {
                //小数点后
                pointTime = pointTime*10;
                pointVaule = pointVaule*10+subValue;
            }
            else {
                if (isLast) {
                    if (customTime >10 && customValue%10 != 0) {
                        //前一位不是0，而且单位>10
                        customValue = customValue*customTime+subValue*customTime/10;
                    }
                    else {
                        customValue = customValue*MAX(customTime,10)+subValue;//
                    }
                }
                else {
                    NSInteger currentTimes = [numberDic[nextStr] integerValue];
                    if (currentTimes  > 9) {
                        if (i < lenth-2) {
                            NSString *temp = [string substringWithRange:NSMakeRange(i+2, 1)];
                            NSString *tempValue = numberDic[temp];
                            if(tempValue && [tempValue integerValue] > 9 ) {
                                //当前单位十万 百万、、
                                NSInteger tempTime = currentTimes*[tempValue integerValue];
                                if (tempTime < customTime) {
                                    currentTimes = tempTime;
                                }
                            }
                        }
                    }
                    else {
                        currentTimes = 1;
                    }
                    
                    if (subValue == 0 && customTime > 10) {
                        customValue = customValue * 10 + subValue;
                        customTime = MAX(customTime/10,1);
                        continue;
                    }
                    if (customTime >10 && customTime < currentTimes) {
                        customValue = customValue * customTime + subValue;
                    }
                    else {
                        customValue = customValue * MAX(customTime/currentTimes,10) + subValue;
                    }
                    customTime = 1;
                }
            }
        }
        if (isLast) {
            break;
        }
    }
    NSString *result = nil;
    if (pointVaule > 0) {
        NSMutableString *appendStr = [NSMutableString string];
        long long temp = pointVaule;
        while (temp *10 < pointTime) {
            [appendStr appendString:@"0"];
            temp  = temp * 10;
        }
        result = [NSString stringWithFormat:@"%lld.%@%lld",customValue,appendStr,pointVaule];
    }
    else {
        result =  [NSString stringWithFormat:@"%lld",customValue];
    }
    return result;
}

+ (NSInteger)convertChineseNumberToIndexNumber:(NSString *)str {
    XZDateUtils *utils = [XZDateUtils sharedInstance];
    NSArray *numberKey = [[XZDateUtils numberTransDic] allKeys];
    NSMutableString *tempStr = [NSMutableString string];
    for (NSString *s in numberKey) {
        [tempStr appendString:s];
    }
    NSString *pattern = [NSString stringWithFormat:@"第([%@]+)",tempStr];
    NSTextCheckingResult *checkResult = [utils firstMatchInString:str pattern:pattern];
    if (checkResult) {
        NSString *l = [str substringWithRange:[checkResult range]];
        NSString *arabicNumber = [XZDateUtils convertChineseNumberToArabicNumber:l];
        return [arabicNumber integerValue];
    }
    pattern = [NSString stringWithFormat:@"([%@]+)",tempStr];
    checkResult = [utils firstMatchInString:str pattern:pattern];
    if (checkResult) {
        NSRange range = [checkResult range];
        if (range.location == 0 && range.length == str.length) {
            NSString *arabicNumber = [XZDateUtils convertChineseNumberToArabicNumber:str];
            return [arabicNumber integerValue];
        }
    }
    return -1;
}



+ (NSString *)customTimeFormateWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *startDate = [formatter dateFromString:startTime];
    if (!startDate) {
        return @"";
    }
    NSDate *endDate = [formatter dateFromString:endTime];
    if (!endDate) {
        return @"";
    }
    formatter = nil;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
    NSCalendarUnitMinute;
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    NSDate *today = [NSDate date];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger interval = [zone secondsFromGMTForDate: today];
    //    NSDate *currentDate  = [today dateByAddingTimeInterval: interval];
    /*不用计算时区，NSDateComponents 会自动计算*/
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *startComps = [currentCalendar components:unitFlags fromDate:startDate];
    NSDateComponents *endComps = [currentCalendar components:unitFlags fromDate:endDate];
    NSDate *yesteradyDate = [currentDate dateByAddingTimeInterval:-60*60*24];
    NSDateComponents *yesteradyComps = [currentCalendar components:unitFlags fromDate:yesteradyDate];
    currentCalendar = nil;
    if (currentComps.year == startComps.year && currentComps.year == endComps.year) {
        if (currentComps.month == startComps.month && currentComps.month == endComps.month) {
            if (currentComps.day == startComps.day && currentComps.day == endComps.day) {
                return [NSString stringWithFormat:@"今天%02ld:%02ld到今天%02ld:%02ld",(long)startComps.hour,(long)startComps.minute,(long)endComps.hour,(long)endComps.minute] ;
            }
        }
    }
    NSString *begin = @"";
    if (startComps.year == currentComps.year && startComps.month == currentComps.month &&  startComps.day == currentComps.day) {
        begin = [NSString stringWithFormat:@"今天%02ld:%02ld",(long)startComps.hour,(long)startComps.minute];
    }
    else if (startComps.year == yesteradyComps.year && startComps.month == yesteradyComps.month &&  startComps.day == yesteradyComps.day) {
        begin = [NSString stringWithFormat:@"昨天%02ld:%02ld",(long)startComps.hour,(long)startComps.minute];
    }
    else  if (startComps.year == currentComps.year) {
        begin = [NSString stringWithFormat:@"%02ld-%02ld %02ld:%02ld",(long)startComps.month,(long)startComps.day,(long)startComps.hour,(long)startComps.minute] ;
    }
    else {
        begin = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)startComps.year,(long)startComps.month,(long)startComps.day,(long)startComps.hour,(long)startComps.minute];
    }
    NSString *end = @"";
    if (endComps.year == currentComps.year && endComps.month == currentComps.month &&  endComps.day == currentComps.day) {
        end = [NSString stringWithFormat:@"今天%02ld:%02ld",(long)endComps.hour,(long)endComps.minute];
    }
    else  if (endComps.year == currentComps.year) {
        end = [NSString stringWithFormat:@"%02ld-%02ld %02ld:%02ld",(long)endComps.month,(long)endComps.day,(long)endComps.hour,(long)endComps.minute];
    }
    else {
        end = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)endComps.year,(long)endComps.month,(long)endComps.day,(long)endComps.hour,(long)endComps.minute];
    }
    return [NSString stringWithFormat:@"%@到%@",begin,end];
}

+ (NSString *)todayMinTimeStamp {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSCalendarUnitEra |NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour  fromDate: date];
    [comps setHour:0];
    NSDate *beginDate = [calendar dateFromComponents:comps];
    long long beginTime = [beginDate timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%lld", beginTime];
}

+ (NSString *)todayMaxTimeStamp {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSCalendarUnitEra |NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour  fromDate: date];
    [comps setHour:0];
    NSDate *beginDate = [calendar dateFromComponents:comps];
    NSDate *endDate = [beginDate dateByAddingTimeInterval:3600*24 - 1];
    long long endTime = [endDate timeIntervalSince1970] * 1000;
    
    return [NSString stringWithFormat:@"%lld",endTime];
}

+ (NSDate *)dateFromStr:(NSString *)aStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormate_YYYY_MM_DD_HHMM];
    NSDate *date = [dateFormatter dateFromString:aStr];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
    return localeDate;
}


/**
 转换为机器可读的时间
 
 @param startTime startTime description
 @param endTime endTime description
 @return return value description
 */
+ (NSString*)readTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *startDate = [formatter dateFromString:startTime];
    if (!startDate) {
        return @"";
    }
    NSDate *endDate = [formatter dateFromString:endTime];
    if (!endDate) {
        return @"";
    }
    formatter = nil;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
    NSCalendarUnitMinute;
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    NSDate *today = [NSDate date];
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //    NSInteger interval = [zone secondsFromGMTForDate: today];
    //    NSDate *currentDate  = [today dateByAddingTimeInterval: interval];
    /*不用计算时区，NSDateComponents 会自动计算*/
    NSDate *currentDate = [NSDate date];
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *startComps = [currentCalendar components:unitFlags fromDate:startDate];
    NSDateComponents *endComps = [currentCalendar components:unitFlags fromDate:endDate];
    NSDate *yesteradyDate = [currentDate dateByAddingTimeInterval:-60*60*24];
    NSDateComponents *yesteradyComps = [currentCalendar components:unitFlags fromDate:yesteradyDate];
    currentCalendar = nil;
    if (currentComps.year == startComps.year && currentComps.year == endComps.year) {
        if (currentComps.month == startComps.month && currentComps.month == endComps.month) {
            if (currentComps.day == startComps.day && currentComps.day == endComps.day) {
                return [NSString stringWithFormat:@"今天%ld点%ld分到今天%ld点%ld分",(long)startComps.hour,(long)startComps.minute,(long)endComps.hour,(long)endComps.minute] ;
            }
        }
    }
    NSString *begin = @"";
    if (startComps.year == currentComps.year && startComps.month == currentComps.month &&  startComps.day == currentComps.day) {
        begin = [NSString stringWithFormat:@"今天%ld点%ld分",(long)startComps.hour,(long)startComps.minute];
    }
    else if (startComps.year == yesteradyComps.year && startComps.month == yesteradyComps.month &&  startComps.day == yesteradyComps.day) {
        begin = [NSString stringWithFormat:@"昨天%ld点%ld分",(long)startComps.hour,(long)startComps.minute];
    }
    else  if (startComps.year == currentComps.year) {
        begin = [NSString stringWithFormat:@"%ld月%ld日%ld点%ld分",(long)startComps.month,(long)startComps.day,(long)startComps.hour,(long)startComps.minute] ;
    }
    else {
        begin = [NSString stringWithFormat:@"%ld年%ld月%ld日%ld点%ld分",(long)startComps.year,(long)startComps.month,(long)startComps.day,(long)startComps.hour,(long)startComps.minute];
    }
    NSString *end = @"";
    if (endComps.year == currentComps.year && endComps.month == currentComps.month &&  endComps.day == currentComps.day) {
        end = [NSString stringWithFormat:@"今天%ld点%ld分",(long)endComps.hour,(long)endComps.minute];
    }
    else  if (endComps.year == currentComps.year) {
        end = [NSString stringWithFormat:@"%ld月%ld日%ld点%ld分",(long)endComps.month,(long)endComps.day,(long)endComps.hour,(long)endComps.minute];
    }
    else {
        end = [NSString stringWithFormat:@"%ld年%ld月%ld日%ld点%ld分",(long)endComps.year,(long)endComps.month,(long)endComps.day,(long)endComps.hour,(long)endComps.minute];
    }
    return [NSString stringWithFormat:@"%@到%@",begin,end];
}

/**
 01-12->-至十二 2016-04-10 包括年份
 
 @param date date description
 @return return value description
 */
+ (NSString *)upperDate:(NSString *)date {
    if (date.length == 5) {//01-12
        NSArray *comp = [date componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@月%@日",[XZDateUtils upperNumber:[comp[0] intValue]], [XZDateUtils upperNumber:[comp[1] intValue]]];
    } else if (date.length == 10) {//2016-04-10
        NSArray *comp = [date componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@年%@月%@日",comp[0],[XZDateUtils upperNumber:[comp[1] intValue]], [XZDateUtils upperNumber:[comp[2] intValue]]];
    }
    
    return @"";
}

+ (NSString *)upperNumber:(int)num {
    if (num <= 0 || num > 99) {
        return @"";
    }
    NSArray *a = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九"];
    if (num < 10) {
        return a[num-1];
    } else if (num == 10) {
        return @"十";
    } else if (num < 20) {
        return [NSString stringWithFormat:@"十%@",a[num%10 - 1]];
    } else if (!(num % 10)) {
        return [NSString stringWithFormat:@"%@十",a[num/10 - 1]];
    } else {
        return [NSString stringWithFormat:@"%@十%@",a[num/10 - 1],a[num%10 - 1]];
    }
    
}

+ (NSString *)formatPublishDate:(NSString *)publishDate {
    NSDate *date =[NSDate date];//简书 FlyElephant
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYear=[formatter stringFromDate:date];
    NSString *result;
    if ([publishDate containsString:currentYear]) {
        result = [publishDate stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-", currentYear] withString:@""];
    } else {
        result = publishDate;
    }
    return result;
}

+ (long long)timestampFormDate:(NSString*)dateStr dateFormat:(NSString *)dateFormat {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    formatter.dateFormat = dateFormat;

    NSDate *date = [formatter dateFromString:dateStr];
    long long result = [date timeIntervalSince1970]*1000;
    return result;
}

+ (NSString *)dateStrFormTimestamp:(long long)timestam dateFormat:(NSString *)dateFormat {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestam/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    NSString *result = [formatter stringFromDate:date];
    return result;
}

//格式化时间
+ (NSString *)localDateString:(NSString *)oldStr hasTime:(BOOL)hasTime {
    if ([NSString isNull:oldStr]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = hasTime ? kDateFormate_YYYY_MM_DD_HHMM : kDateFormate_YYYY_MM_DD;
    
    NSDate *date = [formatter dateFromString:oldStr];//日期
    NSDate *currentDate = [NSDate date];//今天
    NSDate *nextDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];//明天

    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |
    NSCalendarUnitMinute;
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSDateComponents *nextComps = [currentCalendar components:unitFlags fromDate:nextDate];

    NSDateComponents *comps = [currentCalendar components:unitFlags fromDate:date];
   
    //日期
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
   //今天
    NSInteger cyear = currentComps.year;
    NSInteger cmonth = currentComps.month;
    NSInteger cday = currentComps.day;
    
    //明天
    NSInteger nyear = nextComps.year;
    NSInteger nmonth = nextComps.month;
    NSInteger nday = nextComps.day;

    NSString *result = nil;

    if (year == cyear && month == cmonth && day == cday) {
        result = @"今天";
    }
    else if (year == nyear && month == nmonth && day == nday) {
        result = @"明天";
    }
    else  if (year == cyear) {
        result = [NSString stringWithFormat:@"%02ld-%02ld",month,day];
    }
    else {
        result = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",year,month,day];
    }
    if (hasTime) {
        NSInteger hour = comps.hour;
        NSInteger minute = comps.minute;
        result = [NSString stringWithFormat:@"%@ %02ld:%02ld",result,hour,minute];
    }
    return result;
}

@end
