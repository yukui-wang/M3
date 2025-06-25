//
//  CMPLoginViewController.m
//  M3
//
//  Created by CRMO on 2017/10/24.
//

#import "CMPLoginViewController.h"
#import "CMPLoginView.h"
#import <CMPLib/CMPConstant.h>
#import "CMPServerListViewController.h"
#import <CMPLib/CMPDataProvider.h>
#import <CMPLib/GTMUtil.h>
#import "M3LoginManager.h"
#import "AppDelegate.h"
#import "CMPMigrateWebDataViewController.h"
#import "CMPCheckUpdateManager.h"
#import <CMPLib/CMPAppManager.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/EGOCache.h>
#import <CMPLib/UIColor+Hex.h>
#import "CMPServerEditViewController.h"
#import <CMPLib/UIButton+WebCache.h>
#import "CMPCloudLoginHelper.h"
#import "CMPCookieTool.h"
#import "CMPForgotPasswordViewController.h"
#import <CMPLib/CMPBannerWebViewController+Create.h>
#import <CMPLib/CMPLoginDBProvider.h>
#import "CMPPrivacyProtocolWebViewController.h"

#import "TrustdoLoginManager.h"
#import "SyScanViewController.h"
#import "CMPCommonManager.h"
#import <CMPLib/SvUDIDTools.h>
#import <CMPLib/KSLogManager.h>
#import "CMPMsgQuickHandler.h"
#import "CMPVerifyCodeViewController.h"

@interface CMPLoginViewController ()<CMPDataProviderDelegate, SyScanViewControllerDelegate>

@property (nonatomic, strong) CMPLoginView *loginView;
@property (strong, nonatomic) NSString *loginName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *verificationUrl;
@property (strong, nonatomic) CMPCloudLoginHelper *cloudLoginHelper;
@property (copy, nonatomic) NSString *lastServerID;

@end

@implementation CMPLoginViewController

#pragma mark-
#pragma mark-Life circle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowRotation = NO;
    self.navigationController.navigationBarHidden = YES;
    [CMPMigrateWebDataViewController shareInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenNotificationWhenApplicationWillEnterForeground:)
                                                 name:kNotificationName_ApplicationWillEnterForeground
                                               object:nil];
    [self updateDatabaseOldAccountAlreadyPopuUppPrivacypPage];
    
    [self.loginView.policySelectButton setSelected:NO];
    
    [KSLogManager registerOnView:self.view delegate:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_MokeyLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName_MokeySDKNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMokeyLoginSuccessNotification:)
                                                 name:kNotificationName_MokeyLoginSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMokeySDKNotification:)
                                                 name:kNotificationName_MokeySDKNotification
                                               object:nil];
    
    CMPLoginViewStyle *currentStyle = [self currentLoginViewStyle];
    if (InterfaceOrientationIsPortrait) {
        [self updateBackgroundUrl:currentStyle.backgroundImage];
    } else {
        [self updateBackgroundUrl:currentStyle.backgroundLandscapeImage];
    }
    
    // 如果有单位ID更新
    if (![NSString isNull:[CMPCore sharedInstance].currentUser.accountID]) {
        [self requestBackground];
    }
    
    NSString *currentServerID = [CMPCore sharedInstance].serverID;
    // 只有切换了服务器才更新历史账号密码，如果从服务器页面点击返回不更新
    if (![NSString isNull:currentServerID] &&
        ![self.lastServerID isEqualToString:currentServerID]) {
        NSLog(@"zl---[%s]切换了服务器，隐藏验证码", __FUNCTION__);
        [self showHistoryUsername];
        [self hideVerification];
        [self useMokeyTag];
    } else if ([NSString isNull:self.lastServerID]) {
        // self.lastServerID为空，说明用户退出登录返回登录页，回填历史手机号
        // 解决偶发出现掉线返回登录页，currentServerID为空导致历史手机号不回填问题
        [self showHistoryUsername];
    }
    
    self.loginView.style = currentStyle;
    
    // 初始化SSO账号、密码信息
    [self _initSSOInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     if ([NSString isNotNull:self.errorMessage] && ![[M3LoginManager sharedInstance] needDeviceBind:self.error]) {
           if ([self.errorMessage isEqualToString:kNotificationMessage_MokeyAutoLogin]) {
               [self tapLogin];
           }else if(self.error.code == CMPLoginErrorDeviceBindedException){
               NSString *aUDID = [SvUDIDTools UDID];
               NSString *aPartUdid = (aUDID.length >= 8) ? [aUDID substringWithRange:NSMakeRange(aUDID.length-8, 8)] : aUDID;
               [self showAlertWithTitle:self.error.domain message:[NSString stringWithFormat:@"%@: ******%@",@"当前设备已被绑定",aPartUdid] cancelTitle:@"确定"];
           } else {
               [self showAlertMessage:self.errorMessage];
               self.errorMessage = nil;
           }
       }
    
    NSString *verificationCodeUrl = [[M3LoginManager sharedInstance] verificationCodeUrl:self.error];
    if (!verificationCodeUrl.length && [CMPCore sharedInstance].firstShowValidateCode) {
        //默认请求验证码
        verificationCodeUrl = @"/seeyon/verifyCodeImage.jpg";
    }
    if (![NSString isNull:verificationCodeUrl]) { // 自动登录，需要验证码回到登录页，默认展示验证码
        if (self.error || !_loginView.verificationView.imageView.image) {
            [self showVerificationWithUrl:verificationCodeUrl];
        }
    } else { // 到登录页，如果不需要验证码，清空cookie
        [CMPCookieTool clearCookiesAndCache];
        [self.loginView clearVerificationState];
        self.verificationUrl = nil;
    }
    self.error = nil;
    
    [CMPMsgQuickHandler shareInstance].enterRoute = 1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.lastServerID = [CMPCore sharedInstance].serverID;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    CMPLoginViewStyle *currentStyle = [self currentLoginViewStyle];
    if (InterfaceOrientationIsPortrait) {
        [self updateBackgroundUrl:currentStyle.backgroundImage];
    } else {
        [self updateBackgroundUrl:currentStyle.backgroundLandscapeImage];
    }
}

- (void)listenNotificationWhenApplicationWillEnterForeground:(NSNotification *)notification {
    if (![NSString isNull:self.verificationUrl]) {
        if (self.error || !_loginView.verificationView.imageView.image) {
            [self _refreshVerification];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.loginView dismissKeybord];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}

#pragma mark 手机盾登录成功的回调
- (void)getMokeyLoginSuccessNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    __weak typeof(self) weakself = self;
    [[M3LoginManager sharedInstance] requestMokeyLoginWithUserName:self.loginName password:@"" encrypted:NO refreshToken:NO verificationCode:@"" type:CMPLoginAccountModelLoginTypeMokey accToken:userInfoDic[@"message"] start:^{
        [weakself showLoadingView];
    } success:^{
        // 测试要求，点击手动登录，再检查一次更新。特殊处理
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
//            [weakself _loginSuccess];
            BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
                [weakself _mokeyLoginSuccessAndTagPopUpPrivacyProtocolPage];
            }];
            if (isPopUpPrivacyProtocolPage) return;
            [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
        }];
    } fail:^(NSError *error) {
        [weakself _loginFail:error];
    }];
}

#pragma mark 手机盾SDK返回的数据回调
- (void)getMokeySDKNotification:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    NSString *messageStr = userInfoDic[@"message"];
    [self showToastWithText:messageStr];
}


#pragma mark-按钮点击事件

/**
 点击登陆按钮
 */
- (void)tapLogin {
    [self.loginView dismissKeybord];
    
    //ks fix V5-11720 隐私协议--ios】6.1sp2---7.1sp1，低版本的 隐私协议登录页面都没有勾选，就直接登录进入了
    if (_loginView.policySelectButton && !_loginView.policySelectButton.hidden &&!_loginView.policySelectButton.selected) {
        [self showAlertMessage:SY_STRING(@"login_policy_select_policy_detail")];
        return;
    }
    
    self.loginName = self.loginView.username;
    self.phone = self.loginView.phone;
    NSString *verificationCode = self.loginView.verificationInputView.text;
    
    CMPLoginViewMode loginMode = self.loginView.loginMode;
    
    if (loginMode == CMPLoginViewModeLegacy) {
        self.password = self.loginView.password;
        if ([NSString isNull:CMPCore.sharedInstance.serverurl]) {
            [self showAlertMessage:SY_STRING(@"login_server_uninit")];
            return;
        }
        if ([NSString isNull:self.loginName] ||
            [NSString isNull:self.password]) {
            [self showAlertMessage:SY_STRING(@"login_input_empty")];
            return;
        }
        [self loginWithLoginName:self.loginName password:self.password verificationCode:verificationCode];
    } else if (loginMode == CMPLoginViewModePhone) {
        self.password = self.loginView.phonePwdView.text;
        if ([NSString isNull:self.phone] ||
            [NSString isNull:self.password]) {
            [self showAlertMessage:SY_STRING(@"login_input_empty2")];
            return;
        }
        [self loginWithPhone:self.phone password:self.password verificationCode:verificationCode];
    } else if (loginMode == CMPLoginViewModeMokey) {
        [self showLoadingView];
        self.loginName = self.loginView.mokeyUsername;
        if ([NSString isNull:self.loginName]) {
            [self showAlertMessage:SY_STRING(@"login_account_null_tips")];
            return;
        }
        [self loginWithMokeyLoginName:self.loginName];
    }
}

- (void)loginWithMokeyLoginName:(NSString *)loginName {
    [[TrustdoLoginManager sharedInstance] getMokeyKeyIdWithLoginName:loginName Style:@"1"];
     [self hideLoadingView];
}

- (void)loginWithLoginName:(NSString *)loginName password:(NSString *)password verificationCode:(NSString *)verificationCode {
    __weak typeof(self) weakself = self;
    //ks add -- 双因子登录 0926
    [M3LoginManager sharedInstance].loginProcessBlk = ^(NSInteger step, NSError *error, id  _Nullable ext) {
        if (!error) {
            if (step == 1) {
                CMPVerifyCodeViewController *vc = [[CMPVerifyCodeViewController alloc] initWithNumber:ext ext:@{@"loginName":loginName?:@""}];
                __weak typeof(CMPVerifyCodeViewController *) wVc = vc;
                vc.completion = ^(BOOL success, NSError * _Nonnull err, id  _Nonnull ext) {
                    if (success) {
//                        [wVc.navigationController popViewControllerAnimated:YES];
                        [weakself _loginSuccess];
                    }else{
                        [wVc showToastWithText:err.domain];
                    }
                };
                [weakself.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [weakself _loginFail:error];
        }
    };
    //end
    [[M3LoginManager sharedInstance] requestLoginWithUserName:loginName
                                                     password:password
                                                    encrypted:NO
                                                 refreshToken:NO
                                             verificationCode:verificationCode
                                                         type:CMPLoginAccountModelLoginTypeLegacy
                                                 externParams:nil
                                                        start:^{
        [weakself showLoadingView];
    } success:^{
        // 测试要求，点击手动登录，再检查一次更新。特殊处理
        [[CMPCheckUpdateManager sharedManager] startCheckUpdate:^(BOOL success) {
            BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
                [weakself _loginSuccessAndTagPopUpPrivacyProtocolPage];
            }];
            if (isPopUpPrivacyProtocolPage) return;
            [weakself _loginSuccess];
        }];
    } fail:^(NSError *error) {
        [weakself _loginFail:error];
    }];
}

- (void)loginWithPhone:(NSString *)phone password:(NSString *)password verificationCode:(NSString *)verificationCode {
    __weak typeof(self) weakself = self;
    [self showLoadingView];
    [self.cloudLoginHelper loginWithPhone:phone password:password verificationCode:verificationCode loginType:nil success:^{
        BOOL isPopUpPrivacyProtocolPage = [weakself popUpPrivacyProtocolPageWithBlock:^{
           [weakself _loginSuccessAndTagPopUpPrivacyProtocolPage];
        }];
        if (isPopUpPrivacyProtocolPage) return;
        [weakself _loginSuccess];
        [M3LoginManager saveHistoryPhone:phone];
    } fail:^(NSError * _Nonnull error) {
        [weakself _loginFail:error];
    }];
}

- (void)updateDatabaseOldAccountAlreadyPopuUppPrivacypPage {
    NSString *databaseUpdateFlag = kUserDefaultName_DatabaseOldAccountAlreadyPopuUppPrivacypPage;
    BOOL databaseUpdateValue = [[NSUserDefaults standardUserDefaults] boolForKey:databaseUpdateFlag];
    CMPLoginDBProvider *loginDBProvider = [CMPCore sharedInstance].loginDBProvider;
    if (!databaseUpdateValue) {
        [loginDBProvider updateDatabaseOldAccountAlreadyPopuUppPrivacypPage];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:databaseUpdateFlag];
    }
}

- (BOOL)popUpPrivacyProtocolPageWithBlock:(void (^)(void))agreeButtonActionBlock {
      CMPCore *core = [CMPCore sharedInstance];
      if(core.isByPopUpPrivacyProtocolPage && !core.currentUser.extraDataModel.isAlreadyShowPrivacyAgreement) {
        [self hideLoadingViewWithoutCount];
        CMPPrivacyProtocolWebViewController *viewController = [[CMPPrivacyProtocolWebViewController alloc] init];
        viewController.agreeButtonActionBlock = agreeButtonActionBlock;
        viewController.startPage = [CMPCommonManager privacyAgreementUrl];
        viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self.navigationController presentViewController:viewController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

- (void)_loginSuccessAndTagPopUpPrivacyProtocolPage {
    CMPCore *core = [CMPCore sharedInstance];
    CMPLoginDBProvider *loginDBProvider = core.loginDBProvider;
    CMPLoginAccountModel *loginAccountModel = core.currentUser;
    CMPLoginAccountExtraDataModel *extraDataModel = [CMPLoginAccountExtraDataModel yy_modelWithJSON:loginAccountModel.extend10];
    extraDataModel.isAlreadyShowPrivacyAgreement = YES;
    NSString *extraDataModelStr = [extraDataModel yy_modelToJSONString];
    [loginDBProvider updateAccount:loginAccountModel extend10:extraDataModelStr];
    [self _loginSuccess];
}

- (void)_mokeyLoginSuccessAndTagPopUpPrivacyProtocolPage {
    CMPCore *core = [CMPCore sharedInstance];
    CMPLoginDBProvider *loginDBProvider = core.loginDBProvider;
    CMPLoginAccountModel *loginAccountModel = core.currentUser;
    CMPLoginAccountExtraDataModel *extraDataModel = [CMPLoginAccountExtraDataModel yy_modelWithJSON:loginAccountModel.extend10];
    extraDataModel.isAlreadyShowPrivacyAgreement = YES;
    NSString *extraDataModelStr = [extraDataModel yy_modelToJSONString];
    [loginDBProvider updateAccount:loginAccountModel extend10:extraDataModelStr];
    [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
}

- (void)_loginSuccess {
    [self requestBackground];
    [self hideLoadingViewWithoutCount];
    // 需要判断是否需要设置手势密码
    if ([[M3LoginManager sharedInstance] needSetGesturePassword]) {
        [[AppDelegate shareAppDelegate] showSetGesturePwdView];
    } else {
        [[AppDelegate shareAppDelegate] showTabBarWithHideAppIds:nil didFinished:nil];
    }
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
        if (error.code == CMPLoginErrorPhoneUnknown) {
            // 未绑定手机号，使用手机号登录，提示之后自动跳转账号密码界面
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAttributedString *formatMessage = [[NSAttributedString alloc] initWithData:[error.domain dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[formatMessage string] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.loginView switchToLegacyLogin];
                }];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }else if (error.code == CMPLoginErrorDeviceBindedException){
            
            NSString *aUDID = [SvUDIDTools UDID];
            NSString *aPartUdid = (aUDID.length >= 8) ? [aUDID substringWithRange:NSMakeRange(aUDID.length-8, 8)] : aUDID;
            [self showAlertWithTitle:error.domain message:[NSString stringWithFormat:@"%@: ******%@",@"当前设备已被绑定",aPartUdid] cancelTitle:@"确定"];
            
        }else if (error.code == -1001){
            NSString *msg = [SY_STRING(@"Common_Network_Disconnect") stringByAppendingFormat:@"[%ld]",error.code];
            [self showAlertMessage:msg];
        }  else {
            id domain = error.domain;
            NSString *errmsg = domain;
            if (domain && [domain isKindOfClass:NSString.class]) {
                domain = [domain JSONValue];
            }
            if (domain && [domain isKindOfClass:[NSDictionary class]]) {
                NSString *msg = [NSString stringWithFormat:@"%@",domain[@"message"]];
                if ([NSString isNotNull:msg]) {
                    errmsg = msg;
                }
            }
            [self showAlertMessage:errmsg];
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

/**
 点击设置按钮
 */
- (void)tapSetting {
    [self.loginView dismissKeybord];
    UIViewController *vc = nil;
    NSInteger serverCount = [[CMPCore sharedInstance].loginDBProvider countOfServer];
    if (serverCount == 0) {
        // 如果服务器数量为0，点击设置服务器按钮进入添加页面
        vc = [[CMPServerEditViewController alloc] init];
        ((CMPServerEditViewController *)vc).mode = CMPServerEditViewControllerModeAdd;
    } else {
        // 默认进入服务器列表页面
        vc = [[CMPServerListViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 点击忘记密码
 */
- (void)tapForget {
    [self.loginView dismissKeybord];
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

/**
 点击隐私政策
 */
- (void)tapPolicy {
    CMPBannerWebViewController *viewController = [[CMPBannerWebViewController alloc] init];
    viewController.startPage = [CMPCommonManager privacyAgreementUrl];
    viewController.closeButtonHidden = YES;
    viewController.hideBannerNavBar = NO;
    viewController.isShowBannerProgress = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

/**
 手机盾点击扫一扫
 **/
-(void)tagScan {
    SyScanViewController *scanViewController = [SyScanViewController scanViewController];
    scanViewController.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:scanViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark-
#pragma mark SyScanViewControllerDelegate

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
    
    NSString *opType = [NSString stringWithFormat:@"%@", aJson[@"opType"]];
    NSString *qrData = [NSString stringWithFormat:@"%@", aJson[@"qrData"]];
    
    if ([opType isEqualToString:@"(null)"] || [qrData isEqualToString:@"(null)"]) {
        [self showToastWithText:SY_STRING(@"login_scan_err")];
        [scanViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // 手机盾重置功能
    if ([opType isEqualToString:@"4"]) {
        [[TrustdoLoginManager sharedInstance] doMokeyResetWithLoginName:self.loginView.mokeyUsername EventData:qrData Style:@"2"];
    } else if ([opType isEqualToString:@"2"]) {
        [self showToastWithText:SY_STRING(@"login_mokey_scan_login")];
    } else {
        [self showToastWithText:SY_STRING(@"login_mokey_scan_nosupport")];
    }
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma mark-Getter & Setter

- (CMPLoginView *)loginView {
    __weak typeof(self) weakself = self;
    if (!_loginView) {
        _loginView = (CMPLoginView *)self.mainView;
        _loginView.loginAction = ^{
            [weakself tapLogin];
        };
        _loginView.settingAction = ^{
            [weakself tapSetting];
        };
        _loginView.forgetPwdAction = ^{
            [weakself tapForget];
        };
        _loginView.loginAccountDidChange = ^{
            [weakself hideVerification];
        };
        _loginView.policyAction = ^{
            [weakself tapPolicy];
        };
        _loginView.scanAction = ^(BOOL isScan) {
            if (isScan == YES) {
                [weakself tagScan];
            } else {
                [weakself showToastWithText:SY_STRING(@"login_account_null_tips")];
            }
        };
    }
    return _loginView;
}

- (CMPCloudLoginHelper *)cloudLoginHelper {
    if (!_cloudLoginHelper) {
        _cloudLoginHelper = [[CMPCloudLoginHelper alloc] init];
    }
    return _cloudLoginHelper;
}

#pragma mark-
#pragma mark-网络请求

- (void)requestBackground {
    CMPDataRequest *aDataRequest = [[CMPDataRequest alloc] init];
   NSString *url = [CMPCore fullUrlPathMapForPath:@"/seeyon/m3/homeSkinController.do"];
    url = [url appendHtmlUrlParam:@"method" value:@"getSkinImageUrl"];
    url = [url appendHtmlUrlParam:@"imageType" value:@"bg"];
    url = [url appendHtmlUrlParam:@"phoneType" value:@"iphone"];
    url = [url appendHtmlUrlParam:@"companyId" value:[CMPCore sharedInstance].currentUser.accountID];
    [url appendHtmlUrlParam:@"companyId" value:[CMPCore sharedInstance].currentUser.accountID];
    aDataRequest.requestUrl = url;
    aDataRequest.delegate = self;
    aDataRequest.requestMethod = @"GET";
    aDataRequest.headers = [CMPDataProvider headers];
    aDataRequest.requestType = kDataRequestType_Url;
    aDataRequest.httpShouldHandleCookies = NO;
    [[CMPDataProvider sharedInstance] addRequest:aDataRequest];
}

- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider
                      request:(CMPDataRequest *)aRequest
                     response:(CMPDataResponse *)aResponse {
    NSDictionary *strDic = [aResponse.responseStr JSONValue];
    if (!strDic ||
        ![strDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *imageRelatePath = nil;
    id data = strDic[@"data"];
    
    // 服务器返回数据不是标准数据
    if (!data || (![data isKindOfClass:[NSString class]] && ![data isKindOfClass:[NSDictionary class]])) {
        return;
    }
    
    CMPLoginViewStyle *style = [CMPLoginViewStyle defaultStyle];
    BOOL isDefault = NO;
    
    if ([data isKindOfClass:[NSString class]]) {
        imageRelatePath = data;
        if ([NSString isNull:imageRelatePath]) {
            style.backgroundImage = nil;
            style.backgroundLandscapeImage = nil;
        }else {
            NSString *imageUrl = [CMPCore fullUrlForPath:imageRelatePath];
            style.backgroundImage = imageUrl;
            style.backgroundLandscapeImage = imageUrl;
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) { // 1130版本修改接口，新增登录文字颜色
        isDefault = data[@"deft"] ? [data[@"deft"] boolValue] : NO;
        imageRelatePath = data[@"bgImage"];
        NSString *inputTextColorStr = data[@"inputText"];
        NSString *selectedTagColorStr = data[@"selectedTag"];
        NSString *unselectTagColorStr = data[@"selectTag"];
        
        style.inputTextColor = [UIColor colorWithHexString:inputTextColorStr];
        style.tagSelectColor = [UIColor colorWithHexString:selectedTagColorStr];
        style.tagUnSelectColor = [UIColor colorWithHexString:unselectTagColorStr];
        
        NSDictionary *bgStyle = data[@"bgStyle"];
        if (bgStyle && [bgStyle isKindOfClass:[NSDictionary class]]) {
            NSNumber *maskAlpha = bgStyle[@"transparency"];
            NSString *maskColorStr = bgStyle[@"color"];
            style.backgroundMaskColor = [UIColor colorWithHexString:maskColorStr];
            style.backgroundMaskAlpha = [maskAlpha doubleValue] / 100;
        }
        
        NSString *imageUrl = [CMPCore fullUrlForPath:imageRelatePath];
        if (isDefault) {
            style.backgroundImage = nil;
            style.backgroundLandscapeImage = nil;
        }else {
            style.backgroundImage = imageUrl;
            style.backgroundLandscapeImage = imageUrl;
        }
        
        NSDictionary * moreBgImage = data[@"moreBgImage"];
        if (moreBgImage && [moreBgImage isKindOfClass:[NSDictionary class]]) {
            NSDictionary *bgImageDic = nil;
            if (INTERFACE_IS_PAD) {
                bgImageDic = moreBgImage[@"pad"];
            } else if (INTERFACE_IS_PHONE) {
                bgImageDic = moreBgImage[@"phone"];
            }
            
            if ([bgImageDic count]) {
                NSMutableDictionary *portraitCompareResultDic = [NSMutableDictionary dictionary];
                NSMutableDictionary *landscapeCompareResultDic = [NSMutableDictionary dictionary];
                CGFloat screenWidth = [UIScreen mainScreen].nativeBounds.size.width;
                CGFloat screenheight = [UIScreen mainScreen].nativeBounds.size.height;
                CGFloat portraitScale = screenWidth/screenheight;
                CGFloat landscapeScale = screenheight/screenWidth;
                
                [bgImageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([key isKindOfClass:NSString.class] && [key containsString:@"*"]) {
                        NSArray *sizeArr = [key componentsSeparatedByString:@"*"];
                        CGFloat width = [sizeArr[0] doubleValue];
                        CGFloat heght = [sizeArr[1] doubleValue];
                        CGFloat scale = width/heght;
                        CGFloat portraitCompare = fabs(scale - portraitScale);
                        CGFloat landscapeCompare = fabs(scale - landscapeScale);
                        [portraitCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:portraitCompare]];
                        [landscapeCompareResultDic setObject:obj forKey:[NSNumber numberWithDouble:landscapeCompare]];
                    }
                }];
                
                NSArray *portraitCompareResultArr = [portraitCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj1 compare:obj2];
                }];
                
                NSArray *landscapeCompareResultArr = [landscapeCompareResultDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    return [obj1 compare:obj2];
                }];
                
                NSString *portraitUrl = portraitCompareResultDic[portraitCompareResultArr.firstObject];
                NSString *landscapeUrl = landscapeCompareResultDic[landscapeCompareResultArr.firstObject];
                style.backgroundImage = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, portraitUrl];
                style.backgroundLandscapeImage = [NSString stringWithFormat:@"%@%@", [CMPCore sharedInstance].serverurl, landscapeUrl];
                
            } else {
                style.backgroundImage = nil;
                style.backgroundLandscapeImage = nil;
            }
        }
        
    }
    
    if (InterfaceOrientationIsPortrait) {
        [self updateBackgroundUrl:style.backgroundImage];
    } else {
        [self updateBackgroundUrl:style.backgroundLandscapeImage];
    }

    self.loginView.style = style;
    [self saveLoginViewStyle:style];
}

- (void)provider:(CMPDataProvider *)aProvider
         request:(CMPDataRequest *)aRequest
didFailLoadWithError:(NSError *)error {
    NSLog(@"zl---登录页，获取背景图片失败：%@", error);
    self.loginView.style = [self currentLoginViewStyle];
}

#pragma mark-
#pragma mark - 主题颜色

- (CMPLoginViewStyle *)currentLoginViewStyle {
    CMPLoginViewStyle *style = (CMPLoginViewStyle *)[[EGOCache globalCache] objectForKey:[self _loginViewStyleKey]];
    if (!style) {
        NSLog(@"zl---[login style]:没有获取到缓存样式，使用默认样式");
        return [CMPLoginViewStyle defaultStyle];
    }
    NSLog(@"zl---[login style]:获取到缓存样式：%@", style);
    return style;
}

- (void)saveLoginViewStyle:(CMPLoginViewStyle *)style {
    NSLog(@"zl---[login style]:缓存样式：%@", style);
    [[EGOCache globalCache] setObject:style forKey:[self _loginViewStyleKey]];
}

- (NSString*)_loginViewStyleKey {
    NSString *key = [NSString stringWithFormat:@"%@_loginViewStyle", [CMPCore sharedInstance].serverID];
    NSLog(@"zl---[login style]:缓存key%@", key);
    return key;
}

- (void)loadView {
    CGRect frame = [UIScreen mainScreen].bounds;
    if (!_mainView) {
        CMPLoginAccountModelLoginType loginType = [CMPCore sharedInstance].currentUser.loginType;
        CMPLoginViewMode mode = CMPLoginViewModeLegacy;
        if (loginType == CMPLoginViewModePhone) {
            mode = CMPLoginViewModePhone;
        } else if (loginType == CMPLoginViewModeMokey) {
            mode = CMPLoginViewModeMokey;
        }
        CMPBaseView *aView = (CMPBaseView *)[[CMPLoginView alloc] initWithFrame:frame style:[self currentLoginViewStyle] mode:mode];
        self.mainView = aView;
    }
    [super loadView];
}

#pragma mark-
#pragma mark 验证码

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
    [UIView animateWithDuration:0.3 animations:^{
        [self.loginView showVerification];
    }];
    [self.loginView.verificationView addTarget:self action:@selector(tapVerificationView:) forControlEvents:UIControlEventTouchUpInside];
    self.verificationUrl = url;
    [self _refreshVerification];
}

- (void)hideVerification {
    [UIView animateWithDuration:0.3 animations:^{
        [self.loginView hideVerification];
    }];
    self.verificationUrl = nil;
}

- (void)tapVerificationView:(id)sender {
    [self _refreshVerification];
}

- (void)_refreshVerification {
    __weak typeof(self) weakSelf = self;
    [[SDWebImageDownloader sharedDownloader] setValue:nil forHTTPHeaderField:@"ltoken"];
    [[SDWebImageDownloader sharedDownloader]
     downloadImageWithURL:[self verificationImageUrl:self.verificationUrl]
     options:SDWebImageDownloaderHandleCookies|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates
     progress:nil
     completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
         if (finished && !error) {
             [weakSelf.loginView.verificationView setImage:image forState:UIControlStateNormal];
         }
     }];
}

// 手机盾新增
-(void)useMokeyTag {
    [UIView animateWithDuration:0.3 animations:^{
        [self.loginView useMokeyTag];
    }];
}

#pragma mark-Tools

/**
 自动填充历史用户名密码
 企业账号登录：
 保存服务器地址，当前服务器有保存的账号，更新输入框账号，如果没有保存的账号，保留用户之前输入。
 手机号登录：
 与服务器地址没有关系，展示上一次输入的手机号。每次点击登录保存手机号，杀进程、退出登录自动填充。
 */
- (void)showHistoryUsername {
    CMPLoginViewMode loginMode = self.loginView.loginMode;
    // 自动填充企业账号
    if (loginMode == CMPLoginViewModeLegacy) {
        CMPLoginAccountModel *aUser = [[CMPCore sharedInstance] currentUserFromDB];
        // 自动填充企业账号
        NSString *aLoginName = [GTMUtil decrypt:aUser.loginName];
        NSString *aLoginPassword = [GTMUtil decrypt:aUser.loginPassword];
        if (![NSString isNull:aLoginName]) {
            self.loginView.username = aLoginName;
            self.loginView.password = aLoginPassword;
        }
    } else if (loginMode == CMPLoginViewModeMokey) {
        CMPLoginAccountModel *aUser = [[CMPCore sharedInstance] currentUserFromDB];
        // 自动填充手机盾账号
        NSString *aLoginName = [GTMUtil decrypt:aUser.loginName];
        if (![NSString isNull:aLoginName]) {
            self.loginView.mokeyUsername = aLoginName;
        }
    }
    
    // 自动填充手机号
    NSString *phone = [M3LoginManager historyPhone];
    if (![NSString isNull:phone]) {
        NSString *password = [[M3LoginManager sharedInstance] passwordWithPhone:[GTMUtil encrypt:phone]];
        password = [GTMUtil decrypt:password];
        self.loginView.phoneView.text = [phone formatPhoneNumber];
        self.loginView.phonePwdView.text = password;
    }
}

- (void)updateBackgroundUrl:(NSString *)url {
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    if (!imageUrl) { // 加载默认背景图
        self.loginView.backgroundImageView.image = [UIImage imageWithName:@"login_bg" type:@"png" inBundle:@"CMPLogin"];
        self.loginView.backgroundImageIconView.hidden = NO;
        return;
    }
    
    __weak typeof(self) weakself = self;
    
    [[SDWebImageManager sharedManager] loadImageWithURL:imageUrl options:SDWebImageContinueInBackground|SDWebImageAllowInvalidSSLCertificates|SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (!image || error) {
            weakself.loginView.backgroundImageView.image = [UIImage imageWithName:@"login_bg" type:@"png" inBundle:@"CMPLogin"];
            weakself.loginView.backgroundImageIconView.hidden = NO;
            return;
        }
        
        weakself.loginView.backgroundImageView.image = image;
        weakself.loginView.backgroundImageIconView.hidden = YES;
    }];
}

- (void)_initSSOInfo {
    if (![NSString isNull:_defaultUsername] &&
        ![NSString isNull:_defaultPassword]) {
        self.loginView.username = _defaultUsername;
        self.loginView.password = _defaultPassword;
    }
}

@end
