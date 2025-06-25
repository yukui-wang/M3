//
//  CMPMessageListCell.h
//  CMPCore
//
//  Created by wujiansheng on 2017/6/26.
//
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "CMPMessageObject.h"

typedef void(^CMPMessageListCellDragAction)(void);

@interface CMPMessageListCell : CMPBaseTableViewCell

@property (copy, nonatomic)  CMPMessageListCellDragAction dragAction;

+ (CGFloat)height;
- (void)setupObject:(CMPMessageObject *)object;
// 删除未读消息条数
- (void)removeUnReadCount;

@end
