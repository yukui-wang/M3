//
//  LPUnitily.h
//  IntegralManage
//
//  Created by tbow-app-02 on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface LPUnitily : NSObject{
	
}

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/**
 对字符串进行URL解码
 @param string  要进行解码的字符串
 @return    解码后的字符串
 */
+ (NSString *)decodeString:(NSString *)string;
/**
 对字符串进行URL编码
 @param string  要进行编码的字符串
 @return    编码后的字符串
 */
+ (NSString *)encodeString:(NSString *)string;
/**
 将字符串进行MD5加密
 @param source  要进行MD5的源
 @return    加密后的字符串
 */
+ (NSString *)stringWithMD5:(NSString *)source;
/**
 将NSData进行MD5加密
 @param data  要进行MD5的源
 @return    加密后的NSData
 */
+ (NSData *)md5Data:(NSData *)data;
/**
 将字符串转换为16进制形式
 @param str 待转换的字符串
 @return    转换后的16进制字符串
 */
//+ (NSString *) stringToHex:(NSString *)str;
/**
 将字符串进行MD5返回大写形式
 @param source  待加密源
 @return    加密后大写字符串
 @
 */
//+ (NSString *)UpperCaseStringWithMD5:(NSString *)source;
/**
 字符串格式日期转换成NSDate
 @param httpDate    字符串格式日期
 @param NSDate对象
 */
+ (NSDate *)stringToDate:(NSString *)httpDate;
+ (NSDate *)stringToDate2:(NSString *)httpDate;
/**
 日期对象转换为字符串
 @param date 日期对象
 @return 日期字符串格式
 */
+ (NSString *)dateToString:(NSDate *)date;
+ (NSString *)dateToString2:(NSDate *)date;
/**
 得到日期的星期
 @param date    日期对象
 @return 星期的字符串表示
 */
+ (NSString *)weekdayofDate:(NSDate *)date;
/**
 返回带有星期的日期字符串
 @param date    日期对象
 @return    带有星期的日期字符串
 */
+ (NSString *)dateWithWeekDay:(NSDate *)date;
/**
 获取系统版本
 @return    系统版本
 */
+ (float)iosVersion;


+ (void)setBorderByView:(UIView *)view;
+ (void)setRoundBorderByView:(UIView *)view;
//+ (NSString *)md5Digest:(NSString *)str;
// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
//正则判断邮箱格式
+ (BOOL)isEmailNumber:(NSString *)emailNumber;
//正则判断区号
+ (BOOL)isAreaNumber:(NSString *)arealNumber;
//正则判断数字
+ (BOOL)isNumber:(NSString *)number;
//正则判断邮编
+ (BOOL)isZipCode:(NSString *)zipCode;
//正则判断固话号
+ (BOOL)isPhoneNumber:(NSString *)number;

@end

