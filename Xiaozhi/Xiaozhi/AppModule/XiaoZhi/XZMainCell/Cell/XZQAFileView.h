//
//  XZQAFileView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/22.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZQAFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZQAFileView : XZBaseView
- (void)setupInfo:(XZQAFileModel *)info;
+ (CGFloat)viewHeight;
@end

NS_ASSUME_NONNULL_END
