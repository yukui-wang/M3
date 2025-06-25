//
//  CMPAreaCodeViewController.h
//  M3
//
//  Created by zy on 2022/2/19.
//

#import <CMPLib/CMPBannerViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAreaCodeViewController : CMPBannerViewController

@property (copy, nonatomic) void(^selectAreaCodeSuccess)(NSString *areaName, NSString *phoneCode, NSString *contryCode, NSString *checkKey);

@end

NS_ASSUME_NONNULL_END
