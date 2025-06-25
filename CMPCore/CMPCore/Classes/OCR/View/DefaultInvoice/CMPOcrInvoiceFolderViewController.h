//
//  CMPOcrInvoiceFolderViewController.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/25.
//

//#import "CMPOcrBottomPopBaseViewController.h"
#import <CMPLib/CMPBannerViewController.h>

@interface CMPOcrInvoiceFolderViewController : CMPBannerViewController
- (instancetype)initWithInvoiceArr:(NSArray *)invoiceArr selectdPackageId:(NSString *)packageId completion:(void(^)(NSArray *))completion;
- (void)showTargetVC:(UIViewController *)viewController;

@end

