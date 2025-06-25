//
//  CMPOcrMainView.h
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//

#import <CMPLib/CMPBaseView.h>
#import "CMPOcrCardCategoryView.h"
NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrMainView : CMPBaseView
@property (nonatomic,strong)CMPOcrCardCategoryView *cardCategoryView;
@property(nonatomic,weak) CMPOcrMainViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
