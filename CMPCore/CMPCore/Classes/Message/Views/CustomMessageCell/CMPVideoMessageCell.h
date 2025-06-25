//
//  CMPVideoMessageCell.h
//  M3
//
//  Created by MacBook on 2019/12/23.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMPDownloadIndicator;
@interface CMPVideoMessageCell : RCMessageCell

/*!
 显示视频时间的Label
 */
@property(strong, nonatomic) UILabel *timeLabel;

/*!
 显示文件大小的Label
 */
@property(strong, nonatomic) UILabel *sizeLabel;

/*!
 文件类型的ImageView
 */
@property(strong, nonatomic) UIImageView *playIconView;

/*!
 上传或下载的进度条View
 */
@property(nonatomic, strong) CMPDownloadIndicator *progressView;

/*!
 消息的气泡背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 取消发送的Button
 */
@property(nonatomic, strong) UIButton *cancelSendButton;

/*!
 显示“已取消”的Label
 */
@property(nonatomic, strong) UILabel *cancelLabel;

- (void)updateDownloadProgressView:(NSUInteger)progress;

@end

NS_ASSUME_NONNULL_END
