//
//  LPUnitily.m
//  IntegralManage
//
//  Created by tbow-app-02 on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LPUnitily.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"
#import "CMPConstant.h"
@implementation LPUnitily

+ (NSString *)decodeString:(NSString *)string{
	return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeString:(NSString *)string
{
    //(CFStringRef)@";/?:@&=$+<>{},"
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                                    (__bridge CFStringRef)string, 
                                                                                    NULL, 
                                                                                    (CFStringRef)@";/?:@&=$+<>,",
                                                                                    kCFStringEncodingUTF8);
	//NSString *result=[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}

+ (NSString *)stringWithMD5:(NSString *)source{
	
	
	const char *cStr = [source UTF8String]; 
    unsigned char result[32]; 
    CC_MD5( cStr, strlen(cStr), result ); 
    return [NSString stringWithFormat: 
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7], 
            result[8], result[9], result[10], result[11], 
            result[12], result[13], result[14], result[15] 
            ]; 
	
}

+(NSData *)md5Data:(NSData *)data{
    const void *ptrData = [data bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptrData, [data length], result);
    return [NSData dataWithBytes:result length:16];
}


+ (NSDateFormatter *)_HTTPDateFormatter
{
    // Returns a formatter for dates in HTTP format (i.e. RFC 822, updated by RFC 1123).
    // e.g. "Sun, 06 Nov 1994 08:49:37 GMT"
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	//[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return dateFormatter;
}

//convert string to date
+ (NSDate *)stringToDate:(NSString *)httpDate
{
    NSDateFormatter *dateFormatter = [LPUnitily _HTTPDateFormatter];
    return [dateFormatter dateFromString:httpDate];
}

+ (NSDateFormatter *)_HTTPDateFormatter2
{
    // Returns a formatter for dates in HTTP format (i.e. RFC 822, updated by RFC 1123).
    // e.g. "Sun, 06 Nov 1994 08:49:37 GMT"
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	//[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	return dateFormatter;
}

//convert string to date
+ (NSDate *)stringToDate2:(NSString *)httpDate
{
    NSDateFormatter *dateFormatter = [LPUnitily _HTTPDateFormatter2];
    return [dateFormatter dateFromString:httpDate];
}

//convert date to string
+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [LPUnitily _HTTPDateFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)dateToString2:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [LPUnitily _HTTPDateFormatter2];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)weekdayofDate:(NSDate *)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | 
													NSDayCalendarUnit | NSWeekdayCalendarUnit ) 
										  fromDate:date];
    switch ([comp weekday]) {
        case 7:
            return SY_STRING(@"Common_Saturday");
            break;
        case 1:
            return SY_STRING(@"Common_Sunday");
            break;
        case 2:
            return SY_STRING(@"Common_Monday");
        case 3:
            return SY_STRING(@"Common_Tuesday");
            break;
        case 4:
            return SY_STRING(@"Common_Wednesday");
            
        case 5:
            return SY_STRING(@"Common_Thursday");
            break;
        case 6:
            return SY_STRING(@"Common_Friday");
            break;
        default:
            return @"";
            break;
    }
}
+ (NSString *)dateWithWeekDay:(NSDate *)date{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | 
													NSDayCalendarUnit | NSWeekdayCalendarUnit ) 
										  fromDate:date];
    NSString *weekDay=@"";
    switch ([comp weekday]) {
        case 7:
            weekDay=SY_STRING(@"Common_Saturday");
            break;
        case 1:
            weekDay=SY_STRING(@"Common_Sunday");
            break;
        case 2:
            weekDay=SY_STRING(@"Common_Monday");
            break;
        case 3:
            weekDay=SY_STRING(@"Common_Tuesday");
            break;
        case 4:
            weekDay=SY_STRING(@"Common_Wednesday");
            break;
        case 5:
            weekDay=SY_STRING(@"Common_Thursday");
            break;
        case 6:
            weekDay=SY_STRING(@"Common_Friday");
            break;
        default:
            weekDay=@"";
            break;
    }
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld %@",(long)[comp year],(long)[comp month],(long)[comp day],weekDay];
}
+ (float)iosVersion{
    return [[UIDevice currentDevice].systemVersion floatValue];
}

+ (void)setBorderByView:(UIView *)view{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.f];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
}

+ (void)setRoundBorderByView:(UIView *)view{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:6.f];
    [layer setBorderWidth:1.f];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
}


//+ (NSString *)md5Digest:(NSString *)str{
//	const char *cStr = [str UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, strlen(cStr), result);
//    return [NSString stringWithFormat:
//            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
//            ];
//}

// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    /**
     电话号码 手机号码同时验证
     */
    //    NSString *PhoneAndPHS = @"(^(\\d{3,4}-)?\\d{7,8})$|(13[0-9]{9})";
    
    //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    //    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    //    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    //    NSPredicate *regextestPhoneAndPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PhoneAndPHS];
    
    return ([mobileNum isMatchedByRegex:MOBILE]||[mobileNum isMatchedByRegex:CM]||[mobileNum isMatchedByRegex:CU]||[mobileNum isMatchedByRegex:CT]||[mobileNum isMatchedByRegex:PHS]);
}

+ (BOOL)isEmailNumber:(NSString *)emailNumber
{
    NSString * Email = @"^[0-9a-zA-Z_.]+@(([0-9a-zA-Z]+)[.])+[a-z]{2,4}$";
    return [emailNumber isMatchedByRegex:Email];
}

+ (BOOL)isAreaNumber:(NSString *)arealNumber{
    NSString * Area = @"0(10|2[0-5789]|\\d{3})";
    return [arealNumber isMatchedByRegex:Area];
}

+ (BOOL)isNumber:(NSString *)number{
    NSString * Number = @"^[0-9]*$";
    return [number isMatchedByRegex:Number];
}

+ (BOOL)isPhoneNumber:(NSString *)number{
    NSString * Number = @"\\d{7,8}";
    return [number isMatchedByRegex:Number];
}

+ (BOOL)isZipCode:(NSString *)zipCode{
    NSString * code = @"\\d{6}";
    return [zipCode isMatchedByRegex:code];
}


@end


