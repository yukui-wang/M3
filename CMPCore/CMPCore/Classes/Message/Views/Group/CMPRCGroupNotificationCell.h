//
//  CMPRCGroupNotificationCell.h
//  CMPCore
//
//  Created by CRMO on 2017/8/7.
//
//

#import <CMPLib/CMPBaseTableViewCell.h>

@class CMPRCGroupNotificationObject;

@interface CMPRCGroupNotificationCell : CMPBaseTableViewCell


/**
 用CMPRCGroupNotificationObject初始化cell
 */
- (void)setupWithObject:(CMPRCGroupNotificationObject *)object;

/**
 根据传入数据源，计算cell的高度。
 */
+ (CGFloat)getCellHeight:(CMPRCGroupNotificationObject *)object width:(CGFloat)width;

@end
