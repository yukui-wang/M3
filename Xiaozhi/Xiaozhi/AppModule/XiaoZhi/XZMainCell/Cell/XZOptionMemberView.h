//
//  XZOptionMemberView.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/31.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZBaseView.h"
#import "XZOptionMemberModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface XZOptionMemberView : XZBaseView
- (void)setupWithModel:(XZOptionMemberModel *)model;
+ (CGFloat)viewHeightForModel:(XZOptionMemberModel *)model;
@end

NS_ASSUME_NONNULL_END
