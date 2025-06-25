//
//  CMPWebAppsDownloadProgressView.h
//  M3
//  在H5页面展示应用包下载进度
//  Created by CRMO on 2018/12/24.
//

#import <UIKit/UIKit.h>

typedef void(^CMPWebAppsDownloadProgressViewRetry)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CMPWebAppsDownloadProgressView : UIView

/**
 显示下载进度页面
 */
- (void)showInView:(UIView *)view;

/**
 隐藏下载进度页面
 */
- (void)hide;

/**
 更新进度
 隐藏错误信息

 @param aProgress 进度值，0-1
 */
- (void)updateProgress:(CGFloat )aProgress animation:(BOOL)animation;

/**
 展示错误信息
 隐藏进度条
 
 @param block 用户点击重试按钮事件
 */
- (void)showErrorWithRetryAction:(CMPWebAppsDownloadProgressViewRetry)block;
- (void)showErrorWithZipAppName:(NSString *)zipAppName retryAction:(CMPWebAppsDownloadProgressViewRetry)block;

@end

NS_ASSUME_NONNULL_END
