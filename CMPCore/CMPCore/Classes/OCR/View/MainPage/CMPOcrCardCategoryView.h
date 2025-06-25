//
//  CMPOcrCardCategoryView.h
//  M3
//
//  Created by Shoujian Rao on 2021/11/25.
//

#import <CMPLib/CMPBaseView.h>
#import "CMPOcrMainViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrCardCategoryView : CMPBaseView

@property(nonatomic,weak) CMPOcrMainViewModel *viewModel;
@property (nonatomic, assign) NSInteger fromPage;//0为首页，1为我的
- (void)setHeaderOffset:(CGFloat)offset;//固定高度顶部距离
- (void)setMainTableBackgroundColor:(UIColor *)color;
-(instancetype)initWithHeaderView:(UIView *)headerView;
-(void)updateCommonModules;
-(void)updatePackageList;
-(void)selectModulesIndex:(NSInteger)selectIndex;

@end

NS_ASSUME_NONNULL_END
