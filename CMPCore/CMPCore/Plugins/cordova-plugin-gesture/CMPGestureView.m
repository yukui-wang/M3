//
//  CMPGestureView.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/13.
//
//

#import "CMPGestureView.h"
#import "DBGuestureLock.h"
#import <CMPLib/CMPFaceImageManager.h>
#import <CMPLib/CMPFaceView.h>
#import <CMPLib/CMPBaseViewController.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPFileManager.h>
#import "CMPLocalAuthenticationTools.h"
#import "CMPLocalAuthenticationState.h"
#import "CMPGestureHelper.h"
#import <CMPLib/CMPThemeManager.h>

#define kCircleColor_SelectNormal [[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.3]
#define kCircleColor_SelectDeep [UIColor cmp_colorWithName:@"theme-bgc"]

#define kAnimateTimeDuration 0.5

#define kDirection_Top CGRectMake(0, -[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kDirection_Bottom CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kDirection_Right CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kDirection_Left CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)


@interface CMPGestureViewVC : UIViewController

@end

@implementation CMPGestureViewVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)dealloc
{
    [super dealloc];
}

@end


@interface CMPGestureView()<DBGuestureLockDelegate,UIAlertViewDelegate> {
    UIButton *_skipButton;
    UIButton *_returnButton;
    
    CMPFaceView *_personImageView;
    UILabel *_titleLabel;
    UILabel *_userNameLabel;
    UILabel *_infoLabel;
    DBGuestureLock *_lock;
    UIButton *_reSetButton;//重新绘制
    UIButton *_unlockSettingButton; //开启设置打开指纹或人脸识别按钮
    
    UIButton *_forgetGesPwdButton;
    UIButton *_otherLoginButton;
    NSMutableArray *_smalCircularArray;
    BOOL _iphone4;
    NSInteger _pwdWrongCount;
    NSInteger _incorrectCount_Alert;
}

@property (nonatomic,strong)CMPBaseView *mainView;

@end

@implementation CMPGestureView

- (void)dealloc
{
    [_mainView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SY_RELEASE_SAFELY(_mainView);
    
    [_skipButton release];
    _skipButton = nil;
    [_returnButton release];
    _returnButton = nil;
    [_personImageView release];
    _personImageView = nil;
    
    [_titleLabel release];
    _titleLabel = nil;
    
    [_userNameLabel release];
    _userNameLabel = nil;
    
    [_infoLabel removeFromSuperview];
    [_infoLabel release];
    _infoLabel = nil;
    
    _lock.delegate = nil;
    [_lock removeFromSuperview];
    [_lock release];
    _lock = nil;
    
    [_reSetButton release];
    _reSetButton = nil;
    
    [_unlockSettingButton release];
    _unlockSettingButton = nil;
    
    [_forgetGesPwdButton release];
    _forgetGesPwdButton = nil;
    
    [_otherLoginButton release];
    _otherLoginButton = nil;
    
    [_correctGuestureLockPaswd release];
    _correctGuestureLockPaswd = nil;
    [_smalCircularArray release];
    _smalCircularArray = nil;
    
    
    self.imageUrl = nil;
    self.username = nil;
    self.userpassword = nil;
    [super dealloc];
}

- (CGRect)defaultFrame
{
    return [UIScreen mainScreen].bounds;
}

- (CGRect)mainFrame {
    CGFloat f = [UIView staticStatusBarHeight];
    CGRect r = [UIScreen mainScreen].bounds;
    return CGRectMake(0, f, r.size.width, r.size.height-f);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_GestureWillShow object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_WebviewResignKeyboard object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientionDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

        //OA-121976  M3-IOS端：系统IOS8.3，手势密码解锁，还未成功跳转至M3界面，就显示了小致图标
        //小致图标 UIWindowLevelAlert-10, 目前是先显示小致 后关闭手势密码
        self.windowLevel = UIWindowLevelAlert + 10;
        self.frame = [self defaultFrame];
        self.backgroundColor = [UIColor whiteColor];
        _iphone4 = self.frame.size.height <= 480;
        _incorrectCount_Alert = 0;
        CMPGestureViewVC *vc =  [[CMPGestureViewVC alloc] init];
        self.rootViewController = vc;
        vc.view.backgroundColor = [UIColor clearColor];
        [vc.view addSubview:self.mainView];
        SY_RELEASE_SAFELY(vc);
    }
    return self;
}

-(CMPBaseView *)mainView {
    if (!_mainView) {
        _mainView = [[CMPBaseView alloc]init];
        _mainView.frame = self.bounds;
        _mainView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    }
    return _mainView;
}

- (void)orientionDidChange:(NSNotification *)notification {
    self.mainView.cmp_width = [UIWindow mainScreenSize].width;
    self.mainView.cmp_height = [UIWindow mainScreenSize].height;
    [self resizeViews];
}

-(void)showLoading
{
    [self.mainView showLoadingView];
}

-(void)hideLoading
{
    [self.mainView hideLoadingView];
}


-(void)show
{
    self.hidden = NO;
}

-(void)close
{
    [self hideLoading];
    self.hidden = YES;
}

-(void)showAnimateFromDirection:(Direction)direction completion:(void(^)(void))completionBlock
{
    switch (direction) {
            
        case Direction_Top:
            self.frame = kDirection_Top;
            break;
        case Direction_Bottom:
            self.frame = kDirection_Bottom;
            break;
        case Direction_Left:
            self.frame = kDirection_Left;
            break;
        case Direction_Right:
            self.frame = kDirection_Right;
            break;
            
        default:
            break;
    }
    self.hidden = NO;
    if (direction == Direction_None) {
        self.frame = [self defaultFrame];;
        if (completionBlock) {
            completionBlock();
        }
    }
    else {
        [UIView animateWithDuration:kAnimateTimeDuration animations:^{
            self.frame = [self defaultFrame];;
        } completion:^(BOOL finished) {
            if (finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)closeAnimateToDirection:(Direction)direction completion:(void(^)(void))completionBlock
{
    if (direction == Direction_None) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    [UIView animateWithDuration:kAnimateTimeDuration animations:^{
        
        switch (direction) {
                
            case Direction_Top:
                self.frame = kDirection_Top;
                break;
            case Direction_Bottom:
                self.frame = kDirection_Bottom;
                break;
            case Direction_Left:
                self.frame = kDirection_Left;
                break;
            case Direction_Right:
                self.frame = kDirection_Right;
                break;
                
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
        [self close];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)loadViewsWithType:(CMPGestureViewType)type
{
    _viewType = type;
    if (type == CMPGestureViewType_Set) {
        [self setupForSetGesture];
    }
    else if (type == CMPGestureViewType_Verify){
        [self setupForVerifyGesture];
    }
}

- (void)resizeViews {
    if (_viewType == CMPGestureViewType_Set) {
        [self setupForSetGesture];
    }
    else if (_viewType == CMPGestureViewType_Verify){
        [self setupForVerifyGesture];
    }
}

- (void)setupForSetGesture {
    [self.mainView removeAllSubviews];
    
    //设置密码
    if (self.showLeftArrow) {
        if (!_returnButton) {
            _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 50, 26)];
            [_returnButton setImage:[[UIImage imageNamed:@"guesture.bundle/return.png"] cmp_imageWithTintColor:kCircleColor_SelectDeep] forState:UIControlStateNormal];
            [_returnButton addTarget:self action:@selector(returnButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
         [self.mainView addSubview:_returnButton];
        _returnButton.frame = CGRectMake(0, 40, 50, 26);
    }
    else {
        if (!_skipButton) {
            UIColor *color = kCircleColor_SelectDeep;
            _skipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.width - 52 - 15, 44, 52, 24)];
            [_skipButton setTitle:SY_STRING(@"GestureLogin_Skip_Confirm") forState:UIControlStateNormal];
            _skipButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            [_skipButton setTitleColor:color forState:UIControlStateNormal];
            [_skipButton addTarget:self action:@selector(skipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            _skipButton.layer.cornerRadius = 12;
            _skipButton.layer.borderWidth = 1;
            _skipButton.layer.borderColor = color.CGColor;
        }
        [self.mainView addSubview:_skipButton];
        _skipButton.frame = CGRectMake(self.mainView.width - 52 - 15, 44, 52, 24);
    }
    
    CGFloat y = 78;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, 25)];
        _titleLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = font;
        _titleLabel.text = SY_STRING(@"GestureLogin_Titile_Set"); //for test
    }
    [self.mainView addSubview:_titleLabel];
    _titleLabel.frame = CGRectMake(0, y, self.mainView.width, 25);
    
    y += _titleLabel.frame.size.height;
    y += _iphone4?13: 48;
    if (!_smalCircularArray) {
        _smalCircularArray = [[NSMutableArray alloc] init];
    }
    
    if (_smalCircularArray.count == 0) {
        for (NSInteger t = 0; t<9; t++) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
            view.layer.cornerRadius = 4;
            CGFloat beginx = (self.mainView.width -8*3-8*2)/2;
            CGFloat beginy = y;
            NSInteger xc = t%3;
            NSInteger yc = t/3;
            
            CGFloat vx = beginx+(8+8)*xc;
            CGFloat vy = beginy +(8+8)*yc;
            [view setFrame:CGRectMake(vx, vy, 8, 8)];
            [self.mainView addSubview:view];
            [_smalCircularArray addObject:view];
            [view release];
            view = nil;
        }
    } else {
        [_smalCircularArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            view.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
            view.layer.cornerRadius = 4;
            CGFloat beginx = (self.mainView.width -8*3-8*2)/2;
            CGFloat beginy = y;
            NSInteger xc = idx%3;
            NSInteger yc = idx/3;
            
            CGFloat vx = beginx+(8+8)*xc;
            CGFloat vy = beginy +(8+8)*yc;
            [view setFrame:CGRectMake(vx, vy, 8, 8)];
            [self.mainView addSubview:view];
        }];
    }
    
    y += 8*3+8*2;
    y += _iphone4 ? 13 : 14;
    
    UIFont *_infoLabelFont = [UIFont systemFontOfSize:14];
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, 20)];
        _infoLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = _infoLabelFont;
        _infoLabel.text = SY_STRING(@"GestureLogin_DrawUnlock");
    }
    [self.mainView addSubview:_infoLabel];
    _infoLabel.frame = CGRectMake(0, y, self.mainView.width, 20);
    
    y += _infoLabel.frame.size.height;
    y += 14;
    
    if (!_reSetButton) {
        _reSetButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.width/2-100, y, 200, 22)];
        [_reSetButton setTitle:SY_STRING(@"GestureLogin_ResetGesture") forState:UIControlStateNormal];
        _reSetButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_reSetButton setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
        [_reSetButton addTarget:self action:@selector(reSetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _reSetButton.hidden = YES;
        _reSetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self.mainView addSubview:_reSetButton];
    _reSetButton.frame = CGRectMake(self.mainView.width/2-100, y, 200, 22);
    
    y += _reSetButton.frame.size.height;
    
    NSString *firstTimeSetupPassword = nil;
    if (_lock) {
        firstTimeSetupPassword = _lock.firstTimeSetupPassword;
        [_lock removeFromSuperview];
        [_lock release];
    }
    _lock = [[DBGuestureLock alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, self.mainView.height-y-40-30)];
    _lock.firstTimeSetupPassword = firstTimeSetupPassword;
    _lock.delegate = self;
    _lock.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self.mainView addSubview:_lock];
    _lock.correctGuestureLockPaswd = self.correctGuestureLockPaswd;
    
    y = self.mainView.height - 40 - 30;
    
    
    if ([CMPCore sharedInstance].serverIsLaterV7_1 && [CMPLocalAuthenticationTools supportType] != CMPLocalAuthenticationTypeNone && !self.showLeftArrow) {
        NSString *buttonTitle = [NSString string];
        CMPLocalAuthenticationType supportType = [CMPLocalAuthenticationTools supportType];
        if (supportType == CMPLocalAuthenticationTypeFaceID) {
            buttonTitle = SY_STRING(@"localauth_openFaceToUnlock_button");
        } else if (supportType == CMPLocalAuthenticationTypeTouchID){
            buttonTitle = SY_STRING(@"localauth_openFingerprintToUnlock_button");
        }
        CGSize textSize =  [buttonTitle sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]}];
        if (!_unlockSettingButton) {
            _unlockSettingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.width/2-textSize.width*0.5-20, y,textSize.width + 40, 40)];
            _unlockSettingButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            [_unlockSettingButton setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
            [_unlockSettingButton setBackgroundColor:kCircleColor_SelectDeep];
            _unlockSettingButton.layer.cornerRadius = 20;
            _unlockSettingButton.layer.shadowColor = [kCircleColor_SelectDeep colorWithAlphaComponent:0.5].CGColor;
            _unlockSettingButton.layer.shadowOffset = CGSizeMake(0,0);
            _unlockSettingButton.layer.shadowOpacity = 1;
            _unlockSettingButton.layer.shadowRadius = 10;
            
            if (supportType == CMPLocalAuthenticationTypeFaceID) {
                 [_unlockSettingButton setTitle:SY_STRING(@"localauth_openFaceToUnlock_button") forState:UIControlStateNormal];
                 [_unlockSettingButton addTarget:self action:@selector(openSystemUnlock:) forControlEvents:UIControlEventTouchUpInside];
            } else if (supportType == CMPLocalAuthenticationTypeTouchID) {
                [_unlockSettingButton setTitle:SY_STRING(@"localauth_openFingerprintToUnlock_button") forState:UIControlStateNormal];
                [_unlockSettingButton addTarget:self action:@selector(openSystemUnlock:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self.mainView addSubview:_unlockSettingButton];
        _unlockSettingButton.frame = CGRectMake(self.mainView.width/2-textSize.width*0.5-20, y,textSize.width + 40, 40);
    }
    
}

//开启解锁
-(void)openSystemUnlock:(UIButton *)button {
    [CMPLocalAuthenticationTools verifyWithFallbackTitle:@"" usePassCode:YES fallbackAction:nil completion:^(BOOL result, CMPLocalAuthenticationType type, NSError * _Nullable error) {
        CMPLocalAuthenticationType supportType = [CMPLocalAuthenticationTools supportType];
        if (result) {
            NSString *jasonStr = nil;
            if (supportType == CMPLocalAuthenticationTypeFaceID) {
                jasonStr = @"{\"faceID\":{\"login\":1},\"touchID\":{\"login\":0}}";
            }else if (supportType == CMPLocalAuthenticationTypeTouchID) {
                jasonStr = @"{\"faceID\":{\"login\":0},\"touchID\":{\"login\":1}}";
            }
            
            [CMPLocalAuthenticationState updateWithJson:jasonStr];
            [self dispatchAsyncToMain:^{
                [self skipButtonAction:nil];
            }];
        }else{
            //是否需要隐藏【开启人脸解锁】按钮
        }
    }];
}

//返回裁剪好的头像
- (UIImage *)returnUserHeadImage:(UIImage *)image{
    CGFloat imageWidth = CGImageGetWidth(image.CGImage), imageHeight = CGImageGetHeight(image.CGImage);
    UIImage *img = nil;
    if (imageWidth !=imageHeight ) {
        CGFloat _w = (imageWidth<=imageHeight) ? imageWidth:imageHeight;
        CGRect r = CGRectMake(imageWidth/2-_w/2, imageHeight/2-_w/2, _w, _w);
        img = [UIImage imageWithClipImage:image inRect:r];
    }
    else {
        img = image;
    }
    return img;
}

//获取本地头像缓存
- (UIImage *)getLocalCacheHeadImage{
    NSString *name = [NSString stringWithFormat:@"%@.png",[CMPCore sharedInstance].userID];
    NSString *localPath = [[CMPFileManager createFullPath:kFaceImagePath] stringByAppendingPathComponent:name];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        UIImage *img = [[CMPFaceImageManager sharedInstance] imageWithPath:localPath];
        return img;
    }
    return nil;
}

- (void)setupForVerifyGesture
{
    [self.mainView removeAllSubviews];
    
    //验证密码
    CGFloat y = 0;
    if (_iphone4) {
        y = 40;
    } else if (IS_IPHONE_X_UNIVERSAL) {
        y = 70 + 44;
    } else {
        y = 70 + 20;
    }
    
    CGFloat w = _iphone4?80:90;
    if (!_personImageView) {
        CGFloat w = _iphone4?80:90;
        _personImageView = [[CMPFaceView alloc] init];
        _personImageView.frame = CGRectMake(self.mainView.width/2 - w/2, y, w, w);
        _personImageView.layer.borderWidth = kMacro_UserHeadIconBoarderWidth;
        _personImageView.layer.borderColor = [UIColor cmp_colorWithName:@"cmp-line"].CGColor;
        _personImageView.layer.cornerRadius = w/2;
        _personImageView.layer.masksToBounds = YES;
        
        if ([self getLocalCacheHeadImage]) {
            _personImageView.imageView.image = [self returnUserHeadImage:[self getLocalCacheHeadImage]];
        }
        
        //用上面的方法获取的图片太模糊
        [CMPCommonManager getUserHeadImageComplete:^(UIImage *image) {
            //截取图片
            _personImageView.imageView.image = [self returnUserHeadImage:image];
        } cache:NO];
    }
    [self.mainView addSubview:_personImageView];
    _personImageView.frame = CGRectMake(self.mainView.width/2 - w/2, y, w, w);
    
    y += _personImageView.frame.size.height +15;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSInteger fontH = [font lineHeight]+1;
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, fontH)];
        _userNameLabel.textColor = [UIColor cmp_colorWithName:@"main-fc"];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.font = font;
        _userNameLabel.text = self.username;
    }
    [self.mainView addSubview:_userNameLabel];
    _userNameLabel.frame = CGRectMake(0, y, self.mainView.width, fontH);
    
    y += fontH+15;
    
    font = [UIFont systemFontOfSize:14.0f];
    fontH = [font lineHeight]+1;
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, fontH)];
        _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = font;
    }
    [self.mainView addSubview:_infoLabel];
    _infoLabel.frame = CGRectMake(0, y, self.mainView.width, fontH);
    y += fontH;
    
    //    y = _iphone4?210:y;
    y = y-30;
    if (_lock) {
        [_lock removeFromSuperview];
        [_lock release];
    }
    _lock = [[DBGuestureLock alloc] initWithFrame:CGRectMake(0, y, self.mainView.width, self.mainView.height-y-40)];
    _lock.delegate = self;
    _lock.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    [self.mainView insertSubview:_lock atIndex:0];
    _lock.correctGuestureLockPaswd = self.correctGuestureLockPaswd;
    
    y = self.mainView.height - 40 - 20;
    if (IS_IPHONE_X_UNIVERSAL) {
        y -= 34;
    }
    if (!_forgetGesPwdButton) {
        _forgetGesPwdButton = [[UIButton alloc] initWithFrame:CGRectMake(30, y, 110, 20)];
        [_forgetGesPwdButton setTitle:SY_STRING(@"GestureLogin_ForgetGesture") forState:UIControlStateNormal];
        _forgetGesPwdButton.titleLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightLight];
        [_forgetGesPwdButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc1"] forState:UIControlStateNormal];
        [_forgetGesPwdButton addTarget:self action:@selector(forgetGesPwdButton:) forControlEvents:UIControlEventTouchUpInside];
    }
     [self.mainView addSubview:_forgetGesPwdButton];
    _forgetGesPwdButton.frame = CGRectMake(30, y, 110, 20);
    
    if (!_otherLoginButton) {
        _otherLoginButton = [[UIButton alloc] initWithFrame:CGRectMake( self.mainView.width - 130, y, 110, 20)];
        [_otherLoginButton setTitle:SY_STRING(@"GestureLogin_OtherWayLogin") forState:UIControlStateNormal];
        _otherLoginButton.titleLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightLight];
        [_otherLoginButton setTitleColor:[UIColor cmp_colorWithName:@"sup-fc1"]  forState:UIControlStateNormal];
        [_otherLoginButton addTarget:self action:@selector(otherLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.mainView addSubview:_otherLoginButton];
    _otherLoginButton.frame = CGRectMake( self.mainView.width - 130, y, 110, 20);
    [self.mainView bringSubviewToFront:_infoLabel];
}

- (void)returnButtonAction:(id)sender
{
    if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewReturn:)]) {
        [self.gestureDelegate gestureViewReturn:self];
    }
}

- (void)skipButtonAction:(id)sender
{
    if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewSkip:)]) {
        [self.gestureDelegate gestureViewSkip:self];
    }
}

- (void)reSetButtonAction:(id)sender
{
    _lock.firstTimeSetupPassword = nil;
    _infoLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    _infoLabel.text = SY_STRING(@"GestureLogin_DrawUnlock");
}

- (void)forgetGesPwdButton:(id)sender
{
    if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewForgetPswd: inputPassword:)]) {
        [self.gestureDelegate gestureViewForgetPswd:self inputPassword:@""];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:SY_STRING(@"GestureLogin_Inputpassword") message:message delegate:self cancelButtonTitle:nil otherButtonTitles:SY_STRING(@"common_cancel"),SY_STRING(@"common_ok"), nil];
    alertview.alertViewStyle =  UIAlertViewStyleSecureTextInput;
    alertview.tag = 100;
    [alertview show];
    [alertview release];
    alertview = nil;
}

- (void)otherLoginButton:(id)sender
{
    if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewOtherVerify:)]) {
        [self.gestureDelegate gestureViewOtherVerify:self];
    }
}

- (void)clearSmalCircularArray
{
    for (UIView *view in _smalCircularArray) {
        view.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
    }
}

#pragma mark - DBGuestureLockDelegate

- (void)guestureLock:(DBGuestureLock *)lock didSetPassword:(NSString *)password {
    // password 需要加密  // todo
    //NSLog(@"Password set: %@", password);
    
    if (_viewType == CMPGestureViewType_Set) {
        _reSetButton.hidden = NO;
        [self clearSmalCircularArray];
        if (lock.firstTimeSetupPassword == nil) {
            if (password.length<4) {
                //至少连续绘制4个点
                _infoLabel.text = SY_STRING(@"GestureLogin_Input_MoreThan4");
                _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
            }
            else {
                lock.firstTimeSetupPassword = password;
                _infoLabel.text = SY_STRING(@"GestureLogin_Input_Again");
                _infoLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
            }
        }
        else {
            if (password.length<4) {
                //至少连续绘制4个点
                _infoLabel.text = SY_STRING(@"GestureLogin_Input_MoreThan4");
                _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
            }
            else if ([lock.firstTimeSetupPassword isEqualToString:password]) {
                // 设置密码成功
                _infoLabel.text = SY_STRING(@"GestureLogin_Set_Success");
                _infoLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
                if ([self.gestureDelegate  respondsToSelector:@selector(gestureView:didSetPassword:)]) {
                    [self.gestureDelegate gestureView:self didSetPassword:password];
                }
            }
            else {
                // 与首次绘制不一致，请再次绘制
                _infoLabel.text = SY_STRING(@"GestureLogin_Input_SameToPre");
                _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
            }
        }
    }
}


- (void)guestureLock:(DBGuestureLock *)lock didGetCorrectPswd:(NSString *)password {
    //NSLog(@"Password correct: %@", password);
    NSLog(@"login success");
    _infoLabel.text = SY_STRING(@"GestureLogin_Input_Right");
    _infoLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc1"];
    if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewDidGetCorrectPswd:)]) {
        [self.gestureDelegate gestureViewDidGetCorrectPswd:self];
    }
}

- (void)guestureLock:(DBGuestureLock *)lock didGetIncorrectPswd:(NSString *)password  incorrectCount:(NSInteger)count{
    
    if (count >= kIncorrectCount_Max) {
        if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewDidGetIncorrectPswd:)]) {
            [self.gestureDelegate gestureViewDidGetIncorrectPswd:self];
        }
    }
    else {
        if (password.length<4) {
            //至少连续绘制4个点
            _infoLabel.text = SY_STRING(@"GestureLogin_Input_MoreThan4");
            _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
        }else {
            _infoLabel.text = [NSString stringWithFormat: SY_STRING(@"GestureLogin_Input_WrongCountTip"),(long)(kIncorrectCount_Max-count)];
            _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
        }
    }
}
-(void)guestureLock:(DBGuestureLock *)lock passwordAddPswd:(NSString*)password
{
    if (_viewType == CMPGestureViewType_Set) {
        NSInteger t = password.integerValue-1;
        UIView *view = [_smalCircularArray objectAtIndex:t];
        view.backgroundColor = kCircleColor_SelectNormal;
    }
}


#pragma mark color

-(UIColor *)colorOfButtonCircleStrokeOnState:(DBButtonState)buttonState
{
    //外线
    UIColor *color = [UIColor cmp_colorWithName:@"cmp-line"];
    switch (buttonState) {
        case DBButtonStateNormal:
            color = [UIColor cmp_colorWithName:@"cmp-line"];
            break;
        case DBButtonStateSelected:
            color = kCircleColor_SelectDeep;
            break;
        case DBButtonStateIncorrect:
            color = [UIColor cmp_colorWithName:@"hl-bgc3"];
            break;
        default:
            break;
    }
    return color;
}
-(UIColor *)colorOfButtonSmallCircleStrokeOnState:(DBButtonState)buttonState{
    //小圆环颜色
    //外线
    UIColor *color = [UIColor cmp_colorWithName:@"input-bg"];
    switch (buttonState) {
        case DBButtonStateNormal:
            break;
        case DBButtonStateSelected:
            color = kCircleColor_SelectNormal;
            break;
        case DBButtonStateIncorrect:
            color = [UIColor cmp_colorWithName:@"errormask-bgc"];
            break;
        default:
            break;
    }
    return color;
}
-(UIColor *)colorForFillingButtonCircleOnState:(DBButtonState)buttonState
{
    //外大环颜色

    UIColor *color = [UIColor cmp_colorWithName:@"input-bg"];
    switch (buttonState) {
        case DBButtonStateNormal:
            break;
        case DBButtonStateSelected:
            color = [UIColor cmp_colorWithName:@"white-bg1"];
            break;
        case DBButtonStateIncorrect:
            color = [UIColor cmp_colorWithName:@"white-bg1"];
            break;
        default:
            break;
    }
    return color;
    
}
-(UIColor *)colorOfButtonCircleCenterPointOnState:(DBButtonState)buttonState
{
    // 内圆颜色 圆心
    UIColor *color = [UIColor cmp_colorWithName:@"input-bg"];
    switch (buttonState) {
        case DBButtonStateNormal:
            break;
        case DBButtonStateSelected:
            color = kCircleColor_SelectDeep;
            break;
        case DBButtonStateIncorrect:
            color = [UIColor cmp_colorWithName:@"hl-bgc3"];
            break;
        default:
            break;
    }
    return color;
    
}
-(UIColor *)lineColorOfGuestureOnState:(DBButtonState)buttonState
{
    //  九宫格之间的连线
    UIColor *color = [UIColor cmp_colorWithName:@"white-bg1"];
    switch (buttonState) {
        case DBButtonStateNormal:
            break;
        case DBButtonStateSelected:
            color = kCircleColor_SelectDeep;
            break;
        case DBButtonStateIncorrect:
            color = [UIColor cmp_colorWithName:@"hl-bgc3"];
            break;
        default:
            break;
    }
    return color;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100 && buttonIndex == 1) {
        UITextField *filed = [alertView textFieldAtIndex:0];
        NSString *password = [filed text];
        if ([self.userpassword isEqualToString:password]) {
            if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewForgetPswd: inputPassword:)]) {
                [self.gestureDelegate gestureViewForgetPswd:self inputPassword:password];
            }
        }
        else {
            _incorrectCount_Alert ++;
            if (_incorrectCount_Alert >=kIncorrectCount_Max) {
                if ([self.gestureDelegate  respondsToSelector:@selector(gestureViewDidGetIncorrectPswd:)]) {
                    [self.gestureDelegate gestureViewDidGetIncorrectPswd:self];
                }
                return;
            }
            NSString *errorInfo = [NSString stringWithFormat: SY_STRING(@"GestureLogin_Input_WrongCountTip"),(long)(kIncorrectCount_Max-_incorrectCount_Alert)];
            _infoLabel.text = errorInfo;
            _infoLabel.textColor = [UIColor cmp_colorWithName:@"hl-fc3"];
            [self showAlertWithMessage:errorInfo];
        }
    }
}

// todo需要对设置过来的密码解密
- (void)setCorrectGuestureLockPaswd:(NSString *)correctGuestureLockPaswd
{
    [_correctGuestureLockPaswd release];
    _correctGuestureLockPaswd = [correctGuestureLockPaswd copy];
}

@end
