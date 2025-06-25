//
//  CMPOcrFormPickViewController.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/14.
//

#import <CMPLib/CMPBannerViewController.h>
#import "CMPOcrModuleItemModel.h"

@interface CMPOcrFormPickViewController : CMPBannerViewController
- (instancetype)initWithCompletion:(void(^)(CMPOcrModuleItemModel *))completion;
- (void)showTargetVC:(UIViewController *)viewController;
@end

