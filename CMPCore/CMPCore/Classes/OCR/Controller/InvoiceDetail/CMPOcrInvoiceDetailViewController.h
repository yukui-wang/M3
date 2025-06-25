//
//  CMPOcrInvoiceDetailViewController.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import <CMPLib/JXCategoryView.h>
#import <CMPLib/JXCategoryListContainerView.h>
#import <CMPLib/CMPBannerViewController.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrInvoiceDetailViewController : CMPBannerViewController
@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, assign) NSInteger selectIdx;
@property (nonatomic, strong) NSArray *invoiceArr;//头部icon
@end

NS_ASSUME_NONNULL_END
