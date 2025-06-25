//
//  CMPOcrPackageDetailViewController.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/14.
//

#import <CMPLib/CMPBannerViewController.h>
@class CMPOcrPackageModel;

@interface CMPOcrPackageDetailViewController : CMPBannerViewController

//ext=@1 来自首页的页面
//ext=@2 来自我的页面
//ext=@3 来自表单
- (instancetype)initWithPackageModel:(CMPOcrPackageModel *)aModel ext:(id)ext;
@property (nonatomic, strong) NSDictionary *formData;
@end

