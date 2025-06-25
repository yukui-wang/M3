//
//  CMPOcrInvoiceCategoryEditViewModel.m
//  M3
//
//  Created by Kaku Songu on 12/23/21.
//

#import "CMPOcrInvoiceCategoryEditViewModel.h"
#import "CMPOcrMainViewDataProvider.h"
#import "CMPOcrModulesManageCollectionViewModel.h"

@interface CMPOcrInvoiceCategoryEditViewModel()
@property (nonatomic,strong) CMPOcrMainViewDataProvider *dataProvider;
@property (nonatomic,strong) __block NSMutableArray *sortNumbArr;//用于存模块分类的顺序，最后排序后要根据此数据，重新负值sortNo传给后台
@end

@implementation CMPOcrInvoiceCategoryEditViewModel

-(CMPOcrMainViewDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrMainViewDataProvider alloc] init];
    }
    return _dataProvider;
}

-(NSMutableArray *)sortNumbArr
{
    if (!_sortNumbArr) {
        _sortNumbArr = [[NSMutableArray alloc] init];
    }
    return _sortNumbArr;
}

//默认票夹获取全部moudle
-(void)fetchAllModulesToDefaultInvoiceWithParams:(NSDictionary *)params completion:(void(^)(NSArray *modules,NSError *error,id ext))completion{
    if (!completion) {
        return;
    }
    [self.dataProvider fetchAllModulesWithParams:params completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            NSArray *arr = [NSArray yy_modelArrayWithClass:CMPOcrModuleItemModel.class json:respData];
            completion(arr,nil,ext);
        }else{
            completion(nil,error,ext);
        }
    }];
}

-(void)fetchAllModulesWithParams:(NSDictionary *)params completion:(void(^)(NSArray *modules,NSError *error,id ext))completion
{
    if (!completion) {
        return;
    }
    self.sortNumbArr;
    [self.dataProvider fetchAllModulesWithParams:params completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            [self->_sortNumbArr removeAllObjects];
            NSArray *arr = [NSArray yy_modelArrayWithClass:CMPOcrModuleItemModel.class json:respData];
            NSMutableArray *arr1 = [[NSMutableArray alloc] init];
            NSMutableArray *arr2 = [[NSMutableArray alloc] init];
            NSMutableArray *arr11 = [[NSMutableArray alloc] init];
            NSMutableArray *arr22 = [[NSMutableArray alloc] init];
            for (CMPOcrModuleItemModel *aModule in arr) {
                
                CMPOcrModulesManageCollectionItem *item = [[CMPOcrModulesManageCollectionItem alloc] init];
                item.title = aModule.templateName;
                item.identifier = aModule.oid;
                item.extend = aModule;
                
                if (aModule.isOften) {
                    [arr1 addObject:aModule];
                    [arr11 addObject:item];
                }else{
                    [arr2 addObject:aModule];
                    [arr22 addObject:item];
                }
                
                [self->_sortNumbArr addObject:@(aModule.sortNO)];
            }
            [arr11 sortUsingComparator:^NSComparisonResult(CMPOcrModulesManageCollectionItem *obj1, CMPOcrModulesManageCollectionItem *obj2) {
                NSInteger sort1 = ((CMPOcrModuleItemModel *)obj1.extend).sortNO;
                NSInteger sort2 = ((CMPOcrModuleItemModel *)obj2.extend).sortNO;
                if (sort1 < sort2) {
                    return NSOrderedAscending;
                } else if (sort1 > sort2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            [arr22 sortUsingComparator:^NSComparisonResult(CMPOcrModulesManageCollectionItem *obj1, CMPOcrModulesManageCollectionItem *obj2) {
                NSInteger sort1 = ((CMPOcrModuleItemModel *)obj1.extend).sortNO;
                NSInteger sort2 = ((CMPOcrModuleItemModel *)obj2.extend).sortNO;
                if (sort1 < sort2) {
                    return NSOrderedAscending;
                } else if (sort1 > sort2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            [arr1 sortUsingComparator:^NSComparisonResult(CMPOcrModuleItemModel *obj1, CMPOcrModuleItemModel *obj2) {
                NSInteger sort1 = obj1.sortNO;
                NSInteger sort2 = obj2.sortNO;
                if (sort1 < sort2) {
                    return NSOrderedAscending;
                } else if (sort1 > sort2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            [arr2 sortUsingComparator:^NSComparisonResult(CMPOcrModuleItemModel *obj1, CMPOcrModuleItemModel *obj2) {
                NSInteger sort1 = obj1.sortNO;
                NSInteger sort2 = obj2.sortNO;
                if (sort1 < sort2) {
                    return NSOrderedAscending;
                } else if (sort1 > sort2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            completion(@[arr1,arr2],nil,@[arr11,arr22]);
            
            [self->_sortNumbArr sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                NSInteger sort1 = obj1.integerValue;
                NSInteger sort2 = obj2.integerValue;
                if (sort1 < sort2) {
                    return NSOrderedAscending;
                } else if (sort1 > sort2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            
        }else{
            completion(nil,error,ext);
        }
    }];
}

-(void)updateModulesListWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion
{
    if (!params || !params[@"data"]) {
        return;
    }
    
    NSArray *data = params[@"data"];
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    __block int __c = 0;
    for (int i=0; i<data.count; i++) {
        NSArray<CMPOcrModulesManageCollectionItem *> *arr = data[i];
        [arr enumerateObjectsUsingBlock:^(CMPOcrModulesManageCollectionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (__c<self.sortNumbArr.count) {
                NSNumber *sortNumb = self.sortNumbArr[__c];
                NSDictionary *pp = @{@"id":obj.identifier,@"isOften":@(i==0),@"sortNO":sortNumb};
                [resultArr addObject:pp];
                __c++;
            }
        }];
    }
    [self.dataProvider updateModulesListWithParams:resultArr completion:completion];
}

@end
