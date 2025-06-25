//
//  CMPOcrCardMainHeaderView.h
//  M3
//
//  Created by Shoujian Rao on 2021/11/27.
//

#import <CMPLib/CMPBaseView.h>
@class CMPOcrPackageModel;
NS_ASSUME_NONNULL_BEGIN

@interface CMPOcrCardMainHeaderView : CMPBaseView
- (void)scrollViewDidScroll:(CGFloat)contentOffsetY;
@property (nonatomic, strong) CMPOcrPackageModel *defaultPackage;
@end

NS_ASSUME_NONNULL_END
