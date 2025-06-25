

#import "CMPCameraViewController.h"
#import "CMPCameraShutterButton.h"
#import "CMPShowShutterImgView.h"
#import "CMPCameraSelectFlashTypeView.h"
#import "CMPAVPlayerViewController.h"

#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPCAAnimation.h>
#import <CMPLib/UIView+CMPView.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/CMPFileManager.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/YBIBUtilities.h>
#import <Photos/Photos.h>
#import <CMPLib/CMPCustomAlertView.h>
#import <CMPLib/CMPDevicePermissionHelper.h>


typedef void(^PropertyChangeBlock) (AVCaptureDevice * captureDevice);


@interface CMPCameraViewController ()<AVCaptureFileOutputRecordingDelegate>

/*
 *  AVCaptureSession:它从物理设备得到数据流（比如摄像头和麦克风），输出到一个或
 *  多个目的地，它可以通过
 *  会话预设值(session preset)，来控制捕捉数据的格式和质量
 */

/* 闪光灯btn */
@property (strong, nonatomic) UIButton *flashBtn;
/* 选择闪光灯view */
@property (strong, nonatomic) CMPCameraSelectFlashTypeView *selectFlashView;
/* bottomCoverView */
@property (strong, nonatomic) UIView *bottomCoverView;
/* 拍摄按钮 */
@property (strong, nonatomic) CMPCameraShutterButton *pressBtn;
/* 相机切换按钮 */
@property (strong, nonatomic) UIButton *cameraExchangeBtn;

/* 播放按钮当前状态，视频和图片状态两种 */
@property (assign, nonatomic) CMPCameraShutterButtonStatus status;

//负责输入和输出设备之间的数据传输
@property (nonatomic, strong) AVCaptureSession * captureSession;
//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
/* 切换摄像头时的input */
@property (strong, nonatomic) AVCaptureDeviceInput *toChangeDeviceInput;
//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
//视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutPut;

@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识

//相机拍摄预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

@property (nonatomic, strong) UIView * contentView;
/* showImgView */
@property (strong, nonatomic) CMPShowShutterImgView *showImgView;
/* imgView */
@property (strong, nonatomic) UIImageView *imgView;

//聚焦光标
@property (nonatomic, strong) UIImageView * focusCursor;

/* 拍照/视频 切换view */
@property (strong, nonatomic) UIView *switchView;
/* 选中的切换按钮 */
@property (weak, nonatomic) UIButton *selectedSwitchBtn;
/* cancelBtn */
@property (strong, nonatomic) UIButton *cancelBtn;

/* 上次的屏幕方向 */
@property (assign, nonatomic) UIDeviceOrientation lastOrientation;

@end

@implementation CMPCameraViewController
#pragma mark - 懒加载

/// 闪光灯按钮
- (UIButton *)flashBtn {
    
    if (!_flashBtn) {
        _flashBtn = [UIButton.alloc initWithFrame:CGRectMake(10.f, 35.f, 27.f, 32.f)];
        [_flashBtn setImage:[UIImage imageNamed:@"camera_turn_auto_flash"] forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

/// 选择闪光灯view
- (CMPCameraSelectFlashTypeView *)selectFlashView {
    if (!_selectFlashView) {
        _selectFlashView = [CMPCameraSelectFlashTypeView.alloc initWithFrame:CGRectMake(0, 35.f, 180.f, 32.f)];
        _selectFlashView.cmp_x = CGRectGetMaxX(self.flashBtn.frame) + 6.f;
        _selectFlashView.backgroundColor = UIColor.clearColor;
        _selectFlashView.alpha = 0;
        __weak typeof(self) weakSelf = self;
        _selectFlashView.flashClicked = ^(CMPCameraSelectFlashType type, UIImage * _Nonnull btnImg) {
            [weakSelf.flashBtn setImage:btnImg forState:UIControlStateNormal];
            switch (type) {
                case CMPCameraSelectFlashTypeAuto:
                {
                    [weakSelf setFlashMode:AVCaptureFlashModeAuto];
                }
                    break;
                case CMPCameraSelectFlashTypeOn:
                {
                    [weakSelf setFlashMode:AVCaptureFlashModeOn];
                }
                    break;
                case CMPCameraSelectFlashTypeOff:
                {
                    [weakSelf setFlashMode:AVCaptureFlashModeOff];
                }
                    break;
                    
                default:
                    break;
            }
            
        };
    }
    return _selectFlashView;
}

/// 切换拍照和拍视频 方式  view
- (UIView *)switchView {
    if (!_switchView) {
        
        NSString *photoTitle = SY_STRING(@"picture_photo_text");
        NSString *videoTitle = SY_STRING(@"picture_video_text");
        if (self.isNotShowTakeVideo) {
            videoTitle = nil;
        }
        
        if (self.isNotShowTakePhoto) {
            photoTitle = nil;
        }
        
        NSMutableArray *titles = NSMutableArray.array;
        if ([NSString isNotNull:photoTitle]) {
            [titles addObject:photoTitle];
        }
        
        if ([NSString isNotNull:videoTitle]) {
            [titles addObject:videoTitle];
        }
        
        _switchView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 90.f*titles.count, 26.f)];
        _switchView.backgroundColor = UIColor.clearColor;
        _switchView.cmp_x = self.pressBtn.cmp_centerX - _switchView.width/4.f;
        
        
        NSInteger count = titles.count;
        CGFloat w = _switchView.width/count;
        CGFloat h = _switchView.height;
        for (NSInteger i = 0; i < count; i++) {
            UIButton *btn = [UIButton.alloc initWithFrame:CGRectMake(i*w, 0, w, h)];
            [btn setTitleColor:[UIColor colorWithHexString:@"#ffd60a"] forState:UIControlStateSelected];
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(switchBtnsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_switchView addSubview:btn];
            if (0 == i) {
                self.selectedSwitchBtn = btn;
            }
        }
        [self switchBtnsClicked:self.selectedSwitchBtn];
    }
    return _switchView;
}

/// 显示拍摄完成后的view
- (CMPShowShutterImgView *)showImgView {
    if (!_showImgView) {
        _showImgView = [CMPShowShutterImgView.alloc initWithFrame:self.view.bounds];
        _showImgView.backgroundColor = UIColor.blackColor;
        __weak typeof(self) weakSelf = self;
        _showImgView.useClicked = ^(UIImage * _Nonnull img,NSDictionary *videoInfo) {
            //发送图片
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            if (weakSelf.usePhotoClicked) {
                weakSelf.usePhotoClicked(img,videoInfo);
            }
            
            
            if (weakSelf.usePhoto1Clicked) {
                NSString *imgPath = nil;
                if (img) {
                    imgPath = [CMPFileManager.fileTempPath stringByAppendingFormat:@"/%@.jpg",NSString.uuid.md5String];
                    NSData *imgData = UIImageJPEGRepresentation(img, 1.f);
                    
                    [imgData writeToFile:imgPath atomically:YES];
                }
                
                weakSelf.usePhoto1Clicked(imgPath, videoInfo);
            }
            
        };
    }
    return _showImgView;
}

/// 底部coverview
- (UIView *)bottomCoverView {
    if (!_bottomCoverView) {
        CGFloat height = 160.f;
        _bottomCoverView = [UIView.alloc initWithFrame:CGRectMake(0, self.view.height - height, self.view.width, height)];
        _bottomCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    }
    return _bottomCoverView;
}

/// 拍摄按钮
- (CMPCameraShutterButton *)pressBtn {
    if (!_pressBtn) {
        _pressBtn = [CMPCameraShutterButton.alloc initWithFrame:CGRectMake(0, 0, 72.f, 72.f)];
        _pressBtn.backgroundColor = UIColor.clearColor;
        _pressBtn.cmp_centerX = self.bottomCoverView.width/2.f;
        _pressBtn.cmp_centerY = self.bottomCoverView.height/2.f;
        
        if (self.videoMaxTime) {
            _pressBtn.videoMaxTime = self.videoMaxTime;
        }
        
        [_pressBtn addTarget:self action:@selector(pressClicked:) forControlEvents:UIControlEventTouchUpInside];
        __weak typeof(self) weakSelf = self;
        _pressBtn.videoShutCompleted = ^{
            //拍摄视频倒计时动画完成
            [weakSelf pressClicked:weakSelf.pressBtn];
        };
    }
    return _pressBtn;
}

/// 切换前后摄像头按钮
- (UIButton *)cameraExchangeBtn {
    if (!_cameraExchangeBtn) {
        _cameraExchangeBtn = UIButton.alloc.init;
        _cameraExchangeBtn.cmp_size = CGSizeMake(51.f, 41.f);
        _cameraExchangeBtn.cmp_centerY = self.pressBtn.cmp_centerY;
        _cameraExchangeBtn.cmp_x = self.bottomCoverView.width - 15.f - _cameraExchangeBtn.width;
        [_cameraExchangeBtn setImage:[UIImage imageNamed:@"camera_filp_back"] forState:UIControlStateNormal];
        [_cameraExchangeBtn setImage:[UIImage imageNamed:@"camera_filp_front"] forState:UIControlStateSelected];
        [_cameraExchangeBtn addTarget:self action:@selector(exchangeCameraClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cameraExchangeBtn;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 67.f, self.view.width, self.view.height - 67.f - self.bottomCoverView.height);
    }
    return _contentView;
}

- (UIImageView *)focusCursor {
    if (!_focusCursor) {
        _focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60.f, 60.f)];
        _focusCursor.backgroundColor = [UIColor clearColor];
        [_focusCursor cmp_setRoundView];
    }
    return _focusCursor;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        NSString *cancelTitle = SY_STRING(@"common_cancel");
        CGFloat cancelW = [cancelTitle sizeWithFontSize:[UIFont systemFontOfSize:18.f] defaultSize:CGSizeMake(MAXFLOAT, 0)].width;
        _cancelBtn = [UIButton.alloc initWithFrame:CGRectMake(18.f, 0, cancelW, 20.f)];
        _cancelBtn.cmp_centerY = self.pressBtn.cmp_centerY;
        [_cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
        [_cancelBtn addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark - view loading

- (void)dealloc {
    CMPFuncLog;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lastOrientation = UIDevice.currentDevice.orientation;
    
    [self configViews];
    [self checkPermission];
    
    //初始化摄像头
    [self initCamera];
    
}

- (void)configViews {
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.contentView];
    
    [self.view addSubview:self.focusCursor];
    
    self.status = CMPCameraShutterButtonStatusPhoto;
    
    [self.view addSubview:self.bottomCoverView];
    [self.bottomCoverView addSubview:self.pressBtn];
    [self.bottomCoverView addSubview:self.cameraExchangeBtn];
    [self.bottomCoverView addSubview:self.switchView];
    [self.view addSubview:self.flashBtn];
    [self.view addSubview:self.selectFlashView];
    
    [self.bottomCoverView addSubview:self.cancelBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CMPFuncLog;
    
    if (CMP_IPAD_MODE && UIDevice.currentDevice.orientation != self.lastOrientation) {
        CGFloat contentViewW = 67.f;
        CGFloat bottomCoverViewH = 160.f;
        CGFloat focusCursorWH = 60.f;
        
        self.contentView.frame = CGRectMake(0, contentViewW, self.view.width, self.view.height - contentViewW - self.bottomCoverView.height);
        self.bottomCoverView.frame = CGRectMake(0, self.view.height - bottomCoverViewH, self.view.width, bottomCoverViewH);
        self.focusCursor.frame = CGRectMake(0, 0, focusCursorWH, focusCursorWH);
        
        self.pressBtn.cmp_centerX = self.bottomCoverView.width/2.f;
        self.pressBtn.cmp_centerY = self.bottomCoverView.height/2.f;
        
        self.cameraExchangeBtn.cmp_centerY = self.pressBtn.cmp_centerY;
        self.cameraExchangeBtn.cmp_x = self.bottomCoverView.width - 15.f - self.cameraExchangeBtn.width;
        
        self.selectedSwitchBtn.selected = NO;
        [self switchBtnsClicked:self.selectedSwitchBtn];
        
        self.flashBtn.frame = CGRectMake(10.f, 35.f, 27.f, 32.f);
        
        self.selectFlashView.cmp_x = CGRectGetMaxX(self.flashBtn.frame) + 6.f;
        self.selectFlashView.cmp_x = 35.f;
        
        self.cancelBtn.cmp_x = 18.f;
        self.cancelBtn.cmp_centerY = self.pressBtn.cmp_centerY;
        
        self.showImgView.frame = self.view.bounds;
        
    }
    self.lastOrientation = UIDevice.currentDevice.orientation;
}


#pragma mark - 按钮点击

/// 拍照/录制视频 按钮点击
/// @param btn btn
- (void)pressClicked:(CMPCameraShutterButton *)btn {
    if (self.status == CMPCameraShutterButtonStatusPhoto) {
        //直接拍照
        [self capturePhoto];
    }else {
        
        //录制视频
        btn.selected = !btn.selected;
        if (btn.selected) {
            [btn startAnim];
            [btn changeInnerLayerToRectWithBgColor: UIColor.redColor];
        }else {
            [btn stopAnim];
            [btn changeInnerLayerToCycleWithBgColor: UIColor.redColor];
        }
        
        [self captureVideo];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.45f animations:^{
            weakSelf.switchView.alpha = !btn.selected;
            weakSelf.cameraExchangeBtn.alpha = !btn.selected;
            weakSelf.flashBtn.alpha = !btn.selected;
        }];
    }
}

/// 取消按钮点击
- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.didDismissBlock) {
        self.didDismissBlock();
        self.didDismissBlock = nil;
    }
}

/// 前后摄像头置换
- (void)exchangeCameraClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    [CMPCAAnimation cmp_transitionWithLayer:self.contentView.layer type:CMPTransitionTypeOglFlip timeInterval:0.4f transitionType:kCATransitionFromLeft];
    
    [self initToDeviceInput];
    //改变会话到配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    
    if ([self.captureSession canAddInput:self.toChangeDeviceInput]) {
        [self.captureSession addInput:self.toChangeDeviceInput];
        self.captureDeviceInput = self.toChangeDeviceInput;
    }
    
    //提交新的输入对象
    [self.captureSession commitConfiguration];
}

- (void)addCameraPresetIsFrontCamera:(BOOL)isFront {
    if (isFront) {
        //添加新的输入对象
        if (YBIBUtilities.isIphoneX) {
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            }
        }else {
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
            }
        }
    }else {
        //添加新的输入对象
        if (YBIBUtilities.isIphoneX) {
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
            }
        }else {
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            }
        }
    }
}

/// 切换拍照、拍视频点击
- (void)switchBtnsClicked:(UIButton *)btn {
    CMPFuncLog;
    self.selectedSwitchBtn.selected = !self.selectedSwitchBtn.selected;
    btn.selected = YES;
    self.selectedSwitchBtn = btn;
    NSString *photoTitle = SY_STRING(@"picture_photo_text");
    NSString *title = [btn titleForState:UIControlStateNormal];
    if ([title isEqualToString:photoTitle]) {
        //照片按钮点击
        self.status = CMPCameraShutterButtonStatusPhoto;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.45f animations:^{
            if (weakSelf.switchView.subviews.count == 2) {
                weakSelf.switchView.cmp_x = weakSelf.pressBtn.cmp_centerX - weakSelf.switchView.width/4.f;
            }else {
                weakSelf.switchView.cmp_centerX = weakSelf.pressBtn.cmp_centerX;
            }
            
            weakSelf.contentView.cmp_height = weakSelf.view.height - weakSelf.contentView.cmp_y - weakSelf.bottomCoverView.height;
        }];
        //改变拍照按钮中间的圆圈为白色圆圈
        [self.pressBtn changeInnerLayerToCycleWithBgColor:UIColor.whiteColor];
    }else {
        //视频按钮点击
        self.status = CMPCameraShutterButtonStatusVideo;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.45f animations:^{
            if (weakSelf.switchView.subviews.count == 2) {
                weakSelf.switchView.cmp_x = weakSelf.pressBtn.cmp_centerX - weakSelf.switchView.width*3.f/4.f;
            }else {
                weakSelf.switchView.cmp_centerX = weakSelf.pressBtn.cmp_centerX;
            }
            
            weakSelf.contentView.cmp_height = weakSelf.view.height - weakSelf.contentView.cmp_y - 84.f;
        }];
        //改变拍照按钮中间的圆圈为红色圆圈
        [self.pressBtn changeInnerLayerToCycleWithBgColor:UIColor.redColor];
    }
}

/// 闪光灯按钮点击
- (void)flashBtnClicked {
    CMPFuncLog;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.45 animations:^{
        if (weakSelf.selectFlashView.alpha == 1.f) {
            weakSelf.selectFlashView.alpha = 0;
        }else {
            weakSelf.selectFlashView.alpha = 1.f;
        }
        
    }];
}

#pragma mark - 拍摄相关

/// 拍照
- (void)capturePhoto {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation = [self orientationForConnection];
    
    //根据连接取得设备输出的数据
    [self.pressBtn shrink];
    __weak typeof(self) weakSelf = self;
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        [weakSelf.pressBtn expand];
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [weakSelf.view addSubview:self.showImgView];
            image = [image fixOrientation];
            weakSelf.showImgView.image = image;

        }
        
    }];
}

/// 拍视频
- (void)captureVideo {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
      //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutPut isRecording]) {
    //      self.enableRotation=NO;
          //如果支持多任务则则开始多任务
      if ([[UIDevice currentDevice] isMultitaskingSupported]) {
          self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
      }
        //用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        NSString *outputFielPath = [CMPFileManager.fileTempPath stringByAppendingString:[NSString stringWithFormat:@"/%@.mov",[formater stringFromDate:NSDate.date]]];
        CMPLog(@"save path is :%@",outputFielPath);
        NSURL *fileUrl = [NSURL fileURLWithPath:outputFielPath];
        [self.captureMovieFileOutPut startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        
    }
    else{
        [self.captureMovieFileOutPut stopRecording];//停止录制
        //[MBProgressHUD cmp_showProgressHUD];
    }
    
}

#pragma mark - 检查权限

- (void)checkPermission {
    [CMPDevicePermissionHelper cameraPermissionTrueCompletion:nil falseCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPermissionAlert];
        });
    }];
}

- (void)showPermissionAlert {
    id<CMPCustomAlertViewProtocol> alert = [CMPCustomAlertView alertViewWithTitle:nil message:SY_STRING(@"video_component_no_permission") preferredStyle:CMPCustomAlertViewStyleAlert footStyle:CMPAlertPublicFootStyleDefalut bodyStyle:CMPAlertPublicBodyStyleDefalut cancelButtonTitle:SY_STRING(@"common_cancel") otherButtonTitles:@[SY_STRING(@"common_goto_setting")] handler:^(NSInteger buttonIndex, id  _Nullable value) {
        if (buttonIndex == 1) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert setTheme:CMPTheme.new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert show];
    });
}

#pragma mark - 摄像头初始化
- (void)initCamera{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化会话
        weakSelf.captureSession = [[AVCaptureSession alloc] init];
        //设置分辨率
        
        [weakSelf addCameraPresetIsFrontCamera:NO];
        //获得输入设备
        AVCaptureDevice * captureDevice = [weakSelf getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
        if (!captureDevice) {
            CMPLog(@"取得后置摄像头时出现问题。");
            return;
        }
        
        NSError * error = nil;
        
        //添加一个音频输入设备
        AVCaptureDevice * audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput * audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
        if (error) {
            CMPLog(@"获得设备输入对象时出错，错误原因：%@",error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showPermissionAlert];
            });
            return;
        }
        
        weakSelf.captureMovieFileOutPut = [[AVCaptureMovieFileOutput alloc] init];
        
        //根据输入设备初始化设备输入对象，用于获得输入数据
        weakSelf.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
        if (error) {
            CMPLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
            return;
        }
        //初始化设备输出对象，用于获得输出数据
        weakSelf.captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        //输出设置
        [weakSelf.captureStillImageOutput setOutputSettings:outputSettings];
        
        //将设备输入添加到会话中
        if ([weakSelf.captureSession canAddInput:weakSelf.captureDeviceInput]) {
            [weakSelf.captureSession addInput:weakSelf.captureDeviceInput];
            [weakSelf.captureSession addInput:audioCaptureDeviceInput];
            AVCaptureConnection * captureConnection = [weakSelf.captureMovieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
            if ([captureConnection isVideoStabilizationSupported]) {
                captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        
        //将设输出添加到会话中
        if ([weakSelf.captureSession canAddOutput:weakSelf.captureStillImageOutput]) {
            [weakSelf.captureSession addOutput:weakSelf.captureStillImageOutput];
        }
        
        if ([weakSelf.captureSession canAddOutput:weakSelf.captureMovieFileOutPut]) {
            [weakSelf.captureSession addOutput:weakSelf.captureMovieFileOutPut];
        }
        
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //创建视频预览层，用于实时展示摄像头状态
            weakSelf.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:weakSelf.captureSession];
            
            CALayer * layer = weakSelf.contentView.layer;
            layer.masksToBounds = YES;
            
            //weakSelf.captureVideoPreviewLayer.frame = layer.bounds;
            //填充模式
            weakSelf.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            //将视频预览层添加到界面中
            [layer insertSublayer:weakSelf.captureVideoPreviewLayer below:weakSelf.focusCursor.layer];
            
            weakSelf.contentView.layoutSubviewsCallback = ^(UIView *superview) {
                weakSelf.captureVideoPreviewLayer.frame = superview.layer.bounds;
                weakSelf.captureVideoPreviewLayer.connection.videoOrientation = [weakSelf orientationForConnection];
            };
            
            [weakSelf addNotificationToCaptureDevice:captureDevice];
            [weakSelf.captureSession startRunning];
            
            [weakSelf addGenstureRecognizer];
        });
        
        [weakSelf initToDeviceInput];
    });
}


- (void)initToDeviceInput {
    AVCaptureDevice * currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition  toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    
    [self addCameraPresetIsFrontCamera:(toChangePosition == AVCaptureDevicePositionFront)];
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    //获得要调整到设备输入对象
    _toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
}

#pragma mark - 视频输出代理

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    CMPLog(@"开始录制...");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    CMPLog(@"视频录制完成.");
    //[MBProgressHUD cmp_hideProgressHUD];
    self.showImgView.videoUrl = outputFileURL;
    [self.view addSubview:self.showImgView];
    
}

#pragma mark - 摄像头相关
//  给输入设备添加通知
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

////屏幕旋转时调整视频预览图层的方向
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    AVCaptureConnection *captureConnection = [self.captureVideoPreviewLayer connection];
//    captureConnection.videoOrientation = (AVCaptureVideoOrientation)toInterfaceOrientation;
//}
////旋转后重新设置大小
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    _captureVideoPreviewLayer.frame=self.contentView.bounds;
//}

//获取指定位置的摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition) positon{

    NSArray * cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * camera in cameras) {
        if ([camera position] == positon) {
            return camera;
        }
    }
    return nil;
}

//属性改变操作
- (void)changeDeviceProperty:(PropertyChangeBlock ) propertyChange{
   
    AVCaptureDevice * captureDevice = [self.captureDeviceInput device];
    NSError * error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
      
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
    } else {
        
        CMPLog(@"设置设备属性过程发生错误，错误信息：%@", error.localizedDescription);
    }
}

//设置闪光灯模式
- (void)setFlashMode:(AVCaptureFlashMode ) flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

//聚焦模式
- (void)setFocusMode:(AVCaptureFocusMode) focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

//设置曝光模式
- (void)setExposureMode:(AVCaptureExposureMode) exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}

//设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        
    }];
}

//添加点击手势，点按时聚焦
- (void)addGenstureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [self.contentView addGestureRecognizer:tapGesture];
}


//设置聚焦光标位置
- (void)setFocusCursorWithPoint:(CGPoint)point{
    
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    CMPLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    CMPLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    CMPLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    CMPLog(@"会话发生错误.");
}

//#pragma mark - 加速仪相关

//- (void)startDeviceMotion{
//    if (![self.motionManager isDeviceMotionAvailable]) return;
//
//    [self.motionManager setDeviceMotionUpdateInterval:1.f];
//    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//
//        double gravityX = motion.gravity.x;
//        double gravityY = motion.gravity.y;
//
//        if (fabs(gravityY)>=fabs(gravityX)) {
//
//            if (gravityY >= 0) {
//
//                // UIDeviceOrientationPortraitUpsideDown
//                [self setDeviceDirection:SSDeviceDirectionDown];
//                CMPLog(@"头向下");
//
//            } else {
//
//                // UIDeviceOrientationPortrait
//                [self setDeviceDirection:SSDeviceDirectionUp];
//                CMPLog(@"竖屏");
//            }
//
//        } else {
//
//            if (gravityX >= 0) {
//                // UIDeviceOrientationLandscapeRight
//                [self setDeviceDirection:SSDeviceDirectionRight];
//                CMPLog(@"头向右");
//            } else {
//
//                // UIDeviceOrientationLandscapeLef
//                [self setDeviceDirection:SSDeviceDirectionLeft];
//                CMPLog(@"头向左");
//            }
//        }
//    }];
//}


#pragma mark - 点击方法
- (void)tapScreen:(UITapGestureRecognizer *)tapGesture{

    CGPoint point = [tapGesture locationInView:self.contentView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    point.y += 124;
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

- (AVCaptureVideoOrientation)orientationForConnection
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
//    if(self.useDeviceOrientation) {
//        switch ([UIDevice currentDevice].orientation) {
//            case UIDeviceOrientationLandscapeLeft:
//                // yes to the right, this is not bug!
//                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
//                break;
//            case UIDeviceOrientationLandscapeRight:
//                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
//                break;
//            case UIDeviceOrientationPortraitUpsideDown:
//                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
//                break;
//            default:
//                videoOrientation = AVCaptureVideoOrientationPortrait;
//                break;
//        }
//    }
//    else {
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    //}
    
    return videoOrientation;
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return SY_STRING(@"screeenshot_page_title_camera");
}


@end
