//
//  NSDate+XMP_Extensions.h
//  XmppDemo
//
//  Created by weitong on 13-2-3.
//  Copyright (c) 2013年 weit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPConstant.h"

@class XMPDate;
@interface NSDate (XMP_Extensions)

+ (NSDate *)dateFromUTC:(NSString *)utc;
+ (NSString *)utcStringFromDate:(NSDate *)date;
+ (NSString *)timetap:(NSString *)time;
+ (NSString*)nextStringValueForFileName;

+ (NSString *)memberIconText;

+ (BOOL)timeIntervalMoreWithMinite:(NSUInteger)minite withUTC1:(NSString *)utc1 withUTC2:(NSString *)utc2;

@end


@interface XMPDate : NSObject
{
    NSString*                  _year;
    NSString*                  _month;
    NSString*                  _day;
    NSString*                  _hour;
    NSString*                  _minite;
    NSString*                  _second;
    NSDate*                    _date;
}
@property(nonatomic,strong) NSString*      year;
@property(nonatomic,strong) NSString*      month;
@property(nonatomic,strong) NSString*      day;
@property(nonatomic,strong) NSString*      hour;
@property(nonatomic,strong) NSString*      minite;
@property(nonatomic,strong) NSString*      second;
@property(nonatomic,strong) NSDate*        date;
@property(nonatomic,strong) NSString*      dateString;

- (id)initWithUTC:(NSString *)utc;

- (BOOL)isSameDay:(XMPDate *)toDate;
- (BOOL)isSameMinite:(XMPDate *)toDate;

@end