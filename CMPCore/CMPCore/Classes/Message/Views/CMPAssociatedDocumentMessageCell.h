//
//  CMPAssociatedDocumentCell.h
//  M3
//
//  Created by zengbixing on 2017/12/27.
//

#import <RongIMKit/RongIMKit.h>
#import "CMPRCV5Message.h"

@interface CMPAssociatedDocumentMessageCell : RCMessageCell

/*!
 文本内容的Label
 */
@property(strong, nonatomic) UILabel *textLabel;

/*!
 背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 根据消息内容获取显示的尺寸
 
 @param message 消息内容
 
 @return 显示的View尺寸
 */
+ (CGSize)getBubbleBackgroundViewSize:(CMPRCV5Message*)message;

@end
