//
//  SPSearchNewsHelper.m
//  M3
//
//  Created by wujiansheng on 2018/9/13.
//

#import "SPSearchNewsHelper.h"
#import "SPTools.h"
#import "SPWillDoneItemModel.h"
#import "XZOpenM3AppHelper.h"
#import "XZNewsItemModel.h"

@implementation SPSearchNewsHelper
- (instancetype)initWithJson:(NSString *)str {
    if (!str) {
        return nil;
    }
    if (self = [super init]) {
        NSDictionary *responseDic = [SPTools dictionaryWithJsonString:str];
        if (!responseDic) {
            return nil;
        }
        self.data = [responseDic objectForKey:@"list"];
        self.total = [[responseDic objectForKey:@"count"] integerValue];
        if (self.data.count > self.total) {
            self.total = self.data.count;
        }
    }
    return self;
}

- (NSString *)valueWithStr:(NSString *)vaule {
    if ([NSString isNull:vaule]) {
        return @"";
    }
    return vaule;
}


- (XZTextModel *)getShowModel {
    NSMutableArray *itemArr = [NSMutableArray array];
    BOOL showIndex = self.total>1;
    BOOL alignmentLeft = self.data.count < 2;
    for (NSInteger t = 0; t < self.total; t ++) {
        if (t == 5) {
            break;
        }
        NSDictionary *dic  = self.data[t];
        SPWillDoneItemModel *willItem = [[SPWillDoneItemModel alloc] init];
        NSString *title = [self valueWithStr:dic[@"title"]];
        willItem.content = showIndex ?[NSString stringWithFormat:@"%ld、%@",(long)(t+1),title]: title;
        willItem.initiator = [self valueWithStr:dic[@"showPublishName"]];
        willItem.creatDate = [self valueWithStr:dic[@"publishTime"]];
        willItem.pageId =  [self valueWithStr:dic[@"id"]];
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    NSMutableString *title = [NSMutableString stringWithFormat:@"好的，已为你找到以下%ld个相关新闻。{}", (long)self.total];
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotWithClickMessage itemTag:0 contentInfo:title];
    model.clickBlock = ^(NSObject *item) {
        if (self.stopSpeakBlock) {
            self.stopSpeakBlock();
        }
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://news.v5.cmp/v1.0.0/html/newsView.html?openFrom=robot&newsId=%@", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    
    model.clickItems = @[itemArr];
    if (self.total >5) {
        model.showMoreBtn = YES;
        model.moreBtnClickAction = ^(XZTextModel *model) {
            NSString *url = [NSString stringWithFormat:@"http://news.v5.cmp/v1.0.0/html/newsIndex.html?openFrom=robot&conditionValue=%@",[SPTools deletePunc:self.searchTitle]];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    return model;
}

- (XZSearchResultModel *)getShowResultModel {
    
    NSMutableArray *itemArr = [NSMutableArray array];
    BOOL alignmentLeft = self.data.count < 2;
    for (NSInteger t = 0; t < self.total; t ++) {
        if (t == 5) {
            break;
        }
        NSDictionary *dic  = self.data[t];
        XZNewsItemModel *willItem = [[XZNewsItemModel alloc] init];
        NSString *title = [self valueWithStr:dic[@"title"]];
        willItem.content = title;
        willItem.initiator = [self valueWithStr:dic[@"showPublishName"]];
        willItem.creatDate = [self valueWithStr:dic[@"publishTime"]];
        willItem.pageId =  [self valueWithStr:dic[@"id"]];
        willItem.showDot = YES;
        willItem.alignmentLeft = alignmentLeft;
        [itemArr addObject:willItem];
    }
    
    XZSearchResultModel *model = [[XZSearchResultModel alloc]init];
    model.title = [NSString stringWithFormat:@"好的，已为你找到以下%ld个相关新闻。", (long)self.total];
    model.clickBlock = ^(NSObject *item) {
        NSLog(@"点击了%@",[(id)item content]);
        SPWillDoneItemModel *model = (SPWillDoneItemModel *)item;
        NSString *url = [NSString stringWithFormat:@"http://news.v5.cmp/v1.0.0/html/newsView.html?openFrom=robot&newsId=%@", model.pageId];
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    };
    
    model.items = itemArr;
    if (self.total >5) {
        model.showMoreBtn = YES;
        NSString *searchTitle = self.searchTitle;
        model.moreBtnClickAction = ^(XZSearchResultModel *model) {
            NSString *url = [NSString stringWithFormat:@"http://news.v5.cmp/v1.0.0/html/newsIndex.html?openFrom=robot&conditionValue=%@",[SPTools deletePunc:searchTitle]];
            [XZOpenM3AppHelper showWebviewWithUrl:url];
        };
    }
    if (!model.showMoreBtn) {
        XZNewsItemModel *willItem = [itemArr lastObject];
        willItem.isLast = YES;
    }
    return model;
}

- (NSString *)getSpeakStr {
    NSString *result = [NSString stringWithFormat:@"好的，已为你找到以下%ld个相关新闻。",(long)self.total];
    return result;
}

@end

