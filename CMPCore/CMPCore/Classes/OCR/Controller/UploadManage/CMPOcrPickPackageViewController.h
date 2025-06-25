//
//  CMPOcrPickPackageViewController.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/7.
//

#import <CMPLib/CMPBannerViewController.h>
@class CMPOcrPackageModel;
@interface CMPOcrPickPackageViewController : CMPBannerViewController

- (instancetype)initWithPackageArr:(NSArray *)packageArr select:(CMPOcrPackageModel *)selectedPackage pickBackBlock:(void(^)(CMPOcrPackageModel *))pickBackBlock;
@end

