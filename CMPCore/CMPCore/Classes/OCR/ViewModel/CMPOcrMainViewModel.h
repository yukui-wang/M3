//
//  CMPOcrMainViewModel.h
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPOcrModuleItemModel.h"
#import "CMPOcrModuleItemModel.h"
#import "CMPOcrPackageModel.h"

NS_ASSUME_NONNULL_BEGIN
//对网络数据或模型数据的逻辑处理，共viewcontroller使用
@interface CMPOcrMainViewModel : CMPBaseViewModel
@property (nonatomic, strong) NSArray *statusArr;//0:未报销;2:报销中;3:已报销
@property(nonatomic,assign) NSInteger selectedModuleIndex;
@property (nonatomic,strong,readonly) CMPOcrModuleItemModel *selectedModule;
@property (nonatomic,strong,readonly) CMPOcrPackageModel *defaultPackageModel;
@property (nonatomic,strong,readonly) NSMutableArray<CMPOcrModuleItemModel *> *modulesArr;
@property (nonatomic,strong,readonly) NSMutableDictionary<NSString *,NSMutableArray<CMPOcrPackageModel *> *> *packagesMap;
@property (nonatomic,assign) BOOL isHistory;


@property(nonatomic,copy) void(^commonModulesCompletionBlk)(NSArray <CMPOcrModuleItemModel *>*modules,NSError *error);
@property(nonatomic,copy) void(^packagesCompletionBlk)(NSArray <CMPOcrPackageModel *>*packages,NSError *error);

-(void)refreshCommonModules;
-(void)refreshCurrentPackageList;

@end

NS_ASSUME_NONNULL_END
