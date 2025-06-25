//
//  CMPLocalAuthenticationViewController.m
//  M3
//
//  Created by CRMO on 2019/1/17.
//

#import "CMPLocalAuthenticationViewController.h"
#import "CMPLocalAuthenticationView.h"
#import <CMPLib/UIImageView+WebCache.h>
#import "CMPCommonManager.h"
#import "M3LoginManager.h"
#import "CMPLocalAuthenticationTools.h"
#import "AppDelegate.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>

@interface CMPLocalAuthenticationViewController ()
@property (nonatomic, strong) CMPLocalAuthenticationView *authView;
@property (nonatomic, strong) NSArray<UIButton *> *buttomButtonArr;
@end

@implementation CMPLocalAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _authView = (CMPLocalAuthenticationView *)self.mainView;
    
    [self setupUI];
    
    if (![AppDelegate shareAppDelegate].aNeedShowGuidePagesView) {
        [self startAuth];
    }
}

- (void)setupUI {
    self.authView.avatarView.image = [UIImage imageNamed:@"guesture.bundle/ic_def_person.png"];
    [CMPCommonManager getUserHeadImageComplete:^(UIImage *image) {
        self.authView.avatarView.image = [self returnUserHeadImage:image];
    } cache:NO];
    self.authView.nameLabel.text = [CMPCore sharedInstance].currentUser.name;
    NSString *infoStr = nil;
    UIImage *startButtonImage = nil;
    CMPLocalAuthenticationType authType = [CMPLocalAuthenticationTools supportType];
    if (authType == CMPLocalAuthenticationTypeTouchID) {
        infoStr = SY_STRING(@"localauth_touchID_button");
        startButtonImage = [UIImage imageWithName:@"login_touchid" type:@"png" inBundle:@"CMPLogin"];
    } else if (authType == CMPLocalAuthenticationTypeFaceID) {
        infoStr = SY_STRING(@"localauth_faceID_button");
        startButtonImage = [UIImage imageWithName:@"login_faceid" type:@"png" inBundle:@"CMPLogin"];
    } else {
        // 如果开启了Face ID，然后去设置界面取消M3的Face ID授权，会走这段逻辑
        NSString *message = SY_STRING(@"faceid_unavailable");;
        UIAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil callback:nil];
        [aAlertView show];
    }
    self.authView.infoLabel.text = infoStr;
    [self.authView.startButton setImage:startButtonImage forState:UIControlStateNormal];
    [self.authView.startButton addTarget:self action:@selector(startAuth) forControlEvents:UIControlEventTouchUpInside];
    
    M3LoginManager *aLoginManager = [M3LoginManager sharedInstance];
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:2];
    
    if (aLoginManager.hasSetGesturePassword) {
        UIButton *leftButton = [CMPLocalAuthenticationView bottomButton];
        UIButton *rightButton = [CMPLocalAuthenticationView bottomButton];
        [rightButton setTitle:SY_STRING(@"localauth_gesture") forState:UIControlStateNormal];
        [leftButton setTitle:SY_STRING(@"GestureLogin_OtherWayLogin") forState:UIControlStateNormal];
        [buttons addObject:leftButton];
        [buttons addObject:rightButton];
        [rightButton addTarget:self action:@selector(showGestureView) forControlEvents:UIControlEventTouchUpInside];
        [leftButton addTarget:self action:@selector(showLoginView) forControlEvents:UIControlEventTouchUpInside];
        leftButton.enabled = NO;
        rightButton.enabled = NO;
    } else {
        UIButton *centerButton = [CMPLocalAuthenticationView bottomButton];
        [centerButton setTitle:SY_STRING(@"GestureLogin_OtherWayLogin") forState:UIControlStateNormal];
        [buttons addObject:centerButton];
        [centerButton addTarget:self action:@selector(showLoginView) forControlEvents:UIControlEventTouchUpInside];
        centerButton.enabled = NO;
    }
    self.buttomButtonArr = [buttons copy];
    [self.authView addButtomButtons:[buttons copy]];
}

- (void)startAuth {
    [CMPLocalAuthenticationTools verifyUsePassCode:NO Completion:^(BOOL result, CMPLocalAuthenticationType type, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.buttomButtonArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
                button.enabled = YES;
            }];
            
            if (result) {
                [self.authView cmp_showProgressHUDInView:self.authView];
            }
            
            if (type == CMPLocalAuthenticationTypeFaceID) {
                // FaceID验证完成后会播放一个动画
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.authDidFinish) {
                        self.authDidFinish(result, error);
                    }
                });
            } else {
                if (self.authDidFinish) {
                    self.authDidFinish(result, error);
                }
            }
        });
    }];
}

/**
 跳转到手势解锁页面
 */
- (void)showGestureView {
    if (_tapGestureView) {
        _tapGestureView();
    }
}

/**
 跳转到登录页
 */
- (void)showLoginView {
    if (_tapLoginView) {
        _tapLoginView();
    }
}

//返回裁剪好的头像
- (UIImage *)returnUserHeadImage:(UIImage *)image {
    CGFloat imageWidth = CGImageGetWidth(image.CGImage), imageHeight = CGImageGetHeight(image.CGImage);
    UIImage *img = nil;
    if (imageWidth != imageHeight) {
        CGFloat _w = (imageWidth<=imageHeight) ? imageWidth:imageHeight;
        CGRect r = CGRectMake(imageWidth/2-_w/2, imageHeight/2-_w/2, _w, _w);
        img = [UIImage imageWithClipImage:image inRect:r];
    }
    else {
        img = image;
    }
    return img;
}


@end
