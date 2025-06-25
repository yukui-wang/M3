//
//  BFBaseViewController.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//

#import "BFBaseViewController.h"
#import "BFLibraryManager.h"
#import "BFImageUtils.h"
#import "BFRemindView.h"
#import "BFAIPWaterView.h"

#define scaleValue 0.8

#define ScreenRect [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height




@interface BFBaseViewController () <BFCaptureDataOutputProtocol>

@property (nonatomic, readwrite, retain) UILabel *remindLabel;
@property (nonatomic, readwrite, retain) BFRemindView * remindView;
@property (nonatomic, readwrite, retain) UILabel * remindDetailLabel;
@property (nonatomic, readwrite, retain) UIImageView * successImage;
@property (nonatomic, readwrite, assign) CGFloat brightness;
@property (nonatomic, readwrite, retain) BFAIPWaterView* waterView;


@end

@implementation BFBaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == PoseStatus) {
            [weakSelf.remindLabel setHidden:true];
            [weakSelf.remindView setHidden:false];
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
        }else if (status == occlusionStatus) {
            [weakSelf.remindLabel setHidden:false];
            [weakSelf.remindView setHidden:true];
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
            weakSelf.remindLabel.text = @"脸部有遮挡";
        }else {
            [weakSelf.remindLabel setHidden:false];
            [weakSelf.remindView setHidden:true];
            [weakSelf.remindDetailLabel setHidden:true];
            weakSelf.remindLabel.text = warning;
        }
    });
}

- (void)singleActionSuccess:(BOOL)success
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [weakSelf.successImage setHidden:false];
        }else {
            [weakSelf.successImage setHidden:true];
        }
    });
}

//设置权限
- (void)settingAuthentication {
}
//人脸识别基础设置
- (void)setupFaceSDKInfo {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化相机处理类
    self.videoCapture = [[BFVideoCaptureDevice alloc] init];
    self.videoCapture.delegate = self;
    
    // 用于播放视频流
    self.detectRect = CGRectMake(ScreenWidth*(1-scaleValue)/2.0, ScreenHeight*(1-scaleValue)/2.0, ScreenWidth*scaleValue, ScreenHeight*scaleValue);
    self.displayImageView = [[UIImageView alloc] initWithFrame:self.detectRect];
    self.displayImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.displayImageView];
    
    self.coverImage = [BFImageUtils getImageResourceForName:@"facecover"];
    CGRect circleRect = [BFImageUtils convertRectFrom:CGRectMake(125, 334, 500, 500) imageSize:self.coverImage.size detectRect:ScreenRect];
    self.previewRect = CGRectMake(circleRect.origin.x - circleRect.size.width*(1/scaleValue-1)/2.0, circleRect.origin.y - circleRect.size.height*(1/scaleValue-1)/2.0 - 60, circleRect.size.width/scaleValue, circleRect.size.height/scaleValue);
    
    CGFloat scale = circleRect.size.width / ScreenWidth;
    self.displayImageView.frame = CGRectMake(ScreenWidth*(1-scale)/2.0, ScreenHeight*(1-scale)/2.0, ScreenWidth*scale, ScreenHeight*scale);
    
    BFAIPWaterView* waterView = [[BFAIPWaterView alloc] initWithFrame:CGRectMake(circleRect.origin.x, circleRect.origin.y + circleRect.size.height - 60, circleRect.size.width, 60)];
    waterView.hidden = NO;
    self.waterView = waterView;
    [self.view addSubview:waterView];
    
    //画圈
    self.circleView = [[BFCircleView alloc] initWithFrame:ScreenRect];
    self.circleView.circleRect = circleRect;
    [self.view addSubview:self.circleView];
    
    // 遮罩
    UIImageView* coverImageView = [[UIImageView alloc] initWithFrame:ScreenRect];
    coverImageView.image = [BFImageUtils getImageResourceForName:@"facecover"];
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:coverImageView];
    
    //successImage
    self.successImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(circleRect)+CGRectGetWidth(circleRect)/2.0-57/2.0, CGRectGetMinY(circleRect)-57/2.0, 57, 57)];
    self.successImage.image = [BFImageUtils getImageResourceForName:@"success"];
    [self.view addSubview:self.successImage];
    [self.successImage setHidden:true];
    
    // 关闭
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[BFImageUtils getImageResourceForName:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(20, 30, 30, 30);
    [self.view addSubview:closeButton];
    
    // 提示框
    self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, circleRect.origin.y-70, ScreenWidth, 30)];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.textColor = OutSideColor;
    self.remindLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [self.view addSubview:self.remindLabel];
    
    self.remindView = [[BFRemindView alloc]initWithFrame:CGRectMake((ScreenWidth-200)/2.0, CGRectGetMinY(self.remindLabel.frame), 200, 45)];
    [self.view addSubview:self.remindView];
    [self.remindView setHidden:YES];
    
    self.remindDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(circleRect)+20, ScreenWidth, 30)];
    self.remindDetailLabel.font = [UIFont systemFontOfSize:20];
    self.remindDetailLabel.textColor = [UIColor redColor];
    self.remindDetailLabel.textAlignment = NSTextAlignmentCenter;
    self.remindDetailLabel.text = @"建议略微抬头";
    [self.view addSubview:self.remindDetailLabel];
//    [self.remindDetailLabel setHidden:true];
    
    // 监听重新返回APP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    self.enableSound = NO;
    [BFLibraryManager sharedInstance].groupId = self.groupId;
    [[BFLibraryManager sharedInstance] settingAuthentication];
    [[BFLibraryManager sharedInstance] setupFaceSDKInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hasFinished = YES;
    [self stopCapture];
    self.videoCapture.runningStatus = NO;
    [UIScreen mainScreen].brightness = self.brightness;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _hasFinished = NO;
    self.videoCapture.runningStatus = YES;
    [self.videoCapture startSession];
    self.brightness = [UIScreen mainScreen].brightness;
    [UIScreen mainScreen].brightness = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startAnimation {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.waterView.hidden = NO;
        [weakSelf.waterView startAnimation];
    });
}
- (void)stopAnimation {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.waterView.hidden = YES;
        [weakSelf.waterView stopAnimation];
    });
}
- (void)faceProcesss:(UIImage *)image {
}

- (void)startCapture {
    [self.videoCapture startSession];
    self.videoCapture.delegate = self;
}
- (void)stopCapture {
    [self.videoCapture stopSession];
    self.videoCapture.delegate = nil;
}
- (void)closeButtonClick {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self closeAction];
}
- (void)closeAction {
    _hasFinished = YES;
    self.videoCapture.runningStatus = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification

- (void)onAppWillResignAction {
    _hasFinished = YES;
    [UIScreen mainScreen].brightness = self.brightness;

}

- (void)onAppBecomeActive {
    _hasFinished = NO;
}

#pragma mark - CaptureDataOutputProtocol

- (void)captureOutputSampleBuffer:(UIImage *)image {
    if (_hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.displayImageView.image = image;
    });
    [self faceProcesss:image];
}

- (void)captureError {
    NSString *errorStr = @"出现未知错误，请检查相机设置";
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        errorStr = @"相机权限受限,请在设置中启用";
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"知道啦");
        }];
        [alert addAction:action];
        UIViewController* fatherViewController = weakSelf.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [fatherViewController presentViewController:alert animated:YES completion:nil];
        }];
    });
}


#pragma mark baidu face library action

- (void)createFace:(NSString *)imageStr {
    //人脸注册--- 创建上传人脸连数据
    __weak typeof(self) weakSelf = self;
    [[BFLibraryManager sharedInstance] createFace:imageStr
                                           userId:self.userId
                                         userInfo:self.userInfo
                                       completion:^(NSDictionary *result,NSError *error) {
                                           weakSelf.finishBlock(result, error);
                                           weakSelf.finishBlock = nil;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [weakSelf closeAction];
                                           });
                                       }];
}

- (void)updateFace:(NSString *)imageStr {
    //人脸更新--- 更新人脸数据，会覆盖对应人员的数据
    __weak typeof(self) weakSelf = self;
    [[BFLibraryManager sharedInstance] updateFace:imageStr
                                           userId:self.userId
                                         userInfo:self.userInfo
                                       completion:^(NSDictionary *result,NSError *error) {
                                           weakSelf.finishBlock(result, error);
                                           weakSelf.finishBlock = nil;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [weakSelf closeAction];
                                           });
                                       }];
}


- (void)removeFace {
    //人脸删除(删除用户)--- 删除人脸连数据
    __weak typeof(self) weakSelf = self;
    [[BFLibraryManager sharedInstance] removeFaceWithUserId:self.userId
                                                 completion:^(NSDictionary *result,NSError *error) {
                                                     weakSelf.finishBlock(result, error);
                                                     weakSelf.finishBlock = nil;
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf closeAction];
                                                     });
                                                 }];
}

- (void)checkFace:(NSString *)imageStr {
    //--- 判断识别人员是否是某个人员（通过userId返回bool）
    __weak typeof(self) weakSelf = self;
    [[BFLibraryManager sharedInstance] checkFace:imageStr
                                          userId:self.userId
                                      completion:^(NSDictionary *result,NSError *error) {
                                          weakSelf.finishBlock(result, error);
                                          weakSelf.finishBlock = nil;
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [weakSelf closeAction];
                                          });
                                      }];
}

- (void)obtainFace:(NSString *)imageStr {
    //--- 判断识别人员是谁（返回userid）
    __weak typeof(self) weakSelf = self;
    [[BFLibraryManager sharedInstance] obtainFace:imageStr
                                       completion:^(NSDictionary *result,NSError *error) {
                                           weakSelf.finishBlock(result, error);
                                           weakSelf.finishBlock = nil;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [weakSelf closeAction];
                                           });
                                       }];
}

@end
