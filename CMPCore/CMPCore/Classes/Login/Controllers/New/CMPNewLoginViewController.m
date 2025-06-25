//
//  CMPNewLoginViewController.m
//  M3
//
//  Created by wujiansheng on 2020/4/24.
//

#define kLoginName @"kLoginName"
#define kLoginPWD @"kLoginPWD"
#define kLoginVerificationCode @"kLoginVerificationCode"
#define kOrgLoginDomain @"kOrgLoginDomain"
#define kOrgLoginCode @"kOrgLoginCode"

#define kCloudLoginPlistName @"CloudLogin"
#define kCloudLoginKey @"kCloudLoginKey"
#define kCloudLoginDefaultDevKey @"dev"


#import "CMPNewLoginViewController.h"
#import "CMPNewLoginView.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPForgotPasswordViewController.h"
#import "SyScanViewController.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPServerListController.h"
#import "CMPServerEditController.h"
#import "TrustdoLoginManager.h"
#import <CMPLib/CMPCAAnimation.h>
#import <CMPLib/CMPDataRequest.h>
#import "CMPCheckEnvRequest.h"
#import "CMPCheckEnvResponse.h"
#import "CMPMigrateWebDataViewController.h"
#import "CMPCheckUpdateManager.h"
#import "CMPCloudLoginHelper.h"
#import "CMPPrivacyProtocolWebViewController.h"
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import <CMPLib/SDWebImageDownloader.h>
#import <CMPLib/SDWebImageManager.h>
#import <CMPLib/CMPActionSheet.h>
#import <CMPLib/GTMUtil.h>
#import "CMPLoginView.h"
#import <CMPLib/CMPDownloadAttachmentTool.h>
#import "CMPBackgroundRequestsManager.h"
#import "CMPCookieTool.h"
#import "CMPConstant_Ext.h"
#import "CMPCommonManager.h"
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/KSLogManager.h>
#import <CMPLib/KSActionSheetView.h>
#import "CMPAreaCodeViewController.h"
#import "CMPNewPhoneCodeLoginProvider.h"
#import <CMPLib/CMPCommonTool.h>
#import "CMPSMSGraphVerView.h"
#import <CMPVpn/CMPVpn.h>
#import <CMPLib/CMPServerVersionUtils.h>
#import "CMPCustomManager.h"
#import "CMPMsgQuickHandler.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPVerifyCodeViewController.h"

@interface CMPNewLoginViewController ()<SyScanViewControllerDelegate,CMPDataProviderDelegate,CMPNewLoginViewDelegate> {
    CMPNewLoginView *_loginView;
    BOOL _canMokeyLogin;
}
@property (nonatomic, assign) NSInteger currentScanType;
@property (nonatomic, copy) NSString *orgLoginRequestId;
@property (nonatomic, copy) NSString *orgLoginCheckEnvId;
@property (nonatomic, copy) NSString *canSMSLoginCheckEnvId;
@property (nonatomic, strong) CMPCloudLoginHelper *cloudLoginHelper;
@property (nonatomic, strong) CMPNewPhoneCodeLoginProvider *phoneCodeLoginProvider;
@property (nonatomic, strong) NSString *verificationUrl;
/* 账号手机号登录失败错误记录 */
@property (nonatomic, strong) NSError *loginFialedError;
@property (nonatomic, strong) CMPLoginViewStyle *style;
@property (nonatomic, strong) CMPDownloadAttachmentTool *downloadAttachmentTool;
@property (copy, nonatomic) NSString *lastServerID;

@end

@implementation CMPNewLoginViewController
@synthesize style = _style;

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginView = (CMPNewLoginView *)self.mainView;
    _loginView.backgroundColor = [UIColor cmp_colorWithName:@"white-bg1"];
    self.navigationController.navigationBarHidden = YES;
    self.allowRotation = NO;
    
    [self addButtonActions];
    [self addNotis];
    
    [CMPMigrateWebDataViewController shareInstance];
    [self updateDatabaseOldAccountAlreadyPopuUppPrivacypPage];
    [self setupBaseInfo];
    
    [_loginView.selectBtn setSelected:NO];
    
    [KSLogManager registerOnView:self.view delegate:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _loginView.userInteractionEnabled = NO;
    [self addMokeyNoti];
    [self updateLoginStyle:self.style];
    
    // 如果有单位ID更新
    if (![NSString isNull:[CMPCore sharedInstance].currentUser.accountID]) {
        [self requestBackground];
    }
    NSString *currentServerID = [CMPCore sharedInstance].serverID;
    // 只有切换了服务器才更新历史账号密码，如果从服务器页面点击返回不更新
    BOOL switched = NO;
    if ([NSString isNotNull:currentServerID] &&
        ![self.lastServerID isEqualToString:currentServerID]) {
        NSLog(@"zl---[%s]切换了服务器，隐藏验证码", __FUNCTION__);
        NSLog(@"showHistoryUsername:1");
        [self showHistoryUsername];
        [self hideVerification];
        [self useMokeyTag];
        switched = YES;
    } else if ([NSString isNull:self.lastServerID]) {
        // self.lastServerID为空，说明用户退出登录返回登录页，回填历史手机号
        // 解决偶发出现掉线返回登录页，currentServerID为空导致历史手机号不回填问题
        NSLog(@"showHistoryUsername:2");
        [self showHistoryUsername];
    }
    else {
        NSLog(@"showHistoryUsername:3");
    }
    //如果当前设置的服务器为0个，就显示提示信息view
    if (CMPCore.sharedInstance.loginDBProvider.countOfServer == 0) {
        [_loginView showServertipsView];
        [UIDevice switchNewOrientationIncludingIPad:UIInterfaceOrientationPortrait];
        [_loginView setupPrivacyInfoHidden:NO];
        [_loginView hiddenSMSLoginButton:YES];
    }
    else {
        [_loginView setupPrivacyInfoHidden:[[CMPCore sharedInstance] isByPopUpPrivacyProtocolPage]];
        
        // 切换了服务器后 校验是否展示短信验证码登录
//        if (switched) {
            BOOL versionSupport = [CMPServerVersionUtils serverIsLaterV8_1SP1];
            if (versionSupport){
                __weak typeof(_loginView) weakLoginView = _loginView;
                [self.phoneCodeLoginProvider phoneCodeLoginWithCanUserPhoneLogin:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
                    NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
                    NSNumber *code = dict[@"code"];
                    if (code.intValue == 0) {
                        [weakLoginView hiddenSMSLoginButton:NO];
                    }else {
                        [weakLoginView hiddenSMSLoginButton:YES];
                    }
                } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
                    [weakLoginView hiddenSMSLoginButton:YES];
                }];
            }else{
                [_loginView hiddenSMSLoginButton:YES];
            }
//        }
//        [self checkServiceEnv];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _loginView.userInteractionEnabled = YES;
    if ([NSString isNotNull:self.errorMessage] && ![[M3LoginManager sharedInstance] needDeviceBind:self.error]) {
        if ([self.errorMessage isEqualToString:kNotificationMessage_MokeyAutoLogin]) {
            [self loginBtnAction];
        } else {
            __weak typeof(self) wSelf = self;
            BOOL canContinue = [self _canContinueWithNewHandleLoginErr:self.error result:^(NSInteger code, NSString *msg) {
                if (code == CMPLoginErrorDeviceBindedException){
                    NSString *aUDID = [SvUDIDTools UDID];
                    NSString *aPartUdid = (aUDID.length >= 8) ? [aUDID substringWithRange:NSMakeRange(aUDID.length-8, 8)] : aUDID;
                    [wSelf showAlertWithTitle:msg message:[NSString stringWithFormat:@"%@: ******%@",SY_STRING(@"login_current_bind_device_numb"),aPartUdid] cancelTitle:SY_STRING(@"common_confirm")];
                } else {
                    [wSelf showAlertMessage:self.error.domain];
                }
            }];
            if (canContinue) {
                [self showAlertMessage:self.errorMessage];
            }
            self.errorMessage = nil;
        }
    }
    NSString *verificationCodeUrl = [[M3LoginManager sharedInstance] verificationCodeUrl:self.error];
    if (!verificationCodeUrl.length && [CMPCore sharedInstance].firstShowValidateCode) {
        //默认请求验证码
        verificationCodeUrl = @"/seeyon/verifyCodeImage.jpg";
    }
    if ([NSString isNotNull:verificationCodeUrl]) { // 自动登录，需要验证码回到登录页，默认展示验证码
        if (self.error || !_loginView.userLoginView.imgVerificationImgBtn.imageView.image) {
            [self showVerificationWithUrl:verificationCodeUrl];
        }
    } else { // 到登录页，如果不需要验证码，清空cookie
        [CMPCookieTool clearCookiesAndCache];
        self.verificationUrl = nil;
    }
    self.error = nil;
    
    [CMPMsgQuickHandler shareInstance].enterRoute = 1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.lastServerID = CMPCore.sharedInstance.serverID;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeMokeyNoti];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateLoginStyle:self.style];
}

- (void)setupBaseInfo {
    if ([self setupSSOInfo]) {
        return;
    }
    NSString *orgCode = [CMPCore sharedInstance].currentServer.orgCode;
    CMPLoginAccountModelLoginType loginType = CMPCore.sharedInstance.currentUser.loginType;

    if ([NSString isNotNull:orgCode]) {
        [_loginView setLoginMode:CMPNewLoginViewModeOrg delegate:self];
    }
    else if(loginType == CMPLoginAccountModelLoginTypeMokey) {
        [_loginView setLoginMode:CMPNewLoginViewModeMokey delegate:self];
    }
    else if(loginType == CMPLoginAccountModelLoginTypeSMS) {
        //V5-56396【双因子认证】IOS端，双因子角色人员退出登录之后总是返回手机号登录方式页面非双因子角色人员正常返回账号密码登陆页面
        CMPLoginAccountExtraDataModel *extraDataModel = [CMPCore sharedInstance].currentUser.extraDataModel;
        if (extraDataModel.loginModeSubType == CMPLoginModeSubType_MutilVerify) {
            NSString *loginInfoStr = extraDataModel.loginInfoLegency ? : @"";
            NSDictionary *loginInfoDic = [loginInfoStr JSONValue];
            if (loginInfoDic) {
                NSString *loginName = [GTMUtil decrypt:loginInfoDic[@"username"] ? : @""];
                _loginView.userLoginView.accountTF.text = loginName;
            }
            [_loginView setLoginMode:CMPNewLoginViewModeLegacy delegate:self];
        } else {
            [_loginView setLoginMode:CMPNewLoginViewModeSMS delegate:self];
        }

    }
    else {
        NSDictionary *orgInfo = [[CMPCore sharedInstance].loginDBProvider findOrgLoginInfo];
        if (orgInfo) {
            NSString *orgCode = [GTMUtil decrypt:orgInfo[@"orgCode"]];
            NSString *loginName = [GTMUtil decrypt:orgInfo[@"loginName"]];
            _loginView.orgLoginView.orgTF.text = orgCode;
            _loginView.orgLoginView.accountTF.text = loginName;
        }
        [_loginView setLoginMode:CMPNewLoginViewModeLegacy delegate:self];
    }
}
/**
 自动填充历史用户名密码
 企业账号登录：
 保存服务器地址，当前服务器有保存的账号，更新输入框账号，如果没有保存的账号，保留用户之前输入。
 手机号登录：
 与服务器地址没有关系，展示上一次输入的手机号。每次点击登录保存手机号，杀进程、退出登录自动填充。
 */
- (void)showHistoryUsername {
    
    CMPNewLoginViewMode loginMode = _loginView.loginMode;
    CMPLoginAccountModelLoginType loginType = CMPCore.sharedInstance.currentUser.loginType;
    NSLog(@"CMPNewLoginViewMode:%ld",loginMode);
    NSLog(@"CMPLoginAccountModelLoginType:%ld",loginType);
    // 自动填充企业账号
    if (loginMode == CMPNewLoginViewModeLegacy || loginMode == CMPNewLoginViewModeOrg) {
        NSString *loginName = @"";
        NSString *loginPassword = @"";
        
        if (loginType == CMPLoginAccountModelLoginTypeLegacy) {
            CMPLoginAccountModel *aUser = [[CMPCore sharedInstance] currentUserFromDB];
            // 自动填充企业账号
            NSString *aLoginName = [GTMUtil decrypt:aUser.loginName];
            NSString *aLoginPassword = [GTMUtil decrypt:aUser.loginPassword];
            if (![NSString isNull:aLoginName]) {
                loginName = aLoginName;
                loginPassword = aLoginPassword;
            }
        }else {
            CMPLoginAccountExtraDataModel *extraDataModel = [CMPCore sharedInstance].currentUser.extraDataModel;
            if (extraDataModel.loginModeSubType == CMPLoginModeSubType_MutilVerify) {
                NSString *loginInfoStr = extraDataModel.loginInfoLegency ? : @"";
                NSDictionary *loginInfoDic = [loginInfoStr JSONValue];
                if (loginInfoDic) {
                    loginName = [GTMUtil decrypt:loginInfoDic[@"username"] ? : @""];
                }
            } else {
                //  自动填充手机号
                NSString *phone = [M3LoginManager historyPhone];
                if (![NSString isNull:phone]) {
                    NSString *password = [[M3LoginManager sharedInstance] passwordWithPhone:[GTMUtil encrypt:phone]];
                    password = [GTMUtil decrypt:password];
                    loginName = [phone formatPhoneNumber];
                    loginPassword = password;
                }
            }
        }
        if (loginMode == CMPNewLoginViewModeOrg) {
            _loginView.orgLoginView.orgTF.text = [CMPCore sharedInstance].currentServer.orgCode;
            _loginView.orgLoginView.accountTF.text = loginName;
            _loginView.orgLoginView.pwdTF.text = loginPassword;
        }
        else {
            _loginView.userLoginView.accountTF.text = loginName;
            _loginView.userLoginView.pwdTF.text = loginPassword;
        }
        NSLog(@"loginName:%@",loginName);
        NSLog(@"loginPassword:%@",loginPassword);
                
    } else if (loginMode == CMPNewLoginViewModeMokey) {
        CMPLoginAccountModel *aUser = [[CMPCore sharedInstance] currentUserFromDB];
        // 自动填充手机盾账号
        NSString *aLoginName = [GTMUtil decrypt:aUser.loginName];
        if (![NSString isNull:aLoginName]) {
            _loginView.mokeyLoginView.accountTF.text = aLoginName;
        }
        NSLog(@"aLoginName:%@",aLoginName);
    }
    else  if (loginMode == CMPNewLoginViewModeSMS) {
        NSString *name = [M3LoginManager sharedInstance].currentAccount.extend5;//手机号
        if (![NSString isNull:name]) {
            name = [GTMUtil decrypt:name];
            if (![NSString isNull:name]) {
                _loginView.smsLoginView.phoneNumber = name;
                
                NSString *areaCode = [M3LoginManager sharedInstance].currentAccount.extend8;//手机号区号
                if (areaCode.length) {
                    _loginView.smsLoginView.areaCode = areaCode;
                    _loginView.smsLoginView.phoneTextField.areaCode = areaCode;
                }
            }
        }
        NSLog(@"name:%@",name);
    }
    else  if (loginMode == CMPNewLoginViewModeOrg) {
        
    }
    else {
       
    }
}

- (BOOL)setupSSOInfo {
    if (![NSString isNull:_defaultUsername] &&
        ![NSString isNull:_defaultPassword]) {
        [_loginView setLoginMode:CMPNewLoginViewModeLegacy delegate:self];
        _loginView.userLoginView.accountTF.text = _defaultUsername;
        _loginView.userLoginView.pwdTF.text = _defaultPassword;
        return YES;
    }
   return NO;
}

-(void)useMokeyTag {
    _canMokeyLogin = INTERFACE_IS_PHONE && TrustdoLoginManager.sharedInstance.isHaveMokeyLoginPermission;
}

- (void)addNotis {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotificationWhenApplicationWillEnterForeground:)
                                                 name:kNotificationName_ApplicationWillEnterForeground
                                               object:nil];
}

- (void)listenNotificationWhenApplicationWillEnterForeground:(NSNotification *)notification {
    
    if ([NSString isNotNull:self.verificationUrl]) {
        if (self.error || !_loginView.userLoginView.imgVerificationImgBtn.imageView.image) {
            [self _refreshVerification];
        }
    }
}


#pragma mark 更新数据库 旧数据
- (void)updateDatabaseOldAccountAlreadyPopuUppPrivacypPage {
    NSString *databaseUpdateFlag = kUserDefaultName_DatabaseOldAccountAlreadyPopuUppPrivacypPage;
    BOOL databaseUpdateValue = [[NSUserDefaults standardUserDefaults] boolForKey:databaseUpdateFlag];
    CMPLoginDBProvider *loginDBProvider = CMPCore.sharedInstance.loginDBProvider;
    if (!databaseUpdateValue) {
        [loginDBProvider updateDatabaseOldAccountAlreadyPopuUppPrivacypPage];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:databaseUpdateFlag];
    }
}

#pragma mark background

- (CMPLoginViewStyle *)style
{
    if (!_style) {
        _style = [CMPBackgroundRequestsManager sharedManager].requestBgImageUtil.currentLoginViewStyle;
    }
    return _style;
}

- (void)requestBackground
{
    [[CMPBackgroundRequestsManager sharedManager].requestBgImageUtil requestBackgroundWithStart:^{
        
    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
        
    } success:^(CMPLoginViewStyle * _Nonnull aStyle) {
        [self updateLoginStyle:aStyle];
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
- (void)updateLoginStyle:(CMPLoginViewStyle *)aStyle
{
    if (CMPThemeManager.sharedManager.isDisplayDrak) {
        aStyle = [CMPLoginViewStyle defaultStyle];
    }
    self.style = aStyle;
    if (InterfaceOrientationIsPortrait) {
        [self updateBackgroundUrl:aStyle.backgroundImage];
    } else {
        [self updateBackgroundUrl:aStyle.backgroundLandscapeImage];
    }
}

- (void)setStyle:(CMPLoginViewStyle *)style {
    _style = style;
    _loginView.loginTipsLabel.textColor = style.titleColor;
    [_loginView.scanBtn setImage:[[UIImage imageNamed:@"login_view_scan_qrcode_gray_icon"] cmp_imageWithTintColor:style.scanColor] forState:UIControlStateNormal];
    [_loginView.setServerBtn setTitleColor:style.toServerSiteColor forState:UIControlStateNormal];
    if (style.backgroundMaskColor) {
        _loginView.backgroundImageMaskView.hidden = NO;
        _loginView.backgroundImageMaskView.backgroundColor = style.backgroundMaskColor;
        _loginView.backgroundImageMaskView.alpha = style.backgroundMaskAlpha;
    } else {
        _loginView.backgroundImageMaskView.hidden = YES;
    }
}

- (void)updateBackgroundUrl:(NSString *)url {
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    if (!imageUrl) { // 加载默认背景图
        _loginView.bgImgView.image = nil;
        _loginView.bgImgView.hidden = NO;
        return;
    }
    
    __weak typeof(_loginView) weakLoginView = _loginView;
    NSString *aFileId = url.sha1;
    NSString *fileName = [NSString stringWithFormat:@"%@.png", aFileId];
    if (!_downloadAttachmentTool) {
        _downloadAttachmentTool = [[CMPDownloadAttachmentTool alloc] init];
    }
    [_downloadAttachmentTool downloadWithFileID:aFileId fileName:fileName lastModified:@"" url:url start:^{
        
    } progressUpdateWithExt:^(float progress, NSInteger recieveBytes, NSInteger totalBytes) {
        
    } success:^(NSString *localPath) {
        weakLoginView.bgImgView.image = [UIImage imageWithContentsOfFile:localPath];
    } fail:^(NSError *error) {
        
    }];
}

// 是否显示短信登录按钮入口是否显示，判断服务器服务版本号>429显示
- (void)checkServiceEnv {
    
    if (![CMPCore sharedInstance].currentServer) {
        return;
    }
    NSString *domain = [CMPCore sharedInstance].currentServer.fullUrl;
    NSString *contextPath = [CMPCore sharedInstance].currentServer.contextPath;
    if ([NSString isNull:contextPath]) {
        contextPath = @"";
    }
    NSString *checkEnvUrl = [NSString stringWithFormat:@"%@%@/seeyon/rest/m3/appManager/checkEnv",domain,contextPath];
            
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:domain forKey:kOrgLoginDomain];
    
    CMPCheckEnvRequest *request = [[CMPCheckEnvRequest alloc] init];
    request.url = checkEnvUrl;
    request.cmpVersion = [CMPCore clinetVersion];
    request.client = @"iphone";
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = checkEnvUrl;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestParam = [request yy_modelToJSONString];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    
    aDataRequest.userInfo = userInfo;
    self.canSMSLoginCheckEnvId = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

#pragma mark button Action
- (void)addButtonActions {
    [_loginView.scanBtn addTarget:self action:@selector(scanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.setServerBtn addTarget:self action:@selector(setServerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.phoneLoginBtn addTarget:self action:@selector(phoneLoginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.otherLoginBtn addTarget:self action:@selector(otherLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.forgetPwdBtn addTarget:self action:@selector(forgetPwdBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.mokeyScanButton addTarget:self action:@selector(mokeyScanButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.agreementBtn addTarget:self action:@selector(agreementBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    if (_loginView.showOrgCodeChangeButton) {
        [_loginView.orgCodeChangeButton addTarget:self action:@selector(orgCodeChangeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *buttonTitle = [[NSUserDefaults standardUserDefaults]objectForKey:kCloudLoginKey];
        [_loginView.orgCodeChangeButton setTitle:buttonTitle?:kCloudLoginDefaultDevKey forState:UIControlStateNormal];
    }
    
    __weak typeof(self) weakSelf = self;
    _loginView.smsLoginView.phoneTextField.leftViewBtnClicked = ^{
        [weakSelf areaCodeBtnAction];
    };
    _loginView.smsLoginView.smsCodeField.getSMSCodeBtnClicked = ^{
        [weakSelf showGraphVerView];
    };
}
// 区号选择
- (void)areaCodeBtnAction {
    CMPAreaCodeViewController *areaCode = [[CMPAreaCodeViewController alloc] init];
    __weak typeof(_loginView) weakLoginView = _loginView;
    areaCode.selectAreaCodeSuccess = ^(NSString * _Nonnull areaName, NSString * _Nonnull phoneCode, NSString * _Nonnull contryCode, NSString * _Nonnull checkKey) {
        // 选择完的数据
        NSString *areaCode = [NSString stringWithFormat:@"+%@",phoneCode];
        weakLoginView.smsLoginView.phoneTextField.areaCode = areaCode;
        weakLoginView.smsLoginView.areaCode = areaCode;
    };
    [self.navigationController pushViewController:areaCode animated:YES];
}
// 显示图形验证码
- (void)showGraphVerView {
    if (![_loginView.smsLoginView isValidPhoneNumber]) {
        [self showToastWithText:SY_STRING(@"login_sms_login_phone_error")];
        return;
    }
    // 图形验证码
    __weak typeof(self) weakSelf = self;
    __weak typeof(_loginView) weakLoginView = _loginView;
    [self.phoneCodeLoginProvider phoneCodeLoginWithValidPhoneNumbe:_loginView.smsLoginView.phoneNumber success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        if (dict) {
            NSNumber *code = dict[@"code"];
            NSString *message = dict[@"message"];
            if (code.intValue == 0) {
                CMPSMSGraphVerView *verView = [[CMPSMSGraphVerView alloc] initWithFrame:CGRectMake(0, 0, CMP_SCREEN_WIDTH, CMP_SCREEN_HEIGHT)];
                verView.phoneNumber = weakLoginView.smsLoginView.phoneNumber;
                verView.imageURL = [CMPCore fullUrlForPath:@"/rest/authentication/captcha"];
                verView.confirmBtnClicked = ^(NSString * _Nonnull code) {
                    [weakSelf fireCountdonwTimer:code];
                };
                //ks fix -- V5-44000【风暴测试】M3短信验证码登录，没有显示图形验证码
                verView.verifyCodeImgDownloadCallback = ^(UIImage * _Nullable image, NSError * _Nullable error) {
                    if (error) {
                        [weakSelf cmp_showHUDToBottomWithText:@"获取验证码失败，请重新获取！"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                            if ([verView respondsToSelector:NSSelectorFromString(@"cnacelButtonAction")]) {
                                [verView performSelector:NSSelectorFromString(@"cnacelButtonAction")];
                            }
                        });
                    }
                };
                [weakSelf.view addSubview:verView];
                [verView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.offset(0);
                }];
            }else if (code.intValue == 1) {
                [weakSelf showToastWithText:SY_STRING(@"login_sms_phone_unbinding_account")];
            }else if (code.intValue == 2) {
                [weakSelf showToastWithText:SY_STRING(@"login_sms_phone_binding_multi_account")];
            }else if (code.intValue == 4) {
                [weakSelf showToastWithText:SY_STRING(@"login_sms_unit_sms_unauthorized")];
            }else if (code.intValue == 5) {
                [weakSelf showToastWithText:SY_STRING(@"login_sms_get_code_reach_ceiling")];
            }else if (code.intValue == 9999) {
                [weakSelf showToastWithText:[NSString stringWithFormat:SY_STRING(@"login_sms_get_code_after_seconds"),message]];
                NSInteger count = message.integerValue;
                [_loginView.smsLoginView.smsCodeField fireCountdonwTimer:count];
            }else {
                [weakSelf showToastWithText:message];
            }
        }
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        
    }];
}

- (void)fireCountdonwTimer:(NSString *)code {
    [self showToastWithText:SY_STRING(@"login_sms_send_tips")];
    [_loginView.smsLoginView.smsCodeField fireCountdonwTimer];
}

- (void)phoneLoginBtnAction {
    if (_loginView.loginMode != CMPNewLoginViewModeSMS) {
        [_loginView setLoginMode:CMPNewLoginViewModeSMS delegate:self];
    }else {
        [_loginView setLoginMode:CMPNewLoginViewModeLegacy delegate:self];
    }
}

- (void)scanBtnAction {
    [self scanWithType:0];
}

-(void)_autoConfigDefaultServer
{
#if CUSTOM
    if (CMPCore.sharedInstance.loginDBProvider.countOfServer == 0) {
        NSString *server = [CMPCustomManager sharedInstance].cusModel.defaultServer;
        NSString *note = [CMPCustomManager sharedInstance].cusModel.defaultServerNote;
        if (server && server.length) {
            NSString *host = @"";
            NSString *port = @"80";
            if ([server containsString:@"://"]) {
                server = [server componentsSeparatedByString:@"://"].lastObject;
            }
            if (server && server.length) {
                if ([server containsString:@":"]) {
                    host = [server componentsSeparatedByString:@":"].firstObject;
                    port = [server componentsSeparatedByString:@":"].lastObject;
                }else{
                    host = server;
                }
                
                [self.view endEditing:YES];
                _loginView.tipsBubbleView.hidden = YES;//todo
                CMPServerEditController *editVc = CMPServerEditController.alloc.init;
                [editVc autoSaveServerWithHost:host port:port note:note fail:^(NSError *error) {
                        
                }];
                [self.navigationController pushViewController:editVc animated:YES];
            }
        }
    }
#endif
}

- (void)setServerBtnAction {
    [self.view endEditing:YES];
    
    if (CMPCore.sharedInstance.loginDBProvider.countOfServer == 0) {
        _loginView.tipsBubbleView.hidden = YES;//todo
        CMPServerEditController *editVc = CMPServerEditController.alloc.init;
        [self.navigationController pushViewController:editVc animated:YES];
    }else {
        CMPServerListController *serverListVc = CMPServerListController.alloc.init;
        [self.navigationController pushViewController:serverListVc animated:YES];
    }
    
}

- (void)loginBtnAction {
    [self.view endEditing:YES];
    if (_loginView.selectBtn && !_loginView.selectBtn.hidden &&!_loginView.selectBtn.selected) {
        [self showAlertMessage:SY_STRING(@"login_policy_select_policy_detail")];
        return;
    }
    
    NSString *serverID = CMPCore.sharedInstance.serverID;
    CMPServerVpnModel *vpnModel = [CMPVpnManager getVpnModelByServerID:serverID];
    if (![CMPVpnManager isVpnConnected] && vpnModel.vpnUrl.length) {
        [self showLoadingViewWithText:@"VPN加载中"];
        __weak typeof(self) wSelf = self;

        [[CMPVpnManager sharedInstance] loginVpnWithConfig:vpnModel process:^(id obj, id ext) {
                        
                    } success:^(id obj, id ext) {
                        [wSelf hideLoadingView];
                        [wSelf toLogin];
                    } fail:^(id obj, id ext) {
                        [wSelf hideLoadingView];
                        [wSelf showToastWithText:obj];
                    }];

    }else{
        [self toLogin];
    }
}

- (void)toLogin{
    switch (_loginView.loginMode) {
        case CMPNewLoginViewModeLegacy:
            [self loginWithUserInfo];
            break;
        case CMPNewLoginViewModeSMS:
            [self validatePhoneCode];
            break;
        case CMPLoginViewModeMokey:
            [self loginWithMokey];
            break;
        case CMPNewLoginViewModeOrg: {
            [self loginWithOrganizationCode];
        }
            break;
        default:
            break;
    }
}

- (void)otherLoginAction {
    [self.view endEditing:YES];
    NSMutableArray *sheetTitles = [NSMutableArray array];
    NSMutableArray *numbers = [NSMutableArray array];
    CMPLoginViewMode loginViewMode = _loginView.loginMode;
    if (loginViewMode != CMPNewLoginViewModeLegacy) {
        [sheetTitles addObject:SY_STRING(@"login_account_phone_num_login")];
        [numbers addObject:[NSNumber numberWithInteger:CMPNewLoginViewModeLegacy]];
    }
//    if (loginViewMode != CMPNewLoginViewModeSMS) {
//        [sheetTitles addObject:SY_STRING(@"login_sms_login_btn")];
//        [numbers addObject:[NSNumber numberWithInteger:CMPNewLoginViewModeSMS]];
//    }
    if (loginViewMode != CMPNewLoginViewModeOrg) {
        [sheetTitles addObject:SY_STRING(@"login_orgcode_login")];
        [numbers addObject:[NSNumber numberWithInteger:CMPNewLoginViewModeOrg]];
    }
    if (_canMokeyLogin &&loginViewMode != CMPNewLoginViewModeMokey) {
        [sheetTitles addObject:SY_STRING(@"login_mokey_login_btn")];
        [numbers addObject:[NSNumber numberWithInteger:CMPNewLoginViewModeMokey]];
    }
    __weak typeof(_loginView) weakLoginView = _loginView;
    __weak typeof(self) weakSelf = self;
    CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:[sheetTitles copy] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
        if (buttonIndex != 0 && numbers.count > buttonIndex-1) {
            [weakLoginView setLoginMode:[numbers[buttonIndex-1] integerValue] delegate:weakSelf];
        }
    }];
    [actionSheet show];
}

- (void)forgetPwdBtnAction {
    [self.view endEditing:YES];
    
    if ([NSString isNull:CMPCore.sharedInstance.serverurl]) {
        [self showAlertMessage:SY_STRING(@"login_server_uninit2")];
        return;
    }
    
    if ([CMPCore sharedInstance].serverIsLaterV2_5_0) {
        CMPForgotPasswordViewController *vc = [[CMPForgotPasswordViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SY_STRING(@"login_forget_alert") delegate:nil cancelButtonTitle:SY_STRING(@"common_isee") otherButtonTitles:nil];
        [alert show];
    }
}
- (void)mokeyScanButtonAction:(id)sender {
    if (_loginView.mokeyText.length > 0) {
        [self scanWithType:1];
    } else {
        [self showToastWithText:SY_STRING(@"login_account_null_tips")];
    }
}


- (void)agreementBtnAction {
    [self.view endEditing:YES];
    CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
    viewController.startPage = [CMPCommonManager privacyAgreementUrl];
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = NO;
    viewController.isShowBannerProgress = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)validatePhoneCode {
    if ([NSString isNull:_loginView.smsLoginView.phoneNumber]) {
        [self showToastWithText:SY_STRING(@"login_phone_null_tips")];
        return;
    }
    if ([NSString isNull:_loginView.smsLoginView.smsCode]) {
        [self showToastWithText:SY_STRING(@"login_verification_code_can_not_be_null")];
        return;
    }
    [self smsLogin];
//    __weak typeof(self) weakSelf = self;
//    [self showLoginLoading];
//    [self.phoneCodeLoginProvider phoneCodeLoginWithValidatePhoneCode:_loginView.smsLoginView.phoneNumber code:_loginView.smsLoginView.smsCode success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
//        [self hideLoadingView];
//        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
//        NSNumber *code = dict[@"code"];
//        NSString *message = dict[@"message"];
//        if (code.intValue == 0) {
//            [self smsLogin];
//        }else if (code.integerValue == 1) {
//            [weakSelf showToastWithText:@"当前手机号未绑定办公账号"];
//            [weakSelf resetLoginBtn];
//
//        }else if (code.intValue == 2) {
//            [weakSelf showToastWithText:@"当前手机号对应多个办公账号，请更换登录方式"];
//            [weakSelf resetLoginBtn];
//
//        }else if (code.intValue == 3) {
//            [weakSelf showToastWithText:@"请输入正确的手机号"];
//            [weakSelf resetLoginBtn];
//
//        }else if (code.intValue == 4) {
//            [weakSelf showToastWithText:@"手机号或者短信验证码有误"];
//            [weakSelf resetLoginBtn];
//        }else {
//            [weakSelf showToastWithText:message];
//            [weakSelf resetLoginBtn];
//        }
//
//    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
//        [weakSelf resetLoginBtn];
//        [weakSelf _loginFail:response];
//    }];
}

- (void)smsLogin {
    [self loginWithLoginName:_loginView.smsLoginView.phoneNumber password:@"" verificationCode:@"" type:CMPLoginAccountModelLoginTypeSMS loginType:CMPM3LoginTypeSMS smsCode:_loginView.smsLoginView.smsCode];
}

#pragma CMPNewLoginViewDelegate
- (void)shouldRefreshVerification {
    [self _refreshVerification];
}
- (void)shouldLogin {
    [self loginBtnAction];
}


- (void)scanWithType:(NSInteger)type {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    self.currentScanType = type;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}
#pragma mark - SyScanViewControllerDelegate

- (void)scanViewController:(SyScanViewController *)scanViewController didScanFinishedWithResult:(ZXParsedResult *)aResult {
    if (aResult.type != kParsedResultTypeText) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSDictionary *aJson = [aResult.displayResult JSONValue];
    if (!aJson || ![aJson isKindOfClass:[NSDictionary class]]) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.currentScanType == 1) {
        NSString *opType = [NSString stringWithFormat:@"%@", aJson[@"opType"]];
        NSString *qrData = [NSString stringWithFormat:@"%@", aJson[@"qrData"]];
        
        if ([opType isEqualToString:@"(null)"] || [qrData isEqualToString:@"(null)"]) {
            [self showToastWithText:SY_STRING(@"login_scan_err")];
            [scanViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        // 手机盾重置功能
        if ([opType isEqualToString:@"4"]) {
            
            [[TrustdoLoginManager sharedInstance] doMokeyResetWithLoginName:_loginView.mokeyText EventData:qrData Style:@"2"];
        } else if ([opType isEqualToString:@"2"]) {
            [self showToastWithText:SY_STRING(@"login_mokey_scan_login")];
        } else {
            [self showToastWithText:SY_STRING(@"login_mokey_scan_nosupport")];
        }
        
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        NSString *host = aJson[@"host"];
        NSString *port = aJson[@"port"];
        if ([NSString isNotNull:host] && [NSString isNotNull:port]) {
            CMPServerEditController *editVc = [[CMPServerEditController alloc] init];
            editVc.host = host;
            editVc.port = port;
            __weak typeof(self) weakSelf = self;
            [scanViewController dismissViewControllerAnimated:YES completion:^{
                [weakSelf.navigationController pushViewController:editVc animated:YES];
            }];
        }
        else {
            [self showToastWithText:SY_STRING(@"login_scan_err")];
            [scanViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - login
- (void)loginWithOrganizationCode {
    CMPOrgLoginView *orgLoginView = _loginView.orgLoginView;
    NSString *orgCode = orgLoginView.orgTF.text;
    
    //非空判断 todo
    if ([NSString isNull:orgCode]) {
        [self showAlertMessage:SY_STRING(@"login_orgcode_no_null")];
        return;
    }
    NSString *loginName = orgLoginView.accountTF.text;
    if ([NSString isNull:loginName]) {
        [self showAlertMessage:SY_STRING(@"login_account_null_tips")];
        return;
    }
    NSString *password = orgLoginView.pwdTF.text;
    if ([NSString isNull:password]) {
        [self showAlertMessage:SY_STRING(@"login_password_null_tips")];
        return;
    }
    
    NSString *verificationCode = nil;
    if (orgLoginView.verificationCodeRequired) {
        verificationCode = orgLoginView.imgVerificaitionTF.text;
        if ([NSString isNull:verificationCode]) {
            [self showAlertMessage:SY_STRING(@"login_verification_code_can_not_be_null")];
            return;
        }
    }
    
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
    aDataRequest.requestUrl = [self cloudLoginServiceUrl];
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = kRequestMethodType_POST;
    aDataRequest.requestType = kDataRequestType_Url;
    NSDictionary *requestParamDic = @{@"productCode": orgCode};
    aDataRequest.requestParam = [requestParamDic JSONRepresentation];
    aDataRequest.userInfo = @{kLoginName :loginName,
                              kLoginPWD : password,
                              kLoginVerificationCode:verificationCode?:@"",
                              kOrgLoginCode:orgCode};
    self.orgLoginRequestId = aDataRequest.requestID;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}


- (void)loginWithUserInfo {
    CMPUserLoginView *userLoginView = _loginView.userLoginView;
    NSString *loginName = userLoginView.accountTF.text;
    if ([NSString isNull:loginName]) {
        [self showAlertMessage:SY_STRING(@"login_account_null_tips")];
        return;
    }
    NSString *password = userLoginView.pwdTF.text;
    if ([NSString isNull:password]) {
        [self showAlertMessage:SY_STRING(@"login_password_null_tips")];
        return;
    }
    NSString *verificationCode = nil;
    if (userLoginView.verificationCodeRequired) {
        verificationCode = userLoginView.imgVerificaitionTF.text;
        if ([NSString isNull:verificationCode]) {
            [self showAlertMessage:SY_STRING(@"login_verification_code_can_not_be_null")];
            return;
        }
    }
    // V8.0版本需要判断当前输入是否为手机号，如果是手机号就不判断服务器地址，使用手机号从云联获获取服务器地址并登录
    if (loginName.justContainsNumber && loginName.length > 6) {
        loginName = [loginName replaceCharacter:@" " withString:@""];//针对formatPhoneNumber去掉空格
        [self loginWithPhone:loginName password:password verificationCode:verificationCode directLogin:NO];
        return;
    }
    
    [self loginWithLoginName:loginName password:password verificationCode:verificationCode type:CMPLoginAccountModelLoginTypeLegacy loginType:CMPM3LoginTypeAccount smsCode:nil];
}

- (void)loginWithMokey {
    NSString *mokeyText = _loginView.mokeyText;
    //非空判断 todo
    if ([NSString isNull:mokeyText]) {
        [self showAlertMessage:SY_STRING(@"login_account_null_tips")];
        return;
    }
    self.loginFialedError = nil;
    [[TrustdoLoginManager sharedInstance] getMokeyKeyIdWithLoginName:mokeyText Style:@"1"];
    
}

- (void)showLoginLoading {
    [_loginView.loginBtn setEnabled:NO];
    [_loginView.loginBtn startAnimation];
    _loginView.userInteractionEnabled = NO;
}
- (void)resetLoginBtn {
    [_loginView.loginBtn setEnabled:YES];
    [_loginView.loginBtn stopAnimation];
    _loginView.userInteractionEnabled = YES;
}

#pragma mark CMPDataProviderDelegate

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    if ([aRequest.requestID isEqualToString:self.orgLoginRequestId]) {
        [self showLoginLoading];
    }
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    if ([aRequest.requestID isEqualToString:self.orgLoginRequestId]) {
        /* {"success":true,"code":200,"msg":null,"data":{ "domain": "http://xxx/seeyon"}}
         code    int    200表示请求成功，-1表示未知错误，500：服务器异常,1:无效验证码
         msg    string    错误提示信息
         success    boolean    true/false 表示请求是否成功
         data.domain    string    表示客户真实的域名
         */
        NSDictionary *responseDic = [aResponse.responseStr JSONValue];
        
        NSNumber *code = responseDic[@"code"];
        NSInteger codeInt = 0;
        if ([code isKindOfClass:[NSString class]] || [code isKindOfClass:[NSNumber class]]) {
            codeInt = [code integerValue];
        }
        if (codeInt != 200) {
            NSString *msg = responseDic[@"msg"];
            if ([NSString isNull:msg]) {
                msg = @"未知错误";//假的
            }
            [self showAlertMessage:msg];
            [self resetLoginBtn];
            return;
        }
        
        NSString *domain = responseDic[@"data"][@"domain"];
        NSString *checkEnvUrl = [NSString stringWithFormat:@"%@/rest/m3/appManager/checkEnv",domain];
                
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:aRequest.userInfo];
        [userInfo setObject:domain forKey:kOrgLoginDomain];
        
        CMPCheckEnvRequest *request = [[CMPCheckEnvRequest alloc] init];
        request.url = checkEnvUrl;
        request.cmpVersion = [CMPCore clinetVersion];
        request.client = @"iphone";
        
        CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
        aDataRequest.requestUrl = checkEnvUrl;
        aDataRequest.delegate = self;
        aDataRequest.requestMethod = kRequestMethodType_POST;
        aDataRequest.headers = [CMPDataProvider headers];
        aDataRequest.requestParam = [request yy_modelToJSONString];
        aDataRequest.requestType = kDataRequestType_Url;
        aDataRequest.httpShouldHandleCookies = NO;
        
        aDataRequest.userInfo = userInfo;
        self.orgLoginCheckEnvId = aDataRequest.requestID;
        [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
    }
    else if ([aRequest.requestID isEqualToString:self.orgLoginCheckEnvId]) {
        [self handleCheckEnvResponse:aResponse.responseStr useInfo:aRequest.userInfo];
    }
    else if ([aRequest.requestID isEqualToString:self.canSMSLoginCheckEnvId]){
        CMPCheckEnvResponse *aModel = [[CMPCheckEnvResponse class] yy_modelWithJSON:aResponse.responseStr];
        //是否显示短信登录按钮入口，增加一个判断条件，判断服务器服务版本号>429显示
        NSString *compareVersion = @"4.2.9";
        NSString *serviceVersion = aModel.data.version;
        /*
        BOOL show = [serviceVersion isEqualToString:compareVersion];
        if (!show) {
            show = [serviceVersion compare:compareVersion options:NSNumericSearch] == NSOrderedDescending;
        }
         */
        BOOL serverSupport = [[CMPCore sharedInstance] canUseSMS];
        BOOL show = [serviceVersion compare:compareVersion options:NSNumericSearch] == NSOrderedDescending;
        [_loginView hiddenSMSLoginButton:!(show && serverSupport)];
    }
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    if ([aRequest.requestID isEqualToString:self.orgLoginRequestId]||
        [aRequest.requestID isEqualToString:self.orgLoginCheckEnvId]) {
        [self p_handleLoginError:error];
    }
}
- (void)handleCheckEnvResponse:(NSString *)responseStr useInfo:(NSDictionary *)useInfo{
    CMPCheckEnvResponse *aModel = [[CMPCheckEnvResponse class] yy_modelWithJSON:responseStr];
    NSString *identifier = aModel.data.identifier;
    
    if ([NSString isNull:identifier]) {
        NSString *msg = [NSString isNotNull:aModel.message]?aModel.message:@"Server ID is Null";
        [self hideLoadingView];
        [self showToastWithText:msg];
        [self resetLoginBtn];
        return;
    }
    
    // 关联服务器与云联添加服务器不允许新增
    NSArray *aServerModelArr = [self.loginDBProvider findServersWithServerID:identifier];
    for (CMPServerModel *aServerModel in aServerModelArr) {
        if (![aServerModel isMainAssAccount]) {
            [self hideLoadingView];
            [self showToastWithText:SY_STRING(@"ass_add_err2")];
            [self resetLoginBtn];
            return;
        }
    }
    NSString *domain = useInfo[kOrgLoginDomain];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:domain];
    NSString *aScheme = urlComponents.scheme;
    BOOL isSafe = [aScheme isEqualToString:CMPHttpsPrefix];
    
    // 设置给webview
    NSString *aHost = urlComponents.host;
    NSString *aPort = [urlComponents.port isKindOfClass:[NSNumber class]]? [urlComponents.port stringValue]:isSafe?@"443":@"80";
    NSString *contextPath = [NSString isNull:urlComponents.path]?@"":urlComponents.path;
    
    NSString *aNote = @"";
    NSString *aServerVersion = aModel.data.version;
    NSString *aUpdateStr = [aModel.data.updateServer yy_modelToJSONString];
    
    // 保存到本地
    CMPServerModel *newModel = [[CMPServerModel alloc] initWithHost:aHost
                                                               port:aPort
                                                             isSafe:isSafe
                                                             scheme:aScheme
                                                               note:aNote
                                                             inUsed:YES
                                                           serverID:identifier
                                                      serverVersion:aServerVersion
                                                       updateServer:aUpdateStr];
    [newModel setupOrgCode:useInfo[kOrgLoginCode] path:contextPath];
    CMPServerModel *oldServer = aServerModelArr.firstObject;
    if (oldServer) {
        //本地可能有了需要删除
        newModel.extend10 = oldServer.extend10;
        [self.loginDBProvider deleteServerWithUniqueID:newModel.uniqueID];
    }
    [self.loginDBProvider addServerWithModel:newModel];

    [self.loginDBProvider switchUsedServerWithUniqueID:newModel.uniqueID];
    [[CMPCore sharedInstance] setup];
    
    // 设置服务器信息到H5缓存Local Storage
    [[CMPMigrateWebDataViewController shareInstance] saveServerInfo:newModel.h5CacheDic.JSONRepresentation];

    __weak __typeof(self)weakSelf = self;
    __weak __typeof(_loginView)weakLoginView = _loginView;
    [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
        NSLog(@"该用用户名登陆了");
        [weakLoginView setupPrivacyInfoHidden:[[CMPCore sharedInstance] isByPopUpPrivacyProtocolPage]];
        [weakSelf loginWithLoginName:useInfo[kLoginName] password:useInfo[kLoginPWD] verificationCode:useInfo[kLoginVerificationCode] type:CMPLoginAccountModelLoginTypeLegacy loginType:CMPM3LoginTypeAccount smsCode:nil];
    }];
}
- (CMPLoginDBProvider *)loginDBProvider {
    return [CMPCore sharedInstance].loginDBProvider;
}


#pragma mark use name and phone login

- (CMPCloudLoginHelper *)cloudLoginHelper {
    if (!_cloudLoginHelper) {
        _cloudLoginHelper = [[CMPCloudLoginHelper alloc] init];
    }
    return _cloudLoginHelper;
}

- (CMPNewPhoneCodeLoginProvider *)phoneCodeLoginProvider {
    if (!_phoneCodeLoginProvider) {
        _phoneCodeLoginProvider = [[CMPNewPhoneCodeLoginProvider alloc] init];
    }
    return _phoneCodeLoginProvider;
}

//账号密码0，手机号登录1，短信验证码登录2
- (void)loginWithLoginName:(NSString *)loginName password:(NSString *)password verificationCode:(NSString *)verificationCode type:(CMPLoginAccountModelLoginType)type loginType:(CMPM3LoginType)loginType smsCode:(NSString *)smsCode {
    [self loginWithLoginName:loginName password:password verificationCode:verificationCode type:type loginType:loginType smsCode:smsCode success:nil fail:nil];
}

- (void)loginWithLoginName:(NSString *)loginName
                  password:(NSString *)password
          verificationCode:(NSString *)verificationCode
                      type:(CMPLoginAccountModelLoginType)type
                 loginType:(CMPM3LoginType)loginType
                   smsCode:(NSString *)smsCode
                   success:(void(^)(void))success
                      fail:(void(^)(NSError *error))fail {
    if ([NSString isNull:CMPCore.sharedInstance.serverurl]) {
        [self showAlertMessage:SY_STRING(@"login_server_uninit")];
        return;
    }
    
    NSString *loginTypeStr = [NSString stringWithInt:loginType];
    
    //手机号作为账号使用，loginType需要传CMPM3LoginTypePhone，这里逻辑和安卓保持一致。
    if (type == CMPLoginAccountModelLoginTypeLegacy
        && [CMPCore sharedInstance].isShowPhoneLogin
        && loginName.length>=7
        && loginName.justContainsNumber) {
        loginTypeStr = [NSString stringWithInt:CMPM3LoginTypePhone];
    }
    
    //    self.lastLoginMode = self.loginMode;
    self.loginFialedError = nil;
    __weak typeof(self) weakself = self;
    __weak typeof(_loginView) weakLoginView = _loginView;
    //ks add -- 双因子登录 0926
    if (type == CMPLoginAccountModelLoginTypeLegacy) {
        [M3LoginManager sharedInstance].loginProcessBlk = ^(NSInteger step, NSError *error, id  _Nullable ext) {
            if (!error) {
                if (step == 1) {
                    CMPVerifyCodeViewController *vc = [[CMPVerifyCodeViewController alloc] initWithNumber:ext ext:@{@"loginName":loginName?:@""}];
                    __weak typeof(CMPVerifyCodeViewController *) wVc = vc;
                    vc.completion = ^(BOOL success, NSError * _Nonnull err, id  _Nonnull ext) {
                        if (success) {
//                            [wVc.navigationController popViewControllerAnimated:YES];
                            [weakself _loginSuccess];
                        }else{
                            [wVc showAlertMessage:err.domain];
                        }
                    };
                    [weakself.navigationController pushViewController:vc animated:YES];
                    [weakself resetLoginBtn];
                }
            }else{
                [weakself cmp_showHUDError:error];
            }
        };
    }
    //end
    
    //验证码登录，areaCode赋值给M3LoginManager
    if (type == CMPLoginAccountModelLoginTypeSMS && _loginView.smsLoginView.areaCode.length) {
        [M3LoginManager sharedInstance].areaCode = _loginView.smsLoginView.areaCode;
    }else{
        [M3LoginManager sharedInstance].areaCode = nil;
    }
    
    [[M3LoginManager sharedInstance] requestLoginWithUserName:loginName  password:password encrypted:NO refreshToken:NO verificationCode:verificationCode type:type loginType:loginTypeStr smsCode:smsCode externParams:nil  isFromAutoLogin:NO start:^{
        [weakself showLoginLoading];
    } success:^{
        if (success) {
            success();
            return;
        }
        // 测试要求，点击手动登录，再检查一次更新。特殊处理
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
                [weakself _loginSuccessAndTagPopUpPrivacyProtocolPage];
            }];
            [weakself resetLoginBtn];
            if (isPopUpPrivacyProtocolPage) return;
            [weakself _loginSuccess];
        }];
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
            return;
        }
        if (error.code == -1001) {//超时 超时的时候就不继续做后续处理了，否则只会增加登录时长
            [weakself p_handleLoginError:error];
            return;
        }
        
        //      非超时的时候，进行正常的登录处理逻辑
        if (!loginName.justContainsNumber || loginName.length < 7) {
            [weakself p_handleLoginError:error];
        }else if (CMPCore.sharedInstance.isShowPhoneLogin && weakLoginView.loginMode == CMPNewLoginViewModeLegacy){
            weakself.loginFialedError = error;
            [weakself loginWithPhone:loginName password:password verificationCode:verificationCode directLogin:YES];
        }else {
            [weakself p_handleLoginError:error];
        }
        
    }];
}


- (void)loginWithPhone:(NSString *)phone password:(NSString *)password verificationCode:(NSString *)verificationCode directLogin:(BOOL)directLogin {
    
    __weak typeof(self) weakself = self;
    dispatch_block_t block = ^{
        [weakself showLoginLoading];
        [weakself.cloudLoginHelper loginWithPhone:phone password:password verificationCode:verificationCode loginType:@"1" success:^{
            BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
                [weakself _loginSuccessAndTagPopUpPrivacyProtocolPage];
            }];
            [weakself resetLoginBtn];
            if (isPopUpPrivacyProtocolPage) return;
            [weakself _loginSuccess];
            [M3LoginManager saveHistoryPhone:phone];
        } fail:^(NSError * _Nonnull error) {
            [weakself resetLoginBtn];
            if (error.code == CMPLoginErrorCloudUnreachable
                ||error.code == CMPLoginErrorCloudException
                ||error.code == CMPLoginErrorPhoneUnknown
                ||error.code == 0) {
                [weakself _loginFail:weakself.loginFialedError ? weakself.loginFialedError:error];
                
            }else {
                [weakself _loginFail:error];
            }
        }];
    };
    
    if(directLogin || CMPCore.sharedInstance.loginDBProvider.countOfServer == 0) {
        //可以确定用手机号码登陆，或者没有设置服务器地址，直接用手机号码登陆云联
        block();
    }
    else {
        //如果有服务器地址，先用账号登陆，排除手机号码是登陆账号的情况
        [self loginWithLoginName:phone password:password verificationCode:verificationCode type:CMPLoginAccountModelLoginTypeLegacy loginType:CMPM3LoginTypeAccount smsCode:nil success:nil fail:^(NSError *error) {
            weakself.loginFialedError = error;
            block();
        }];
    }
}



- (BOOL)popUpPrivacyProtocolPageWithBlock:(void (^)(void))agreeButtonActionBlock {
    return [CMPPrivacyProtocolWebViewController popUpPrivacyProtocolPageWithPresentedController:self.navigationController beforePopPageBlock:^{
        [self hideLoadingViewWithoutCount];
    } agreeButtonActionBlock:agreeButtonActionBlock notAgreeButtonActionBlock:nil];
}

- (void)_loginSuccessAndTagPopUpPrivacyProtocolPage {
    [CMPCore.sharedInstance tagCurrentUserPopUpPrivacyProtocolPage];
    [self _loginSuccess];
}

- (void)_mokeyLoginSuccessAndTagPopUpPrivacyProtocolPage {
   [CMPCore.sharedInstance tagCurrentUserPopUpPrivacyProtocolPage];
   [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
}

- (void)_loginSuccess {
    
    if (_loginView.loginMode == CMPNewLoginViewModeOrg) {
        //保存组织码登陆信息
        CMPOrgLoginView *orgLoginView = _loginView.orgLoginView;
        NSString *orgCode = [GTMUtil encrypt:orgLoginView.orgTF.text];
        NSString *loginName = [GTMUtil encrypt:orgLoginView.accountTF.text];
        [[CMPCore sharedInstance].loginDBProvider addOrgLoginInfoWithOrgCode:orgCode loginName:loginName];
    }
    
    [self hideLoadingViewWithoutCount];
    // 需要判断是否需要设置手势密码
    if ([[M3LoginManager sharedInstance] needSetGesturePassword]) {
        [[AppDelegate shareAppDelegate] showSetGesturePwdView];
    } else {
        [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
        [CMPCAAnimation cmp_animShowNextViewWithAnimView:self.navigationController.view];
    }
}

//ks add 主要用于处理一些需要特殊处理的code，比如-3005需要拼接设备号等
-(BOOL)_canContinueWithNewHandleLoginErr:(NSError *)error result:(void(^)(NSInteger code,NSString *msg))result
{
    if (!error) {
        return YES;
    }
    if (error.userInfo) {
        NSString *str = error.userInfo[@"responseString"];
        NSDictionary *strDic = [str JSONValue];
        NSInteger code = [strDic[@"code"] integerValue];
        if (code == CMPLoginErrorDeviceBindedException) {
            if (result) {
                NSString *message = strDic[@"message"]?:@"";
                result(code,message);
            }
            return NO;
        }
    }
    return YES;
}

- (void)_loginFail:(NSError *)error {
    [self hideLoadingViewWithoutCount];
    if ([[M3LoginManager sharedInstance] needDeviceBind:error]) {
        [[M3LoginManager sharedInstance] showBindTipAlert];
        if (![NSString isNull:self.verificationUrl]) {
            [self _refreshVerification];
        }
        return;
    }

    // 第一次验证码错误不弹窗提示
    if ([[M3LoginManager sharedInstance] isVerificationError:error] &&
        [NSString isNull:self.verificationUrl]) {
    } else {
        __weak typeof(self) wSelf = self;
        BOOL canContinue = [self _canContinueWithNewHandleLoginErr:error result:^(NSInteger code, NSString *msg) {
            if (code == CMPLoginErrorDeviceBindedException){
                NSString *aUDID = [SvUDIDTools UDID];
                NSString *aPartUdid = (aUDID.length >= 8) ? [aUDID substringWithRange:NSMakeRange(aUDID.length-8, 8)] : aUDID;
                [wSelf showAlertWithTitle:msg message:[NSString stringWithFormat:@"%@: ******%@",SY_STRING(@"login_current_bind_device_numb"),aPartUdid] cancelTitle:SY_STRING(@"common_confirm")];
            } else {
                [wSelf showAlertMessage:error.domain];
            }
        }];
        if (canContinue) {
            if (error.code == CMPLoginErrorPhoneUnknown) {
                // 未绑定手机号，使用手机号登录，提示之后自动跳转账号密码界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAttributedString *formatMessage = [[NSAttributedString alloc] initWithData:[error.domain dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[formatMessage string] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        //                    [self switchToLegacyLogin];// 手机号与账号合并后，无需再处理
                    }];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }else if (error.code == -1001){
                NSString *msg = [SY_STRING(@"Common_Network_Disconnect") stringByAppendingFormat:@"[%ld]",error.code];
                [self showAlertMessage:msg];
            }  else {
//                [self showAlertMessage:error.localizedDescription];
                [self showAlertMessage:error.domain];
            }
        }
    }
    // 展示验证码
    NSString *verificationCodeUrl = [[M3LoginManager sharedInstance] verificationCodeUrl:error];
    if (!verificationCodeUrl.length && [CMPCore sharedInstance].firstShowValidateCode) {
        //默认请求验证码
        verificationCodeUrl = @"/seeyon/verifyCodeImage.jpg";
    }
    if (![NSString isNull:verificationCodeUrl]) {
        [self showVerificationWithUrl:verificationCodeUrl];
    }
}

#pragma mark - 验证码


- (NSURL *)verificationImageUrl:(NSString *)url {
    if ([NSString isNull:url]) {
        return nil;
    }
    NSString *imageUrlStr = [[CMPCore sharedInstance].serverurl stringByAppendingString:url];
    NSString *timeStamp = [NSString stringWithFormat:@"?%f", [[NSDate date] timeIntervalSince1970]];
    imageUrlStr = [imageUrlStr stringByAppendingString:timeStamp];
    NSURL *aUrl = [NSURL URLWithString:imageUrlStr];
    return aUrl;
}

- (void)showVerificationWithUrl:(NSString *)url {
    [CMPCAAnimation cmp_transitionWithView:self.view type:CMPTransitionTypeFade timeInterval:0.25f transitionType:nil];
    self.verificationUrl = url;
    [self _refreshVerification];
}


- (void)hideVerification {
    [CMPCAAnimation cmp_transitionWithView:self.view type:CMPTransitionTypeFade timeInterval:0.25f transitionType:nil];
    [_loginView hideVerification];
    self.verificationUrl = nil;
}


- (void)_refreshVerification {
    __weak __typeof(_loginView) weakLoginView = _loginView;
    [[SDWebImageDownloader sharedDownloader] setValue:nil forHTTPHeaderField:@"ltoken"];
    [[SDWebImageDownloader sharedDownloader]
     downloadImageWithURL:[self verificationImageUrl:self.verificationUrl]
     options:SDWebImageDownloaderHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates
     progress:nil
     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
         if (finished && !error) {
             [weakLoginView setupVerificationImg:image];
         }
     }];
}

- (void)p_handleLoginError:(NSError *)error {
    [self _loginFail:error];
    [self resetLoginBtn];
}

#pragma mark use mokey login

- (void)addMokeyNoti {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMokeyLoginSuccessNotification:)
                                                 name:kNotificationName_MokeyLoginSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMokeySDKNotification:)
                                                 name:kNotificationName_MokeySDKNotification
                                               object:nil];
}

- (void)removeMokeyNoti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_MokeyLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_MokeySDKNotification object:nil];
    
}


- (void)getMokeyLoginSuccessNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    __weak typeof(self) weakself = self;
    [[M3LoginManager sharedInstance] requestMokeyLoginWithUserName:_loginView.mokeyText password:@"" encrypted:NO refreshToken:NO verificationCode:@"" type:CMPLoginAccountModelLoginTypeMokey accToken:userInfoDic[@"message"] start:^{
        [weakself showLoginLoading];
    } success:^{
        // 测试要求，点击手动登录，再检查一次更新。特殊处理
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
                [weakself _mokeyLoginSuccessAndTagPopUpPrivacyProtocolPage];
            }];
            [weakself resetLoginBtn];
            if (isPopUpPrivacyProtocolPage) return;
            [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
        }];
    } fail:^(NSError *error) {
        [weakself p_handleLoginError:error];
    }];
}
///手机盾SDK返回的数据回调
- (void)getMokeySDKNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    NSString *messageStr = userInfoDic[@"message"];
    [self showToastWithText:messageStr];
}

#pragma mark 点击view，退出键盘

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (NSString *)cloudLoginServiceUrl {
    if (!_loginView.showOrgCodeChangeButton) {
        return kCloudLoginServiceUrl;
    }
    NSDictionary *dictionary = [self cloudLoginDictionary];
    if (dictionary) {
        NSString *key = [[NSUserDefaults standardUserDefaults]objectForKey:kCloudLoginKey];
        if (!key) {
            key = kCloudLoginDefaultDevKey;
        }
        if (dictionary[key]) {
            return dictionary[key];
        }
    }
    return kCloudLoginServiceUrl;
}

#pragma mark 切换多租户云登陆环境

- (void)orgCodeChangeButtonAction:(id)sender {
    [self.view endEditing:YES];
    NSArray *sheetTitles = [self cloudLoginDictionary].allKeys;
    __weak typeof(self) weakSelf = self;
    CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:[sheetTitles copy] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
        if (buttonIndex != 0 && sheetTitles.count > buttonIndex-1) {
            [weakSelf setupCloudLoginServiceUrl:sheetTitles[buttonIndex-1]];
        }
    }];
    [actionSheet show];
}
- (NSDictionary *)cloudLoginDictionary {
    NSString *path = [[NSBundle mainBundle] pathForResource:kCloudLoginPlistName ofType:@"plist"];
    if (path) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    }
   return nil;
}

- (void)setupCloudLoginServiceUrl:(NSString *)key {
    [_loginView.orgCodeChangeButton setTitle:key forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults]setObject:key forKey:kCloudLoginKey];
}






@end




