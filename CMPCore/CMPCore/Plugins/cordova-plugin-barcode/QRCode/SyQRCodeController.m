//
//  QRCodeController.m
//  eCarry
//  依赖于AVFoundation
//  Created by whde on 15/8/14.
//  Copyright (c) 2015年 Joybon. All rights reserved.
//

#import "SyQRCodeController.h"
#import <AVFoundation/AVFoundation.h>
#import "SyScanViewControllerDelegate.h"
#import "ZXAddressBookParsedResult.h"
#import "ZXResult.h"
#import "ZXResultParser.h"
#import "ZXLuminanceSource.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXHybridBinarizer.h"
#import "ZXDecodeHints.h"
#import "ZXMultiFormatReader.h"
#import <CMPLib/CMPGlobleManager.h>
#import <CMPLib/CMPDevicePermissionHelper.h>

@interface SyQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>
{
    AVCaptureSession * _session;//输入输出的中间桥梁
    AVCaptureVideoPreviewLayer * _videoPreviewLayer;
    CGRect currentFrame;
}

@property(nonatomic,retain) AVCaptureDeviceInput * input;
@property(nonatomic,retain) UIView * scanView;
@property(nonatomic,retain) UIView * preView;
@property (nonatomic,retain) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic,assign) CGFloat beginGestureScale;
@property (nonatomic,assign) CGFloat effectiveScale;

@property (nonatomic,copy) NSString *oldMetadataString;

@end

@implementation SyQRCodeController

- (void)dealloc
{
    SY_RELEASE_SAFELY(_scanView);
    SY_RELEASE_SAFELY(_preView);
    SY_RELEASE_SAFELY(_input);
    SY_RELEASE_SAFELY(_pinchGesture);
    SY_RELEASE_SAFELY(_oldMetadataString);
    [_session stopRunning];
    [_session release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

/**
 *  @author Whde
 *
 *  viewDidLoad
 */
- (void)viewDidLoad {
    
    _effectiveScale = 1.0f;
    
    [super viewDidLoad];
}

- (void)initCaputre
{
    [self instanceDevice];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    if (_session && !CGRectEqualToRect(self.view.bounds, currentFrame)) {
        [self instanceDevice];
    }
}

/**
 *  @author Whde
 *
 *  配置相机属性
 */
- (void)instanceDevice
{
    CGRect aFrame = self.view.bounds;
    currentFrame = aFrame;
    
    CGFloat sideLength = 255;
    CGFloat halfSideLength = sideLength * 0.5;
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    self.input = input;
    
    //创建输出流
    AVCaptureMetadataOutput * output = [[[AVCaptureMetadataOutput alloc] init] autorelease];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    CGRect rect = CGRectMake(currentFrame.size.width*0.5 - halfSideLength, currentFrame.size.height*0.5 - halfSideLength, sideLength, sideLength);
    CGRect cropRect = [self getScanRectWithCropRect:rect];
    output.rectOfInterest = cropRect;
    
    //初始化链接对象
    [_session stopRunning];
    [_session release];
    _session = [[AVCaptureSession alloc] init];
    
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [_session addInput:input];
    }
    if (output) {
        [_session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = a;
        [a release];
    }
    
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    
    if (!self.preView) {
        self.preView = [[[UIView alloc]initWithFrame:currentFrame] autorelease];
        [self.view insertSubview:self.preView belowSubview:self.statusBarView];
    }
    
    self.preView.frame = currentFrame;
    _videoPreviewLayer.frame = self.preView.bounds;
    [self.preView.layer addSublayer:_videoPreviewLayer];
    
    if (!self.scanView) {
        self.scanView = [[[UIView alloc]initWithFrame:currentFrame] autorelease];
        [self.view addSubview:self.scanView];
    }
    
    _scanView.frame = currentFrame;
    [self setOverlayPickerView:self.scanView.layer frame:aFrame];
    
    if (!self.pinchGesture) {
        self.pinchGesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)] autorelease];
        self.pinchGesture.delegate = self;
        [self.scanView addGestureRecognizer:self.pinchGesture];
    }
    
    [device lockForConfiguration:nil];
    //自动白平衡
    if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
    {
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if ([device isFocusPointOfInterestSupported ]&&[device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    //自动曝光
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    [self startScan];
}

//根据矩形区域，获取识别区域
- (CGRect)getScanRectWithCropRect:(CGRect)rect {
    int expand = 50;
    int XRetangleLeft = rect.origin.x - expand;
    int XRetangleTop =  rect.origin.y - expand;
    CGSize sizeRetangle = CGSizeMake(rect.size.width + expand * 2, rect.size.width + expand * 2);
    //扫码区域坐标
    CGRect cropRect =  CGRectMake(XRetangleLeft, XRetangleTop, sizeRetangle.width, sizeRetangle.height);
    //计算兴趣区域
    //ref:http://www.cocoachina.com/ios/20141225/10763.html
    
    CGRect rectOfInterest;
    CGSize size = currentFrame.size;
    CGFloat p1 = 0;
    CGFloat p2 = 0;
    if (InterfaceOrientationIsPortrait) {
        p1 = size.height/size.width;
        p2 = 1920./1080.;  //以1080p的图像为标准计算
        if (p1 < p2) {
            CGFloat fixHeight = size.width * 1920. / 1080.;
            CGFloat fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                        cropRect.origin.x/size.width,
                                        cropRect.size.height/fixHeight,
                                        cropRect.size.width/size.width);
        } else {
            CGFloat fixWidth = size.height * 1080. / 1920.;
            CGFloat fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                        (cropRect.origin.x + fixPadding)/fixWidth,
                                        cropRect.size.height/size.height,
                                        cropRect.size.width/fixWidth);
        }
    } else {
        p1 = size.width/size.height;
        p2 = 1920./1080.;
        if (p1 < p2) {
            CGFloat fixWidth = size.height * 1920. / 1080.;
            CGFloat fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRectMake((cropRect.origin.x + fixPadding)/fixWidth,
                                        cropRect.origin.y/size.height,
                                        cropRect.size.width/fixWidth,
                                        cropRect.size.height/size.height
                                        );
        } else {
            CGFloat fixHeight = size.width * 1080. / 1920.;
            CGFloat fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRectMake(cropRect.origin.x/size.width,
                                        (cropRect.origin.y + fixPadding)/fixHeight,
                                        cropRect.size.width/size.width,
                                        cropRect.size.height/fixHeight
                                        );
        }
        
    }
    return rectOfInterest;
}

- (void)setVideoScale:(CGFloat)scale
{
    
    [_input.device lockForConfiguration:nil];
    
    CGFloat maxScaleAndCropFactor = _input.device.activeFormat.videoMaxZoomFactor;
    if (scale > maxScaleAndCropFactor)
        scale = maxScaleAndCropFactor;
    
    if (scale <= 1)
        scale = 1;
    
    _input.device.videoZoomFactor = scale;
    
    [_input.device unlockForConfiguration];
    
    [UIView animateWithDuration:0.11 animations:^{

         self.preView.transform = CGAffineTransformMakeScale(scale, scale);

    }];

    
}

- (void)changeVideoScale:(AVMetadataMachineReadableCodeObject *)objc
{
    
    NSArray *array = objc.corners;
    CGPoint point = CGPointZero;
    int index = 0;
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    // NSLog(@"X:%f -- Y:%f",point.x,point.y);
    CGPoint point2 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[2], &point2);
    // NSLog(@"X:%f -- Y:%f",point2.x,point2.y);
    
    CGRect aFrame = self.mainFrame;
    CGFloat mX = aFrame.size.width;
    CGFloat mY = aFrame.size.height;
    CGFloat sideLength;
    if (INTERFACE_IS_PAD) {
        sideLength = MIN(mX, mY) * 0.5;
    } else {
        sideLength = mX - 120;
    }
    sideLength += 5;
    CGFloat scace = sideLength /(point2.x-point.x); //当二维码图片宽小于205，进行放大
    
    [self setVideoScale:scace];
    
    return;
    
}


#pragma mark Pinch Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.scanView];
        CGPoint convertedLocation = [self.scanView.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.scanView.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > self.input.device.activeFormat.videoMaxZoomFactor)
            _effectiveScale = self.input.device.activeFormat.videoMaxZoomFactor;
        NSError *error = nil;
        if ([self.input.device lockForConfiguration:&error]) {
            [self.input.device rampToVideoZoomFactor:_effectiveScale withRate:100];
            [self.input.device unlockForConfiguration];
        }
    }
}



- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
        default:
            break;
    }
    return AVCaptureVideoOrientationLandscapeLeft;
}

/**
 *  @author Whde
 *
 *  获取扫码结果
 *
 *  @param captureOutput
 *  @param metadataObjects
 *  @param connection
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
        if ([NSString isNull:data]) {
            [self performScanFailed];
        }
        else {
            if ([self.oldMetadataString isEqualToString:data]) {
                return;
            }
            if([self.delegate respondsToSelector:@selector(scanViewController:didScanFinishedWithResult:)]){
                self.oldMetadataString = data;
                AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObjects.lastObject];
                [self changeVideoScale:obj];
                
                ZXResult *aZXResult = [[ZXResult alloc] initWithText:data rawBytes:nil resultPoints:nil format:kBarcodeFormatQRCode];
                ZXParsedResult *parseResult = [ZXResultParser parseResult:aZXResult];
                [aZXResult release];
                [self.delegate scanViewController:(SyScanViewController *)self didScanFinishedWithResult:parseResult];
            }
        }
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    _videoPreviewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
}
- (void)startScan
{
    if (![CMPDevicePermissionHelper cheackPermissionsForCamera]) {
        return;
    }
    [self setVideoScale:1];
    self.oldMetadataString = nil;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session startRunning];
    });
    
}
- (void)continueScan
{
    [super continueScan];
    if (![CMPDevicePermissionHelper cheackPermissionsForCamera]) {
        return;
    }
    self.effectiveScale = 1.0f;
    [self setVideoScale:1];
    self.oldMetadataString = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session startRunning];
    });
}

- (void)stopScan
{
    [super stopScan];
    [_session stopRunning];
}
/**
 *  @author Whde
 *
 *  didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
