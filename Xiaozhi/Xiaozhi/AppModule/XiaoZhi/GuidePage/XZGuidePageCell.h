//
//  XZGuidePageCell.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "XZGuidePageItem.h"
#import "SPConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZGuidePageCell : CMPBaseTableViewCell

- (void)setupPageItem:(XZGuidePageItem *)item isTop:(CGFloat)isTop;
+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
