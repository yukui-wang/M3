//
//  CMPAVPlayerProgressView.h
//  CMPLib
//
//  Created by MacBook on 2020/2/17.
//  Copyright © 2020 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPAVPlayerProgressView : UIView

/* 关闭点击 */
@property (copy, nonatomic) void(^closeClicked)(void);
/* 视频大小  多少MB */
@property (assign, nonatomic) long long recievedSize;
/* 视频大小  多少MB */
@property (assign, nonatomic) long long fileSize;

- (void)setProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
