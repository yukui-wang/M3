//
//  XZCreateScheduleModel.m
//  M3
//
//  Created by wujiansheng on 2018/8/8.
//

#import "XZCreateScheduleModel.h"
#import <CMPLib/NSString+CMPString.h>

@implementation XZCreateScheduleModel

- (void)dealloc {
    self.from = nil;
    self.shareType = nil;
    self.beginDate = nil;
    self.endDate = nil;
}

- (id)initWithUnitResult:(NSDictionary *)dic {
    if (self = [super init]) {
        self.subject = nil;
        self.content = nil;
        self.from = @"robot";
        self.shareType = @"1";//标准产品是1，郑州大学西亚斯国际学院是 @"4"; //[[dic allKeys] containsObject:@"user_schedulepublic"]? @"4":@"1";
//        NSString *time = dic[@"user_begintime"];
        self.beginDate = [self standardTime:dic[@"user_begintime"] appendStr:@"08:30:00"];
//        time = dic[@"user_endtime"];
        self.endDate = [self standardTime:dic[@"user_endtime"] appendStr:@"17:30:00"];
        self.subject = @"";
        self.content = @"";
    }
    return self;
}

- (NSString *)standardTime:(NSString *)time appendStr:(NSString *)appdStr{
    NSString *result = [time replaceCharacter:@"|" withString:@" "];
    result = [result replaceCharacter:@"-00" withString:@"-01"];

    if (result.length ==10) {
        //这个代表只有日期，没有时间
        result = [NSString stringWithFormat:@"%@ %@",time,appdStr];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ([result rangeOfString:@"-"].location == NSNotFound &&[result rangeOfString:@":"].location != NSNotFound) {
        //只有时间
        NSString *rightStr = result;
        NSInteger t = [[rightStr replaceCharacter:@":" withString:@""] integerValue];
        if (t == 0 ) {
            //处理类似0:0:0
            rightStr = @"00:00:00";
        }
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        result = [NSString stringWithFormat:@"%@ %@",dateStr,rightStr];
    }
    
    if (result.length >16) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else if (result.length == 16) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormatter dateFromString:result];
    long long timeInterval = [date timeIntervalSince1970] *1000;
    return [NSString stringWithLongLong:timeInterval];
}

- (NSString *)submitUrl {
    return @"/rest/event/add?&option.n_a_s=1";
}

- (NSString *)showUrl {
    return @"http://application.m3.cmp/v/layout/xiaozhi-transit-page.html";
}

- (NSDictionary *)requestParam {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.subject forKey:@"subject"];
    [dic setObject:self.beginDate forKey:@"beginDate"];
    [dic setObject:self.endDate forKey:@"endDate"];
    [dic setObject:self.content?self.content: @"" forKey:@"content"];
    [dic setObject:self.shareType forKey:@"shareType"];
    [dic setObject:self.from forKey:@"from"];
    [dic setObject:[NSNumber numberWithInteger:10] forKey:@"alarmDate"];//此处写死，开始前10分钟提醒
    [dic setObject:[NSNumber numberWithInteger:0] forKey:@"beforendAlarm"];//此处写死，结束提醒时间约等于结束时间
    [dic setObject:[NSNumber numberWithInteger:0] forKey:@"signifyType"];//此处写死，重要程度写成0，重要紧急
    return dic;
}

- (NSDictionary *)speechInput {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"11",@"appId", nil] forKey:@"extData"];
    [dic setObject:[self requestParam] forKey:@"sendParms"];
    return dic;
}


@end
