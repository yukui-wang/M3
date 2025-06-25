//
//  CMPRobotMessageCell.h
//  M3
//
//  Created by Shoujian Rao on 2022/2/21.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPRobotMessageCell : RCMessageCell

+ (CGFloat)calculateCellHeight:(RCMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
