//
//  XZBaseMsgDataCell.h
//  M3
//
//  Created by wujiansheng on 2018/9/12.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "XZBaseMsgData.h"
@interface XZBaseMsgDataCell : CMPBaseTableViewCell {
    UILabel *_titleLabel;
}
@property(nonatomic,retain)XZBaseMsgData *msgData;
@end
