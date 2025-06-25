//
//  RCCombineMessageCell.h
//  RongIMKit
//
//  Created by liyan on 2019/8/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPCombineMessageCell : RCMessageCell

/*!
 消息的背景 View
 */
@property(nonatomic, strong) UIView *backView;

/*!
 展示消息的 title
 */
@property(nonatomic, strong) UILabel *titleLabel;

/*!
 展示消息的缩略内容
 */
@property(nonatomic, strong) NSMutableArray<UILabel *> *contentLables;

@end

NS_ASSUME_NONNULL_END
