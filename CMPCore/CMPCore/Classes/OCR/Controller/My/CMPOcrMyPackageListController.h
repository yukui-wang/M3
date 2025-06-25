//
//  CMPOcrMyPackageListController.h
//  M3
//
//  Created by Shoujian Rao on 2022/7/23.
//

#import <CMPLib/CMPBannerViewController.h>
@class CMPOcrPackageModel;

@interface CMPOcrMyPackageListController : CMPBannerViewController
//ext=3来自表单,2来自我的，1来自首页
- (instancetype)initWithPackage:(CMPOcrPackageModel *)package ext:(id)ext;
@property (nonatomic, strong) NSDictionary *formData;
@end

