//
//  CMPOcrMainViewModel.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import "CMPOcrMainViewModel.h"
#import "CMPOcrMainViewDataProvider.h"
#import "CMPPageBaseModel.h"

@interface CMPOcrMainViewModel ()
{
    CMPPageBaseModel *_pageModel;
    CMPOcrModuleItemModel *_selectedModule;
    NSMutableArray<CMPOcrModuleItemModel *> *_modulesArr;
    NSMutableDictionary<NSString *,NSMutableArray<CMPOcrPackageModel *> *> *_packagesMap;
//    NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,NSArray<CMPOcrPackageModel *> *> *> *_packagesMap;
    __block CMPOcrPackageModel *_defaultPackageModel;
}
@property (nonatomic,strong) CMPOcrMainViewDataProvider *dataProvider;

@end

@implementation CMPOcrMainViewModel

-(instancetype)init
{
    if (self = [super init]) {
        _selectedModuleIndex = 0;
        _pageModel = [[CMPPageBaseModel alloc] init];
        _modulesArr = [[NSMutableArray alloc] init];
        _packagesMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(CMPOcrMainViewDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrMainViewDataProvider alloc] init];
        [self fetchDefaultPackageId];
    }
    return _dataProvider;
}

-(void)setSelectedModuleIndex:(NSInteger)selectedModuleIndex
{
    _selectedModuleIndex = selectedModuleIndex;
    if (_modulesArr.count && selectedModuleIndex < _modulesArr.count) {
        _selectedModule = _modulesArr[selectedModuleIndex];
    }else{
        _selectedModule = nil;
    }
}

-(void)refreshCommonModules
{
    __weak typeof(self) wSelf = self;
    [self fetchCommonModulesCompletion:^(NSArray<CMPOcrModuleItemModel *> * _Nonnull modules, NSError * _Nonnull error) {
       
        if (!error) {
            [wSelf.modulesArr removeAllObjects];
            [wSelf.modulesArr addObjectsFromArray:modules];
        }
        
        if (wSelf.commonModulesCompletionBlk) {
            wSelf.commonModulesCompletionBlk(modules, error);
        }
    }];
}


-(void)refreshCurrentPackageList
{
    if (!self.modulesArr.count) {
        return;
    }
    @synchronized (self) {
        NSInteger index = _selectedModuleIndex;
        CMPOcrModuleItemModel *selectModule = self.modulesArr.lastObject;
        if (index < self.modulesArr.count) {
            selectModule = self.modulesArr[index];
        }
        NSString *templateIdStr = selectModule.templateId;
        NSString *formIdStr = selectModule.formId;
        __weak typeof(self) wSelf = self;
        [self.dataProvider fetchPackageListWithParams:@{@"templateId":@([templateIdStr longLongValue]),
                                                        @"formId":@([formIdStr longLongValue]),
                                                        @"pageSize":@(_pageModel.pageSize),
                                                        @"pageNo":@(_pageModel.pageNo),
                                                        @"status":self.statusArr?:@[@0],
                                                      } completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            NSArray *packages;
            if (!error) {
                packages = [NSArray yy_modelArrayWithClass:CMPOcrPackageModel.class json:respData[@"data"]];
                
                NSString *oid = selectModule.oid;
                NSMutableArray *arr = [wSelf.packagesMap objectForKey:oid];
                if (!arr || self->_pageModel.pageNo == 0) {
                    [wSelf.packagesMap setObject:packages forKey:oid];
                }else{
                    [arr addObjectsFromArray:packages];
                    [wSelf.packagesMap setObject:arr forKey:oid];
                }
                
            }else{
            }
            
            if (wSelf.packagesCompletionBlk) {
                wSelf.packagesCompletionBlk(packages, error);
            }
            
        }];

    }
    
}


-(void)fetchCommonModulesCompletion:(void(^)(NSArray <CMPOcrModuleItemModel *>*modules,NSError *error))completion
{
    if (completion) {
        __weak typeof(self) wSelf = self;
        [self.dataProvider fetchCommonModulesWithParams:@{@"history":@(_isHistory)} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            if (!error) {
                NSArray *arr = [NSArray yy_modelArrayWithClass:CMPOcrModuleItemModel.class json:respData];
                completion(arr,nil);
            }else{
                completion(nil,error);
            }
        }];
    }
}


-(void)fetchDefaultPackageId
{
    if (_defaultPackageModel && _defaultPackageModel.pid) {
        return;
    }
    [self.dataProvider fetchDefaultPackageIdWithParams:nil completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
       
        if (!error) {
            self->_defaultPackageModel = nil;
            _defaultPackageModel = [CMPOcrPackageModel yy_modelWithJSON:respData];
            //保存一个全局的默认票夹ID
            [[NSUserDefaults standardUserDefaults] setValue:_defaultPackageModel.pid?:@"" forKey:@"cmp_ocr_defaultPackageId"];
        }
    }];
}

-(NSMutableArray<CMPOcrModuleItemModel*> *)modulesArr
{
    return _modulesArr;
}

-(NSMutableDictionary<NSString *,NSMutableArray<CMPOcrPackageModel *> *> *)packagesMap
{
    return _packagesMap;
}

-(CMPOcrModuleItemModel *)selectedModule
{
    return _selectedModule;
}

-(CMPOcrPackageModel *)defaultPackageModel
{
    return _defaultPackageModel;
}

@end
