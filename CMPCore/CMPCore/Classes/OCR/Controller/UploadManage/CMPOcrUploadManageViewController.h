//
//  CMPOcrUploadManageViewController.h
//  M3
//
//  Created by Shoujian Rao on 2021/12/5.
//

#import <CMPLib/CMPBannerViewController.h>
@class CMPOcrPackageModel;
@interface CMPOcrUploadManageViewController : CMPBannerViewController

//ext=2,来自包详情
//ext=3,来自表单
- (instancetype)initWithFileArray:(NSArray *)fileArray package:(CMPOcrPackageModel *)package ext:(id)ext;

@property (nonatomic, strong) NSDictionary *formData;

@end

