//
//  XZIntentPrivilege.m
//  M3
//
//  Created by wujiansheng on 2018/12/27.
//

#define kDefaultShowStr    @"播报今日安排\n查【某天】的工作提醒\n发起日程\n打电话给“张三”\n发短信给“张三”\n查找“张三”\n我要请假\n打开应用（如：打开协同）"
#define kDefaultShowAllStr @"播报今日安排\n查【某天】的工作提醒\n发起日程\n打电话给“张三”\n发短信给“张三”\n查找“张三”\n我要请假\n打开应用（如：打开协同）\n我要发协同\n查询报销流程\n查找报表数据\n查找文档\n查找公告\n查找协同\n查找“张三”发的“待办”协同\n可以通过“你好小致”唤醒我"

#import "XZIntentPrivilege.h"
#import "XZUnitIntent.h"
#import "XZCore.h"

@implementation XZIntentPrivilege

- (id)initWithResult:(NSArray *)array {
    
    if (self = [super init]) {
        if (array) {
            NSMutableString *showAllStr = [NSMutableString string];
            NSMutableString *showStr = [NSMutableString string];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
                for (NSInteger i = 0 ; i < array.count ; i ++) {
                    XZUnitIntent *c = [[XZUnitIntent alloc] initWithResult:array[i]];
                    if (![NSString isNull:c.intentName]) {
                        [dic setObject:c forKey:c.intentName];
                        if (c.display) {
                            if (showAllStr.length > 0) {
                                [showAllStr appendString:@"\n"];
                            }
                            [showAllStr appendString:c.text];
                            
                            if (i < 8) {
                                [showStr appendString:c.text];
                                if (i < 7) {
                                    [showStr appendString:@"\n"];
                                }
                            }
                            if (i > 8) {
                                self.showMore = YES;
                            }
                        }
                    }
                }
            }
            else {
                [showStr appendString:kDefaultShowStr];
                [showAllStr appendString:kDefaultShowAllStr];
                self.showMore = YES;
            }
            self.intentDic = dic;
            self.showStr = showStr;
            self.showAllStr = showAllStr;
        }
        else {
            self.showStr = kDefaultShowStr;
            self.showAllStr = kDefaultShowAllStr;
            self.showMore = YES;
        }
    }
    return self;
}

- (id)initWithIntentNameArray:(NSArray *)array {
    if (self = [super init]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *intentName in array) {
            if (![NSString isNull:intentName]) {
                [dic setObject:[NSNumber numberWithBool:YES] forKey:intentName];
            }
        }
        self.intentDic = dic;
        
        self.showStr = kDefaultShowStr;
        self.showAllStr = kDefaultShowAllStr;
        self.showMore = YES;
    }
    return self;
}

- (BOOL)isAvailableIntentName:(NSString *)intentName {
    if (!self.intentDic) {
        return YES;
    }
    if ([intentName rangeOfString:@"FAQ_"].location != NSNotFound) {
        //QA不在这儿判断权限
        return YES;
    }
    if ([[XZCore sharedInstance] isM3ServerIsLater8]  &&
        [intentName rangeOfString:@"FAQ_KB"].location != NSNotFound) {
       //8.0权限在server过滤
        return YES;
    }
    return self.intentDic[intentName] ? YES : NO;
}

@end

