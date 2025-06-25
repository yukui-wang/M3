//
//  CMPOcrTabbarViewController.h
//  M3
//
//  Created by Kaku Songu on 12/14/21.
//

#import <CMPLib/RDVTabBarController.h>
#import "CMPOcrTabbarViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrTabbarViewController : RDVTabBarController

@property (nonatomic,strong) CMPOcrTabbarViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
