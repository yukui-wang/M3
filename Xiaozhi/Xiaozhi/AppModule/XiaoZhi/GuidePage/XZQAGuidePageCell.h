//
//  XZQAGuidePageCell.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/12.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZQAGuidePageCell : CMPBaseTableViewCell
@property(nonatomic,strong)UILabel *titleLabel;
+ (CGFloat)cellHeightForText:(NSString *)text width:(CGFloat)width;
@end

NS_ASSUME_NONNULL_END
