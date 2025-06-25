//
//  CMPDateHelper.h
//  CMPLib
//
//  Created by youlin on 2017/2/21.
//  Copyright © 2017年 CMPCore. All rights reserved.
//

#define kDateFormate_YYYY_MM_DD_HH_MM_SS        @"yyyy-MM-dd hh:mm:ss"  // 12小时制
#define kDateFormate_YYYY_MM_DD_HH_MM_PM        @"yyyy-MM-dd hh:mm a"   // 2013-01-22 20:22 AM/PM
#define kDateFormate_YYYY_MM_DD_HH_MM           @"yyyy-MM-dd HH:mm"     // 2013-01-22 20:22
#define kDateFormate_YYYY_MM_DD                 @"yyyy-MM-dd"           // 2013-01-22
#define kDateFormate_yyyy_mm_dd_HH_mm        @"yyyy-MM-dd HH:mm:ss" // 24小时制
#define kDateFormate_yyyy_mm_dd_HH_mm_ss_SSS        @"yyyy-MM-dd HH:mm:ss.SSS" // 2013-01-22 20:22:22.222
#define kDateFormate_HH_MM        @"HH:mm"  // 20:22

#import <Foundation/Foundation.h>

@interface CMPDateHelper : NSObject

+ (NSString *)getCurrentDate;
+ (NSString *)getCurrentDateStr;

+ (long long)localeDateTimeInterval; // 获取当前时间戳 （以秒为单位）
+ (NSTimeInterval)getNowTimeTimestamp3; //获取当前时间戳 （以毫秒为单位）
+ (NSDate *)getLocalDateFormateUTCDate:(NSString *)utcDate;
+ (long long)longLongFromDate:(NSDate*)date;
+(NSString*)dateStrFromLongLong:(long long)msSince1970;

// 获取当期时间以string形式返回
+ (NSString *)currentDate;
+ (NSNumber *)currentNumberDate;
+ (NSString *)currentDateNumberFormatter;
+(int)getWeekday:(CFGregorianDate)date;					// 计算某一天是星期几 周一＝1，周二＝2......
+(NSString *)getWeekdayString:(CFGregorianDate)date;    // 计算某一天是星期几 周一＝1，周二＝2......
+ (CFGregorianDate)stringToCFGregorianDate2:(NSString*)aStr;
+ (NSString *)localDateByDay:(NSString *)dateStr hasTime:(BOOL)hasTime;
+ (NSString *)messageDateByDay:(NSString *)dateStr hasTime:(BOOL)hasTime;
//将NSDate 转换为Str
+ (NSString *)strFromDate:(NSDate *)aDate formatter:(NSString *)aFormat;
+ (NSDate *)dateFromStr:(NSString *)aStr dateFormat:(NSString *)aFormat;

/**
 计算两个时间之间的间隔(24小时之内)
 时间格式：HH:mm:ss
 两种情况：
 1.开始时间<=结束时间。直接减得到结果。
 2.开始时间>结束时间。结果 = 24- startTime + endTime
 */
+ (long long)intervalOfStartTime:(NSString *)startTime andEndTime:(NSString *)endTime;

/**
 当前时间是否在指定时间段内
 时间格式：HH:mm:ss

 @param startTime 开始时间
 @param endTime 结束时间
 @return 是否在时间段
 */
+ (BOOL)isNowInPeriodWithStart:(NSString *)startTime end:(NSString *)endTime;

/**
 获取当前毫秒时间戳

 @return 毫秒时间戳，字符串
 */
+ (NSString *)nowMillisecondStr;

/**
 获取明天毫秒时间戳

 @return 毫秒时间戳，字符串
 */
+ (NSString *)tomorrowMillisecondStr;

/*获取系统时区GMT+08:00*/
+ (NSString *)timeZoneAbbreviation;

@end
