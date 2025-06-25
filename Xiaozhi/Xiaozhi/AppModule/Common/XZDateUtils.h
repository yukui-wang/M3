//
//  XZDateUtils.h
//  M3
//
//  Created by wujiansheng on 2019/2/13.
//

#define kDateFormate_YYYY_MM_DD                 @"yyyy-MM-dd"
#define kDateFormate_YYYY_MM_DD_HHMMSS           @"yyyy-MM-dd HH:mm:ss"
#define kDateFormate_YYYY_MM_DD_HHMM           @"yyyy-MM-dd HH:mm"

#import <Foundation/Foundation.h>

/*
 * @Description 语音中文转日期格式
 * 转换策略：
 *  1、将语音文字进行所有口语化的文字正则匹配，如果能匹配其中一种，则返回值，如果全部不匹配则返回null，澄清提示用户需要说时间
 *  2、语音具体的时间进行时间格式返回，如：二零一九年八月五日，则返回2019-08-05，如果语音说的是一个时间段，则将开始时间和结束时间一起返回，比如说“上个月”，则返回"2019-02-01#2019-02-28"，前后时间使用#连接
 *  3、转换的内容包括国历、农历、常用国历、农历节假日时间、周、旬、年、时分秒,上午、下午
 * ====================================================================
 *
 */
@interface XZDateUtils : NSObject
//interval 是否是时间区间
+ (NSString *)obtainFormatDateTime:(NSString *)command hasTime:(BOOL)hasTime interval:(BOOL)interval;
+ (NSString *)obtainTimestamp:(NSString *)command hasTime:(BOOL)hasTime interval:(BOOL)interval;
+ (void)clearData;

/**中文数字转阿拉伯数字(包含小数点)*/
+ (NSString *)convertChineseNumberToArabicNumber:(NSString *)str;
+ (NSInteger)convertChineseNumberToIndexNumber:(NSString *)str;

+ (NSString *)customTimeFormateWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;
/**获取到今日开始的时间戳*/
+ (NSString *)todayMinTimeStamp;
/**获取到今日结束的时间戳*/
+ (NSString *)todayMaxTimeStamp;
/**转换为机器可读的时间*/
+ (NSString*)readTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;
/** 如果是本年的日期，去掉年份*/
+ (NSString *)formatPublishDate:(NSString *)publishDate;

+ (long long)timestampFormDate:(NSString*)dateStr dateFormat:(NSString *)dateFormat;
+ (NSString *)dateStrFormTimestamp:(long long)timestam dateFormat:(NSString *)dateFormat;

//格式化时间
+ (NSString *)localDateString:(NSString *)oldStr hasTime:(BOOL)hasTime;


@end

