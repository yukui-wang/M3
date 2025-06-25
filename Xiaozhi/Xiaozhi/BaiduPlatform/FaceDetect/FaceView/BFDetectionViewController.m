//
//  BFDetectionViewController.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//



#import "BFDetectionViewController.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+BFImage.h"

@interface BFDetectionViewController ()
{
}

@property (nonatomic, readwrite, retain) UIView *animaView;
@property (nonatomic, readwrite, retain) NSString *accessToken;

@end

@implementation BFDetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 纯粹为了在照片成功之后，做闪屏幕动画之用
    self.animaView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.animaView.backgroundColor = [UIColor whiteColor];
    self.animaView.alpha = 0;
    [self.view addSubview:self.animaView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IDLFaceDetectionManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IDLFaceDetectionManager sharedInstance] reset];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [[IDLFaceDetectionManager sharedInstance] reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [IDLFaceDetectionManager sharedInstance].enableSound = self.enableSound;
    [[IDLFaceDetectionManager sharedInstance] detectStratrgyWithImage:image
                                                          previewRect:self.previewRect
                                                           detectRect:self.detectRect
                                                    completionHandler:^(NSDictionary *images, DetectRemindCode remindCode) {
        switch (remindCode) {
            case DetectRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [weakSelf stopCapture];
                [weakSelf warningStatus:CommonStatus warning:@"非常好"];
                [weakSelf singleActionSuccess:true];
                [weakSelf handleDetectFaceSucess:images orgImage:image];
                break;
            }
            case DetectRemindCodePitchOutofDownRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微抬头"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodePitchOutofUpRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微低头"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofLeftRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向右转头"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofRightRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向左转头"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodePoorIllumination:
                [weakSelf warningStatus:CommonStatus warning:@"光线再亮些"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeNoFaceDetected:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeImageBlured:
                [weakSelf warningStatus:CommonStatus warning:@"请保持不动"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftEye:
                [weakSelf warningStatus:occlusionStatus warning:@"左眼有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightEye:
                [weakSelf warningStatus:occlusionStatus warning:@"右眼有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionNose:
                [weakSelf warningStatus:occlusionStatus warning:@"鼻子有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionMouth:
                [weakSelf warningStatus:occlusionStatus warning:@"嘴巴有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftContour:
                [weakSelf warningStatus:occlusionStatus warning:@"左脸颊有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightContour:
                [weakSelf warningStatus:occlusionStatus warning:@"右脸颊有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionChinCoutour:
                [weakSelf warningStatus:occlusionStatus warning:@"下颚有遮挡"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeTooClose:
                [weakSelf warningStatus:CommonStatus warning:@"手机拿远一点"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeTooFar:
                [weakSelf warningStatus:CommonStatus warning:@"手机拿近一点"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeBeyondPreviewFrame:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内"];
                [weakSelf singleActionSuccess:false];
                break;
            case DetectRemindCodeVerifyInitError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyDecryptError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoFormatError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyExpired:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyMissRequiredInfo:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoCheckError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyLocalFileError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyRemoteDataError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeTimeout: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"remind" message:@"超时" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"知道啦");
                    }];
                    [alert addAction:action];
                    UIViewController* fatherViewController = weakSelf.presentingViewController;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        [fatherViewController presentViewController:alert animated:YES completion:nil];
                    }];
                });
                break;
            }
            case DetectRemindCodeConditionMeet: {
                weakSelf.circleView.conditionStatusFit = true;
            }
                break;
            default:
                break;
        }
        if (remindCode == DetectRemindCodeConditionMeet || remindCode == DetectRemindCodeOK) {
            weakSelf.circleView.conditionStatusFit = true;
        }else {
            weakSelf.circleView.conditionStatusFit = false;
        }
    }];
}

- (void)handleDetectFaceSucess:(NSDictionary *)images orgImage:(UIImage *)image {
    NSString* tempString = [images[@"bestImage"] lastObject];
    if (images[@"landMarks"] != nil && [images[@"landMarks"] count] >= 57) {
        CGPoint nose = [images[@"landMarks"][57] CGPointValue];
        //默认是竖屏情况，所以选择以鼻子为中心，边长为图片宽的正方形来做压缩
        CGRect rect = CGRectMake(0, MAX(nose.y-image.size.width/2.0, 0), image.size.width, image.size.width);
        UIImage* tempImage = [[image subImageAtRect:rect] resizedToSize:CGSizeMake(200, 200)];
        tempString = [[tempImage dataWithCompress:0.8] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    switch (self.handleType) {
        case BFaceHandleTypeCreate:
            [self createFace:tempString];
            break;
        case BFaceHandleTypeUpdate:
            [self updateFace:tempString];
            break;
        case BFaceHandleTypeObtain:
            [self obtainFace:tempString];
            break;
        case BFaceHandleTypeCheck:
            [self checkFace:tempString];
            break;
        default:
            break;
    }
}

- (void)dealloc {
}

@end
