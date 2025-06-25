//
//  NSDate+CMPDate.m
//  CMPLib
//
//  Created by CRMO on 2018/10/18.
//  Copyright © 2018 CMPCore. All rights reserved.
//

#import "NSDate+CMPDate.h"

@implementation NSDate (CMPDate)

- (NSString *)cmp_millisecondStr {
//    NSInteger time = [self timeIntervalSince1970] * 1000;
//    NSString *str = [[NSNumber numberWithInteger:time] stringValue];
    NSTimeInterval time = [self timeIntervalSince1970] * 1000;
    NSString *str = [[NSNumber numberWithDouble:time] stringValue];

    return str;
}

- (NSString *)cmp_secondStr {
//    NSInteger time = [self timeIntervalSince1970];
//    NSString *str = [[NSNumber numberWithInteger:time] stringValue];
    NSTimeInterval time = [self timeIntervalSince1970];
    NSString *str = [[NSNumber numberWithDouble:time] stringValue];

    return str;
}

- (BOOL)cmp_isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

- (NSString *)formatDateDayString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentTimeString = [formatter stringFromDate:self];
    return currentTimeString;
}

@end
