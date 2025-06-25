//
//  XZGuideSubPageCell.h
//  Xiaozhi
//
//  Created by wujiansheng on 2019/5/16.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import <CMPLib/CMPBaseTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZGuideSubPageCell : CMPBaseTableViewCell

- (void)setupText:(NSString *)text;
- (void)setupTextForHeader:(NSString *)text;
+ (CGFloat)cellHeight;
+ (CGFloat)headerCellHeight;
@end

NS_ASSUME_NONNULL_END
