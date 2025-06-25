//
//  CMPOcrAssociatedInvoiceViewController.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrBaseViewController.h"
#import <CMPLib/CMPBannerViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrAssociatedInvoiceViewController : CMPBannerViewController

///报销包ID
@property (nonatomic ,strong) NSString *rPackageId;

///主发票ID
@property (nonatomic ,strong) NSString *mainInvoiceId;


@end


NS_ASSUME_NONNULL_END
