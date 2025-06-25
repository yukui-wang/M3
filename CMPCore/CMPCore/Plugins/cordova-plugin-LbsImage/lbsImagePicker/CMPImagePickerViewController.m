//
//  ViewController.m
//  photographDemo
//
//  Created by liguohuai on 16/4/3.
//  Copyright © 2015年 Renford. All rights reserved.
//
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0

#define kTopViewHeight  67

#import "CMPImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPConstant.h>
#import "SyLocationManager.h"
#import "SyReverseGeocoder.h"
#import <CMPLib/NSString+CMPString.h>
#import "CMPLbsImageView.h"
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/CMPDataRequest.h>
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/CMPDataResponse.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPLocationManager.h"
#import <CMPLib/RTL.h>
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPImagePickerViewController ()<AVCaptureMetadataOutputObjectsDelegate,CMPDataProviderDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic, strong)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic, strong)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic, strong)AVCaptureMetadataOutput *output;

@property (nonatomic, strong)AVCaptureStillImageOutput *imageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic, strong)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;

//按钮
@property (nonatomic, readonly)UIButton *changeButton;
@property (nonatomic, readonly)UIButton *photoButton;
@property (nonatomic, readonly)UIButton *flashButton;
@property (nonatomic, readonly)UIButton *remakeButton;
@property (nonatomic, readonly)UIButton *useButton;
@property (nonatomic, readonly)UIButton *cancelButton;

@property (nonatomic, readonly)UIButton *flashAutoButton;
@property (nonatomic, readonly)UIButton *flashOnButton;
@property (nonatomic, readonly)UIButton *flashOffButton;

@property (nonatomic, strong)CMPLbsImageView *imageView;
@property (nonatomic, strong)UIView *focusView;
@property (nonatomic, strong)UIImage *image;

@property (nonatomic, assign)BOOL canCa;

@property (nonatomic, strong)UIView *topView;
@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong) SyAddress *currentAddress;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSError *currentLocateErr;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign)BOOL isFlashButtonAndShowTitle;
@property (nonatomic, assign)BOOL isShowTakePhotoView;
@property (nonatomic, assign)BOOL showChangeFlash;


@end

@implementation CMPImagePickerViewController


- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _canCa = [CMPImagePickerViewController canUserCamear];
    if (_canCa) {
        [self customCamera];
        [self customUI];
        //        if (self.location) {
        //            [self fetchAdress];
        //        }
        if (_location && _location.length) {
            [self addText];
            if (!_currentAddress) {
                [self fetchAdress];
            }
        }else{
            [self fetchAdress];
        }
        [self autoLayoutSubviews];
    }else{
        return;
    }
}

- (CGFloat)widthForButton:(UIButton *)botton {
    CGSize s = [botton.currentTitle sizeWithFontSize:botton.titleLabel.font defaultSize:CGSizeMake(200, 200)];
    return s.width;
}

- (void)topViewUI {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopViewHeight)];
        _topView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_topView];
    }
    
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.frame = CGRectMake(_topView.width-36-5, _topView.cmp_bottom - 40, 36, 40);
        [_changeButton setImage:[UIImage imageNamed:@"CMPTakeLbsPhoto.bundle/btn_switchcamera.png"] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(changeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_changeButton];
    }
    
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_flashButton];
    }
    [self layoutFlashButtonAndShowTitle:YES];
}

- (void)takePhotoBottomViewUI {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-120, kScreenWidth, 120)];
        _bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_bottomView];
    }
    
    CGFloat h = 120;
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectMake(kScreenWidth/2.0-33.5, h/2-33.5, 77, 77);
        [_photoButton setImage:[UIImage imageNamed:@"CMPTakeLbsPhoto.bundle/btn_takephoto.png"] forState: UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_photoButton];
    }
    
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        NSInteger w = [self widthForButton:_cancelButton];
        _cancelButton.frame = CGRectMake(23-10, h/2-20, w+20, 40);
        [_cancelButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelButton];
    }
}


- (void)chooseBottomViewUI {
    CGFloat h = 82;
    if (!_remakeButton) {
        _remakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_remakeButton setTitle:SY_STRING(@"common_takePhotoAgain") forState:UIControlStateNormal];
        _remakeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _remakeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        NSInteger w = [self widthForButton:_remakeButton];
        if (IS_IPHONE_X_LATER) {
            _remakeButton.frame = CGRectMake(20, h - 35 - 20, w , 20);
        }else{
            _remakeButton.frame = CGRectMake(20, h - 20 - 20, w , 20);
        }
        [_remakeButton addTarget:self action:@selector(remakeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_remakeButton];
    }
    
    if (!_useButton) {
        _useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_useButton setTitle:SY_STRING(@"common_usePhoto") forState:UIControlStateNormal];
        _useButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _useButton.titleLabel.font = [UIFont systemFontOfSize:14];
        NSInteger w = [self widthForButton:_useButton];
        if (IS_IPHONE_X_LATER) {
            _useButton.frame = CGRectMake(_bottomView.width - 20 - w,  h - 35 - 20, w, 20);
        }else{
            _useButton.frame = CGRectMake(_bottomView.width - 20 - w,  h - 20 - 20, w, 20);
        }
        [_useButton addTarget:self action:@selector(useButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_useButton];
    }
}

- (void)customUI {
    [self topViewUI];
    [self takePhotoBottomViewUI];
    [self chooseBottomViewUI];
    [self showTakePhotoView:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture = nil;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [UIView animateWithDuration:coordinator.transitionDuration animations:^{
            [self autoLayoutSubviews];
        }];
        self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    } completion:nil];
    
}

-(CMPLbsImageView *)imageView {
    if (!_imageView) {
        _imageView = [[CMPLbsImageView alloc]initWithFrame:self.previewLayer.frame];
        //        [self.view insertSubview:_imageView belowSubview:self.bottomView];
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (void)autoLayoutSubviews {
    _topView.frame = CGRectMake(0, 0, kScreenWidth, kTopViewHeight);
    _changeButton.frame = CGRectMake(_topView.width-36-5, _topView.cmp_bottom - 36, 36, 40);
    [self layoutFlashButtonAndShowTitle:self.isFlashButtonAndShowTitle];
    
    CGFloat h = 120;
    _bottomView.frame = CGRectMake(0, kScreenHeight-120, kScreenWidth, 120);
    _photoButton.frame = CGRectMake(kScreenWidth/2.0-33.5, h/2-33.5, 77, 77);
    NSInteger w = [self widthForButton:_cancelButton];
    _cancelButton.frame = CGRectMake(23-10, h/2-20, w+20, 40);
    
    h = 82;
    w = [self widthForButton:_remakeButton];
    if (IS_IPHONE_X_LATER) {
        _remakeButton.frame = CGRectMake(20, h - 35 - 20, w , 20);
    }else{
        _remakeButton.frame = CGRectMake(20, h - 20 - 20, w , 20);
    }
    
    w = [self widthForButton:_useButton];
    if (IS_IPHONE_X_LATER) {
        _useButton.frame = CGRectMake(_bottomView.width - 20 - w,  h - 35 - 20, w, 20);
    }else{
        _useButton.frame = CGRectMake(_bottomView.width - 20 - w,  h - 20 - 20, w, 20);
    }
    
    [self showTakePhotoView:self.isShowTakePhotoView];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.previewLayer.frame = CGRectMake(0, kTopViewHeight, kScreenWidth, kScreenHeight-kTopViewHeight-120);
    self.imageView.frame = CGRectMake(0, _topView.height, _topView.width, kScreenHeight-_topView.height);
    [CATransaction commit];
    
    [self.imageView customLayoutSubviews];
    
    [_changeButton resetFrameToFitRTL];
    [_flashButton resetFrameToFitRTL];
    [_photoButton resetFrameToFitRTL];
    [_cancelButton resetFrameToFitRTL];
    [_remakeButton resetFrameToFitRTL];
    [_useButton resetFrameToFitRTL];
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


- (void)customCamera {
    self.view.backgroundColor = [UIColor blackColor];
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    _input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    _output = [[AVCaptureMetadataOutput alloc]init];
    _imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    _session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, kTopViewHeight, kScreenWidth, kScreenHeight-kTopViewHeight-120);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

- (void)changeCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error = nil;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            } else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point {
    if (point.y<_topView.height || point.y > _bottomView.originY) {
        return;
    }
    
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self->_focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self->_focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self->_focusView.hidden = YES;
            }];
        }];
    }
    
}
#pragma mark - 截取照片
- (void)shutterCamera {
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoOrientationSupported]) {
        videoConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    }
    
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        
        if (!error) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //需要同步执行才不会崩溃
                NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                self.image = [UIImage imageWithData:imageData];
                [self.session stopRunning];
                //        if (!self.imageView) {
                //            self->_imageView = [[CMPLbsImageView alloc]initWithFrame:self.previewLayer.frame];
                //            [self.view insertSubview:self->_imageView belowSubview:self->_bottomView];
                //            self.imageView.layer.masksToBounds = YES;
                //        }
                [self.view insertSubview:self.imageView belowSubview:self.bottomView];
                [self showTakePhotoView:NO];
                self.imageView.frame = CGRectMake(0, self->_topView.height, self->_topView.width, kScreenHeight-self->_topView.height);
                self.imageView.image = self->_image;
                self.imageView.nameLabel.text = self.userName;
                [self.imageView showDateTimeWithTime:self.serverDate];
                [self addText];
        //        [self.imageView customLayoutSubviews];
            });
        }        
    }];
    
}

#pragma mark - 检查相机权限
+ (BOOL)canUserCamear {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        NSString *boundName = [[NSBundle mainBundle]
                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:SY_STRING(@"common_nocameraalert"),boundName];
        UIAlertView *alertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_camera_unavailable") message:message cancelButtonTitle:nil
                                                   otherButtonTitles:[NSArray arrayWithObjects:SY_STRING(@"commom_ok"),SY_STRING(@"commom_setting"), nil] callback:^(NSInteger buttonIndex) {
                                                       if (buttonIndex == 1) {
                                                           NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                           if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                               [[UIApplication sharedApplication] openURL:url];
                                                           }
                                                       }
                                                       else {
                                                       }
                                                   }];
        
        [alertView show];
        alertView = nil;
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)layoutFlashButtonAndShowTitle:(BOOL)show {
    self.isFlashButtonAndShowTitle = show;
    
    UIColor *titlecolor = UIColorFromRGB(0x999999);
    AVCaptureFlashMode flashMode = _device.flashMode;
    NSString *imageName = @"";
    NSString *title = @"";
    switch (flashMode) {
        case AVCaptureFlashModeOn:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_on.png";
            title = SY_STRING(@"pic_open");
            break;
        case AVCaptureFlashModeOff:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_off.png";
            title = SY_STRING(@"pic_close");
            break;
            
        case AVCaptureFlashModeAuto:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_auto.png";
            title = SY_STRING(@"pic_automatic");
            titlecolor = UIColorFromRGB(0xffcc00);
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    
    [_flashButton setImage:image forState:UIControlStateNormal];
    CGSize imgsize = image.size;
    CGFloat topviewH = kTopViewHeight;
    
    if (show) {
        [_flashButton setTitle:title forState:UIControlStateNormal];
        NSInteger titleWidth =  [self widthForButton:_flashButton]+1;
        [_flashButton setFrame:CGRectMake(15, topviewH - 30, imgsize.width+titleWidth+9, 30)];
        [_flashButton setImageEdgeInsets:UIEdgeInsetsMake(15-imgsize.height/2, 0, 15-imgsize.height/2, titleWidth+9)];
    }
    else {
        [_flashButton setFrame:CGRectMake(15, topviewH - 30, imgsize.width, 30)];
        [_flashButton setImageEdgeInsets:UIEdgeInsetsMake(15-imgsize.height/2, 0, 15-imgsize.height/2, 0)];
    }
    [_flashButton setTitleColor:titlecolor forState:UIControlStateNormal];
    
}

- (void)showChangeFlashButtons {
    [self layoutFlashButtonAndShowTitle:NO];
    
    CGFloat topviewH = kTopViewHeight;
    
    if (!_flashAutoButton) {
        _flashAutoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashAutoButton setTitle:SY_STRING(@"pic_automatic") forState:UIControlStateNormal];
        _flashAutoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _flashAutoButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashAutoButton setTitleColor:UIColorFromRGB(0xffcc00) forState:UIControlStateNormal];
        [_flashAutoButton addTarget:self action:@selector(flashAuto) forControlEvents:UIControlEventTouchUpInside];
        
        [_topView addSubview:_flashAutoButton];
    }
    
    
    if (!_flashOnButton) {
        _flashOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashOnButton setTitle:SY_STRING(@"pic_open") forState:UIControlStateNormal];
        _flashOnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _flashOnButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashOnButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_flashOnButton addTarget:self action:@selector(flashOn) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_flashOnButton];
    }
    
    
    if (!_flashOffButton) {
        _flashOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashOffButton setTitle:SY_STRING(@"pic_close") forState:UIControlStateNormal];
        _flashOffButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _flashOffButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashOffButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_flashOffButton addTarget:self action:@selector(flashOff) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_flashOffButton];
    }
    
    AVCaptureFlashMode flashMode = _device.flashMode;
    NSString *imageName = @"";
    switch (flashMode) {
        case AVCaptureFlashModeOn:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_on.png";
            break;
        case AVCaptureFlashModeOff:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_off.png";
            break;
            
        case AVCaptureFlashModeAuto:
            imageName = @"CMPTakeLbsPhoto.bundle/btn_flash_auto.png";
            break;
        default:
            break;
    }
    
    CGSize s = [UIImage imageNamed:imageName].size;
    CGFloat x = 15+s.width+64;
    NSInteger w = [self widthForButton:_flashAutoButton];
    _flashAutoButton.frame = CGRectMake(x, topviewH - 40, w+20, 40);
    
    x += w +64;
    w = [self widthForButton:_flashOnButton];
    _flashOnButton.frame = CGRectMake(x, topviewH - 40, w+20, 40);
    
    x += w +64;
    w = [self widthForButton:_flashOffButton];
    _flashOffButton.frame = CGRectMake(x, topviewH - 40, w+20, 40);
    
    _flashAutoButton.hidden = NO;
    _flashOnButton.hidden = NO;
    _flashOffButton.hidden = NO;
    _changeButton.hidden = YES;
}

- (void)hideChangeFlashButtons {
    [self layoutFlashButtonAndShowTitle:YES];
    
    _flashAutoButton.hidden = YES;
    _flashOnButton.hidden = YES;
    _flashOffButton.hidden = YES;
    _changeButton.hidden = NO;
}

- (void)showTakePhotoView:(BOOL)show {
    self.isShowTakePhotoView = show;
    
    _flashButton.hidden = !show;
    _changeButton.hidden = !show;
    
    _cancelButton.hidden = !show;
    _photoButton.hidden = !show;
    _focusView.hidden = !show;
    
    _remakeButton.hidden = show;
    _useButton.hidden = show;
    
    if (IS_IPHONE_X_LATER) {
        
        [_topView setFrame:CGRectMake(0, 0, _topView.width, show?kTopViewHeight: 44)];
        
    }else{
        
        [_topView setFrame:CGRectMake(0, 0, _topView.width, show?kTopViewHeight: 0)];
        
    }
    
    if (show) {
        _bottomView.backgroundColor = [UIColor blackColor];
    }else{
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    
    
    CGFloat h = show?120:83;
    [_bottomView setFrame:CGRectMake(0, self.view.height -h, _topView.width, h)];
}

#pragma mark ButtonAction

- (void)changeButtonAction {
    AVCaptureDevicePosition position = [[_input device] position];
    _flashButton.hidden = position == AVCaptureDevicePositionBack;
    
    [self changeCamera];
}

- (void)photoButtonAction {
    [self hideChangeFlashButtons];
    [self shutterCamera];
    [self requestServerDate];
    [self autoLayoutSubviews];
}

- (void)cancleButtonAction {
    self.image = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [_delegate imagePickerControllerDidCancel:self];
    }
    
}

- (void)flashButtonAction {
    if (!_showChangeFlash) {
        [self showChangeFlashButtons];
    }
    else {
        [self hideChangeFlashButtons];
    }
    _showChangeFlash = !_showChangeFlash;
}

- (void)remakeButtonAction {
    self.image = nil;
    [self showTakePhotoView:YES];
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.session startRunning];
}

- (void)useButtonAction {
    if (!self.currentAddress && !_currentLocateErr /*!self.currentAddress && !_location*/) {
//        CMPAlertView *alertView =
//        [[CMPAlertView alloc] initWithTitle:nil
//                                    message:SY_STRING(@"Sign_Local_locat_data_waiting")
//                          cancelButtonTitle:SY_STRING(@"common_ok")
//                          otherButtonTitles:nil
//                                   callback:nil];
//        [alertView show];
        [self cmp_showHUDWithText:SY_STRING(@"Sign_Local_locat_data_waiting")];
        return;
    }
    UIImage *result =  [self.imageView result];
    NSString *path = [self writeToTempImagePath:result];
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController: didFinishPickingImagePath:withAddress:currentLoaction:)]) {
        [_delegate imagePickerController:self didFinishPickingImagePath:path withAddress:self.currentAddress currentLoaction:self.currentLocation];
    }
}


- (void)setflashMode:(AVCaptureFlashMode)flashMode {
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:flashMode]) {
            [_device setFlashMode:flashMode];
        }
        [_device unlockForConfiguration];
    }
    [self hideChangeFlashButtons];
}

- (void)flashOn {
    //闪光灯开
    [self setflashMode:AVCaptureFlashModeOn];
}

- (void)flashOff {
    //闪光灯关
    [self setflashMode:AVCaptureFlashModeOff];
}

- (void)flashAuto {
    //闪光自动
    [self setflashMode:AVCaptureFlashModeAuto];
}


#pragma mark - Lbs

- (void)fetchAdress {
    
    self.currentAddress = nil;
    self.currentLocation = nil;
    _currentLocateErr = nil;
    
    CMPLocationManager *locationManager = [CMPLocationManager shareLocationManager];
    __weak CMPImagePickerViewController* weakSelf = self;
    
    if (!locationManager.locationServiceEnable) {
        _currentLocateErr = [NSError errorWithDomain:@"has no access" code:-1001 userInfo:nil];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"Sign_location_servicesSet") delegate:nil cancelButtonTitle:nil otherButtonTitles:SY_STRING(@"common_ok"), nil];
        [alertView show];
        alertView = nil;
        return;
    }
    
    [[CMPLocationManager shareLocationManager] getSingleLocationWithCompletionBlock:^(NSString *  _Nullable provider, AMapGeoPoint * _Nullable location, AMapReGeocode * _Nullable regeocode, NSError * _Nullable locationError, NSError * _Nullable searchError, NSError * _Nullable locationResultError) {
        if (locationError) {
            _currentLocateErr = [NSError errorWithDomain:locationError.domain code:locationError.code userInfo:locationError.userInfo];
            return;
        }
        
        if (searchError) {
            _currentLocateErr = [NSError errorWithDomain:searchError.domain code:searchError.code userInfo:searchError.userInfo];
            return;
        }
        
        if (locationResultError) {
            _currentLocateErr = [NSError errorWithDomain:locationResultError.domain code:locationResultError.code userInfo:locationResultError.userInfo];
            if ([self.location isKindOfClass:NSString.class] && self.location.length>0) {
                return;
            }
            NSString *message = locationResultError.localizedDescription?:@"unKnown error";
//            if (locationError.code == AMapLocationErrorLocateFailed) {
//                NSString *app_Name = [[NSBundle mainBundle]
//                                      objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//                message = [NSString stringWithFormat:SY_STRING(@"Sign_location_servicesSet_m3"),app_Name];
//            } else {
//                message = SY_STRING(@"Sign_Local_locat_data_unavailable");
//            }
//            __weak CMPImagePickerViewController* weakSelf = self;
            UIAlertView *alertView = [[CMPAlertView alloc] initWithTitle:@"获取位置信息异常" message:message cancelButtonTitle:nil otherButtonTitles:[NSArray arrayWithObject:SY_STRING(@"common_ok")] callback:^(NSInteger buttonIndex) {
//                if ( [weakSelf.delegate respondsToSelector:@selector(imagePickerControllerHasNotLocationPermission:)]) {
//                    [weakSelf.delegate imagePickerControllerHasNotLocationPermission:weakSelf];
//                }
            } ];
            [alertView show];
            alertView = nil;
            return;
        }
        
        SyAddress *address = [[SyAddress alloc] init];
        address.provinceName =  regeocode.addressComponent.province;
        address.cityName = regeocode.addressComponent.city;
        address.districtName = regeocode.addressComponent.district;
        address.street = regeocode.formattedAddress;
        address.nearestPOI =  regeocode.formattedAddress;
        address.citycode = regeocode.addressComponent.citycode;
        address.latitude = location.latitude;
        address.longitude = location.longitude;
        weakSelf.currentAddress = address;
        weakSelf.currentLocation = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        [self addText];
        
    }];
    
}

- (void)addText {
    if (self.location/* && self.currentAddress*/) {
        self.imageView.locationLabel.text = self.location;
        [self.imageView customLayoutSubviews];
        return;
    }
    
    if (!self.image || !self.currentAddress) {
        return;
    }
    
    self.imageView.locationLabel.text = _currentAddress.nearestPOI;
    [self.imageView customLayoutSubviews];
}

/************************Lbs   end*****************************/



- (NSString *)writeToTempImagePath:(UIImage *)image {
    if (!image) {
        return @"";
    }
    NSString *filePath = [CMPFileManager imageMultiTempPath];
    
    NSString *str = [CMPFileManager uploadTempFilePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    filePath = [NSString stringWithFormat:@"%@/image_%@.png",str,dateStr] ;
    dateFormatter = nil;
    
    //NSData *data = UIImagePNGRepresentation(image);
    NSData *data = UIImageJPEGRepresentation(image, 0.3);
    
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

#pragma mark request server date  and Delegate
- (void)requestServerDate {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = self.serverDateUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.headers = [CMPDataProvider headers];
    NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithObject:@"getServerDate" forKey:@"methd"];
    aDataRequest.userInfo = aDict;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    if ([[[aRequest userInfo]objectForKey:@"methd"] isEqualToString:@"getServerDate"]) {
        NSDictionary*  dictionary = [[aResponse responseStr] JSONValue];
        self.serverDate = [dictionary objectForKey:@"value"];
        [self.imageView showDateTimeWithTime:self.serverDate];
    }
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    
}

- (void)providerProgessUpdate:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest ext:(NSDictionary *)aExt {
    
}



@end
