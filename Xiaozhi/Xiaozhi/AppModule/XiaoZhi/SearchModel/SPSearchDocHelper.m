//
//  SPSearchDocHelper.m
//  CMPCore
//
//  Created by CRMO on 2017/2/26.
//
//

#import "SPSearchDocHelper.h"
#import "SPTools.h"
#import "SPSearchDocModel.h"
#import "SPWillDoneItemModel.h"
#import "XZOpenM3AppHelper.h"
@implementation SPSearchDocHelper

- (instancetype)initWithJson:(NSString *)str {
    if (!str) {
        NSLog(@"speech---SPSearchHelper:initWithJson err, str is nil");
        return nil;
    }
    
    if (self = [super init]) {
        NSDictionary *responseDic = [SPTools dictionaryWithJsonString:str];
        if (!responseDic) {
            NSLog(@"speech---SPSearchDocHelper:解析json的字典为空");
            return nil;
        }
        self.total = [[responseDic objectForKey:@"total"] integerValue];
        
        NSMutableArray *dataTmp = [NSMutableArray array];
        NSArray *dataArr = [responseDic objectForKey:@"data"];
        for (NSDictionary *dataDic in dataArr) {
            SPSearchDocModel *model = [[SPSearchDocModel alloc] initWithDictionary:dataDic];
            [dataTmp addObject:model];
        }
        self.data = [dataTmp copy];
    }
    return self;
}

- (XZTextModel *)getShowModel {
    NSMutableArray *itemArr = [NSMutableArray array];
    NSInteger t = 0;
    BOOL alignmentLeft = self.data.count < 2;
    for (SPSearchDocModel *model in self.data) {
        SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
        willItem.content = self.total >1 ?[NSString stringWithFormat:@"%ld、%@",(long)++t,model.frName]: model.frName;
        willItem.initiator = [NSString stringWithFormat:@"创建人：%@", model.frCreateUsername];
        willItem.creatDate = model.frCreateTime;
        willItem.pageId = model.frId;
        willItem.frMineType = [NSString stringWithFormat:@"%ld", (long)model.frMineType];
        willItem.frType = [NSString stringWithFormat:@"%ld", (long)model.frType];
        willItem.sourchId = model.sourchId;
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    
    NSMutableString *title;
    if (self.isOption) {
        title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个相关文档。{}", (long)self.total];
    } else {
        title = [NSMutableString stringWithFormat:@"{}"];
    }
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotWithClickMessage itemTag:0 contentInfo:title];
    
    if (self.total > 5) {
        model.showMoreBtn = YES;
        model.moreBtnClickAction = ^(XZTextModel *model) {
            if (self.stopSpeakBlock) {
                self.stopSpeakBlock();
            }
            NSString *url = [NSString stringWithFormat:@"http://doc.v5.cmp/v1.0.0/html/docList4xz.html?value=%@", [SPTools deletePunc:self.searchTitle]];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://doc.v5.cmp/v1.0.0/html/doc4xz.html?fr_id=%@&entranceType=5&isShareAndBorrowRoot=false&fr_type=%@&fr_mine_type=%@&source_id=%@", model.pageId, model.frType, model.frMineType, model.sourchId];
        [XZOpenM3AppHelper showWebviewWithUrl:url autoOrientation:YES];
    };
    
    model.clickItems = @[itemArr];
    return model;
}

- (NSString *)getSpeakStr {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    
    if (self.isOption) {
        [result appendFormat:@"好的，已为你找到以下%ld个相关文档。", (long)self.total];
    } else {
        [result appendFormat:@"{}"];
        NSInteger count = 0; // 条数
        for (SPSearchDocModel *model in self.data) {
            count++;
            if (self.data.count > 1) {
                [result appendFormat:@"第%ld条，《%@》。\n", (long)count, model.frName];
            } else {
                [result appendFormat:@"《%@》。\n", model.frName];
            }
        }
    }
    
    return [result copy];
}

@end
