/*!
 @abstract
 Created by 孙凯峰 on 2016/10/18.
 */
#define KScreenSize [UIScreen mainScreen].bounds.size
#define KScreenwidth [UIScreen mainScreen].bounds.size.width
#define KScreenheight [UIScreen mainScreen].bounds.size.height
#define IsIphone6P KScreenSize.width==414
#define IsIphone6 KScreenSize.width==375
#define IsIphone5S KScreenSize.height==568
#define IsIphone5 KScreenSize.height==568
//456字体大小
#define KIOS_Iphone456(iphone6p,iphone6,iphone5s,iphone5,iphone4s) (IsIphone6P?iphone6p:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?iphone5s:iphone4s)))
//宽高
#define KIphoneSize_Widith(iphone6) (IsIphone6P?1.104*iphone6:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?0.853*iphone6:0.853*iphone6)))
#define KIphoneSize_Height(iphone6) (IsIphone6P?1.103*iphone6:(IsIphone6?iphone6:((IsIphone5S||IsIphone5)?0.851*iphone6:0.720*iphone6)))
#import "PureCamera.h"
#import "TOCropViewController.h"
#import "LLSimpleCamera.h"
#import <CoreServices/CoreServices.h>

@interface PureCamera ()<TOCropViewControllerDelegate>
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *backButton;

@end

@implementation PureCamera

+ (instancetype) createFromPictureOptions:(TZPictureOptions*)pictureOptions
{
    PureCamera* cameraPicker = [[PureCamera alloc] init];
    cameraPicker.pictureOptions = pictureOptions;
    cameraPicker.sourceType = pictureOptions.sourceType;
    cameraPicker.allowsEditing = pictureOptions.allowsEditing;
    
    if (pictureOptions.mediaType == MediaTypePicture && pictureOptions.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // We only allow taking pictures (no video) in this API.
        cameraPicker.mediaTypes = @[(NSString*)kUTTypeImage];
        // We can only set the camera device if we're actually using the camera.
        cameraPicker.cameraDevice = pictureOptions.cameraDirection;
    } else if (pictureOptions.mediaType == MediaTypeAll) {
        cameraPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:cameraPicker.sourceType];
    } else {
        NSArray* mediaArray = @[(NSString*)(pictureOptions.mediaType == MediaTypeVideo ? kUTTypeMovie : kUTTypeImage)];
        cameraPicker.mediaTypes = mediaArray;
    }
    
    return cameraPicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //拍照按钮
    [self InitializeCamera];
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius =75 / 2.0f;
    [self.snapButton setImage:[UIImage imageNamed:@"PureCamera.bundle/cameraButton"] forState:UIControlStateNormal];
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    //闪关灯按钮
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    self.flashButton.tintColor = [UIColor whiteColor];
    //     UIImage *image = [UIImage imageNamed:@"PureCamera.bundle/camera-flash.png"];
    [self.flashButton setImage:[UIImage imageNamed:@"PureCamera.bundle/camera-flash"] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        //摄像头转换按钮
        self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"PureCamera.bundle/swapButton"] forState:UIControlStateNormal];
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
        //返回按钮
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.backButton setImage:[UIImage imageNamed:@"PureCamera.bundle/closeButton"] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.backButton];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // snap button to capture image
    
    //判断前后摄像头是否可用
    
    
    // start the camera
    [self.camera start];
}
#pragma mark   ------------- 初始化相机--------------
-(void)InitializeCamera{
    CGRect screenRect = self.view.frame;
    
    // 创建一个相机
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh  position:LLCameraPositionRear];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        //NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        //NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission) {
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"未获取相机权限";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    
    
}

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}
-(void)backButtonPressed:(UIButton *)button{
    
    if ([self.delegate respondsToSelector: @selector(pureCameraControllerDidCancel:)]) {
        
        [self.delegate pureCameraControllerDidCancel:self];
        
    }

}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}
#pragma mark   -------------拍照--------------

- (void)snapButtonPressed:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    // 去拍照
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        //NSLog(@"拍照结束");
        if(!error) {
            
            TOCropViewControllerAspectRatio aspectRatioStle = TOCropViewControllerAspectRatioOriginal;
            
            if (weakSelf.isOnlyNeedRatioSquare) {
                
                aspectRatioStle = TOCropViewControllerAspectRatioSquare;
                
            }
            
            if (weakSelf.aspectRatioStle) {
                aspectRatioStle = weakSelf.aspectRatioStle;
            }
            TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:image aspectRatioStle:aspectRatioStle];
            cropController.delegate = self;
            cropController.imageInfo = metadata;
            cropController.isOnlyNeedRatioSquare = weakSelf.isOnlyNeedRatioSquare;
            [weakSelf presentViewController:cropController animated:YES completion:nil];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.camera.view.frame=self.view.frame;
    self.snapButton.frame=CGRectMake((KScreenwidth-KIphoneSize_Widith(75))/2, KScreenheight-KIphoneSize_Widith(90), KIphoneSize_Widith(75), KIphoneSize_Widith(75));
    self.flashButton.frame=CGRectMake((KScreenwidth-KIphoneSize_Widith(36))/2, 25, KIphoneSize_Widith(36), KIphoneSize_Widith(44));
    self.switchButton.frame=CGRectMake(KScreenwidth-50, KScreenheight-KIphoneSize_Widith(75), KIphoneSize_Widith(45), KIphoneSize_Widith(45));
    self.backButton.frame=CGRectMake(5, KScreenheight-KIphoneSize_Widith(75), KIphoneSize_Widith(45), KIphoneSize_Widith(45));
}
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle imageInfo:(NSDictionary *)info{
    self.view.alpha = 0;
    
    ;
    
    NSMutableDictionary *imageInfo = [info mutableCopy];
    [imageInfo setObject:image forKey:UIImagePickerControllerEditedImage];
    
    if (self.fininshcapture) {
        
        self.fininshcapture(image);
        
    }
    
    if ([self.delegate respondsToSelector:@selector(pureCameraController:didFinishPickingMediaWithInfo:)] ){
        
        [self.delegate pureCameraController:self didFinishPickingMediaWithInfo:[imageInfo copy]];
        
    }
    

    [self dismissViewControllerAnimated:NO completion:^{
    }];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
