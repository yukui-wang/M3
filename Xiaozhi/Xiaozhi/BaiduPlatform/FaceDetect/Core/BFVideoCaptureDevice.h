//
//  BFVideoCaptureDevice.h
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//  
// 相机视频流处理类
// 初始化之后，设定delegate，即可从代理里面获取到每一个分帧的image
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BFCaptureDataOutputProtocol;
@interface BFVideoCaptureDevice : NSObject
@property (nonatomic, readwrite, weak) id<BFCaptureDataOutputProtocol> delegate;

@property (nonatomic, readwrite, assign) BOOL runningStatus;

/**
 * 设定使用前置摄像头或者后置摄像头
 * AVCaptureDevicePositionFront 前置摄像头(默认)
 * AVCaptureDevicePositionBack 后置摄像头
 */
@property (nonatomic, readwrite, assign) AVCaptureDevicePosition position;

- (void)startSession;

- (void)stopSession;

- (void)resetSession;

- (void)switchCamera;

@end

@protocol BFCaptureDataOutputProtocol <NSObject>

/**
 * 回调每一个分帧的image
 */
- (void)captureOutputSampleBuffer:(UIImage *)image;

- (void)captureError;

@end
