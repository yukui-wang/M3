//
//  CMPOcrDefaultInvoiceViewController.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import <CMPLib/CMPBannerViewController.h>
#import "CMPOcrPackageModel.h"

@interface CMPOcrDefaultInvoiceViewController : CMPBannerViewController
@property (nonatomic, copy) void(^ChangeTabToMyBlock)(void);
//ext=3 来自表单
- (instancetype)initWithPackage:(CMPOcrPackageModel *)package ext:(id)ext;
@property (nonatomic, strong) NSDictionary *formData;//仅限表单传参数
@end

