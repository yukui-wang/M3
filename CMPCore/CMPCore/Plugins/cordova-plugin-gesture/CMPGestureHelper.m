//
//  CMPGestureHelper.m
//  CMPCore
//
//  Created by Kaku_Songu on 17/2/15.
//
//

#import "CMPGestureHelper.h"
#import "CMPEncryptPlugin.h"
#import "CMPCommonManager.h"
#import <CMPLib/CMPCore.h>
#import "CMPGestureView.h"
#import "AppDelegate.h"
#import <CMPLib/GTMUtil.h>
#import "CMPCommonManager.h"
#import "M3LoginManager.h"
@interface CMPGestureHelper()<CMPGestureViewDelegate>
@end

@implementation CMPGestureHelper

- (void)dealloc
{
    [_currentGestureView release];
    _currentGestureView = nil;
    [_beginTime release];
    _beginTime = nil;
    _delegate = nil;
    _transParams = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

static CMPGestureHelper *_helper = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _helper = [[super allocWithZone:NULL] init];
        [_helper initHelper];
    });
    return _helper;
}

- (oneway void)release
{
    //
}

- (void)initHelper
{
    self.gesSwitchState = YES;
}

- (void)setGesSwitchState:(BOOL)gesSwitchState
{
    NSString *userId = [CMPCore sharedInstance].userID;
    if (userId) {
        NSString *key = [userId stringByAppendingString:@"gestureConfigSwitchState"];
        NSString *val = gesSwitchState==YES? @"1":@"2";
        [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)getGesSwitchState
{
    NSString *userId = [CMPCore sharedInstance].userID;
    if (userId) {
        NSString *key = [userId stringByAppendingString:@"gestureConfigSwitchState"];
        NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        BOOL au = [val isEqualToString:@"1"] ? YES:NO;
        if (au) {
            return au;
        }
    }
    return NO;
}

- (void)setGesturePwd:(NSString *)gesturePwd
{
    NSString *userId = [CMPCore sharedInstance].userID;
    if (userId) {
        NSString *key = [userId stringByAppendingString:@"gestureConfigPwd"];
        [[NSUserDefaults standardUserDefaults] setObject:(gesturePwd ? gesturePwd:@"") forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)getGesturePwd
{
    NSString *gesturePassword = [CMPCore sharedInstance].currentUser.gesturePassword;
    if (![NSString isNull:gesturePassword]) {
        return gesturePassword;
    }
    
    // 兼容老版本，从NSUserDefaults中取手势密码
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *aStr = [userDefaults objectForKey:@"kUserInfo_M3"];
    NSDictionary *aDict = [aStr JSONValue];
    if (aDict && [aDict isKindOfClass:[NSDictionary class]]) {
        NSString *userId = aDict[@"userID"];
        if (userId) {
            NSString *key = [userId stringByAppendingString:@"gestureConfigPwd"];
            NSString *pwd = [userDefaults objectForKey:key];
            if (![NSString isNull:pwd]) {
                return pwd;
            }
        }
    }
    
    return @"";
}

- (BOOL)getLoginState
{
    NSString *jesession = [CMPCore sharedInstance].jsessionId;
    if (![NSString isNull:jesession] && jesession.length > 0) {
        return YES;
    }
    return NO;
}

//***************************

- (void)hideGestureView {
    self.delegate = nil;
    if (_currentGestureView) {
        _currentGestureView.hidden = YES;
        _currentGestureView.gestureDelegate = nil;
//        [_currentGestureView removeAllSubviews]; // 要崩溃
        [_currentGestureView removeFromSuperview];
        [_currentGestureView release];
        _currentGestureView = nil;
    }
    self.from = - 1;
    _transParams = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_GestureWillHiden object:nil];
}

- (void)initGestureViewWithName:(NSString *)aName pwd:(NSString *)aPwd gesPwd:(NSString *)aGesPwd imageUrl:(NSString *)aUrl
{
    // 销毁之前的
    _currentGestureView.hidden = YES;
    _currentGestureView.gestureDelegate = nil;
    [_currentGestureView removeAllSubviews];
    [_currentGestureView removeFromSuperview];
    [_currentGestureView release];
    // 销毁完成
    _currentGestureView = [[CMPGestureView alloc] init];
    _currentGestureView.gestureDelegate = self;
    _currentGestureView.correctGuestureLockPaswd = [GTMUtil decrypt:aGesPwd];
    _currentGestureView.userpassword = [GTMUtil decrypt:aPwd];
    _currentGestureView.username = aName;
    _currentGestureView.imageUrl = aUrl;
}

- (void)showGestureViewWithDelegate:(id<CMPGestureHelperDelegate>)aDelegate from:(GESTURE_FROM)from object:(NSDictionary *)object ext:(__nullable id)ext
{
    AppDelegate *aAppDelegate = [UIApplication sharedApplication].delegate;
    aAppDelegate.allowRotation = NO;
    if (INTERFACE_IS_PHONE) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
    self.autoClose = YES; // 默认为yes
    self.from = from;
    self.delegate = aDelegate;
    _transParams = [ext mutableCopy];
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        // 错误统一处理
        [self.delegate gestureHelperDidFail:self];
        return;
    }
    if (from == FROM_INIT) {
        BOOL showLeftArrow = [[object objectForKey:@"showLeftArrow"] boolValue];
        self.autoClose = [[object objectForKey:@"autoHide"] boolValue];
        [self dispatchAsyncToMain:^{
            [self initGestureViewWithName:nil pwd:nil gesPwd:nil imageUrl:nil];
            _currentGestureView.showLeftArrow = showLeftArrow;
            [_currentGestureView loadViewsWithType:CMPGestureViewType_Set];
            if (showLeftArrow) {
                [_currentGestureView showAnimateFromDirection:Direction_Right completion:nil];
            }
            else {
                [_currentGestureView show];
            }
        }];
    }
    else if (from == FROM_VERIFY || from == FROM_BACKGROUND) {
        NSString *userpassword = [object objectForKey:@"userpassword"];
        id gespasswordobj = [object objectForKey:@"gespassword"];
        NSString *gespassword = [gespasswordobj isKindOfClass:[NSString class]]?gespasswordobj:@"";
        NSString *username = [object objectForKey:@"username"];
        NSString *imgUrl = [object objectForKey:@"imgUrl"];
//        userpassword = [CMPEncryptPlugin decrypt:userpassword];
        self.autoClose = [[object objectForKey:@"autoHide"]boolValue];
//        NSString *index_ =[[CMPCommonManager appdelegate] fetchTabBarDefaultApp];
//        if ([@"62" isEqualToString:index_]) { //如果默认index为通讯录
//            self.autoClose = YES;
//        }
        self.gesturePwd = gespassword;
        // 返回完成后的密码串
        [self dispatchAsyncToMain:^{
            [self initGestureViewWithName:username pwd:userpassword gesPwd:gespassword imageUrl:imgUrl];
            [_currentGestureView loadViewsWithType:CMPGestureViewType_Verify];
            [_currentGestureView show];
        }];
    }
}

- (void)closeGestureViewWithType:(GESTURE_TYPE)aType
{
    Direction aDirection = Direction_None;
    if (_helper.from == FROM_BACKGROUND){
    }
    else if (aType == TYPE_RETURN || (aType == TYPE_SET && _currentGestureView.showLeftArrow))
    {
        aDirection = Direction_Right;
    }
    else if (_helper.autoClose || aType == TYPE_FORGET || aType == TYPE_OTHER) {
        //
    }
    [_helper.currentGestureView closeAnimateToDirection:aDirection completion:^{
        [_helper hideGestureView];
    }];
}

- (void)dealResultWithType:(GESTURE_TYPE)type object:(id)object
{
    switch (type) {
        case TYPE_NORMAL:
            break;
        case TYPE_FORGET: {
            self.gesturePwd = @"";
            self.gesSwitchState = NO;
            if (self.from == FROM_BACKGROUND) {
                [self showLoginPage];//没有传给js，应该webview执行一个方法
            }
            break;
        }
        case TYPE_OTHER: {
            if (self.from == FROM_BACKGROUND) {
                [self showLoginPage];//没有传给js
            }
            break;
        }
        case TYPE_SET: {
            self.gesturePwd = (NSString *)object;
            self.gesSwitchState = YES;
            break;
        }
        case TYPE_PWDWRONG: {
            self.gesturePwd = @"";
            self.gesSwitchState = NO;
            if (self.from == FROM_BACKGROUND) {
                [self showLoginPage];//没有传给js
            }
            break;
        }
        default:
            break;
    }
}

//在从后天进入的时候，当用户点击忘记手势密码或者其他账号登录时，要跳转到登录页
- (void)showLoginPage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_GestureShowLoginView object:nil];
//    [CMPCommonManager showM3LoginPage];
}

#pragma -mark CMPGestureViewDelegate
- (void)gestureViewSkip:(CMPGestureView *)gestureView
{
    // 回调
    [self.delegate gestureHelperSkip:self];
    // 关闭手势界面
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_NORMAL];
    }
}

- (void)gestureViewReturn:(CMPGestureView *)gestureView
{
    // 回调
    [self.delegate gestureHelperReturn:self];
    // 关闭手势界面
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_RETURN];
    }
}

- (void)gestureView:(CMPGestureView *)gestureView didSetPassword:(NSString *)password
{
    // 手势密码需要加密
    NSString *aPwd = [GTMUtil encrypt:password];
    // 回调
    [self.delegate gestureHelper:self didSetPassword:aPwd];
    // 关闭手势界面
    [_helper dealResultWithType:TYPE_SET object:aPwd];
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_SET];
    }
}

- (void)gestureViewDidGetCorrectPswd:(CMPGestureView *)gestureView {
    // 回调
    [self.delegate gestureHelperDidGetCorrectPswd:self];
    // 关闭手势界面
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_NORMAL];
    }
    else {
        // todo 需要修改
        [_currentGestureView showLoading];
    }
}

- (void)gestureViewDidGetIncorrectPswd:(CMPGestureView *)gestureView
{
    // 回调
    [self.delegate gestureHelperDidGetIncorrectPswd:self];
    // 关闭手势界面
    [self dealResultWithType:TYPE_PWDWRONG object:nil];
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_NORMAL];
    }
}

- (void)gestureViewForgetPswd:(CMPGestureView *)gestureView inputPassword:(NSString *)password
{
    // 回调
    [self.delegate gestureHelperForgetPswd:self inputPassword:password];
    // 关闭手势界面
    [self dealResultWithType:TYPE_FORGET object:nil];
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_FORGET];
    }
    [CMPCore sharedInstance].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)gestureViewOtherVerify:(CMPGestureView *)gestureView
{
    // 回调
    [self.delegate gestureHelperOtherVerify:self];
    // 关闭手势界面
    [self dealResultWithType:TYPE_OTHER object:nil];
    if (self.autoClose) {
        [self closeGestureViewWithType:TYPE_OTHER];
    }
    [CMPCore sharedInstance].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
