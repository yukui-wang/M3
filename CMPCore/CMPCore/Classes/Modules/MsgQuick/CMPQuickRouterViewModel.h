//
//  CMPQuickRouterViewModel.h
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/1/10.
//

#import <CMPLib/CMPBaseViewModel.h>
@class CMPAppModel;
NS_ASSUME_NONNULL_BEGIN

@interface CMPQuickRouterViewModel : CMPBaseViewModel
@property (nonatomic,strong) NSArray<CMPAppModel *> *sortedAppList;
-(void)fetchQuickItemsWithResult:(void(^)(NSArray<CMPAppModel *> *appList,NSError *error,id ext))result;
-(NSArray<CMPAppModel *> *)needToShowItemsArr;

@end

NS_ASSUME_NONNULL_END
