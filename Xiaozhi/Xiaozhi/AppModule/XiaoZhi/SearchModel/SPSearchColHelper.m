//
//  SPSearchHelper.m
//  CMPCore
//
//  Created by CRMO on 2017/2/25.
//
//

#import "SPSearchColHelper.h"
#import "XZOpenM3AppHelper.h"
@implementation SPSearchColHelper

- (instancetype)initWithJson:(NSString *)str {
    if (!str) {
        NSLog(@"speech---SPSearchHelper:initWithJson err, str is nil");
        return nil;
    }
    
    if (self = [super init]) {
        NSDictionary *responseDic = [SPTools dictionaryWithJsonString:str];
        if (!responseDic) {
            NSLog(@"speech---SPSearchHelper:解析json的字典为空");
            return nil;
        }
        self.total = [SPTools integerValue:responseDic forKey:@"total"] ;
        
        NSMutableArray *dataTmp = [NSMutableArray array];
        NSArray *dataArr = [SPTools arrayValue:responseDic forKey:@"data"];
        for (NSDictionary *dataDic in dataArr) {
            SPSearchColModel *model = [[SPSearchColModel alloc] initWithDictionary:dataDic];
            [dataTmp addObject:model];
        }
        self.data = dataTmp;
    }
    return self;
}

- (XZTextModel *)getShowModel {
    NSMutableArray *itemArr = [NSMutableArray array];
    NSInteger t = 0;
    BOOL alignmentLeft = self.data.count < 2;
    for (SPSearchColModel *model in self.data) {
        SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
        willItem.content = self.total >1 ?[NSString stringWithFormat:@"%ld、%@",(long)++t,model.subject]: model.subject;
        willItem.initiator = [NSString stringWithFormat:@"发起人：%@", model.startMemberName];
        willItem.creatDate = model.startDate;
        willItem.pageId = model.affairId;
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    
    NSMutableString *title;
    if (self.isOption) {
        title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个%@。{}", (long)self.total,self.isExpense ?@"报销单":@"相关协同"];
    } else {
        title = [NSMutableString stringWithFormat:@"{}"];
    }
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotWithClickMessage itemTag:0 contentInfo:title];
    
    if (self.total > self.max) {
        SPSearchColModel *colModel = [self.data firstObject];
        NSString *condition;
        if (colModel.affairState == 3) {
            condition = @"listPending";
        } else if (colModel.affairState == 4) {
            condition = @"listDone";
        }
        else if (colModel.affairState == 2) {
            condition = @"listSent";
        }
        else {
            NSLog(@"speech---SPSearchColHelper,解析到非待办已办数据,affartState=%ld", (long)colModel.affairState);
        }
        model.showMoreBtn = YES;
        model.moreBtnClickAction = ^(XZTextModel *model) {
            if (self.stopSpeakBlock) {
                self.stopSpeakBlock();
            }
            NSString *key = self.info[@"key"];
            NSString *value = self.info[@"value"];

            NSString *url = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/colAffairs.html?openFrom=%@&condition=%@&conditionValue=%@", condition,key,value];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/details/summary.html?affairId=%@", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url autoOrientation:YES];
    };
    
    model.clickItems = @[itemArr];
    return model;
}

- (XZSearchResultModel *)getShowResultModel {
    XZSearchResultModel *model = [[XZSearchResultModel alloc]init];
    model.title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个%@。", (long)self.total,self.isExpense ?@"报销单":@"相关协同"];;
    NSMutableArray *itemArr = [NSMutableArray array];
    NSInteger t = 0;
    BOOL alignmentLeft = self.data.count < 2;
    for (SPSearchColModel *model in self.data) {
        SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
        willItem.content = self.total >1 ?[NSString stringWithFormat:@"%ld、%@",(long)++t,model.subject]: model.subject;
        willItem.initiator = [NSString stringWithFormat:@"发起人：%@", model.startMemberName];
        willItem.creatDate = model.startDate;
        willItem.pageId = model.affairId;
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    
    
    if (self.total > self.max) {
        SPSearchColModel *colModel = [self.data firstObject];
        NSString *condition;
        if (colModel.affairState == 3) {
            condition = @"listPending";
        } else if (colModel.affairState == 4) {
            condition = @"listDone";
        }
        else if (colModel.affairState == 2) {
            condition = @"listSent";
        }
        else {
            NSLog(@"speech---SPSearchColHelper,解析到非待办已办数据,affartState=%ld", (long)colModel.affairState);
        }
        NSString *key = self.info[@"key"];
        NSString *value = self.info[@"value"];
        model.showMoreBtn = YES;
        model.moreBtnClickAction = ^(XZSearchResultModel *model) {
            NSString *url = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/colAffairs.html?openFrom=%@&condition=%@&conditionValue=%@", condition,key,value];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/details/summary.html?affairId=%@", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url autoOrientation:YES];
    };
    
    model.items = itemArr;
    return model;
}

- (NSString *)getSpeakStr {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    
    if (self.isOption) {
        [result appendFormat:@"好的，已为你找到以下%ld个%@。", (long)self.total,self.isExpense ?@"报销单":@"相关协同"];
    } else {
        [result appendFormat:@"{}"];
        NSInteger count = 0;
        for (SPSearchColModel *model in self.data) {
            count++;
            if (self.data.count > 1) {
                [result appendFormat:@"第%ld条，《%@》。\n", (long)count, model.subject];
            } else {
                [result appendFormat:@"《%@》。\n", model.subject];
            }
        }
    }
    
    return [result copy];
}

@end
