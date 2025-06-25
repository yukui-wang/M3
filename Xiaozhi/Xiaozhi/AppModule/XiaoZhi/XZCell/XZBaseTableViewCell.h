//
//  XZBaseTableViewCell.h
//  M3
//
//  Created by wujiansheng on 2017/11/8.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import <CMPLib/CMPConstant.h>
#import "XZCellModel.h"

@interface XZBaseTableViewCell : CMPBaseTableViewCell {
    XZCellModel *_model;
}

@property (nonatomic, retain) XZCellModel *model;

@end
