//
//  CMPShowShutterImgView.h
//  CMPLib
//
//  Created by MacBook on 2019/12/19.
//  Copyright © 2019 crmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMPShowShutterImgView : UIView

/* image */
@property (copy, nonatomic)  UIImage * _Nullable image;

/* 重拍点击 */
@property (copy, nonatomic) void(^retakeClicked)(void);
/* 使用点击 */
@property (copy, nonatomic) void(^useClicked)(UIImage *img,NSDictionary *videoInfo);

/* 视频播放url */
@property (copy, nonatomic)  NSURL * _Nullable videoUrl;

/* view点击 */
@property (copy, nonatomic) void(^viewClicked)(NSURL *url);

@end

NS_ASSUME_NONNULL_END
