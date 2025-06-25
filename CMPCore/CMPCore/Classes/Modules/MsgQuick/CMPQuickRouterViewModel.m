//
//  CMPQuickRouterViewModel.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/10.
//

#import "CMPQuickRouterViewModel.h"
#import "CMPQuickRouterDataProvider.h"
#import "CMPAppViewItem.h"

@interface CMPQuickRouterViewModel()

@property (nonatomic,strong) CMPQuickRouterDataProvider *dataProvider;

@end

@implementation CMPQuickRouterViewModel

-(void)fetchQuickItemsWithResult:(void(^)(NSArray<CMPAppModel *> *appList,NSError *error,id ext))result
{
    if (!result) {
        return;
    }
    __weak typeof(self) wSelf = self;
    [self.dataProvider fetchQuickItemsWithResult:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            if (respData && [respData isKindOfClass:NSArray.class]) {
                NSArray *apps = [NSArray yy_modelArrayWithClass:CMPAppModel.class json:respData];
                if (apps) {
                    [apps enumerateObjectsUsingBlock:^(CMPAppModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (!obj.iconBgColor || obj.iconBgColor.length == 0) {
                            if ([@"6" isEqualToString:obj.appId]) {
                                obj.iconBgColor = @"qk-bg-meet";
                            }else if ([obj isScanCodeApp]) {
                                obj.iconBgColor = @"qk-bg-scan";
                            }else if ([@"118" isEqualToString:obj.appId]) {
                                obj.iconBgColor = @"qk-bg-doc";
                            }
                        }
                    }];
                    wSelf.sortedAppList = [apps sortedArrayUsingComparator:^NSComparisonResult(CMPAppModel  *obj1, CMPAppModel *obj2) {
                        if (obj1.sort <= obj2.sort) {
                            return NSOrderedAscending;
                        }
                        return NSOrderedDescending;
                    }];
                    result(wSelf.sortedAppList,nil,ext);
                    return;
                }
            }
            result(nil,[NSError errorWithDomain:@"data convert error" code:-11 userInfo:nil],ext);
        }else{
            result(nil,error,ext);
        }
        wSelf.sortedAppList = nil;
    }];
}

-(NSArray<CMPAppModel *> *)needToShowItemsArr
{
    if (!self.sortedAppList || self.sortedAppList.count == 0) return @[];

    BOOL containUnread = NO;
    for (CMPAppModel *appModel in self.sortedAppList) {
        if ([appModel isScanCodeApp]){
            continue;
        }
        if (appModel.unread > 0) {
            containUnread = YES;
            break;
        }
    }
    if (!containUnread) return @[];
    return [NSArray arrayWithArray:self.sortedAppList];
    
//    NSMutableArray *notIgnoreArr = [NSMutableArray array];
//    NSMutableArray *ignoreArr = [NSMutableArray array];
//
//    for (CMPAppModel *appModel in self.sortedAppList) {
//        if ([appModel isScanCodeApp]){
//            [ignoreArr addObject:appModel];
//            continue;
//        }
//        if (appModel.unread <= 0) {
//            continue;
//        }
//        [notIgnoreArr addObject:appModel];
//    }
//    if (notIgnoreArr.count == 0) return @[];
//
//    NSMutableArray *finalArr = [NSMutableArray array];
//    [finalArr addObjectsFromArray:ignoreArr];
//    [finalArr addObjectsFromArray:notIgnoreArr];
//
//    return [finalArr sortedArrayUsingComparator:^NSComparisonResult(CMPAppModel  *obj1, CMPAppModel *obj2) {
//        if (obj1.sort <= obj2.sort) {
//            return NSOrderedAscending;
//        }
//        return NSOrderedDescending;
//    }];
}

-(CMPQuickRouterDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPQuickRouterDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
