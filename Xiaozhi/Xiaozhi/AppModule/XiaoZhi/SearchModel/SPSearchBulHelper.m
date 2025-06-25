//
//  SPSearchBulHelper.m
//  CMPCore
//
//  Created by CRMO on 2017/2/26.
//
//

#import "SPSearchBulHelper.h"
#import "SPTools.h"
#import "SPSearchBulModel.h"
#import "SPWillDoneItemModel.h"
#import "XZDateUtils.h"
#import "XZOpenM3AppHelper.h"
@implementation SPSearchBulHelper

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
        self.total = [[responseDic objectForKey:@"count"] integerValue];
        
        NSMutableArray *dataTmp = [NSMutableArray array];
        NSArray *dataArr = [responseDic objectForKey:@"list"];
        for (NSDictionary *dataDic in dataArr) {
            SPSearchBulModel *model = [[SPSearchBulModel alloc] initWithDictionary:dataDic];
            [dataTmp addObject:model];
        }
        self.data = [dataTmp copy];
    }
    return self;
}

- (XZTextModel *)getShowModel {
    NSMutableArray *itemArr = [NSMutableArray array];
    NSInteger t = 0 ;
    BOOL alignmentLeft = self.data.count < 2;
    for (SPSearchBulModel *model in self.data) {
        SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
        willItem.content = self.total >1 ?[NSString stringWithFormat:@"%ld、%@",(long)++t,model.title]: model.title;
        willItem.initiator = [NSString stringWithFormat:@"发起部门：%@", model.publishDeptName];
        willItem.creatDate = [XZDateUtils formatPublishDate:model.publishDateFormat];
        willItem.pageId = model.idField;
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    
    NSMutableString *title;
    if (self.isOption) {
        title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个相关公告。{}", (long)self.total];
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
            NSString *url = [NSString stringWithFormat:@"http://bulletin.v5.cmp/v1.0.0/html/bulIndex.html?openFrom=robot&conditionValue=%@", [SPTools deletePunc:self.searchTitle]];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://bulletin.v5.cmp/v1.0.0/html/bulView.html?openFrom=robot&bulId=%@", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    
    model.clickItems = @[itemArr];
    return model;
}

- (NSString *)getSpeakStr {
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    
    if (self.isOption) {
        [result appendFormat:@"好的，已为你找到以下%ld个相关公告。", (long)self.total];
    } else {
        [result appendFormat:@"{}"];
        NSInteger count = 0;
        for (SPSearchBulModel *model in self.data) {
            count++;
            if (self.data.count > 1) {
                [result appendFormat:@"第%ld条，《%@》。\n", (long)count, model.title];
            } else {
                [result appendFormat:@"《%@》。\n", model.title];
            }
        }
    }
    
    return [result copy];
}

@end
