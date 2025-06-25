//
//  CMPVideoMessage.h
//  M3
//
//  Created by MacBook on 2019/12/23.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPVideoMessage : RCFileMessage

/* 视频文件的总播放时长 */
@property (nonatomic,assign) NSInteger timeDuration;
/* 视频文件缩略图base64 data 字符串 */
@property (nonatomic,copy) NSString *base64;
/* 视频文件缩略图 */
@property (nonatomic,strong) UIImage *videoThumImage;
/* 展示时长 */
@property (nonatomic,copy,readonly) NSString *showTime;

@end

NS_ASSUME_NONNULL_END
