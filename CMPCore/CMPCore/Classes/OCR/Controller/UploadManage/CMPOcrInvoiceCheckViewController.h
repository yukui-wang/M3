//
//  CMPOcrInvoiceCheckViewController.h
//  M3
//
//  Created by Shoujian Rao on 2022/1/12.
//

#import <CMPLib/CMPBannerViewController.h>
@class CMPOcrPackageModel;
@interface CMPOcrInvoiceCheckViewController : CMPBannerViewController

//ext=3 来自表单
- (instancetype)initWithFileArray:(NSArray *)fileArray package:(CMPOcrPackageModel *)package ext:(id)ext;
@property (nonatomic, strong) NSDictionary *formData;

@end

