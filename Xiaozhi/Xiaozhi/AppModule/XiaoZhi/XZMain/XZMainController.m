//
//  XZMainController.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZMainController.h"
#import "XZTouchWindow.h"
#import "SPConstant.h"
#import "XZMainViewController.h"
#import "SPTools.h"
#import "SPSpeechEngine.h"
#import "XZCellModel.h"
#import "SPScheduleModel.h"
#import "SPWillDoneModel.h"
#import "SPWillDoneItemModel.h"
#import "SPAudioPlayer.h"
#import "SPWakeuper.h"
#import "XZDateUtils.h"
#import "XZCore.h"
#import "CMPSpeechRobotConfig.h"
#import "SPTimer.h"
#import "XZMemberModel.h"
#import "XZOptionMemberModel.h"
#import "XZOpenM3AppHelper.h"
#import "XZQATextModel.h"
#import "XZQAFileModel.h"
#import "XZTransWebViewController.h"
#import "XZM3RequestManager.h"
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XZSmartMsgManager.h"

#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPFaceImageManager.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPConstant.h>
#import "XZAppIntent.h"
#import "XZSearchAppIntent.h"
#import "XZCreateAppIntent.h"
#import "XZOpenAppIntent.h"

#import "XZMainProjectBridge.h"

#import "XZWebViewModel.h"
#import "XZCancelModel.h"
#import "XZSendIMMsgModel.h"
#import "XZSearchResultModel.h"
#import <CMPLib/NSObject+Thread.h>
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import "XZObtainOptionStep.h"
#import "CMPSpeechRobotManager.h"
#define MAX_UNKNOWN_COUNT 3 // 第n次输入未知一级命令后，回到主页面

typedef NS_ENUM(NSUInteger, XZMainControllerState) {
    XZMainControllerClose,   // 小致隐藏
    XZMainControllerSpeak,   // 小致正在说话
    XZMainControllerRecognize, // 小致正在识别
    XZMainControllerQuery, // 小致正在访问网络
    XZMainControllerSleep, // 小致休眠
};

typedef void(^AllSearchReturnBlock)(NSString *question);

@interface XZMainController() <SPSmartEngineDelegate, SPSpeechEngineDelegate, UIAlertViewDelegate,XZMainViewControllerDelegate,MFMessageComposeViewControllerDelegate> {

    XZTouchWindow *_touchWindow;//小智悬浮框
    XZMainViewController *_mainViewController;
    BOOL _showOrNot;
    BOOL _resultFromSpeech;//结果来自语音
    BOOL _xzCanUseWakeup;//小致能否使用语音唤醒
    BOOL _enterForegroundShowIcon;//冲后台到前台是否显示小致按钮
    NSInteger _intentErrorCount;// server替代unit版本用
    UIView *_touchWindowSupperview;
}

@property (nonatomic, assign) BOOL isShowMainView;
@property (nonatomic, assign) BOOL mainVCShowFirst;
@property (nonatomic, strong) XZMainViewController *mainViewController;

@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, strong) SPSpeechEngine *speechEngine;
@property (nonatomic) NSUInteger state; // 小致状态

@property (nonatomic) NSInteger unknownCount; // 未知一级命令计数器
@property (nonatomic) BOOL isContactSuccess; // 离线通讯录是否下载成功
@property (nonatomic) BOOL isLogout; // 是否退出登录
@property (nonatomic, strong) CMPSpeechRobotConfig *robotConfig; // 小致配置

@property (nonatomic, strong) NSString *currentStartTime; // 开始工作时间
@property (nonatomic, strong) NSString *currentEndTime; // 结束工作时间
@property (nonatomic) BOOL isInWorkTime; // 当前是否在工作时间段

@property(nonatomic, strong) NSString *optionKey;//选项识别缓存数据
@property (nonatomic, copy) void (^speakEndBlock)(void);
@property (nonatomic, copy) void (^speakEndStartWakeupBlock)(void);//语音结束加唤醒

@property(nonatomic, copy) NSString *QARequestId;//防止多次点击

@property (nonatomic, assign) NSInteger hideWindowCount;//hideWindowCount = 0时执行showspeech

@property (nonatomic, copy)void(^viewDidAppearBlock)(void);

@property (nonatomic, copy)AllSearchReturnBlock xzReturnBlock;//小致界面返回事件

@end

@implementation XZMainController
static id shareInstance;
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _touchWindow = nil;
    self.mainViewController = nil;
    self.currentText = nil;
    self.speechEngine = nil;
    self.smartEngine = nil;
    self.robotConfig = nil;
    self.currentStartTime = nil;
    self.currentEndTime = nil;
    self.optionKey = nil;
    self.speakEndBlock = nil;
    self.speakEndStartWakeupBlock = nil;
    self.QARequestId = nil;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [super allocWithZone:zone];
            }
        }
    }
    return shareInstance;
}

+ (instancetype)sharedInstance {
    if (shareInstance == nil) {
        @synchronized(self) {
            if (shareInstance == nil) {
                shareInstance = [[self alloc] init];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}


- (void)showInWindow{
    self.hideWindowCount = 0;
    _enterForegroundShowIcon = YES;
    _isLogout = NO;
        
    [self initSpeechEngine]; // 初始化语音引擎
    [self initSmartEngine]; // 初始化小致智能引擎
    [self registeNotification]; // 注册通知
    // 小致设置
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    if (permission == AVAudioSessionRecordPermissionUndetermined) {
        self.isInWorkTime = YES;
        [self initTouchWindow:^{
            [self startTimer:[XZCore sharedInstance].robotConfig];
        }];
        [self showTouchWindow];
    }else{
        [self initTouchWindow:^{}];
        [self startTimer:[XZCore sharedInstance].robotConfig];
    }
    
    //请求权限
    [self requestQAPermission];

    //开始显示智能消息
    [self startShowSmartMsg];

    //初始化小致配置：意图配置单、语音纠错、人员拼音校验
    [self initXiaozConfigure];
}

- (void)needShowXiaozIconInViewController:(UIViewController *)vc {
    UIViewController *controller = vc;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        controller = nav.viewControllers[0];
    }
    if(![controller isKindOfClass:[UIViewController class]]) return;
    _touchWindowSupperview = controller.view;
    if (_touchWindow && !_touchWindow.hidden) {
        [_touchWindow showInView:controller.view frame:vc.view.bounds];
    }
}

- (void)openXiaoz:(NSDictionary *)params {
    self.xzReturnBlock = params[@"returnBlock"];
    CMPBannerWebViewController *vc = params[@"pushVC"];
    if (vc && _mainViewController && self.xzReturnBlock) {
        //小致界面已经存在了，直接返回
        [vc backBarButtonAction:nil];
        self.xzReturnBlock(@"");
        self.xzReturnBlock = nil;
        return;
    }
    [self showMainviewWithGuideInfo:nil unit:nil pushConrroller:INTERFACE_IS_PHONE?vc:nil];
}

- (void)openAllSearchPage:(NSDictionary *)params{
    if (![self returnAllSearch:params[@"question"]]) {
        if (INTERFACE_IS_PAD) {
            //ipad 在插件处处理，此处仅关闭小致界面
            [self hideMainview];
            
            return;
        }
        NSString *url = params[@"url"];
        NSDictionary *urlParam = params[@"urlParam"];

        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:url]];
        aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
        aCMPBannerViewController.pageParam = urlParam;
        aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
        [_mainViewController.navigationController pushViewController:aCMPBannerViewController animated:YES];
    }
}
- (void)openQAPage:(NSDictionary *)params {
    if (_mainViewController) {
        NSDictionary *dataParams = params[@"params"];
        NSString *question = dataParams[@"question"];
        NSDictionary *answer = [SPTools dicValue:dataParams forKey:@"answer"];
        if (![NSString isNull:question]) {
            [_mainViewController humenSpeakText:question];
        }
        if (answer) {
            XZWebViewModel *model = [[XZWebViewModel alloc] initForQA];
            model.loadUrl = kXiaozQACardUrl;
            model.gotoParams = answer;
            [_mainViewController robotSpeakWithWebModel:model];
        }
        else {
            [self analysisResult:question];
        }
    }
}

- (BOOL)returnAllSearch:(NSString *)question {
    if (self.xzReturnBlock) {
        self.xzReturnBlock(question);
        self.xzReturnBlock = nil;
        [self hideMainview];
        return YES;
      }
    return NO;
}
/**
 初始小致图标
 */
- (void)initTouchWindow:(void(^)(void))tapBlock {
    if (!_touchWindow) {
        _touchWindow = [[XZTouchWindow alloc] init];
        _touchWindow.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _touchWindow.didClickTapBtn = ^(BOOL isShow) {
            if (tapBlock) {
                tapBlock();
            }
            [weakSelf showMainview];
        };
        if (_touchWindowSupperview) {
            _touchWindow.frame = CGRectMake(_touchWindowSupperview.width-60, _touchWindowSupperview.height-60, 60, 60);
            
        }
    }
}

/**
 初始化语音引擎
 */
- (void)initSpeechEngine {
    SPSpeechEngineType type = SPSpeechEngineBaidu;
    [SPWakeuper sharedInstance].type = type;
    _speechEngine = [SPSpeechEngine sharedInstance:type];
    _speechEngine.delegate = self;
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    [_speechEngine setupBaseInfo:[XZCore sharedInstance].baiduSpeechInfo];
}

/**
 初始化智能引擎
 */
- (void)initSmartEngine {
    _smartEngine = [XZSmartEngine sharedInstance];
    _smartEngine.delegate = self;
    [_smartEngine setupBaseInfo:[XZCore sharedInstance].baiduUnitInfo];
}

- (void)startTimer:(CMPSpeechRobotConfig *)config {
    [SPTimer removeAllSechedule];
    _currentStartTime = config.startTime;
    _currentEndTime = config.endTime;
    SPTimerScheduleItem *scheduleItem = [[SPTimerScheduleItem alloc] init];
    scheduleItem.startTime = config.startTime;
    scheduleItem.endTime = config.endTime;
    __weak typeof(self) weakself = self;
    scheduleItem.onAction = ^() {
        weakself.isInWorkTime = YES;
        [weakself handleRobotConfig];
    };
    scheduleItem.offAction = ^() {
        weakself.isInWorkTime = NO;
        [weakself handleRobotConfig];
    };
    [SPTimer addTimeSechedule:scheduleItem];
}

- (void)requestQAPermission {
    if (![[CMPCore sharedInstance] serverIsLaterV2_5_0]) {
        return;
    }
    [XZCore sharedInstance].qaPermissions = nil;
    NSString *url = [XZCore fullUrlForPath:kQAPermissionUrl];
    [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *result = [response  JSONValue];
        NSArray * qaPermissions = [SPTools arrayValue:result forKey:@"data"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dic in qaPermissions) {
            NSString *intentName = [SPTools stringValue:dic forKey:@"intentName"];
            if (![NSString isNull:intentName]) {
                [array addObject:intentName];
            }
        }
        [XZCore sharedInstance].qaPermissions = array;
    } fail:^(NSError *error,NSDictionary* userInfo) {
        
    }];
}

/**
 初始intent json 文件 判断更新 下载zip 解压
 */

- (void)initXiaozConfigure {
    XZCore *core = [XZCore sharedInstance];
    if (core.isM3ServerIsLater8) {
        if (core.downloadIntent) {
            [self downloadIntentJsonFileWithMd5:core.intentMd5Temp success:nil fail:nil];
        }
        if (core.downloadSpeechError) {
            [self downloadSpeechErrorCorrectionFile:core.spErrorCorrectionMd5Temp];
        }
        if (core.downloadRosterPinyin) {
            [self downloadPinyinRegularFile:core.pinyinRegularMd5Temp];
        }
    }
    else {
        [self initLocalIntentJsonFile];
        [self initSpeechErrorCorrectionFile];
    }
}


- (void)initLocalIntentJsonFile{

    [self requestIntentJsonFileWithSuccess:nil fail:nil];
}

- (void)requestIntentJsonFileWithSuccess:(void(^)(void))success
                                    fail:(void(^)(void))fail {
    //判断更新
    [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_Downloading;
    NSString *updateUrl = [XZCore fullUrlForPath:kIntentCheckMd5Url];
    NSString *md5 = [XZCore sharedInstance].intentMd5;
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:md5,@"md5", nil];
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:updateUrl params:params success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *updateInfo = [response JSONValue];
        NSDictionary *data = [SPTools dicValue:updateInfo forKey:@"data"];
        BOOL download = [SPTools boolValue:data forKey:@"download"];
        if (download) {
            NSString *newMd5 = [SPTools stringValue:data forKey:@"md5"];
            //下载zip
            [weakSelf downloadIntentJsonFileWithMd5:newMd5 success:success fail:fail];
        }
        else {
            [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_Sucess;
            if (success) {
                success();
            }
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_UpdateFailed;
        if (fail) {
            fail();
        }
    }];
    
}

- (void)downloadIntentJsonFileWithMd5:(NSString *)md5
                              success:(void(^)(void))success
                                 fail:(void(^)(void))fail {
    NSString *url = [XZCore fullUrlForPath:kIntentJsonDownloadUrl];
    NSString *path = [SPTools localIntentDownloadPath];
    [[XZM3RequestManager sharedInstance] downloadFileWithUrl:url params:nil localPath:path success:^(NSString *response,NSDictionary* userInfo) {
        //解压
        NSString *localPath = [SPTools unZipLocalIntents];
        if (localPath) {
            //更新MD5
            [XZCore sharedInstance].intentMd5 = md5;
            [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_Sucess;
            if (success) {
                success();
            }
        }
        else {
            [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_DownloadFailed;
            if (fail) {
                fail();
            }
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [XZCore sharedInstance].intentJsonState = XZIntentJsonFile_DownloadFailed;
        if (fail) {
            fail();
        }
    }];
}


//加载语音纠错文件：更新及下载
- (void)initSpeechErrorCorrectionFile{
    NSString *updateUrl = [XZCore fullUrlForPath:kSPErrorCorrectionCheckUrl];
    NSString *md5 = [XZCore sharedInstance].spErrorCorrectionMd5;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:md5,@"md5", nil];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:updateUrl params:params success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *updateInfo = [response JSONValue];
        NSDictionary *data = [SPTools dicValue:updateInfo forKey:@"data"];
        BOOL download = [SPTools boolValue:data forKey:@"download"];
        if (download) {
            NSString *newMd5 = [SPTools stringValue:data forKey:@"md5"];
            //下载zip
            [weakSelf downloadSpeechErrorCorrectionFile:newMd5];
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
    }];
}

- (void)downloadSpeechErrorCorrectionFile:(NSString *)md5{
    NSString *url = [XZCore fullUrlForPath:kSPErrorCorrectionDownloadUrl];
    NSString *path = [SPTools speechErrorCorrectionDownloadPath];
    [[XZM3RequestManager sharedInstance] downloadFileWithUrl:url params:nil localPath:path success:^(NSString *response,NSDictionary* userInfo) {
        //解压
        [SPTools unZipspeechErrorCorrection];
        //更新MD5
        [XZCore sharedInstance].spErrorCorrectionMd5 = md5;
    } fail:^(NSError *error,NSDictionary* userInfo) {
    }];
}

//加载拼音正则文件：更新及下载
- (void)downloadPinyinRegularFile:(NSString *)md5{
    NSString *url = [XZCore fullUrlForPath:kPinyinRegularDownloadUrl];
    NSString *path = [SPTools pinyinRegularDownloadPath];
    [[XZM3RequestManager sharedInstance] downloadFileWithUrl:url params:nil localPath:path success:^(NSString *response,NSDictionary* userInfo) {
       //解压
        [SPTools unZipPinyinRegularFile];
       //更新MD5
        [XZCore sharedInstance].pinyinRegularMd5 = md5;
    } fail:^(NSError *error,NSDictionary* userInfo) {
    }];
}


- (BOOL)reShowInWindow {
    if (_touchWindow) {
        [self mainViewControllerDidDismiss];
        return YES;
    }
    return NO;
}

- (void)closeInWindow {
    [self logout];
}

- (void)showQAWithIntentId:(NSString *)intentId {
    if (![[CMPCore sharedInstance] serverIsLaterV2_5_0]) {
        return;
    }
    if ([NSString isNull:intentId]) {
        return;
    }
    [[XZM3RequestManager sharedInstance] cancelWithRequestId:self.QARequestId];
    __weak typeof(self) weakself = self;
    NSString *url = [XZCore fullUrlForPathFormat:kOpenQAUrl,intentId];
    self.QARequestId = [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response,NSDictionary* userInfo) {
        weakself.QARequestId = nil;
        NSDictionary *result = [response JSONValue];
        NSDictionary *data = [SPTools dicValue:result forKey:@"data"];
        if (data) {
            XZQAGuideInfo *info = [[XZQAGuideInfo alloc] initWithResult:data];
            SPBaiduUnitInfo *unitInfo = nil;
            if (info.preset) {
                unitInfo = [[SPBaiduUnitInfo alloc] initWithQAResult:data];
            }
            [weakself showQA:info unit:unitInfo];
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.QARequestId = nil;
        NSString *errorStr = error.domain;
        CMPAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_prompt")  message:errorStr cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
        }];
        [aAlertView show];
    }];
}

- (void)showMainview {
    [self showMainviewWithGuideInfo:nil unit:nil];
}
- (void)showMainviewWithGuideInfo:(XZQAGuideInfo *)guideInfo unit:(SPBaiduUnitInfo *)unitInfo {
    [self showMainviewWithGuideInfo:guideInfo unit:unitInfo pushConrroller:nil];
}

- (void)showMainviewWithGuideInfo:(XZQAGuideInfo *)guideInfo
                             unit:(SPBaiduUnitInfo *)unitInfo
                   pushConrroller:(UIViewController *)pushcontroller {
    
    [XZCore sharedInstance].spErrorCorrectionDic = [SPTools spErrorCorrectionDic];
    [XZCore sharedInstance].pinyinRegular = [SPTools pinyinRegular];

    [_smartEngine resetSmartEngine];
    SPBaiduUnitInfo *unit = unitInfo? unitInfo:[XZCore sharedInstance].baiduUnitInfo;
    [_smartEngine setupBaseInfo:unit];
    
    //显示主界面前关闭唤醒
    [self stopWakeUp];
  
    _touchWindow.hidden = YES;
    if (self.mainViewController) {
        //清除遗漏
        self.mainViewController = nil;
    }
    if (!_mainViewController) {
        _mainViewController = [[XZMainViewController alloc] init];
        _mainViewController.delegate = self;
        _mainViewController.allowRotation = INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
        __weak typeof(self) weakSelf = self;
        self.mainVCShowFirst = YES;
        _mainViewController.guideInfo = guideInfo;
        if (pushcontroller) {
            [pushcontroller.navigationController pushViewController:_mainViewController animated:YES];
            self.isShowMainView = YES;
            self.viewDidAppearBlock = ^{
                [weakSelf mainViewControllerDidShow];
                weakSelf.mainVCShowFirst = NO;
            };
        }
        else {
            CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:_mainViewController];
            UIViewController *vc = [SPTools currentViewController];
            [vc presentViewController:nav animated:YES completion:^{
                [weakSelf mainViewControllerDidShow];
                weakSelf.mainVCShowFirst = NO;
            }];
        }
    }
    _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
    _speechEngine.delegate = self;//语音速记影响点   delegate
}

- (void)showQA:(XZQAGuideInfo *)guideInfo unit:(SPBaiduUnitInfo *)unitInfo {
    [self showMainviewWithGuideInfo:guideInfo unit:unitInfo];
}

- (void)hideMainview
{
    self.isShowMainView = NO;
    UINavigationController *nav = self.mainViewController.navigationController;
    if (nav.viewControllers.count > 1) {
        [nav popViewControllerAnimated:YES];
        self.mainViewController = nil;
    }
    else {
        __weak typeof(self) weakSelf = self;
        [self.mainViewController dismissViewControllerAnimated:YES completion:^{
            weakSelf.mainViewController = nil;
        }];
    }
    [XZMainProjectBridge clearMediatorCache];
    //显示悬浮icon
    if (!self.isLogout) {
        [self handleRobotConfig];
    }
}

#pragma mark XZMainViewControllerDelegate begin


- (BOOL)checkIntentJson {
    NSString *fileFolder = [SPTools localIntentFolderPath];
    NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:fileFolder];
    if (array.count == 0) {
        __weak typeof(self) weakSelf = self;
        __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;

        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"小致唤醒失败，确认重新唤醒？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakMainViewController dismissViewControllerAnimated:NO completion:^{
                [weakSelf mainViewControllerDidDismiss];
            }];
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakMainViewController showLoadingView];
            [weakSelf requestIntentJsonFileWithSuccess:^{
                [weakMainViewController hideLoadingView];
                [weakSelf checkIntentJson];
            } fail:^{
                [weakMainViewController hideLoadingView];
                [weakSelf checkIntentJson];
            }];
        }];
        [ac addAction:sure];
        [ac addAction:cancel];
        [_mainViewController presentViewController:ac animated:YES completion:nil];
        return NO;
    }
    return YES;
}


- (void)mainViewControllerDidShow
{
    self.isShowMainView = YES;
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [self enterSleep:YES];
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    self.speechEngine.isNeedPlayStartAudio = YES;
 
    //判断配置文件是否下载成功
    if (![self checkIntentJson]) {
        return;
    }
    _unknownCount = 0;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self recognizeFirstCommond];
    if ([_mainViewController isInSpeechView] && !_mainViewController.guideInfo) {
        //智能QA ，不自动起监听
        [self mainViewControllerShouldSpeak];
    }
}

- (void)mainViewControllerDidDismiss {
    self.speakEndBlock = nil;
    [_smartEngine resetSmartEngine];
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self needResetUnitDialogueState];
    [self.speechEngine stop];
    [self enterClose];
    if (![self returnAllSearch:@""]) {
        [self hideMainview];
    }
   
    [_mainViewController clearMessage];

    [[XZM3RequestManager sharedInstance] cancelAllRequest];
    [XZCore sharedInstance].spErrorCorrectionDic = nil;
    [XZCore sharedInstance].pinyinRegular = nil;
}

- (void)mainViewControllerShouldSpeak {
    [self stopWakeUp];//关闭唤醒

    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        if (![weakMainViewController isInSpeechView]) {
            return ;
        }
        [weakSelf mainViewControllerShouldSpeakInner];
    } falseCompletion:^{
        NSString *boundName = [[NSBundle mainBundle]
                               objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"请在设备的“设置-隐私-麦克风”选项中允许“%@”访问你的麦克风",boundName];
        CMPAlertView * alert = [[CMPAlertView alloc] initWithTitle:@"麦克风不可用" message:message cancelButtonTitle:@"取消" otherButtonTitles:[NSArray arrayWithObject:@"去设置"] callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        
    }];
}

- (void)mainViewControllerShouldSpeakInner {
    if (!self.isShowMainView) {
        return;
    }
    self.speakEndBlock = nil;
    [_mainViewController enbaleSpeakButton:NO];
    SpeechRecognizeType recognizeType = _mainViewController.recognizeType;
    switch (recognizeType) {
        case SpeechRecognizeShortText:
            // 短文本
            [_speechEngine recognizeShortText];
            break;
        case SpeechRecognizeLongText:
            // 长文本
            [_speechEngine recognizeLongText];
            break;
        case SpeechRecognizeFirstCommond:
            // 一级命令词
            [_speechEngine recognizeFirstCommond];
            break;
        case SpeechRecognizeMember:
        case SpeechRecognizeMemberOption:{
            // 人员
            [_speechEngine recognizeMember];
        }
            break;
        case SpeechRecognizeOption: {
            // 选项
            [_speechEngine recognizeOption:self.optionKey];
            self.optionKey = nil;
        }
            break;
        case SpeechRecognizeSearchColText:
            // 搜索协同
            [_speechEngine recognizeSearchColText];
            break;
        default:
            break;
    }
}

- (void)mainViewControllerShouldStopSpeak {
    //关闭语音识别
    self.speakEndBlock = nil;
    [self enterSleep:YES];
    [[SPAudioPlayer sharedInstance] stopPlayAudio];
}

- (BOOL)mainViewControllerNeedAlertWhenClickCloseBtn {
    return  _smartEngine.intent && [_smartEngine.intent isCreateIntent] ? YES : NO;
}

- (void)mainViewControllerVoiceStateChange:(BOOL)on {
    self.speechEngine.canSpeak = on;
    [SPAudioPlayer sharedInstance].canPlay = on;
    if (!on) {
        [self.speechEngine stopSpeak];
        [self onSpeakEnd];
    }
}

- (void)mainViewControllerInputText:(NSString *)text {
    //关闭语音识别
    [self mainViewControllerShouldStopSpeak];
    _resultFromSpeech = NO;
    [self humanSpeak:text];
    [self analysisResult:text];
}

- (void)mainViewControllerTapText:(NSString *)text {
    [self mainViewControllerInputText:text];
}

- (void)mainViewControllerDidSelectMembers:(NSArray *)members skip:(BOOL)skip {
    //关闭语音识别
    [self mainViewControllerShouldStopSpeak];
    //常用联系人选了人员
    if (_smartEngine.membersBlock) {
        _smartEngine.membersBlock(members, NO,nil);
    }
    if (skip) {
        [_speechEngine stopSpeak];
        [self analysisResult:@"下一步"];
    }
}

//启动用于开启监听的语音唤醒
- (void)mainViewControllerShouldstartWakeup {
    [self startWakeup];
}
//启动用于关闭监听的语音唤醒
- (void)mainViewControllerShouldstopWakeUp{
    [self stopWakeUp];
}

- (void)mainViewControllerDidAppear {
    if (!self.mainVCShowFirst) {
        [self startWakeup];
    }
    if (self.viewDidAppearBlock) {
        self.viewDidAppearBlock();
        self.viewDidAppearBlock = nil;
    }
}

- (void)mainViewControllerWillDisappear {
    if (self.isShowMainView) {
        [_speechEngine stop];
        [self showRecord];
        [self stopWakeUp];
    }
}


#pragma mark XZMainViewControllerDelegate end
- (void)handleWakeup {
    if (self.isShowMainView) {
        [self needContinueRecognize];
    }
    else {
        [self showMainview];
    }
}

- (void)startWakeup {
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    if (permission == AVAudioSessionRecordPermissionUndetermined) {
        return;//没有决定。则不唤醒
    }

    self.speakEndStartWakeupBlock = nil;
    if (!_xzCanUseWakeup || _isLogout || ![XZCore sharedInstance].robotConfig.isAutoAwake || !_isInWorkTime) {
        return;
    }
    [_speechEngine stop];
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToChild:^{
        [[SPWakeuper sharedInstance] startWakeupWithAction:^{
            [weakSelf handleWakeup];
        }];
    }];
}

- (void)stopWakeUp {
    self.speakEndStartWakeupBlock = nil;
    [[SPWakeuper sharedInstance] stopWakeup];
}

#pragma mark 封装识别分类方法  start

/**
 识别短文本
 */
- (void)recognizeShortText {
    _mainViewController.recognizeType = SpeechRecognizeShortText;
}

- (void)recognizeSearchColText {
    _mainViewController.recognizeType = SpeechRecognizeSearchColText;
}
/**
 识别长文本
 */
- (void)recognizeLongText {
    _mainViewController.recognizeType = SpeechRecognizeLongText;
}

/**
 识别一级命令词
 */
- (void)recognizeFirstCommond {
    _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
}
/**
 识别人员
 param isSelect 是否选人流程  重复人员选择
 */
- (void)recognizeMember {
    BOOL multi = [_smartEngine isMultiSelectMember];//目前仅协同选人多选
    [_mainViewController recognizeMemberWithMulti:multi];
}
/**
 识别选项
 */
- (void)recognizeOption:(NSString *)optionKey {
    _mainViewController.recognizeType = SpeechRecognizeOption;
}
#pragma mark 封装识别分类方法  end


- (void)humanSpeak:(NSString *)word {
    if (!word ||[word isEqualToString:@""]) {
        return;
    }
    [_mainViewController humenSpeakText:word];
}

- (void)robotSpeak:(NSString *)word speakContent:(NSString *)content {
    if ([NSString isNull:word]) {
        return;
    }
    [_mainViewController robotSpeakWithText:word];
    [self speak:content];
}

- (void)speak:(NSString *)word {
    if (!self.isShowMainView) {
        return;
    }
    [self enterSpeak];
    [_speechEngine speak:word];
}

#pragma mark - SPSpeechEngineDelegate
// 识别结果返回代理
- (void)onResults:(NSArray *)resultArr type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    _resultFromSpeech = YES;
    NSString *parameter = [resultArr firstObject];
    parameter = [self correctionSpeechInput:parameter];
    NSInteger limit = [XZCore sharedInstance].textLenghtLimit;
    if (limit > 0 && parameter.length > limit) {
        parameter = [parameter substringToIndex:limit];
    }
    [self humanSpeak:parameter];
    [self analysisResult:parameter];
}

- (NSString *)correctionSpeechInput:(NSString *)input {
    NSString *result = input;
    NSDictionary *spErrorCorrectionDic = [XZCore sharedInstance].spErrorCorrectionDic;
    NSString *target = _smartEngine.targetSlot;
    if ([NSString isNull:target]) {
       target = @"INTENT_ERROR";
    }
    NSDictionary *targetDic = spErrorCorrectionDic[target];
    if (target && input) {
        NSString *temp = targetDic[input];
        if (temp) {
            result = temp;
        }
    }
    return result;
}

- (void)onError:(NSError *)error {
    if ([error.domain integerValue] == 31) {
//        EVRClientErrorDomainLocalNetwork = 31 本地网络联接出错
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [self showRecord];
        [self startWakeup];
        return;
    }
    if (error.code == 2625535 ) {
        /*Error Domain=40 Code=2625535 "ASR: engine is busy."*/ //不处理
        [_mainViewController showToast:@"引擎忙。"];
        [self showRecord];
        [self startWakeup];
        return;
    }
    if (error.code == 2225219 || error.code == 1310722 ) {
        /*2225219 server speech quality problem。音频质量过低，无法识别。 相当于没有说话*/ //不处理
        /*1310722 :Error Domain=20 Code=1310722 "VAD detect: no speech." */
        [_mainViewController showToast:@"没有语音输入。"];
        [_mainViewController humenSpeakNothing];
        [self showRecord];
        [self startWakeup];
        return;
    }
    
    if (error.code == 2225213 ) {
        /*
         1966081    网络意外出错
         1966082    网络不可用
         2031617    网络请求超时
         2225213    日志中有字样 err_no is: -3011. Server unkown error. 一般是网络有代理导致。联网请不要走代理。
         */
        [self robotSpeak:@"请关闭网络代理。" speakContent:nil];
        [self showRecord];
        [self startWakeup];
        return;
    }
    if (_state != XZMainControllerClose) {
        [self robotSpeak:@"对不起，我好像打断你了，请你再说一遍。" speakContent:@"对不起，我好像打断你了，请你再说一遍。"];
        [_smartEngine wakeUp];
        [self needStartWakeup];
        
    }
}

//停止录音回调
- (void)onEndOfSpeech {
    [_mainViewController hideWaveView];
}

//开始录音回调
- (void)onBeginOfSpeech {
    [self enterRecognize];
}

//音量回调函数
- (void)onVolumeChanged:(NSInteger)volume {
    [_mainViewController waveVolumeChanged:volume];
}

//会话取消回调
- (void)onCancel {
    [_mainViewController hideWaveView];
}

- (void)onSpeakEnd {
    if (self.speakEndBlock) {
        self.speakEndBlock();
        self.speakEndBlock = nil;
    }
    else {
        if (self.speakEndStartWakeupBlock) {
            self.speakEndStartWakeupBlock();
            self.speakEndStartWakeupBlock = nil;         
        }
    }   
}

#pragma mark - SPSmartEngineDelegate

- (void)needReadWord:(NSString *)word speakContent:(NSString *)speakContent {
    [self robotSpeak:word speakContent:speakContent];
}

- (void)needShowHumanWord:(NSString *)word newLine:(BOOL)isNewLine {
}

- (void)needHumanSpeakNewLine {
}

- (void)needShowMemberPromt:(NSString *)members {
    [_mainViewController addPromptMessage:[NSString stringWithFormat:@"你已选择%@", members]];
}

- (void)needAnswerFirstCommond {
    [self recognizeFirstCommond];
}

- (void)needAnswerShortText {
    [self recognizeShortText];
}

- (void)needAnswerMemberIsShow:(BOOL)isShow isSelect:(BOOL)isSelect {
    [self recognizeMember];
}
- (void)needChooseFormOptionMembers:(XZOptionMemberParam *)param block:(SmartMembersBlock)block{
    NSString *extData = param.extData;
    _smartEngine.isClarifyMembers = YES;
    [self speak:param.speakContent];
    _mainViewController.recognizeType = SpeechRecognizeMemberOption;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    __weak typeof(self) weakself = self;
    if(param.isMultipleSelection) {
        //用于 多选 不支持第几位选择
        param.membersChoosedBlock = block;
    }
    XZOptionMemberModel *model = [[XZOptionMemberModel alloc] init];
    model.param = param;
    model.didChoosedMembersBlock = ^(NSArray *members, BOOL showName) {
        weakSmartEngine.currentCellModel = nil;
        weakSmartEngine.isClarifyMembers = NO;
        [weakself needHumanSpeakNewLine];
        if (showName) {
            NSString *name =@"";
            for (CMPOfflineContactMember *member in members) {
                NSString *cname = [NSString stringWithFormat:@"%@%@",member.department,member.name];
                name =  name.length > 0 ? [NSString stringWithFormat:@"%@、%@",name,cname] : cname;
            }
            [weakself humanSpeak:name];
        }
        block(members,NO,extData);
    };
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    model.showMoreBlock = ^(NSArray *selectedMembers,BOOL isMultiSelect) {
        [weakMainViewController showChooseMemberViewController:selectedMembers isMultiSelect:isMultiSelect];
    };
    model.clickTextBlock = ^(NSString *text) {
        weakSmartEngine.isClarifyMembers = NO;
//        block(nil,YES,nil);
        [weakself humanSpeak:text];
        [weakself analysisResult:text];
//        [weakself robotSpeak:@"好的" speakContent:@"好的"];
//        [weakEngine stop];
//        [weakself needResetUnitDialogueState];
    };
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModels:@[model]];
    if (!param.isMultipleSelection) {
        [self needContinueRecognize];
    }
}

- (void)needHideMemberView {
    [_mainViewController hideMemberView];
    [self recognizeShortText];
}
- (void)needAnswerLongText {
    [self recognizeLongText];
}

- (void)needAnswerOption {
    SPBaseCommondNode *currentNode = [_smartEngine getCurrentNode];
    NSString *key = [NSString stringWithFormat:@"%@-%@", currentNode.commondID, currentNode.stepIndex];
    [self recognizeOption:key];
}

- (void)needShowCloseAlert {
}

- (void)needShowCloseAlertView {
    __weak typeof(self) weakself = self;
    [_mainViewController showCloseAlert:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself mainViewControllerDidDismiss];
        });
    }];
}

//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will {
    if (will) {
        [_mainViewController memberNodeWillNextStep:will];
    }
    else {
        [self robotSpeak:@"对不起，你还没有告诉我发给谁" speakContent:@"对不起，你还没有告诉我发给谁"];
    }
}

- (void)stepDidEnd:(BOOL)isRestart {
   [_mainViewController restoreView];
    [self enterSleep:NO];
    [self recognizeFirstCommond];
}

- (void)needClose {
    __weak typeof(self) weakself = self;
    self.speakEndBlock = ^{
        [weakself mainViewControllerDidDismiss];
    };
    if (![SPAudioPlayer sharedInstance].canPlay) {
        //静音的时候 需调用onSpeakEnd
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself mainViewControllerDidDismiss];
        });
    }
}

- (void)needSleep {
    [self enterSleep:YES];
    _speechEngine.isNeedPlayStartAudio = YES;
}


- (void)didCompleteLongText {
    _speechEngine.isNeedPlayStartAudio = YES;
    [self enterQuery];
}

- (void)needSendColl:(NSDictionary *)result {
    [self sendCollByRobot:result];
}

- (void)needJumpToColl:(NSDictionary *)result {
    [self robotSpeak:@"好的" speakContent:@"好的"];
    __weak typeof(self) weakself = self;
    if (_speechEngine.isSpeaking) {
        NSDictionary*collResult = [NSDictionary dictionaryWithDictionary:result];
        self.speakEndBlock = ^{
            [weakself jumpToCollDetail:collResult];
        };
    }
    else {
        [self jumpToCollDetail:result];
    }
}

// 跳转到新建协同
- (void)jumpToCollDetail:(NSDictionary *)result {
    if (!result) {
        return;
    }
    NSString *subject = [result objectForKey:@"subject"];
    NSString *content = [result objectForKey:@"content"];
    NSString *members = [result objectForKey:@"members"];
    NSString *href = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/newCollaboration.html?openFrom=robot&subject=%@&content=%@&members=%@", subject, content, members];
    [XZOpenM3AppHelper showWebviewWithUrl:href];
}

// 发协同
- (void)sendCollByRobot:(NSDictionary *)result {
    NSString *url = [XZCore fullUrlForPath:kCreateCollUrl];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:result success:^(NSString *response,NSDictionary* userInfo) {
        [weakSelf handleCreateCollResult:response];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

- (void)handleCreateCollResult:(NSString *)response {
    if ([response containsString:@"true"] &&
        [response containsString:@"success"]) {
        [self analysisResult:@"success"];
    } else {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [_smartEngine resetSmartEngine];
    }
    [self enterSleep:NO];
}


- (void)needGetTodayArrange {
    [self getTodayArrange];
}


/**
 是否显示搜索子项
 */
- (void)needShoWOrHideSearchType:(BOOL) show {

}


- (void)needSearchDoc:(NSString *)title {
    [self searchDoc:title];
}

- (void)needSearchBul:(NSString *)title {
    [self searchBul:title];
}

- (void)needShowSearch:(SPSearchHelper *)helper {
    if (!helper) {
        return;
    }
    XZSearchResultModel *resultModel =  [helper getShowResultModel];
    if (resultModel) {
        [_mainViewController robotSpeakWithText:resultModel.title];
        __weak typeof(self) weakSelf = self;
        resultModel.stopSpeakBlock = ^{
            [weakSelf.speechEngine stopSpeak];
        };
        [self speak:[helper getSpeakStr]];
        [_mainViewController robotSpeakWithModels:@[resultModel]];

        return;
    }
    
    helper.stopSpeakBlock = ^{
        [self.speechEngine stopSpeak];
    };
    XZTextModel *model = [helper getShowModel];
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModels:@[model]];
    [self speak:[helper getSpeakStr]];
    helper.isOption = NO;
}

- (void)needShowMemberCard:(CMPOfflineContactMember *)member  showOK:(BOOL)ok{
    if (!member) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine= _smartEngine;
    XZMemberModel *model = [[XZMemberModel alloc] init];
    model.cellClass = @"XZMemberCell";
    model.clickButtonBlock = ^(NSString *title) {
        [weakSelf humanSpeak:title];
    };
    model.callBlock = ^(NSString *phone) {
        NSString *str = @"好的";
        [weakSelf robotSpeak:str speakContent:str];
        [weakSelf needCallPhone:phone];
        [weakSelf needResetUnitDialogueState];
        weakSmartEngine.currentMember = nil;
    };
    model.sendSMSBlock = ^(NSString *phone) {
        BOOL result = [weakSelf needSendSMS:phone];
        NSString *str = result?@"好的":@"对不起，该设备不支持发短信";
        [weakSelf robotSpeak:str speakContent:str];
        [weakSelf needResetUnitDialogueState];
        weakSmartEngine.currentMember = nil;
    };
    model.sendCollBlock = ^(CMPOfflineContactMember *member) {
        [weakSelf analysisResult:@"新建协同"];
    };
    model.sendIMMessageBlock = ^(CMPOfflineContactMember *member) {
        [weakSelf analysisResult:@"发消息"];
    };
    
    model.member = member;
    if (ok) {
        [self robotSpeak:@"好的" speakContent:@"好的"];
    }
    if (model.canOperate) {
        _smartEngine.intentState = XZIntentState_PWaiting;
    }
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModels:@[model]];
}

- (void)needShowSchedule:(SPScheduleHelper *)helper {
    if (!helper) {
        return;
    }
    [self speak:[helper getPlanSpeakStr]];
    [_mainViewController robotSpeakWithModels:@[[helper getPlanShowModel1]]];

}

- (void)needShowTodo:(SPScheduleHelper *)helper {
    if (!helper) {
        return;
    }
    [_mainViewController robotSpeakWithModels:@[[helper getTodoShowModel]]];
    [self speak:[helper getTodoSpeakStr]];
}

- (void)needUnknownCommond {
}

/**
 是否有请假单
 */
- (void)needCheckLeaveForm:(void(^)(BOOL success,NSString *msg))complete {
    NSString *url = [XZCore fullUrlForPath:kCheckLeaveUrl];
    [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *dic = [response JSONValue];
        NSDictionary *data = [SPTools dicValue:dic forKey:@"data"];
        BOOL success = [SPTools boolValue:data forKey:@"success"];
        NSString *msg = [SPTools stringValue:data forKey:@"msg"];
        if (complete) {
            complete(success,msg);
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        if (complete) {
            complete(NO,nil);
        }
    }];
}


/**
 发请假单
 */
- (void)needSendLeaveForm:(XZLeaveModel *)model {
    model.isNewInterface = YES;
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    model.sendLeaveBlock = ^(XZLeaveModel *model) {
      //发送请假单
        [weakSpeechEngine stop];
        if (model.clickTitle) {
            /*model.clickTitle = nil 应该是语音识别出来的，不用再显示*/
            [weakSelf humanSpeak:model.clickTitle];
        }
        [weakSelf sendLeaveForm:model];
        [weakSelf needResetUnitDialogueState];
    };
    model.modifyLeaveBlock = ^(XZLeaveModel *model) {
      //修改请假单
        [weakSpeechEngine stop];
        if (model.clickTitle) {
            /*model.clickTitle = nil 应该是语音识别出来的，不用再显示*/
            [weakSelf humanSpeak:model.clickTitle];
        }
        [weakSelf modifyLeaveForm:model];
        [weakSelf needResetUnitDialogueState];
    };
    model.cancelLeaveBlock = ^(XZLeaveModel *model) {
        //取消请假单
        [weakSpeechEngine stop];
        if (model.clickTitle) {
            /*model.clickTitle = nil 应该是语音识别出来的，不用再显示*/
            [weakSelf humanSpeak:model.clickTitle];
        }
        [weakSelf showCancelCard];
    };
    [self requestLeaveTimeCount:model];
}

- (void)needResetUnitDialogueState {
    [_smartEngine needResetUnitDialogueState];
    [_mainViewController hideKeyboard];
}

- (void)needContinueRecognize {
    if (_isLogout || !self.isShowMainView) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    [self dispatchAsyncToMain:^{
        if (![weakMainViewController isInSpeechView]) {
            return;
        }
        if (weakSpeechEngine.isSpeaking) {
            weakSelf.speakEndBlock = ^{
                [weakSelf mainViewControllerShouldSpeak];
            };
        }
        else {
            [weakSelf mainViewControllerShouldSpeak];
        }
    }];
    
}
- (void)needStartWakeup {
    __weak typeof(self) weakSelf = self;
    if (_speechEngine.isSpeaking) {
        self.speakEndStartWakeupBlock = ^{
            [weakSelf startWakeup];
        };
    }
    else {
        [self startWakeup];
    }
}
- (void)needShowLeaveTypes:(XZLeaveTypesModel *)model {
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    model.clickTypeBlock = ^(NSString *leaveType) {
        [weakSpeechEngine stop];
        [weakSelf humanSpeak:leaveType];
        [weakSelf analysisResult:leaveType];
    };
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModels:@[model]];
}

/**
 显示帮助信息
 */
- (void)needShowHelpInfo {

}

- (BOOL)canSendSMS {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil && [messageClass canSendText]) {
        return YES;
    }
    return NO;
}

#pragma mark - State Machine

- (void)enterClose {
    _state = XZMainControllerClose;
    [_speechEngine stop];
    [self showRecord];
    [_smartEngine resetSmartEngine];
    self.currentText = @"";
}

- (void)enterRecognize {
    if (_state == SPAnswerSleep) {
        [_smartEngine wakeUp];
    }
    _state = XZMainControllerRecognize;
    [self showWave];
}

- (void)enterSpeak {
    _state = XZMainControllerSpeak;
    [self showRecord];
}

- (void)enterQuery {
    _state = XZMainControllerQuery;
    if (_resultFromSpeech) {
        [[SPAudioPlayer sharedInstance] playEndAudio];
    }
    [self showWaiting];
}

- (void)enterSleep:(BOOL)isBreak {
    _state = XZMainControllerSleep;
    if (isBreak) {
        [_speechEngine stop];
    }
    [self showRecord];
}

- (void)enterBackground {
    [self stopWakeUp];
    [self enterSleep:YES];
    [_mainViewController hideKeyboard];
    [_mainViewController hideWaveView];
    [XZSmartMsgManager sharedInstance].canShowMsgView = NO;
}

- (void)logout {
    self.viewDidAppearBlock = nil;
    self.isShowMainView = NO;
    _isLogout = YES;
    _touchWindow.hidden = YES;
    [_touchWindow removeFromSuperview];
    _touchWindow = nil;
    [_mainViewController dismissViewControllerAnimated:NO completion:nil];
    _mainViewController = nil;
    [self stopWakeUp];
    [_smartEngine resetSmartEngine];
    [self.speechEngine logout];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SPTimer removeAllSechedule];
    [[XZCore sharedInstance] clearData];
    [XZMainProjectBridge clearMediatorCache];
    [[XZSmartMsgManager sharedInstance] userLogout];
    [XZCore sharedInstance].spErrorCorrectionDic = nil;
    [XZCore sharedInstance].pinyinRegular = nil;
}

- (void)willLogout {
    self.viewDidAppearBlock = nil;
    [XZCore sharedInstance].baiduSpeechInfo = nil;
    self.isShowMainView = NO;
    _isLogout = YES;
    [self stopWakeUp];
    [self needResetUnitDialogueState];
    [self.speechEngine logout];
    [_mainViewController hideWaveView];
    [SPTimer removeAllSechedule];
    [[XZSmartMsgManager sharedInstance] userLogout];
}


/**
 分析语句
 */
- (void)analysisResult:(NSString *)result {
    [self enterQuery];
    if (![XZMainProjectBridge reachableNetwork]) {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [self showRecord];
        return;
    }
    if ([_smartEngine filterResult:result]) {
        [_mainViewController hideSpeechLoadingView];
        [self showRecord];
        return;
    }
    if ([_smartEngine needAnalysisByServer:result]) {
        [_mainViewController showSpeechLoadingView];
        [self showRecord];
        __weak typeof(self) weakSelf = self;
        NSDictionary *mDict = @{
            @"content":result,
            @"sessionId":_smartEngine.unitSessionId ?:@""
        };
        NSString *url = [XZCore fullUrlForPath:kXiaozChatUrl];
        [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
            [weakSelf handleChatResponse:responseStr currentText:result];
          } fail:^(NSError *error,NSDictionary* userInfo) {
              [weakSelf handleChatError:error];
          }];
        return;
    }
    if ([_smartEngine setResult:result]) {
        [_mainViewController hideSpeechLoadingView];
    }
}




- (void)handleChatResponse:(NSString *)responseStr currentText:(NSString *)currentText{
    
    NSDictionary *dic = [SPTools dictionaryWithJsonString:responseStr];
    
    NSInteger code = [SPTools integerValue:dic forKey:@"code"]; 
    if (code == 292003 || code == 292002) {
        [_mainViewController hideSpeechLoadingView];
        [_mainViewController hideKeyboard];
        [self handleChatError:[NSError errorWithDomain:@"" code:code userInfo:nil]];
        return;
    }
    
    NSDictionary *data = [SPTools dicValue:dic forKey:@"data"];
    NSString *intent = [SPTools stringValue:data forKey:@"intentName"];
//    NSString *sessionId = [SPTools stringValue:data forKey:@"sessionId"];
    NSArray *qa = [SPTools arrayValue:data forKey:@"qa"];
    if (qa && qa.count > 0) {
        [_mainViewController hideSpeechLoadingView];
        if (_smartEngine.intent) {
             [self needShowCancelCardInHistory];
            _smartEngine.intent = nil;
            _smartEngine.cancelBlock = nil;
            _smartEngine.sendBlock = nil;
            _smartEngine.modifyBlock = nil;
        }
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
        model.loadUrl = kXiaozQACardUrl;
        model.gotoParams = data;
        [_mainViewController robotSpeakWithWebModel:model];
        _intentErrorCount = 0;
        return;
    }
    NSDictionary *unit = [SPTools dicValue:data forKey:@"unit"];
    if (unit) {
        NSArray *slots = [SPTools arrayValue:unit forKey:@"slots"];
        BUnitResult *unitResult = [[BUnitResult alloc]init];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        NSMutableDictionary *infoList = [NSMutableDictionary dictionary];
        for (NSDictionary *slotDic in slots) {
            NSString *slotKey = [SPTools stringValue:slotDic forKey:@"slotKey"];
            NSArray *slotValues = [SPTools arrayValue:slotDic forKey:@"slotValues"];
            if (slotKey && slotValues && slotValues.count >0) {
                [info setObject:slotValues[0] forKey:slotKey];
                [infoList setObject:slotValues forKey:slotKey];
            }
        }
        unitResult.say = [SPTools stringValue:unit forKey:@"say"];
        unitResult.intentName = intent;//APP_1_1_S
        unitResult.intentTarget = @"";//？？
        unitResult.intentType = [SPTools stringValue:unit forKey:@"type"];//satisfy
        unitResult.intentId = [SPTools stringValue:unit forKey:@"actionId"];//app_1_1_s_satisfy
        unitResult.currentText = currentText;
        unitResult.infoDict = info;
        unitResult.infoListDict = infoList;
        NSArray *options = [SPTools arrayValue:unit forKey:@"options"];
        
        if (options && options.count > 0) {
            if ([unitResult.intentName isEqualToString:kBUnitIntent_FAQ_ANSWER] || options.count == 1) {
                NSDictionary *oDic = options[0];
                unitResult.say = oDic[@"slotNormalizedWord"];
            }
            else {
                NSMutableArray *optionalOpenIntentList = [[NSMutableArray alloc] init];
                for (NSDictionary *oDic in options) {
                    BUnitOptionalOpenIntent *openIntent = [[BUnitOptionalOpenIntent alloc] init];
                    openIntent.displayName = oDic[@"option"];
                    openIntent.say = oDic[@"slotNormalizedWord"];
                    [optionalOpenIntentList addObject:openIntent];
                }
                if (optionalOpenIntentList.count > 0) {
                    unitResult.optionalOpenIntentList = optionalOpenIntentList;
                }
            }
        }
        if ([unitResult needKeepSessionId]) {
            _smartEngine.unitSessionId = [SPTools stringValue:data forKey:@"sessionId"];
        }
        else {
            _smartEngine.unitSessionId = @"";
        }
        [_smartEngine handleBaiduUnitResult:unitResult];
        _intentErrorCount = 0;
        
        return;
    }
    [_mainViewController hideSpeechLoadingView];
    if (_smartEngine.intent.isCreateIntent) {
        _intentErrorCount ++;
       if (_intentErrorCount > 2) {
           NSString *string = @"不好意思，没明白什么意思";
           [self robotSpeak:string speakContent:string];
           [self needShowCancelCardInHistory];
           _smartEngine.intent = nil;
           _intentErrorCount = 0;
       }
       else {
           NSString *string = @"没明白什么意思，是否继续发送？";
           [self robotSpeak:string speakContent:string];
           if (_smartEngine.intent.showCardBlock) {
               _smartEngine.intent.showCardBlock(_smartEngine.intent);
           }
       }
    }
    else {
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
           model.loadUrl = kXiaozAllSearchUrl;
           BOOL hasIndexPlugin = [XZCore sharedInstance].privilege.hasIndexPlugin;
           model.gotoParams = @{
               @"question":currentText,
               @"hasIndexPlugin":hasIndexPlugin?@"1":@"0"
           };
        [_mainViewController robotSpeakWithWebModel:model];
        _intentErrorCount = 0;
        _smartEngine.cancelBlock = nil;
        _smartEngine.sendBlock = nil;
        _smartEngine.modifyBlock = nil;

    }
}

- (void)handleChatError:(NSError *)error {
    [_mainViewController hideSpeechLoadingView];
    [self showRecord];
    [self handleRequestError:error];
}

#pragma mark 打电话
/**
 打电话
 */
- (void)needCallPhone:(NSString *)number{
    _mainViewController.recognizeType =  SpeechRecognizeFirstCommond;
    [_mainViewController hideKeyboard];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]];
        [[UIApplication sharedApplication]openURL:url];
    });
}

#pragma mark 发短信
/**
 发短信
 */

- (BOOL)needSendSMS:(NSString *)phoneNumber {
    _mainViewController.recognizeType =  SpeechRecognizeFirstCommond;
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil && [messageClass canSendText]) {
        __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
        [self dispatchAsyncToMain:^{
            [weakMainViewController hideKeyboard];
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate= self;
            picker.body = @""; // 默认信息内容
            // 默认收件人(可多个)
            picker.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                picker.modalPresentationStyle = UIModalPresentationPageSheet;
                [weakMainViewController cmp_presentViewController:picker animated:YES completion:nil];
            }
            else {
                picker.modalPresentationStyle = UIModalPresentationFullScreen;
                [weakMainViewController presentViewController:picker animated:YES completion:nil];
            }
        }];
        return YES;
    }
     return NO;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)handleBeforeRequest {
    _resultFromSpeech = NO;
    [self enterQuery];
}
/*发致信*/
- (BOOL)needSendIMMsg:(CMPOfflineContactMember *)member content:(NSString *)content {
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    [XZMainProjectBridge chatToMember:member content:content completion:^(NSError * error) {
        if (error) {
            NSString *message = error.domain;
            if ([NSString isNull:message]) {
                message = @"发送失败";
            }
            [weakSelf robotSpeak:message speakContent:message];
        }
        else {
            [weakSelf robotSpeak:@"好的，已经发送成功！" speakContent:@"好的，已经发送成功！"];
            XZSendIMMsgModel *immodel = [[XZSendIMMsgModel alloc] init];
            immodel.targetMember = member;
            immodel.content = content;
            [weakMainViewController robotSpeakWithModels:@[immodel]];
        }
    }];
    [_smartEngine resetSmartEngine];
    return YES;
}
- (void)sendIMMsg:(CMPOfflineContactMember *)member {
    [_smartEngine resetSmartEngine];
    self.isShowMainView = NO;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self needResetUnitDialogueState];
    [self.speechEngine stop];
    [self enterClose];
    if (!self.isLogout) {
        [self handleRobotConfig];
    }
    [_mainViewController clearMessage];
    [self showTouchWindow];
    [_mainViewController dismissViewControllerAnimated:NO completion:^{
        [XZMainProjectBridge showChatWithMember:member];
    }];
}


/**
 查协同
 param startMemberName 发起人
 param subject 标题
 param state 3-待办 4-已办
 */
- (void)needSearchCollWithParam:(NSDictionary *)param {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchCollUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    [mDict setObject:@"1" forKey:@"pageNo"];
    [mDict setObject:@"5" forKey:@"pageSize"];

    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchColResult:responseStr info:mDict];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

/**
 查报销
 */
- (void)needSearchExpenseWithParam:(NSDictionary *)param {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchCollUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:param];
    [mDict setObject:@"1" forKey:@"pageNo"];
    [mDict setObject:@"100" forKey:@"pageSize"];

    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchExpenseResult:responseStr info:param];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}


/**查查报表**/
- (void)needSearchStatistics:(NSString *)title {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchStatisticsUrl];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"2" forKey:@"aListType"];//类型   1：查询；2：统计
    [param setObject:title forKey:@"aSearchValue"];//查询值
  
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:param success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchStatisticsResult:responseStr title:title];
        [weakSmartEngine resetSmartEngine];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

/**查新闻**/
- (void)needSearchNews:(NSString *)title {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchNewsUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:@"1" forKey:@"pageNo"];
    [mDict setObject:@"5" forKey:@"pageSize"];
    [mDict setObject:@"-1" forKey:@"curTabId"];
    [mDict setObject:@"title" forKey:@"condition"];
    [mDict setObject:title forKey:@"value"];
    //    {"pageNo":1,"pageSize":20,"curTabId":"-1","condition":"title","value":"第"}
   
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchNewsResult:responseStr title:title];
        [weakSmartEngine resetSmartEngine];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}


- (void)needOpenM3AppWithAppId:(NSString *)appId result:(void(^)(BOOL sucess))result {
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;

    [self dispatchAsyncToMain:^{
        if ([XZOpenM3AppHelper canOpenM3AppWithAppId:appId]) {
            if (result) {
                result(YES);
            }
            if (weakSpeechEngine.canSpeak) {
                weakSelf.speakEndBlock = ^{
                    [weakSelf needOpenM3AppWithAppId:appId time:0.5];
                };
            }
            else {
                [weakSelf needOpenM3AppWithAppId:appId time:1.5];
            }
        }
        else {
            if (result) {
                result(NO);
            }
        }
    }];
}

- (void)needCreateObject:(XZCreateModel *)model {
    NSString *url = [XZCore fullUrlForPath:model.submitUrl];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:[model requestParam] success:^(NSString *responseStr,NSDictionary* userInfo) {
        [weakSelf handleCreateObj:responseStr];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

- (void)handleCreateObj:(NSString *)responseStr {
    if ([responseStr containsString:@"true"]||
        [responseStr containsString:@"success"]) {
        [_smartEngine resetSmartEngine];
        [_smartEngine needResetUnitDialogueState];
        [self robotSpeak:@"好的，已经发送。" speakContent:@"好的，已经发送。"];
    }
    else {
        NSDictionary *dic = [responseStr JSONValue];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if ([dic.allKeys containsObject:@"code"]) {
                if ([dic[@"code"] integerValue] == 200) {
                    [_smartEngine resetSmartEngine];
                    [_smartEngine needResetUnitDialogueState];
                    [self enterSleep:NO];
                    [self robotSpeak:@"好的，已经发送。" speakContent:@"好的，已经发送。"];
                    return;
                }
            }
        }
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [_smartEngine resetSmartEngine];
    }
    [self enterSleep:NO];
    
}

- (void)needShowObject:(XZCreateModel *)model {
    [self robotSpeak:@"好的" speakContent:@"好的"];
    [XZCore sharedInstance].speechInput = model.speechInput;
    NSInteger time = 1;//_speechEngine.canSpeak ?4 :2;//延迟时间
    NSString *url = model.showUrl;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [XZOpenM3AppHelper showWebviewWithUrl:url];
    });
}
/*QAj回答*/
- (void)needShowQAAnswer:(NSString *)answer {
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    [XZQATextModel modelsWithQAResult:answer block:^(NSArray *models, NSString * _Nonnull speakStr) {
        for (XZCellModel *mode in models) {
            if ([mode isKindOfClass:[XZQATextModel class]]) {
                XZQATextModel *m = (XZQATextModel *)mode;
                m.clickLinkBlock = ^(NSString *linkUrl) {
                    [weakSpeechEngine stopSpeak];
                    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                    aCMPBannerViewController.startPage = linkUrl;
                    aCMPBannerViewController.hideBannerNavBar = NO;
                    aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
                    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
                    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:aCMPBannerViewController];
                    [[SPTools currentViewController] presentViewController:nav animated:YES completion:^{
                    }];
                };
                m.clickAppBlock = ^(NSString *text) {
                    //中转界面跳转
                    [weakSpeechEngine stopSpeak];
                    XZTransWebViewController *vc = [[XZTransWebViewController alloc] init];
                    vc.hideBannerNavBar = NO;
                    vc.loadUrl = @"http://xiaoz.v5.cmp/v/html/transit-page.html";
                    vc.gotoParams = [text JSONValue];
                    CMPNavigationController *nav = [[CMPNavigationController alloc] initWithRootViewController:vc];
                    [[SPTools currentViewController] presentViewController:nav animated:YES completion:^{
                    }];
                };
            }
            else if ([mode isKindOfClass:[XZQAFileModel class]]) {
                XZQAFileModel *m = (XZQAFileModel *)mode;
                m.clickFileBlock = ^(XZQAFileModel *model) {
                    [weakSpeechEngine stopSpeak];
                    [XZOpenM3AppHelper showQAFile:model];
                };
            }
        }
        [weakMainViewController robotSpeakWithModels:models];
        [weakSelf speak:speakStr];
    }];
}

- (void)needHandleIntent:(XZAppIntent *)appIntent {
    //先把选人关闭了
    _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
    [_mainViewController hideMemberView];
  
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;

    NSString *loadUrl = appIntent.loadUrl;
    BOOL handleCookies = [appIntent handleCookies];

    appIntent.searchBlock = ^(XZAppIntent *intent) {
        weakSmartEngine.unitSessionId = @"";
        NSString *sUrl = intent.request_url;
        NSDictionary *sParams = intent.request_params;
        [[XZM3RequestManager sharedInstance] postRequestWithUrl:sUrl params:sParams handleCookies:handleCookies success:^(NSString *response,NSDictionary* userInfo) {
            [weakSelf handleResponseForAppIntentSearchRequest:response loadUrl:loadUrl];
        } fail:^(NSError *error,NSDictionary* userInfo) {
            [weakSelf handleRequestError:error];
            [weakMainViewController hideSpeechLoadingView];
        }];
        [weakSmartEngine resetSmartEngine];
        [weakMainViewController hideKeyboard];
        weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
    };
    appIntent.createBlock = ^(XZAppIntent *intent){
        weakSmartEngine.unitSessionId = @"";
        NSString *sUrl = intent.request_url;
        NSDictionary *sParams = intent.request_params;
        [[XZM3RequestManager sharedInstance] postRequestWithUrl:sUrl params:sParams handleCookies:handleCookies success:^(NSString *response,NSDictionary* userInfo) {
            [weakSelf handleResponseForAppIntentCreateRequest:response loadUrl:loadUrl];
        } fail:^(NSError *error,NSDictionary* userInfo) {
            [weakSelf handleRequestError:error];
            [weakSmartEngine resetSmartEngine];
            [weakMainViewController hideKeyboard];
            weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
            [weakMainViewController hideSpeechLoadingView];
        }];
    };
    appIntent.openBlock = ^(XZAppIntent *intent) {
        weakSmartEngine.unitSessionId = @"";
        NSString *openUrl = intent.open_url;
        [weakSmartEngine resetSmartEngine];
        [weakMainViewController hideCreateAppCard];
        [weakMainViewController hideKeyboard];
        [weakMainViewController hideSpeechLoadingView];
        weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
      
        NSDictionary *openParams = intent.open_params;
        [self dispatchAsyncToMain:^{
            NSLog(@"intent open url:\n%@\nparam:\n%@\n\n",openUrl,openParams.JSONRepresentation);
            [XZOpenM3AppHelper openH5AppWithParams:openParams url:openUrl inController:[SPTools currentViewController]];
        }];
        NSString *relateUrl = intent.relation_url;
        NSDictionary *relateParams = intent.relation_params;
        if (relateUrl && relateParams) {
            self.viewDidAppearBlock = ^{
                [weakSelf dispatchAsyncToChild:^{
                    [[XZM3RequestManager sharedInstance] postRequestWithUrl:relateUrl params:relateParams handleCookies:handleCookies success:^(NSString *response,NSDictionary* userInfo) {
                        [weakSelf handleResponseForRelationRequest:response loadUrl:loadUrl];
                    } fail:^(NSError *error,NSDictionary* userInfo) {
                        [weakSelf handleRequestError:error];
                    }];
                }];
            };
        }
    };
    appIntent.cancelBlock = ^(id intent) {
        weakSmartEngine.unitSessionId = @"";
        [weakSelf showCancelCard];
        [weakMainViewController hideKeyboard];
    };
    appIntent.nestingBlock = ^(XZAppIntent *intent) {
        NSDictionary *data = [intent request_params];
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
        model.loadUrl = loadUrl;
        model.gotoParams = data;
        [weakMainViewController robotSpeakWithWebModel:model];
        [weakMainViewController hideKeyboard];
        weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
    };
    appIntent.checkParamsBlock = ^(XZAppIntent *intent) {
        NSString *checkeUrl = intent.checkParams_url;
        NSDictionary *checkParams = intent.checkParams_params;
        [[XZM3RequestManager sharedInstance] postRequestWithUrl:checkeUrl params:checkParams handleCookies:handleCookies success:^(NSString *response,NSDictionary* userInfo) {
            NSDictionary *responseDic = [SPTools dictionaryWithJsonString:response];
            NSInteger code = [SPTools integerValue:responseDic forKey:@"code"];
            NSString *message = [SPTools stringValue:responseDic forKey:@"message"];
            if (code == 700001 || code == 700002) {
                //700001 取消  修改 直接发送
                //700002 取消 修改
                [weakSelf robotSpeak:message speakContent:message];
                NSArray *buttons = code == 700001?[NSArray arrayWithObjects:@"取消",@"修改",@"直接发送", nil]:[NSArray arrayWithObjects:@"取消",@"修改", nil];
                [weakMainViewController showCreateAppCardButtons:buttons];
                [weakMainViewController hideSpeechLoadingView];
                weakSmartEngine.sendBlock = ^{
                    if (intent.createBlock) {
                        intent.createBlock(intent);
                    }
                };
            }
            else {
                if (intent.createBlock) {
                    intent.createBlock(intent);
                }
            }
        } fail:^(NSError *error,NSDictionary* userInfo) {
            //todo 处理提示 
            [weakSelf handleRequestError:error];
            [weakMainViewController hideSpeechLoadingView];
        }];
        [weakMainViewController hideKeyboard];
        weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
    };
    appIntent.showCardBlock = ^(XZAppIntent *intent) {
        [weakMainViewController showCreateAppCardWithAppName:intent.appName infoList:[intent card_params]];
        NSArray *buttons = [NSArray arrayWithObjects:@"取消", nil];
       
        if (intent.isEnd) {
            buttons = [NSArray arrayWithObjects:@"取消",@"修改",@"发送", nil];
            [weakSmartEngine needResetUnitDialogueState];
            weakMainViewController.recognizeType = SpeechRecognizeFirstCommond;
        }
        else if (intent.isRequiredEnd) {
            buttons = [NSArray arrayWithObjects:@"取消",@"修改",@"直接发送", nil];
        }
        
        [weakMainViewController showCreateAppCardButtons:buttons];
    };
    appIntent.showGuideBlock = ^(NSString *guideWord) {
        if ([NSString isNull:guideWord]) {
            return;
        }
        NSString *speak = [XZTextModel handleGuideWord:guideWord];
        [weakSelf robotSpeak:guideWord speakContent:speak];
        [weakSelf needContinueRecognize];
    };

    appIntent.clarifyMembersBlock = ^(XZIntentStepClarifyMemberParam *memberParam) {
        NSString *speak = memberParam.isMultipleSelection?@"请确认是哪几位?":@"请确认是哪位？";
        XZOptionMemberParam *param = [[XZOptionMemberParam alloc] init];
        param.speakContent = speak;
        param.showContent = speak;
        param.members = memberParam.members;
        param.defaultSelectArray = memberParam.defaultSelectArray;
        param.isMultipleSelection = memberParam.isMultipleSelection;
        [weakSelf needChooseFormOptionMembers:param block:^(NSArray *result, BOOL cancel, NSString *extData) {
            [weakSmartEngine.intent handleMembers:result target:extData next:YES];
        }];
    };
    appIntent.spRecognizeTypeBlock = ^(SpeechRecognizeType type) {
        [weakSelf handleAppIntentSPType:type];
    };
    appIntent.obtainOptionBlock = ^(XZObtainOptionConfig *config, NSDictionary *params,XZIntentStep *intentStep) {
        NSString *loadUrl = [config loadUrl];
        [[XZM3RequestManager sharedInstance]postRequestWithUrl:config.requestUrl params:params success:^(NSString *response, NSDictionary *userInfo) {
            NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
            NSString *message = [SPTools stringValue:dic forKey:@"message"];
            if (message) {
                [weakSelf robotSpeak:message speakContent:message];
            }
            NSDictionary *data = dic[@"data"];// [SPTools dicValue:dic forKey:@"data"];
            if (![SPTools dataIsNull:data]) {
                XZWebViewModel *model = [[XZWebViewModel alloc] init];
                model.loadUrl = loadUrl;
                model.gotoParams = data;
                model.showInHistory = NO;
                model.canDisappear = NO;
                model.optionValueBlock = ^(NSDictionary *params) {
                    NSString *msg = params[@"message"];
                    if (msg) {
                        [weakSelf humanSpeak:msg];
                    }
                    NSDictionary *data = params[@"data"];
                    [intentStep handleOptionValue:data];
                    weakSmartEngine.intent.tempData = data;
                    [weakSmartEngine.intent next];
                };
                model.optionCommandsBlock = ^(NSDictionary *params) {
                    
                };
                [weakMainViewController robotSpeakWithWebModel:model];
                [weakMainViewController hideKeyboard];
            }
            else {
                [weakSmartEngine resetSmartEngine];
                [weakMainViewController hideCreateAppCard];
            }
            
        } fail:^(NSError *error, NSDictionary *userInfo) {
            
        }];
    };
}

- (void)needShowOptionIntents:(NSArray *)intentArray {
    [self speak:kChooseIntentInfo];
    [_mainViewController hideKeyboard];
    [_mainViewController showOptionIntents:intentArray];
}

- (void)needShowCancelCardInHistory {
    XZCancelModel *model = [[XZCancelModel alloc] init];
    [_mainViewController showModelsInHistory:@[model]];
}

- (void)handleResponseForAppIntentSearchRequest:(NSString *)response
                                  loadUrl:(NSString *)loadUrl {
    NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
    NSString *message = [SPTools stringValue:dic forKey:@"message"];
    if (message) {
        [self robotSpeak:message speakContent:message];
    }
    NSDictionary *data = dic[@"data"];// [SPTools dicValue:dic forKey:@"data"];
    if (![SPTools dataIsNull:data]) {
        __weak typeof(self) weakSelf = self;
        __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
        model.loadUrl = loadUrl;
        model.gotoParams = data;
        model.nextIntentBlock = ^(NSDictionary *params) {
            NSDictionary *data = params[@"data"];
            NSString *nextIntent = params[@"nextIntent"];
            NSString *message = params[@"message"];
            if (message) {
                [weakSelf humanSpeak:message];
            }
            [weakSmartEngine nextIntent:nextIntent data:data];
        };
        model.optionCommandsBlock = ^(NSDictionary *params) {
            
        };
        [_mainViewController robotSpeakWithWebModel:model];
    }
}

- (void)handleResponseForAppIntentCreateRequest:(NSString *)response
                                  loadUrl:(NSString *)loadUrl {
    NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
    NSString *message = [SPTools stringValue:dic forKey:@"message"];
    if (message) {
        [self robotSpeak:message speakContent:message];
    }
    NSDictionary *data = dic[@"data"];// [SPTools dicValue:dic forKey:@"data"];
    if (![SPTools dataIsNull:data]) {
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
        model.loadUrl = loadUrl;
        model.gotoParams = data;
        [_mainViewController robotSpeakWithWebModel:model];
        [_smartEngine resetSmartEngine];
        [_mainViewController hideKeyboard];
        _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
        [_mainViewController hideCreateAppCard];
    }
    else {
        [_mainViewController showCreateAppCardButtons:@[@"取消",@"修改"]];
    }
}

- (void)handleResponseForRelationRequest:(NSString *)response
                                  loadUrl:(NSString *)loadUrl
{
    NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
    NSDictionary *data = dic[@"data"];// [SPTools dicValue:dic forKey:@"data"];
    if (![SPTools dataIsNull:data]) {
        //通过sourceId查询，如果没有数据，不显示提示，但是其他接口要提示信息，如：（查询）没有查询到数据
        NSString *message = [SPTools stringValue:dic forKey:@"message"];
        [self robotSpeak:message speakContent:message];
        XZWebViewModel *model = [[XZWebViewModel alloc] init];
        model.loadUrl = loadUrl;
        model.gotoParams = data;
        [_mainViewController robotSpeakWithWebModel:model];
    }
    else {
        [self showCancelCard];
    }
}


- (void)showCancelCard {
  
    [self speak:@"好的，已取消"];
    
    [_smartEngine resetSmartEngine];
    [_mainViewController hideCreateAppCard];

    XZCancelModel *model = [[XZCancelModel alloc] init];
    [_mainViewController robotSpeakWithModels:@[model]];
    _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
}

- (void)handleAppIntentSPType:(SpeechRecognizeType)type {
    if (_mainViewController.recognizeType == type) {
        return;
    }
    _mainViewController.recognizeType = type;
    if (type == SpeechRecognizeMember) {
        [self recognizeMember];
    }
    else {
        [self needHideMemberView];
    }
    if (type != SpeechRecognizeLongText) {
        [self needHumanSpeakNewLine];
    }
}

- (void)needOpenM3AppWithAppId:(NSString *)appId  time:(NSInteger)time{
//    NSInteger time = 1;//_speechEngine.canSpeak ?4 :2;//延迟时间
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZMainViewController) *weakMainViewController= _mainViewController;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSmartEngine resetSmartEngine];
        weakSelf.isShowMainView = NO;
        //设置屏幕常亮
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [weakSelf needResetUnitDialogueState];
        [weakSelf.speechEngine stop];
        [weakSelf enterClose];
        if (!weakSelf.isLogout) {
            [weakSelf handleRobotConfig];
        }
        [weakMainViewController clearMessage];
        [weakSelf showTouchWindow];
        [weakMainViewController dismissViewControllerAnimated:NO completion:^{
            [XZOpenM3AppHelper openM3AppWithAppId:appId];
        }];
    });
}

#pragma mark - NetWork

/**
 查看今日安排
 */
- (void)getTodayArrange {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kTodayArrangeUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[XZDateUtils todayMinTimeStamp] forKey:@"startTime"];
    [mDict setObject:[XZDateUtils todayMaxTimeStamp] forKey:@"endTime"];
    [mDict setObject:@"robot" forKey:@"from"];
   
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *response,NSDictionary* userInfo) {
        [weakSmartEngine handleScheduleResult:response];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

// 搜索文档
- (void)searchDoc:(NSString *)title {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchDocUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[SPTools deletePunc:title] forKey:@"value"];
    [mDict setObject:@"1" forKey:@"pageNo"];
    [mDict setObject:@"5" forKey:@"pageSize"];

    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchDocResult:responseStr title:title];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

// 搜索公告
- (void)searchBul:(NSString *)title {
    [self handleBeforeRequest];
    NSString *url = [XZCore fullUrlForPath:kSearchBulUrl];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[SPTools deletePunc:title] forKey:@"conditionValue"];
    [mDict setObject:@"1" forKey:@"pageNo"];
    [mDict setObject:@"5" forKey:@"pageSize"];
   
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:mDict success:^(NSString *responseStr, NSDictionary* userInfo) {
        [weakSmartEngine handleSearchBulResult:responseStr title:title];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}


/**
 请假单--计算时间
 */

- (void)requestLeaveTimeCount:(XZLeaveModel *)model  {
    NSString *url = [XZCore fullUrlForPath:kLeaveDaysUrl];
    if (![NSString isNull:model.endTime]) {
        url = [url appendHtmlUrlParam:@"begin" value:model.startTime];
        url = [url appendHtmlUrlParam:@"end" value:model.endTime];
        url = [url appendHtmlUrlParam:@"type" value:@"0"];
    }
    else {
        url = [url appendHtmlUrlParam:@"begin" value:model.startTime];
        NSString *days = [model translationArebicStr:model.timeNumber] ;
        url = [url appendHtmlUrlParam:@"days" value:days];
        url = [url appendHtmlUrlParam:@"type" value:@"1"];
    }
    url = [url urlCFEncoded];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response,NSDictionary* userInfo) {
        [weakSelf handleLeaveTimeCountResponse:response model:model];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];
}

/**
 请假单--发送
 */
- (void)sendLeaveForm:(XZLeaveModel *)model {
    NSString *url = [XZCore fullUrlForPath:kSendLeaveUrl];
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZSmartEngine) *weakSmartEngine= _smartEngine;

    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:[model paramsDic] success:^(NSString *response,NSDictionary* userInfo) {
        [weakSelf handleSendLeaveResponse:response model:model];
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakSmartEngine.sendBlock = nil;
        weakSmartEngine.modifyBlock = nil;
        weakSmartEngine.cancelBlock = nil;
        [weakSelf handleRequestError:error];
    }];
}
/**
请假单--修改
 */
- (void)modifyLeaveForm:(XZLeaveModel *)model {
    [self sendLeaveForm:model];
}

- (void)jumpToLeaveForm:(NSString *)templateId
             sendOnload:(NSString *)sendOnload
               formData:(NSString *)formData {
    NSString *href = [NSString stringWithFormat:@"http://collaboration.v5.cmp/v1.0.0/html/newCollaboration.html?openFrom=robot&templateId=%@&sendOnload=%@&initFormData=%@", templateId, sendOnload, formData];
    [XZOpenM3AppHelper showWebviewWithUrl:href];
    __weak typeof(_smartEngine) weakEngine = _smartEngine;
    [self dispatchAsyncToChild:^{
        [weakEngine resetSmartEngine];
    } ];
}

- (void)handleRequestError:(NSError *)error{
    [_smartEngine resetSmartEngine];
    [self enterSleep:YES];
    
    if (error.code == 292002) {
        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"提示" message:@"系统忙，请稍后重试" cancelButtonTitle:@"好的" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
           }];
        [alert show];
        return;
    }
    if (error.code == 292003) {
        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"提示" message:@"当前人数过多，请稍后再试" cancelButtonTitle:@"好的" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
           }];
        [alert show];
        return;
    }
    
    
    [XZMainProjectBridge updateReachableServer:error];
    if (![XZMainProjectBridge reachableServer] || ![XZMainProjectBridge reachableNetwork]) {
        NSString* aStr = ![XZMainProjectBridge reachableNetwork] ? @"当前网络不可用，请检查您的网络设置" :@"当前网络异常，无法访问服务器";
        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"提示" message:aStr cancelButtonTitle:@"好的" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
        }];
        [alert show];
        return;
    }
    NSString *message = error.domain;
    NSInteger errorCode = error.code;
    if (errorCode == 401 ||
        errorCode == 1001 ||
        errorCode == 1002 ||
        errorCode == 1003 ||
        errorCode == 1004 ||
        errorCode == 1005 ||
        errorCode == 1006 ||
        errorCode == 1007 ||
        errorCode == 50011 ||
        errorCode == 50022 ||
        errorCode == -1001 ||
        errorCode == 1010) {
        [self willLogout];
        __weak typeof(self) weakSelf = self;
        [self dispatchAsyncToMain:^{
            if (![CMPCore sharedInstance].isAlertOnShowSessionInvalid) {
                [CMPCore sharedInstance].isAlertOnShowSessionInvalid = YES;
                CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"登陆失效" message:message cancelButtonTitle:@"返回登录页" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [XZMainProjectBridge showLoginViewControllerWithMessage:nil];//这个荡与Sp2不一样滴
                        [weakSelf logout];
                    }
                }];
                [alert show];
            }
        }];
    } else {
        if (![NSString isNull:message]) {
            [_mainViewController showToast:message];
        }
    }
}

- (void)handleSendLeaveResponse:(NSString *)response model:(XZLeaveModel*)model {
    NSDictionary *reponseDic = [response JSONValue];
    NSDictionary *data = reponseDic[@"data"];
    BOOL success = [data[@"success"] boolValue];
    if (!success) {
        NSInteger errorType = [data[@"errorType"] integerValue];
        if (errorType == 1 || errorType == 2 ) {
            NSString *templateId = data[@"templateId"];
            NSString *resultData = data[@"resultData"];
            NSString *sendOnload = errorType == 1? @"true":@"false";
            NSString *msg = data[@"msg"];
            NSString *contentInfo =  errorType == 1 ? @"请你选择流程节点。":msg;
            NSString *buttonTitle = errorType == 1? @"选择":@"查看";
            __weak typeof(self) weakself = self;
            __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
            _smartEngine.sendBlock = nil;
            _smartEngine.modifyBlock = ^{
                [weakSpeechEngine stop];
                [weakself robotSpeak:@"好的，已为你打开请假单。" speakContent:@"好的，已为你打开请假单。"];
                if (weakSpeechEngine.isSpeaking) {
                    weakself.speakEndBlock = ^{
                        [weakself jumpToLeaveForm:templateId sendOnload:sendOnload formData:resultData];
                    };
                }
                else {
                    [weakself jumpToLeaveForm:templateId sendOnload:sendOnload formData:resultData];
                }
                [weakself needResetUnitDialogueState];
            };
            _smartEngine.cancelBlock = ^{
                [weakself showCancelCard];
            };
            [_mainViewController robotSpeakWithText:contentInfo];
            [_mainViewController showCreateAppCardButtons:@[@"取消",buttonTitle]];
            [_speechEngine speak:contentInfo];
            [self needContinueRecognize];
            [self needHumanSpeakNewLine];
        }
        else {
            _smartEngine.sendBlock = nil;
            _smartEngine.modifyBlock = nil;
            _smartEngine.cancelBlock = nil;

            NSString *msg = data[@"msg"];
            if (![NSString isNull:msg]) {
                msg = [NSString stringWithFormat:@"%@,%@",[model.handleType isEqualToString:@"modify"]?@"修改失败":@"发送失败",msg];
                [self robotSpeak:msg speakContent:msg];
            }
        }
    }
    else {
        if ([model.handleType isEqualToString:@"modify"]) {
            //请假单 --- 修改
            NSString *templateId = data[@"templateId"];
            NSString *resultData = data[@"resultData"];
            [self robotSpeak:@"好的，已为你打开请假单。" speakContent:@"好的，已为你打开请假单。"];
            __weak typeof(self) weakself = self;
            if (_speechEngine.isSpeaking) {
                self.speakEndBlock = ^{
                    [weakself jumpToLeaveForm:templateId sendOnload:@"false" formData:resultData];
                };
            }
            else {
                [self jumpToLeaveForm:templateId sendOnload:@"false" formData:resultData];
            }
        }
        else {
            [self robotSpeak:@"已成功为你交请假申请，请等待审批结果。" speakContent:@"已成功为你交请假申请，请等待审批结果。"];
        }
    }
}

- (void)handleLeaveTimeCountResponse:(NSString *)response model:(XZLeaveModel*)model {
    if (!model) {
        return;
    }
    NSDictionary *reponseDic = [response JSONValue];
    NSDictionary *data = reponseDic[@"data"];
    NSString *begin = data[@"begin"];
    NSString *end = data[@"end"];
    NSString *days = data[@"days"];
    if([days isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)days;
        days = [number stringValue];
    }
    model.startTime = begin;
    model.endTime = end;
    model.timeNumber = [NSString stringWithFormat:@"%@天",days];
    _smartEngine.sendBlock = ^{
        [model sendLeave];
    };
    _smartEngine.modifyBlock = ^{
        [model modifyLeave];
    };
    _smartEngine.cancelBlock = ^{
        [model cancelLeave];
    };
    [_mainViewController robotSpeakWithModels:@[model]];
    [_mainViewController showCreateAppCardButtons:@[@"取消",@"修改",@"发送"]];
    [self needContinueRecognize];
}


#pragma mark - UI
/**
 显示录音按钮
 */
- (void)showRecord {
    [_mainViewController enbaleSpeakButton:YES];
    [_speechEngine stopRecognize];
    [_mainViewController hideWaveView];
}


/**
 显示波形
 */
- (void)showWave {
    [_mainViewController enbaleSpeakButton:YES];
    [_mainViewController showWaveView];
}

/**
 显示等待波形
 */
- (void)showWaiting {
    [_mainViewController enbaleSpeakButton:YES];
    [_mainViewController showWaveViewAnalysis];
}

#pragma mark - Getter&Setter

- (NSString *)currentText {
    if (!_currentText || ![_currentText isKindOfClass:[NSString class]]) {
        _currentText = @"";
    }
    return _currentText;
}

- (void)handleRobotConfig {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf handleRobotConfigInner];
    }];
}

- (void)handleRobotConfigInner {
    UIView *msgview = [[XZSmartMsgManager sharedInstance] msgView];
    if (msgview && !msgview.hidden) {
        return ;
    }
    CMPSpeechRobotConfig *robotConfig = [XZCore sharedInstance].robotConfig;
    if (robotConfig.isOnShow && _isInWorkTime &&!self.isShowMainView) {
        // 判断小致按钮是否显示
        [self showTouchWindow];
    }
    else {
        _touchWindow.hidden = YES;
    }
    if (robotConfig.isAutoAwake && _isInWorkTime ) { // 判断小致唤醒是否开启
        [self startWakeup];
    }
    else {
        [self stopWakeUp];
    }
}


- (void)showTouchWindow {
    _touchWindow.hidden = NO;
    UIViewController *vc = [CMPSpeechRobotManager sharedInstance].xzIconInViewController;
    if (vc && INTERFACE_IS_PHONE) {
        [self needShowXiaozIconInViewController:vc];
    }
    else {
        UIWindow *window = [SPTools keyWindow];
        [_touchWindow removeFromSuperview];
        [window addSubview:_touchWindow];
        [window bringSubviewToFront:_touchWindow];
    }
}




#pragma mark - Registe And Handle Notification

- (void)registeNotification {
    _showOrNot  =   YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRobotConfigChanged:)
                                                 name:kNotificationName_RobotConfigValueChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleShowRobotAssistiveTouchOnPageSwitch:)
                                                 name:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_ShowGuidePagesView
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_HideGuidePagesView
                                               object:nil];
    //手势密码
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_GestureWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_GestureWillHiden
                                               object:nil];
    //二维码
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_BarcodeScannerWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_BarcodeScannerWillHide
                                               object:nil];
    //录音
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_AudioRecorderWillRecording
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_AudioRecorderWillStop
                                               object:nil];
    //播放语音
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_AudioPlayerWillPlay
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_AudioPlayerWillStop
                                               object:nil];
    //新建联系人 人员保存到本地
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_ABNewPersonViewWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_ABNewPersonViewWillHide
                                               object:nil];
    //语音输入
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_SpeechInputWillInput
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_SpeechInputWillStop
                                               object:nil];
    //拍照相册 统一不好区分
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_CameraWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_CameraWillHide
                                               object:nil];
    
    //快捷方式
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(quickModuleWillShow)
                                                 name:kNotificationName_QuickModuleWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(quickModuleWillHide)
                                                 name:kNotificationName_QuickModuleWillHide
                                               object:nil];
    //红包
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_RedPacketWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_RedPacketWillHide
                                               object:nil];
    //第三方打开附件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_ThirdAppMenuWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_ThirdAppMenuWillHide
                                               object:nil];
    //alert alert- show 关闭唤醒
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(canNotUseWakeup)
                                                 name:kNotificationName_AlertWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(canUseWakeup)
                                                 name:kNotificationName_AlertWillHide
                                               object:nil];
    //发短信
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_SMSViewWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_SMSViewWillHide
                                               object:nil];
   
    /*融云需关闭小致，以修复 OA-161007（致信）开着小致的时候致信语音发不出去，一直提示时间过短*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_RCChatWillShow
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_RCChatWillHide
                                               object:nil];
    /*语音插件 开始：隐藏小致   结束：重新显示小致*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideSpeechRobot:)
                                                 name:kNotificationName_SpeechPluginOn
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpeechRobot:)
                                                 name:kNotificationName_SpeechPluginOff
                                               object:nil];
    //QA界面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(hideSpeechRobot:)
                                                    name:kNotificationName_QAChatOn
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(showSpeechRobot:)
                                                name:kNotificationName_QAChatOff
                                                object:nil];
    _xzCanUseWakeup = YES;
}
- (void)quickModuleWillShow {
    [XZSmartMsgManager sharedInstance].canShowMsgView = NO;
    [self hideSpeechRobot:nil];
}
- (void)quickModuleWillHide {
    [XZSmartMsgManager sharedInstance].canShowMsgView = YES;
    [self showSpeechRobot:nil];
}
- (void)canNotUseWakeup {
    _xzCanUseWakeup = NO;
    [self stopWakeUp];
    [_speechEngine stop];
    [_mainViewController hideKeyboard];
}
- (void)canUseWakeup {
    _xzCanUseWakeup = YES;
    if (!_touchWindow.hidden) {
        [self startWakeup];
    }
}

- (void)showSpeechRobot:(NSNotification *)notification{
    self.hideWindowCount --;
    if (self.hideWindowCount > 0) {
        return;
    }
    self.hideWindowCount = 0;
    _enterForegroundShowIcon = YES;
    if (!_isLogout) {
        [self handleRobotConfig];
    }
}

- (void)hideSpeechRobot:(NSNotification *)notification{
    self.hideWindowCount ++;
    _touchWindow.hidden = YES;
    _enterForegroundShowIcon = NO;
    [self stopWakeUp];
    
}

- (void)handleRobotConfigChanged:(NSNotification *)notification {
    NSObject *object = [notification object];
    if ([object isKindOfClass:[CMPSpeechRobotConfig class]]) {
        CMPSpeechRobotConfig *config = (CMPSpeechRobotConfig *)object;
        [self handleRobotConfig];
        if (![_currentStartTime isEqualToString:config.startTime] ||
            ![_currentEndTime isEqualToString:config.endTime]) {
            [self startTimer:config];
        }
    } else {
    }
}

- (void)handleWillEnterForeground {
    [self stopOtherMusic];
    if (_showOrNot && !self.isShowMainView && _enterForegroundShowIcon) {
        [[SPTimer sharedInstance] refershTimer];
    }
    [self startWakeup];
    [XZSmartMsgManager sharedInstance].canShowMsgView = YES;
}

- (void)toggleShowRobotAssistiveTouchOnPageSwitch:(NSNotification *)notification {
    _showOrNot = [notification.object boolValue];
    [SPTimer sharedInstance].showOrNot = _showOrNot;
    if (_showOrNot) {
        if (!_isLogout) {
            [self handleRobotConfig];
        }
    }else{
        _touchWindow.hidden = YES;
        [self stopWakeUp];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    [self mainViewControllerDidDismiss];
}

- (void)handleDidBecomeActiveNotification:(NSNotification *)notif {
    [self stopOtherMusic];
}
//停止其它app音乐
- (void)stopOtherMusic {
//    百度sdk会setActive:NO 以下代码没用了
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [session setActive:YES error:nil];
}



#pragma mark smart  msg
- (void)startShowSmartMsg {
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    __weak typeof(XZTouchWindow) *weakWindow = _touchWindow;
    XZSmartMsgManager *manager = [XZSmartMsgManager sharedInstance];
    manager.robotSpeakBlock = ^(NSString *word, NSString *speakContent) {
        if ([NSString isNull:word]) {
            [weakSpeechEngine speakLongStr:speakContent];
        }
        else {
            [weakSelf robotSpeak:word speakContent:speakContent];
        }
    };
    manager.stopSpeakBlock = ^{
        [weakSpeechEngine stopSpeak];
    };
    manager.showSpeechRobotBlock = ^{
        [weakSelf showSpeechRobot:nil];
    };
    manager.handleBeforeRequestBlock = ^{
        [weakSelf handleBeforeRequest];
    };
    manager.willShowMsgViewBlock = ^{
        [weakSelf hideSpeechRobot:nil];
        weakWindow.hidden = YES;
        [weakSelf stopWakeUp];
    };
    manager.enterSleepBlock = ^(BOOL sleep) {
        [weakSelf enterSleep:sleep];
    };
    manager.handleErrorBlock = ^(NSError *error) {
        [weakSelf handleRequestError:error];
    };
    [manager startShowSmartMsg];
}

- (void)needSearchSmartMsg:(NSString *)date {
    [_mainViewController hideKeyboard];
    [[XZSmartMsgManager sharedInstance] needSearchSmartMsg:date inController:_mainViewController];
}

- (void)addListenToTabbarControllerShow {
    [[XZSmartMsgManager sharedInstance] addListenToTabbarControllerShow];
}


@end
