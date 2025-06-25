//
//  XZSHForwardListCell.h
//  M3
//
//  Created by wujiansheng on 2019/1/9.
//

#import <CMPLib/CMPBaseTableViewCell.h>
#import "XZSHForwardListObj.h"

@interface XZSHForwardListCell : CMPBaseTableViewCell

@property(nonatomic, retain)XZSHForwardListObj *data;

@end


#pragma mark 转发协同
@interface XZSHForwardCollCell : XZSHForwardListCell

@end

#pragma mark 转发任务
@interface XZSHForwardTaskCell : XZSHForwardListCell

@end


#pragma mark 转发会议
@interface XZSHForwardMeetingCell : XZSHForwardListCell

@end

#pragma mark 转发日程
@interface XZSHForwardCalCell : XZSHForwardListCell

@end
