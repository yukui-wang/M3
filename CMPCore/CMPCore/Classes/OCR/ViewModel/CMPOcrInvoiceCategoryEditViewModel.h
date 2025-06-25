//
//  CMPOcrInvoiceCategoryEditViewModel.h
//  M3
//
//  Created by Kaku Songu on 12/23/21.
//

#import <CMPLib/CMPBaseViewModel.h>
#import "CMPOcrModuleItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrInvoiceCategoryEditViewModel : CMPBaseViewModel
@property (nonatomic,assign) BOOL history;
-(void)fetchAllModulesWithParams:(NSDictionary *)params completion:(void(^)(NSArray *modules,NSError *error,id ext))completion;
-(void)fetchAllModulesToDefaultInvoiceWithParams:(NSDictionary *)params completion:(void(^)(NSArray *modules,NSError *error,id ext))completion;
-(void)updateModulesListWithParams:(NSDictionary *)params completion:(void(^)(id respData,NSError *error,id ext))completion;
@end

NS_ASSUME_NONNULL_END
