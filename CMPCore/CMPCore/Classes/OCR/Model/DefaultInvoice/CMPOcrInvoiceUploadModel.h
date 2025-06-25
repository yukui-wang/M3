//
//  CMPOcrInvoiceUploadModel.h
//  CMPOcr
//
//  Created by 张艳 on 2021/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrInvoiceUploadModel : NSObject

/// 发票图片
@property (nonatomic, strong) UIImage *iconImage;

/// 图片名称
@property (nonatomic, copy) NSString *imageName;

/// cell类型
@property (nonatomic, assign) NSInteger  cellType;

///  进度
@property (nonatomic ,assign) CGFloat   progress;

@end

NS_ASSUME_NONNULL_END
