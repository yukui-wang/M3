//
//  SPSearchStatisticsHelper.m
//  M3
//
//  Created by wujiansheng on 2018/2/25.
//

#import "SPSearchStatisticsHelper.h"
#import "SPTools.h"
#import "SPScheduleModel.h"
#import "XZStatisticsResultViewController.h"
#import "XZOpenM3AppHelper.h"
@implementation SPSearchStatisticsHelper
- (instancetype)initWithJson:(NSString *)str {
    if (!str) {
        NSLog(@"speech---SPSearchBulHelper:initWithJson err, str is nil");
        return nil;
    }
    
    if (self = [super init]) {
        NSDictionary *responseDic = [SPTools dictionaryWithJsonString:str];
        if (!responseDic) {
            NSLog(@"speech---SPSearchBulHelper:解析json的字典为空");
            return nil;
        }
        self.data = [responseDic objectForKey:@"list"];
        self.total = self.data.count;
        /*
         {
         "id" : null,
         "caption" : "表单统计",
         "list" : [ {
         "id" : "-5074659273918035936",
         "title" : "有流程表单统计图（授权给集团）",
         "itemtype" : 2
         } ]
         }
         */
    }
    return self;
}

- (XZTextModel *)getShowModel {
    NSMutableArray *itemArr = [NSMutableArray array];
    BOOL showIndex = self.total>1;
    for (NSInteger t = 0; t < self.total; t ++) {
        if (t == 5) {
            break;
        }
        NSDictionary *dic  = self.data[t];
        SPScheduleModel *model = [[SPScheduleModel alloc] init];
        model.pageId = dic[@"id"];
        model.content = showIndex ? [NSString stringWithFormat:@"%ld、%@",(long)t+1,dic[@"title"]] : dic[@"title"];
        model.type = dic[@"itemtype"];
        [itemArr addObject:model];
    }
    NSMutableString *title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个相关报表。{}", (long)self.total];
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotWithClickMessage itemTag:0 contentInfo:title];
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPScheduleModel *model = (SPScheduleModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://formqueryreport.v5.cmp/v/html/index.html#dostatistics/2/%@?from=from", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    
    model.clickItems = @[itemArr];
    if (self.total >5) {
        model.showMoreBtn = YES;
        model.moreBtnClickAction = ^(XZTextModel *model) {
            if (self.stopSpeakBlock) {
                self.stopSpeakBlock();
            }
            XZStatisticsResultViewController *aController = [[XZStatisticsResultViewController alloc] init];
            aController.dataList = self.data;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aController];
            [[SPTools currentViewController] presentViewController:nav animated:YES completion:nil];
            nav = nil;
            aController = nil;
        };
    }
    return model;
}

- (NSString *)getSpeakStr {
    NSString *result = [NSString stringWithFormat:@"好的，已为你找到以下%ld个相关报表。",(long)self.total];
    return result;
}
@end
