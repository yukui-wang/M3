//
//  XZShortHandListCell.h
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "XZShortHandObj.h"

@interface XZShortHandListCell : CMPBaseTableViewCell

@property(nonatomic, retain)XZShortHandObj *data;
@property(nonatomic, copy)void (^forwardBlock)(XZShortHandObj *data);
@property(nonatomic, copy)void (^deleteBlock)(XZShortHandObj *data);
@property(nonatomic, copy)void (^showForwardListBlock)(XZShortHandObj *data,NSString *appId,NSString *title);

@end
