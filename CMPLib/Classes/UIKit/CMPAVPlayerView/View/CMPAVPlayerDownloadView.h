//
//  CMPAVPlayerDownloadView.h
//  CMPLib
//
//  Created by MacBook on 2020/2/17.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMPAVPlayerDownloadType) {
    CMPAVPlayerDownloadTypeVideo = 0,
    CMPAVPlayerDownloadTypeAudio   = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface CMPAVPlayerDownloadView : UIView

/* default CMPAVPlayerDownloadTypeVideo */
@property (assign, nonatomic)CMPAVPlayerDownloadType downloadType;

/* 下载完成回调 */
@property (copy, nonatomic) void(^downloadCompleted)(void);
/* 关闭按钮点击 */
@property (copy, nonatomic) void(^closeBtnClicked)(void);

- (void)setProgress:(CGFloat)progress;
/* 视频大小  多少MB */
- (void)setRecievedSize:(long long)recievedSize;
/* 视频大小  多少MB */
- (void)setFileSize:(long long)fileSize;
- (void)setCoverImage:(NSString *)coverImageUrl;

@end

NS_ASSUME_NONNULL_END
