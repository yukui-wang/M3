//
//  BFLivenessViewController.m
//  M3
//
//  Created by wujiansheng on 2018/12/12.
//

#import <IDLFaceSDK/IDLFaceSDK.h>
#import "BFLivenessViewController.h"
#import "UIImage+BFImage.h"

@interface BFLivenessViewController ()

@property (nonatomic, strong) NSArray * livenessArray; //活体动作列表
@property (nonatomic, assign) BOOL order;//是否按顺序进行活体动作
@property (nonatomic, assign) NSInteger numberOfLiveness;//活体动作数目（array为nil是起作用）

@end

@implementation BFLivenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.order = YES;
    self.numberOfLiveness = 1;

    NSMutableArray *liveList = [NSMutableArray array];
    if ([self.liveEnum[@"eye"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLiveEye)];
    }
    if ([self.liveEnum[@"mouth"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLiveMouth)];
    }
    if ([self.liveEnum[@"headRight"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLiveYawRight)];
    }
    if ([self.liveEnum[@"headLeft"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLiveYawLeft)];
    }
    if ([self.liveEnum[@"headUpward"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLivePitchUp)];
    }
    if ([self.liveEnum[@"headDownward"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLivePitchDown)];
    }
    if ([self.liveEnum[@"headShake"] boolValue]) {
        [liveList addObject:@(FaceLivenessActionTypeLiveYaw)];
    }
    self.livenessArray = liveList;
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:self.livenessArray
                                                        order:self.order
                                             numberOfLiveness:self.numberOfLiveness];

    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:BFConditionTimeout_Liveness];

    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IDLFaceLivenessManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IDLFaceLivenessManager sharedInstance] reset];
}

- (void)onAppBecomeActive {
    [super onAppBecomeActive];
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:self.livenessArray
                                                        order:self.order
                                             numberOfLiveness:self.numberOfLiveness];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [[IDLFaceLivenessManager sharedInstance] reset];
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
    [IDLFaceLivenessManager sharedInstance].enableSound = self.enableSound;
    [[IDLFaceLivenessManager sharedInstance] livenessStratrgyWithImage:image
                                                           previewRect:self.previewRect
                                                            detectRect:self.detectRect
                                                     completionHandler:^(NSDictionary *images, LivenessRemindCode remindCode) {
        switch (remindCode) {
            case LivenessRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [weakSelf stopCapture];
                [weakSelf warningStatus:CommonStatus warning:@"非常好"];
                [self handleDetectFaceSucess:images orgImage:image];
                weakSelf.circleView.conditionStatusFit = true;
                [weakSelf singleActionSuccess:true];
                break;
            }
            case LivenessRemindCodePitchOutofDownRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微抬头" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodePitchOutofUpRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微低头" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeYawOutofLeftRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向右转头" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeYawOutofRightRange:
                [weakSelf warningStatus:PoseStatus warning:@"建议略微向左转头" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodePoorIllumination:
                [weakSelf warningStatus:CommonStatus warning:@"光线再亮些" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeNoFaceDetected:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeImageBlured:
                [weakSelf warningStatus:CommonStatus warning:@"请保持不动" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionLeftEye:
                [weakSelf warningStatus:occlusionStatus warning:@"左眼有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionRightEye:
                [weakSelf warningStatus:occlusionStatus warning:@"右眼有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionNose:
                [weakSelf warningStatus:occlusionStatus warning:@"鼻子有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionMouth:
                [weakSelf warningStatus:occlusionStatus warning:@"嘴巴有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionLeftContour:
                [weakSelf warningStatus:occlusionStatus warning:@"左脸颊有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionRightContour:
                [weakSelf warningStatus:occlusionStatus warning:@"右脸颊有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionChinCoutour:
                [weakSelf warningStatus:occlusionStatus warning:@"下颚有遮挡" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeTooClose:
                [weakSelf warningStatus:CommonStatus warning:@"手机拿远一点" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeTooFar:
                [weakSelf warningStatus:CommonStatus warning:@"手机拿近一点" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeBeyondPreviewFrame:
                [weakSelf warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveEye:
                [weakSelf warningStatus:CommonStatus warning:@"眨眨眼" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveMouth:
                [weakSelf warningStatus:CommonStatus warning:@"张张嘴" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYawRight:
                [weakSelf warningStatus:CommonStatus warning:@"向右缓慢转头" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYawLeft:
                [weakSelf warningStatus:CommonStatus warning:@"向左缓慢转头" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLivePitchUp:
                [weakSelf warningStatus:CommonStatus warning:@"缓慢抬头" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLivePitchDown:
                [weakSelf warningStatus:CommonStatus warning:@"缓慢低头" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYaw:
                [weakSelf warningStatus:CommonStatus warning:@"摇摇头" conditionMeet:true];
                [weakSelf singleActionSuccess:false];
                break;
            case LivenessRemindCodeSingleLivenessFinished:
            {
                [weakSelf warningStatus:CommonStatus warning:@"非常好" conditionMeet:true];
                [weakSelf singleActionSuccess:true];
            }
                break;
            case LivenessRemindCodeVerifyInitError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyDecryptError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyInfoFormatError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyExpired:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyMissRequiredInfo:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyInfoCheckError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyLocalFileError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyRemoteDataError:
                [weakSelf warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeTimeout: {
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
            case LivenessRemindCodeConditionMeet: {
                weakSelf.circleView.conditionStatusFit = true;
            }
                break;
            default:
                break;
        }
    }];
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning conditionMeet:(BOOL)meet
{
    [self warningStatus:status warning:warning];
    self.circleView.conditionStatusFit = meet;
}

- (void)handleDetectFaceSucess:(NSDictionary *)images orgImage:(UIImage *)image {
  
    if (images[@"bestImage"] == nil || [images[@"bestImage"] count] == 0) {
        return;
    }
    NSString* tempString = [images[@"bestImage"] lastObject];
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

- (void)dealloc
{
    
}
@end
