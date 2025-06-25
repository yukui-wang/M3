//
//  SPScheduleHelper.m
//  CMPCore
//
//  Created by CRMO on 2017/2/24.
//
//

#import "SPScheduleHelper.h"
#import "SPTools.h"
#import "SPScheduleModel.h"
#import "SPWillDoneItemModel.h"
#import "SPConstant.h"
#import "XZDateUtils.h"
#import "XZOpenM3AppHelper.h"
#import <CMPLib/NSString+CMPString.h>

#define SCHEDULE_TITLE  @"好的，你今天的安排有：{}另外，你有：{}"

@implementation SPScheduleHelper

- (instancetype)initWithJson:(NSString *)str {
    if (!str) {
        NSLog(@"speech---SPScheduleHelper:initWithJson err, str is nil");
        return nil;
    }
    
    if (self = [super init]) {
        NSDictionary *responseDic = [SPTools dictionaryWithJsonString:str];
        NSArray *datas = [responseDic objectForKey:@"datas"];
        
        NSMutableArray *planModels = [NSMutableArray array];
        NSMutableArray *beyondDateModels = [NSMutableArray array];
        
        NSInteger planCount = 1;
        NSInteger willdoneCount = 1;
        
        NSInteger numberOfPlan = 0;
        for (NSDictionary *data in datas) {
            NSString *type = [data objectForKey:@"type"];
            if ([self availableType:type]) {
                numberOfPlan ++;
            }
        }

        for (NSDictionary *data in datas) {
            NSString *beginDate = [data objectForKey:@"beginDate"];
//            NSString *createUserId = [data objectForKey:@"createUserId"];
            NSString *endDate = [data objectForKey:@"endDate"];
            NSString *typeName = [data objectForKey:@"typeName"];
            NSString *createUserName = [data objectForKey:@"createUserName"];
            NSString *summaryId = [data objectForKey:@"summaryId"];
            NSString *type = [data objectForKey:@"type"];
            NSString *mid = [data objectForKey:@"id"];
            NSString *title = [data objectForKey:@"title"];
            NSString *timeStr = [XZDateUtils customTimeFormateWithStartTime:beginDate endTime:endDate];
            NSString *readTimeStr = [XZDateUtils readTimeWithStartTime:beginDate endTime:endDate];
            if ([self availableType:type]) {
                SPScheduleModel *sch = [[SPScheduleModel alloc] init];
                if (numberOfPlan > 1) {
                    sch.content = [NSString stringWithFormat:@"%ld、%@%@：%@", (long)planCount, timeStr, typeName, title];
                    sch.readCotent = [NSString stringWithFormat:@"%ld、%@%@：%@", (long)planCount ,readTimeStr, typeName, title];
                } else {
                    sch.content = [NSString stringWithFormat:@"%@%@：%@", timeStr, typeName, title];
                    sch.readCotent = [NSString stringWithFormat:@"%@%@：%@" ,readTimeStr, typeName, title];

                }
                sch.pageId = mid;
                sch.summaryId = summaryId;
                sch.type = type;
                sch.createUserName = createUserName;
                sch.tilte = [NSString stringWithFormat:@"%@：%@",typeName,title];
                sch.time = timeStr;
                [planModels addObject:sch];
                planCount ++;
            } else {
                SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
                willItem.content = [NSString stringWithFormat:@"%ld、《%@》", (long)willdoneCount, title];
                willItem.initiator = [NSString stringWithFormat:@"发起人：%@", createUserName];
                willItem.creatDate = beginDate;
                willItem.type = type;
                willItem.pageId = mid;
                willItem.summaryId = summaryId;
                [beyondDateModels addObject:willItem];
                willdoneCount ++;
            }
        }
        
        self.plans = planModels;
        self.willDones = beyondDateModels;
        if (beyondDateModels.count == 1) {
            //OA-134037 M3-IOS端：查询结果显示，只有一条数据时显示了序号，应该不显示的
            SPWillDoneItemModel *willItem = [beyondDateModels firstObject];
            willItem.content = [willItem.content substringFromIndex:2];
        }
    }
    return self;
}
- (BOOL)availableType:(NSString *)type {
    if ([NSString isNull:type]) {
        return NO;
    }
    NSArray *array = [NSArray arrayWithObjects:SCHEDULE_TYPE_PLAN,SCHEDULE_TYPE_TASK,SCHEDULE_TYPE_TASK_MANAGE,SCHEDULE_TYPE_MEETING,SCHEDULE_TYPE_EVENT,SCHEDULE_TYPE_Calender, nil];
    return [array containsObject:type];
}

- (NSString *)getPlanSpeakStr {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    
    NSInteger willDoneCount = _willDones.count;
    NSInteger planCount = _plans.count;
    
    if (planCount > 0 && willDoneCount > 0) { // 今日安排和待办都有内容
        if (!_noReadPlan) {
            result = [NSMutableString stringWithFormat:@"好的，你今天的安排有："];
            for (SPScheduleModel *schedule in _plans) {
                NSString *readContent = [schedule.readCotent stringByReplacingOccurrencesOfString:@" — " withString:@"至"];
                [result appendFormat:@"%@。 ", readContent];
            }
        }
        [result appendString:@"。另外，你还有：。"];
        [result appendFormat:@"%ld条超期待办未处理。", (unsigned long)_willDones.count];
        [result appendString:@"好了就这些。"];
    } else if (planCount > 0 && willDoneCount == 0) {
        if (!_noReadPlan) {
            result = [NSMutableString stringWithFormat:@"好的，你今天的安排有："];
            for (SPScheduleModel *schedule in _plans) {
                NSString *readContent = [schedule.readCotent stringByReplacingOccurrencesOfString:@" — " withString:@"至"];
                [result appendFormat:@"%@。 ", readContent];
            }
            [result appendString:@"好了就这些。"];
        }
    } else if (planCount == 0 && willDoneCount > 0) {
        result = [NSMutableString stringWithFormat:@"好的，你今天有："];
        [result appendFormat:@"%ld条超期待办未处理。", (unsigned long)_willDones.count];
        [result appendString:@"好了就这些。"];
    }
    return result;
}


- (XZTextModel *)getPlanShowModel {
    NSInteger willDoneCount = _willDones.count;
    NSInteger planCount = _plans.count;
        
    SPWillDoneModel *will = [[SPWillDoneModel alloc] init];
    will.content = @"条超期待办未处理；";
    will.count = willDoneCount;
    
    NSMutableString *title = [NSMutableString stringWithFormat:@""];
    NSArray *itemArr;

    if (planCount > 0 && willDoneCount > 0) { // 今日安排和待办都有内容
        title = [NSMutableString stringWithFormat:@"好的，你今天的安排有：{}另外，你还有：{}好了就这些。"];
        itemArr = @[_plans, @[will]];
    } else if (planCount > 0 && willDoneCount == 0) { // 今日安排有内容，待办没有内容
        title = [NSMutableString stringWithFormat:@"好的，你今天的安排有：{}好了就这些。"];
        itemArr = @[_plans];
    } else if (planCount == 0 && willDoneCount > 0) {
        title = [NSMutableString stringWithFormat:@"好的，你今天有：{}好了就这些。"];
        itemArr = @[@[will]];
    }
    
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:title];
    model.clickBlock = ^(NSObject *item) {
        NSString *url;
        if ([item isKindOfClass:[SPWillDoneModel class]]) { // 点击超期待版
            url = @"http://calendar.v5.cmp/v1.0.0/html/todayArrange.html?from=robot";
        } else {
            SPScheduleModel *schedule = (SPScheduleModel *)item;
            url = [SPScheduleHelper urlWithType:schedule.type andID:schedule.pageId summaryId:schedule.summaryId];
        }
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    model.clickItems = itemArr;
    return model;
}

- (XZScheduleModel *)getPlanShowModel1 {
    XZScheduleModel *model = [[XZScheduleModel alloc] init];
    model.content = @"好的，你今天的安排有：";
    model.showItems = self.plans;
    model.clickBlock = ^(NSObject *clickedObj) {
        SPScheduleModel *schedule = (SPScheduleModel *)clickedObj;
        NSString *url = [SPScheduleHelper urlWithType:schedule.type andID:schedule.pageId summaryId:schedule.summaryId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    return model;
}

- (NSString *)getTodoSpeakStr {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    NSInteger count = 0; // 条数
    for (SPWillDoneItemModel *schedule in _willDones) {
        count++;
        if (_willDones.count > 1) {
            [result appendFormat:@"《%@》。\n", schedule.content];
        } else {
            [result appendFormat:@"《%@》。\n", schedule.content];
        }
    }
    [result appendString:@"好了就这些。"];
    return result;
}

- (XZTextModel *)getTodoShowModel {

    NSMutableArray *itemArr = [NSMutableArray array];
    
    for (SPWillDoneItemModel *willdone in _willDones) {
        [itemArr addObject:willdone];
    }

    
    NSMutableString *title = [NSMutableString stringWithFormat:@"{}好了就这些"];
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:title];
    
    model.clickBlock = ^(NSObject *item) {
        SPWillDoneItemModel *schedule = (SPWillDoneItemModel *)item;
        NSString *url = [SPScheduleHelper urlWithType:schedule.type andID:schedule.pageId summaryId:schedule.summaryId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    
    model.clickItems = @[itemArr];
    return model;
}


/**
 获取跳转的url
 */
+ (NSString *)urlWithType:(NSString *)type andID:(NSString *)ID summaryId:(NSString *)summaryId {
    NSString *url;
    if ([type isEqualToString:SCHEDULE_TYPE_TASK] ||[type isEqualToString:SCHEDULE_TYPE_TASK_MANAGE]  ) {
        url = [NSString stringWithFormat:@"http://taskmanage.v5.cmp/v1.0.0/html/taskEditor.html?from=robot&taskId=%@", ID];
    } else if ([type isEqualToString:SCHEDULE_TYPE_PLAN]) {
        
    } else if ([type isEqualToString:SCHEDULE_TYPE_MEETING]) {
        url = [NSString stringWithFormat:@"http://meeting.v5.cmp/v1.0.0/html/meetingDetail.html?meetingId=%@", ID];
    } else if ([type isEqualToString:SCHEDULE_TYPE_EVENT]||[type isEqualToString:SCHEDULE_TYPE_Calender]) {
        url = [NSString stringWithFormat:@"http://calendar.v5.cmp/v1.0.0/html/newCalEvent.html?from=robot&id=%@", ID];
    } else if ([type isEqualToString:SCHEDULE_TYPE_COLLABORATION]) {
        url = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/details/summary.html?from=robot&affairId=%@&summaryId=%@", ID, summaryId];
    } else if ([type isEqualToString:SCHEDULE_TYPE_EDOC]) {
        url = [NSString stringWithFormat:@"http://edoc.v5.cmp/v1.0.0/html/edocSummary.html?from=robot&affairId=%@", ID];
    }
    return url;
}


@end
