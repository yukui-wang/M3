//
//  CMPSelectItemView.h
//  M3
//
//  Created by MacBook on 2019/11/4.
//

#import "CMPTopCornerView.h"

@class CMPFileManagementRecord;

NS_ASSUME_NONNULL_BEGIN

@interface CMPSelectItemView : CMPTopCornerView

/* pushParentVC */
@property (weak, nonatomic) UIViewController *pushParentVC;

/* vc */
@property (weak, nonatomic) UIViewController *viewController;
/* CMPFileManagementRecord */
@property (strong, nonatomic) CMPFileManagementRecord *mfr;

@end

NS_ASSUME_NONNULL_END
