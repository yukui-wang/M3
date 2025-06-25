//
//  XZMainController.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZPreMainController.h"
#import "XZTouchWindow.h"
#import "SPConstant.h"
#import "XZPreMainViewController.h"
#import "XZPreMainView.h"
#import "SPTools.h"
#import "XZSmartEngine.h"
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
#import "XZLeaveErrorModel.h"
#import "XZOptionMemberModel.h"
#import "XZOpenM3AppHelper.h"
#import "XZPreQATextModel.h"
#import "XZPreQAFileModel.h"
#import "XZTransWebViewController.h"
#import "XZM3RequestManager.h"
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XZSmartMsgManager.h"

#import <CMPLib/NSString+CMPString.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPFaceImageManager.h>
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/UIViewController+CMPViewController.h>
#import <CMPLib/CMPConstant.h>
#import "XZAppIntent.h"
#import "XZSearchAppIntent.h"
#import "XZCreateAppIntent.h"
#import "XZOpenAppIntent.h"

#import "XZMainProjectBridge.h"


#define MAX_UNKNOWN_COUNT 3 // 第n次输入未知一级命令后，回到主页面

typedef NS_ENUM(NSUInteger, XZMainControllerState) {
    XZMainControllerClose,   // 小致隐藏
    XZMainControllerSpeak,   // 小致正在说话
    XZMainControllerRecognize, // 小致正在识别
    XZMainControllerQuery, // 小致正在访问网络
    XZMainControllerSleep, // 小致休眠
};

@interface XZPreMainController() <SPSmartEngineDelegate, SPSpeechEngineDelegate, UIAlertViewDelegate,XZMainViewControllerDelegate,MFMessageComposeViewControllerDelegate> {

    XZTextModel *_humanSpeakModel;//当前正在说话的,说完了将其设置为nil
    XZTouchWindow *_touchWindow;//小智悬浮框
    XZPreMainViewController *_mainViewController;
    BOOL _showOrNot;
    BOOL _mainVCNeedAlert;
    BOOL _isShowMainView;
    BOOL _resultFromSpeech;//结果来自语音
    BOOL _xzCanUseWakeup;//小致能否使用语音唤醒
    BOOL _enterForegroundShowIcon;//冲后台到前台是否显示小致按钮
    BOOL _mainVCShowFirst;
}

@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, strong) SPSpeechEngine *speechEngine;
@property (nonatomic, strong) XZSmartEngine *smartEngine;
@property (nonatomic, strong) XZPreMainViewController *mainViewController;

@property (nonatomic) int currentVolume; // 音量
@property (nonatomic) NSUInteger state; // 小致状态

@property (nonatomic) NSInteger unknownCount; // 未知一级命令计数器
@property (nonatomic) BOOL isShowMemberSelect; // 选人逻辑用户输入是否显示（下一步、第几要显示）
@property (nonatomic) BOOL isContactSuccess; // 离线通讯录是否下载成功
@property (nonatomic) BOOL isLogout; // 是否退出登录
@property (nonatomic, strong) CMPSpeechRobotConfig *robotConfig; // 小致配置

@property (nonatomic, strong) NSString *currentStartTime; // 开始工作时间
@property (nonatomic, strong) NSString *currentEndTime; // 结束工作时间
@property (nonatomic) BOOL isInWorkTime; // 当前是否在工作时间段
@property (nonatomic) BOOL isSelectPeople; // 是否是选人模式


@property(nonatomic, strong)NSString *optionKey;//选项识别缓存数据
@property (nonatomic, copy) void (^speakEndBlock)(void);
@property (nonatomic, copy) void (^speakEndStartWakeupBlock)(void);//语音结束加唤醒

@property(nonatomic, copy) NSString *QARequestId;//防止多次点击

@property (nonatomic, assign)NSInteger hideWindowCount;//hideWindowCount = 0时执行showspeech


@end

@implementation XZPreMainController
static id shareInstance;
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _humanSpeakModel = nil;//不能release
    SY_RELEASE_SAFELY(_touchWindow);
    SY_RELEASE_SAFELY(_mainViewController);
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
    [super dealloc];
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
//    [self initTouchWindow];
    [self initSpeechEngine]; // 初始化语音引擎
    [self initSmartEngine]; // 初始化小致智能引擎
    [self registeNotification]; // 注册通知
    // 小致设置
//    [self startTimer:[XZCore sharedInstance].robotConfig];
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
    //获取当前人员头像
    [self loadUserFace];
    //请求权限
    [self requestCalEventAuth];
    [self requestQAPermission];

    //开始显示智能消息
    [self startShowSmartMsg];
}
- (void)needShowXiaozIconInViewController:(UIViewController *)vc {
    
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
        _isInWorkTime = YES;
        [weakself handleRobotConfig];
    };
    scheduleItem.offAction = ^() {
        _isInWorkTime = NO;
        [weakself handleRobotConfig];
    };
    [SPTimer addTimeSechedule:scheduleItem];
}

- (void)loadUserFace {
    [XZCore sharedInstance].userProfileImage = XZ_IMAGE(@"xz_user_def.png");
    
    [[CMPFaceImageManager sharedInstance] fetchfaceImageWithMemberId:[XZCore userID] complete:^(UIImage *image) {
        if (image) {
            [XZCore sharedInstance].userProfileImage = image;
        }
    } cache:YES];
}


- (void)requestCalEventAuth {
    NSString *url = [XZCore fullUrlForPath:kCalEventAuthUrl];
    [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response,NSDictionary* userInfo) {
        NSDictionary *result = [response JSONValue];
        [XZCore sharedInstance].privilege.hasCalEventAuth = [SPTools boolValue:result forKey:@"hasCalEventAuth"];
        [XZCore sharedInstance].privilege.hasMeetingAuth = [SPTools boolValue:result forKey:@"hasMeetingAuth"];
        [XZCore sharedInstance].privilege.hasTaskAuth = [SPTools boolValue:result forKey:@"hasTaskAuth"];
        
    } fail:^(NSError *error,NSDictionary* userInfo) {
        
    }];
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

- (BOOL)reShowInWindow {
    if (_touchWindow) {
        [self handleRobotConfig];
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
            XZQAGuideInfo *info = [[[XZQAGuideInfo alloc] initWithResult:data] autorelease];
            SPBaiduUnitInfo *unitInfo = nil;
            if (info.preset) {
                unitInfo = [[[SPBaiduUnitInfo alloc] initWithQAResult:data] autorelease];
            }
            [weakself showQA:info unit:unitInfo];
        }
    } fail:^(NSError *error,NSDictionary* userInfo) {
        weakself.QARequestId = nil;
        NSString *errorStr = error.domain;
        CMPAlertView *aAlertView = [[CMPAlertView alloc] initWithTitle:SY_STRING(@"common_prompt")  message:errorStr cancelButtonTitle:SY_STRING(@"common_ok") otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
        }];
        [aAlertView show];
        [aAlertView release];
    }];
   
}


- (void)showMainview {
    [self showMainviewWithGuideInfo:nil unit:nil];
}

- (void)showMainviewWithGuideInfo:(XZQAGuideInfo *)guideInfo unit:(SPBaiduUnitInfo *)unitInfo {
    
    [_smartEngine resetSmartEngine];
    SPBaiduUnitInfo *unit = unitInfo? unitInfo:[XZCore sharedInstance].baiduUnitInfo;
    [_smartEngine setupBaseInfo:unit];
    
    
    BOOL allowRotation = INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
//    [XZMainViewController lockRotation:!allowRotation];

    
    //显示主界面前关闭唤醒
    [self stopWakeUp];
  
    _touchWindow.hidden = YES;
    if (_mainViewController) {
        //清除遗漏
        SY_RELEASE_SAFELY(_mainViewController);
    }
    if (!_mainViewController) {
        _mainViewController = [[XZPreMainViewController alloc] init];
        _mainViewController.delegate = self;
        _mainVCNeedAlert = NO;
        _mainViewController.allowRotation = allowRotation;
        __weak typeof(self) weakSelf = self;
        _mainVCShowFirst = YES;
        _mainViewController.guideInfo = guideInfo;
        UIViewController *vc = [SPTools currentViewController];
        [vc presentViewController:_mainViewController animated:YES completion:^{
            [weakSelf mainViewControllerDidShow];
            _mainVCShowFirst = NO;
        }];
    }
    _mainViewController.recognizeType = SpeechRecognizeFirstCommond;
    _speechEngine.delegate = self;//语音速记影响点   delegate
}

- (void)showQA:(XZQAGuideInfo *)guideInfo unit:(SPBaiduUnitInfo *)unitInfo {
    [self showMainviewWithGuideInfo:guideInfo unit:unitInfo];

}

- (void)hideMainview
{
    [self showTouchWindow];
    [_mainViewController dismissViewControllerAnimated:YES completion:^{
        SY_RELEASE_SAFELY(_mainViewController);
    }];
    [XZMainProjectBridge clearMediatorCache];
}


#pragma mark XZMainViewControllerDelegate begin


- (void)mainViewControllerDidShow
{
    _isShowMainView = YES;
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [self enterSleep:YES];
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    self.speechEngine.isNeedPlayStartAudio = YES;
    _unknownCount = 0;
    _mainVCNeedAlert = NO;
    
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [_mainViewController setXzMoodState:XZMoodStateInactive];
    [self recognizeFirstCommond];
    if (![_mainViewController keyboardIsShow]) {
        [self mainViewControllerShouldSpeak];
    }
}

- (void)mainViewControllerDidDismiss {
    self.speakEndBlock = nil;
    [_smartEngine resetSmartEngine];
    _isShowMainView = NO;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self needResetUnitDialogueState];
    [self.speechEngine stop];
    [self enterClose];
    if (!self.isLogout) {
        [self handleRobotConfig];
    }
    [_mainViewController clearMessage];
    [self hideMainview];
    [[XZM3RequestManager sharedInstance] cancelAllRequest];
}

- (void)mainViewControllerShouldSpeak {
    [self stopWakeUp];//关闭唤醒

    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZPreMainViewController) *weakMainViewController= _mainViewController;
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
        if ([weakMainViewController keyboardIsShow]) {
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
        [alert show];
        SY_RELEASE_SAFELY(alert)
    }];
}

- (void)mainViewControllerShouldSpeakInner {
    if (!_isShowMainView) {
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
    return _mainVCNeedAlert;
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
    SpeechRecognizeType type = _mainViewController.recognizeType;
    if (!(type == SpeechRecognizeLongText || (type == SpeechRecognizeMember && [_smartEngine isInCreateColl]))) {
        _humanSpeakModel = nil;
    }
    [self mainViewControllerShouldStopSpeak];
    _resultFromSpeech = NO;
    [self humanSpeak:text];
    [self analysisResult:text];
}

- (void)mainViewControllerTapText:(NSString *)text {
    _humanSpeakModel = nil;
    [self mainViewControllerInputText:text];
}

- (void)mainViewControllerDidSelectMembers:(NSArray *)members skip:(BOOL)skip{
    //关闭语音识别
    [self mainViewControllerShouldStopSpeak];
    //常用联系人选了人员
    if (_smartEngine.membersBlock) {
        _smartEngine.membersBlock(members, NO,nil);
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
    if (!_mainVCShowFirst) {
        [self startWakeup];
    }
}

- (void)mainViewControllerWillDisappear {
    if (_isShowMainView) {
        [_speechEngine stop];
        [self showRecord];
        [self stopWakeUp];
    }
}


#pragma mark XZMainViewControllerDelegate end
- (void)handleWakeup {
    if (_isShowMainView) {
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SPWakeuper sharedInstance] startWakeupWithAction:^{
            [weakSelf handleWakeup];
        }];
    });
}
- (void)stopWakeUp {
    self.speakEndStartWakeupBlock = nil;
    [[SPWakeuper sharedInstance] stopWakeup];
}

/**
 说话按钮点击事件  目前是没有用到
 */
- (void)speakButtonTap {
    [_speechEngine stopSpeak];
    if (_state == XZMainControllerSpeak) {
        [self enterSleep:YES];
    }
    if (_state == XZMainControllerSleep) { // 如果当前状态是挂起，恢复现场，继续识别
        if (![XZMainProjectBridge reachableNetwork]) {
            [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
            return;
        }
        [_smartEngine wakeUp];
    }
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
    _mainViewController.recognizeType = SpeechRecognizeMember;
    BOOL multi = [_smartEngine isMultiSelectMember];//目前仅协同选人多选
    __weak XZPreMainView *weakView = (XZPreMainView *)_mainViewController.mainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView showMemberView:multi];
    });
    //常用联系人
    [XZMainProjectBridge topTenFrequentContact:^(NSArray * result) {
        if (result.count >0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakView showFrequentView:multi members:result];
            });
        }
    } addressbook:!multi];
}
/**
 识别选项
 */
- (void)recognizeOption:(NSString *)optionKey {
    _mainViewController.recognizeType = SpeechRecognizeOption;
}
#pragma mark 封装识别分类方法  end


- (void)humanSpeak:(NSString *)word {
    if ([word isEqualToString:@""]) {
        return;
    }
    if(_humanSpeakModel) {//正在说话
        _humanSpeakModel.contentInfo = [_humanSpeakModel.contentInfo stringByAppendingString:word];
        [_mainViewController humenSpeakWithModel:_humanSpeakModel];
    } else { // 新增说话
        XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeUserMessage itemTag:0 contentInfo:word];
        _humanSpeakModel = model;
        [_mainViewController humenSpeakWithModel:model];
    }
}

- (void)robotSpeak:(NSString *)word speakContent:(NSString *)content {
    _humanSpeakModel = nil;
    XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:word];
    [model cellHeight];
    if (model.tapEnable) {
        _smartEngine.currentCellModel = model;
    }
    model.clickLinkBlock = ^(NSString *linkUrl) {
        CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
        aCMPBannerViewController.startPage = linkUrl;
        aCMPBannerViewController.hideBannerNavBar = NO;
        aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
        aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
        [[SPTools currentViewController] presentViewController:aCMPBannerViewController animated:YES completion:^{
            
        }];
        SY_RELEASE_SAFELY(aCMPBannerViewController);
    };
    [_mainViewController robotSpeakWithModel:model];
    [self speak:content];
}

- (void)speak:(NSString *)word {
    if (!_isShowMainView) {
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
    if (!(type == SpeechRecognizeLongText || (type == SpeechRecognizeMember && [_smartEngine isInCreateColl]))) {
        _humanSpeakModel = nil;
    }
    if (!_smartEngine.useUnit && [_smartEngine isInCreateColl]) {
        //发起协同特殊处理按照第一版的逻辑处理
        [self onResultsInner:resultArr type:type isLast:isLast];
    }
    else {
        [self humanSpeak:parameter];
        [self analysisResult:parameter];
    }
}

- (void)onResultsInner:(NSArray *)resultArr type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    [_mainViewController setXzMoodState:XZMoodStateAnalysising];
    NSString *result = @"";
    if (type == SpeechRecognizeMember) {    // 选人流程需要获取
        result = [SPTools arrayToStr:resultArr];
    }
    else {
        result = [resultArr firstObject];
    }
    
    if (![result isEqualToString:@""] &&
        ![result containsString:NOMATCH_ALL]) {
        self.currentText = [NSString stringWithFormat:@"%@%@", self.currentText, result];
    }
    
    if (type == SpeechRecognizeFirstCommond ||
        type == SpeechRecognizeMember ||
        type == SpeechRecognizeOption ||
        type == SpeechRecognizeSearchColText) {
        if (isLast) {
            [self enterQuery];
        }
    }
    else if (type == SpeechRecognizeShortText) {
        if (![result isEqualToString:@""]) {
        }
        if (isLast && ![self.currentText isEqualToString:@""]) {
            [self enterQuery];
        }
        if (isLast && [self.currentText isEqualToString:@""]) {
            _speechEngine.isNeedPlayStartAudio = NO;
            [_smartEngine wakeUp];
        }
    }
    else if (type == SpeechRecognizeLongText) {
        if (![result isEqualToString:@""]) {
        }
        if (isLast && [self.currentText isEqualToString:@""]) {
            _speechEngine.isNeedPlayStartAudio = NO;
            [_smartEngine wakeUp];
        }
    }
    
    if (type == SpeechRecognizeFirstCommond) {  // 处理一级命令词
        // 如果返回为空，则说明暂不支持该命令词
        if ([result isEqualToString:@""] ||
            [result containsString:NOMATCH_ALL]) {
            [self unknownCommond:type];
            return;
        }
        _unknownCount = 0;
        [self humanSpeak:result];
        if (isLast) {
            _humanSpeakModel = nil;
            self.currentText = @"";
        }
    }
    else {
        // 如果返回为空，说明没有识别出来，执行unkownCount逻辑
        if ([result containsString:NOMATCH_ALL]) {
            [self unknownCommond:type];
            return;
        }
        _unknownCount = 0;
        // 把识别出来的文字显示到人员说话框中
        [self showHumanText:result withType:type isLast:(BOOL)isLast];
    }
}

- (void)onError:(NSError *)error {
    [_mainViewController setXzMoodState:XZMoodStateError];
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
}

//开始录音回调
- (void)onBeginOfSpeech {
    [self enterRecognize];
}

//音量回调函数
- (void)onVolumeChanged:(NSInteger)volume {

}

//会话取消回调
- (void)onCancel {
   
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


#pragma mark - 语音识别结果处理

/**
 把识别出来的文字显示到屏幕
 
 param text 识别出来的文本
 param type 类型
 */
- (void)showHumanText:(NSString *)text withType:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    if (type == SpeechRecognizeLongText) {
        if (![self.currentText containsString:SPEECH_END_KEY] &&
            ![self.currentText containsString:SPEECH_END_KEY2] &&
            ![self.currentText containsString:SPEECH_END_KEY3] &&
            ![self.currentText containsString:SPEECH_END_KEY4] &&
            ![self.currentText containsString:SPEECH_END_KEY5] &&
            ![self.currentText containsString:SPEECH_END_KEY6]) {
            [self humanSpeak:text];
        }
        else {
            NSString *result = [text replaceCharacter:SPEECH_END_KEY withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY2 withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY2 withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY3 withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY4 withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY5 withString:@""];
            result = [result replaceCharacter:SPEECH_END_KEY6 withString:@""];
            [self humanSpeak:result];
            isLast = YES;
        }
    }
    else if (type == SpeechRecognizeMember) { //选人比较特殊，不能实时显示
        if (_isShowMemberSelect && ![self.currentText isEqualToString:@"下一步"]) {
            NSArray *tmpArr = [text componentsSeparatedByString:@","];
            [self humanSpeak:[tmpArr firstObject]];
            _humanSpeakModel = nil;
        }
    }
    else {
        if (type == SpeechRecognizeMemberOption) {
            _humanSpeakModel = nil;
        }
        [self humanSpeak:text];
    }
    
    if (isLast) {
        if (type == SpeechRecognizeMember) {
            if ([self.currentText isEqualToString:@"下一步"]) {
                _humanSpeakModel = nil;
                [self humanSpeak:self.currentText];
                _humanSpeakModel = nil;
            }
            else {
            }
        }
        else if (type == SpeechRecognizeLongText) {
        }
        else {
            _humanSpeakModel = nil;
        }
        if (![self.currentText isEqualToString:@""]) {
            [_smartEngine setResult:self.currentText];
        }
        self.currentText = @"";
    }
}


#pragma mark - SPSmartEngineDelegate

- (void)needReadWord:(NSString *)word speakContent:(NSString *)speakContent {
    [self robotSpeak:word speakContent:speakContent];
}

- (void)needShowHumanWord:(NSString *)word newLine:(BOOL)isNewLine {
    if (isNewLine) {
        _humanSpeakModel = nil;
    }
    if (!_humanSpeakModel) {
        [self humanSpeak:word];
    } else {
        [self humanSpeak:[NSString stringWithFormat:@"、%@", word]];
    }
    [self showRecord];
    if (isNewLine) {
        _humanSpeakModel = nil;
    }
}

- (void)needHumanSpeakNewLine {
    _humanSpeakModel = nil;
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
    _isSelectPeople = isSelect;
    [self recognizeMember];
    _isShowMemberSelect = isShow;
}
- (void)needChooseFormOptionMembers:(XZOptionMemberParam *)param block:(SmartMembersBlock)block{
    _humanSpeakModel = nil;
    _smartEngine.isClarifyMembers = YES;
    _isSelectPeople = YES;
    _isShowMemberSelect = YES;
    [self speak:param.speakContent];
    [self needContinueRecognize];
    _mainViewController.recognizeType = SpeechRecognizeMemberOption;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;
    __weak typeof(SPSpeechEngine) *weakEngine = _speechEngine;
    __weak typeof(self) weakself = self;
    if(param.isMultipleSelection) {
        //用于 多选 不支持第几位选择
        param.membersChoosedBlock = block;
    }
    XZOptionMemberModel *model = [[XZOptionMemberModel alloc] init];
    model.param = param;
    model.didChoosedMembersBlock = ^(NSArray *selectMembers,BOOL showName) {
        weakSmartEngine.currentCellModel = nil;
        weakSmartEngine.isClarifyMembers = NO;
        [weakself needHumanSpeakNewLine];
        CMPOfflineContactMember *member = [selectMembers firstObject];
        NSString *name = [NSString stringWithFormat:@"%@%@",member.department,member.name];
        NSLog(@"点击重复人员：%@",name);
        [weakself humanSpeak:name];
        block(selectMembers,NO,nil);
        [weakself needResetUnitDialogueState];
    };
    model.clickTextBlock = ^(NSString *text) {
        weakSmartEngine.isClarifyMembers = NO;
        block(nil,YES,nil);
        
        if ([weakSmartEngine isInCreateColl]) {
            [weakself onResultsInner:[NSArray arrayWithObject:text] type:SpeechRecognizeMemberOption isLast:YES];
            [weakself robotSpeak:@"好的" speakContent:@"好的"];
            _isSelectPeople = NO;
        }
        else {
            [weakself humanSpeak:text];
            [weakself robotSpeak:@"好的" speakContent:@"好的"];
            [weakEngine stop];
            [weakself needResetUnitDialogueState];
        }
    };
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModel:model];
    SY_RELEASE_SAFELY(model);
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
    _mainVCNeedAlert = YES;
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
    _mainVCNeedAlert = NO;
}

- (void)needClose {
    __weak typeof(self) weakself = self;
    self.speakEndBlock = ^{
        [weakself mainViewControllerDidDismiss];
    };
//    [self robotSpeak:@"好的，再见" speakContent:@"好的，再见"];
   
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
    _humanSpeakModel = nil;
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
        [_smartEngine setResult:@"success"];
    } else {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [_smartEngine resetSmartEngine];
        _mainVCNeedAlert = NO;
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
    if (show) {
        [_mainViewController showSubSearchView];
    }
    else {
        [_mainViewController hideSubSearchView];
    }
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
    helper.stopSpeakBlock = ^{
        [self.speechEngine stopSpeak];
    };
    XZTextModel *model = [helper getShowModel];
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModel:model];
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
        [weakSmartEngine createColl];
        weakSmartEngine.currentMember = nil;
    };
    model.sendIMMessageBlock = ^(CMPOfflineContactMember *member) {
        [weakSelf needSendIMMsg:member content:nil];
        weakSmartEngine.currentMember = nil;
    };
    
    model.member = member;
    if (ok) {
        [self robotSpeak:@"好的" speakContent:@"好的"];
    }
    if (model.canOperate) {
        _smartEngine.intentState = XZIntentState_PWaiting;
    }
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModel:model];
    SY_RELEASE_SAFELY(model);
}

- (void)needShowSchedule:(SPScheduleHelper *)helper {
    if (!helper) {
        return;
    }
    [_mainViewController robotSpeakWithModel:[helper getPlanShowModel]];
    [self speak:[helper getPlanSpeakStr]];
}

- (void)needShowTodo:(SPScheduleHelper *)helper {
    if (!helper) {
        return;
    }
    [_mainViewController robotSpeakWithModel:[helper getTodoShowModel]];
    [self speak:[helper getTodoSpeakStr]];
}

- (void)needUnknownCommond {
    [self unknownCommond:_mainViewController.recognizeType];
}


/**
 是否有请假单
 */
- (void)needCheckLeaveForm:(void(^)(BOOL success,NSString *msg))complete {
    if (complete) {
        complete(YES,nil);
    }
}
/**
 发请假单
 */
- (void)needSendLeaveForm:(XZLeaveModel *)model {
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
        [weakSelf robotSpeak:@"已为你取消发送请假申请。" speakContent:@"已为你取消发送请假申请。"];
        [weakSelf needResetUnitDialogueState];
    };
    [self requestLeaveTimeCount:model];
}

- (void)needResetUnitDialogueState {
    [_smartEngine needResetUnitDialogueState];
    [_mainViewController hideKeyboard];
}

- (void)needContinueRecognize {
    if (_isLogout || !_isShowMainView) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    __weak typeof(XZPreMainViewController) *weakMainViewController= _mainViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
    
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
    [_mainViewController robotSpeakWithModel:model];
}

/**
 显示帮助信息
 */
- (void)needShowHelpInfo {
    [_mainViewController robotSpeakWithModels:[_mainViewController.guideInfo cellModels:NO]];
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
    [_mainViewController setXzMoodState:XZMoodStateInactive];
    self.currentText = @"";
    _humanSpeakModel = nil;
}

- (void)enterRecognize {
    if (_state == SPAnswerSleep) {
        [_smartEngine wakeUp];
    }
    _state = XZMainControllerRecognize;
    [self showWave];
    [_mainViewController setXzMoodState:XZMoodStateActive];
}

- (void)enterSpeak {
    _state = XZMainControllerSpeak;
    [self showRecord];
    [_mainViewController setXzMoodState:XZMoodStateInactive];
}

- (void)enterQuery {
    _state = XZMainControllerQuery;
    if (_resultFromSpeech) {
        [[SPAudioPlayer sharedInstance] playEndAudio];
    }
    [self showWaiting];
    [_mainViewController setXzMoodState:XZMoodStateAnalysising];
}

- (void)enterSleep:(BOOL)isBreak {
    _state = XZMainControllerSleep;
    if (isBreak) {
        [_speechEngine stop];
    }
    [self showRecord];
    [_mainViewController setXzMoodState:XZMoodStateInactive];
}

- (void)enterBackground {
    [self stopWakeUp];
    [self enterSleep:YES];
}

- (void)logout {
    [_mainViewController dismissViewControllerAnimated:NO completion:nil];
    _isShowMainView = NO;
    _isLogout = YES;
    _touchWindow.hidden = YES;
    [_touchWindow removeFromSuperview];
    SY_RELEASE_SAFELY(_touchWindow);
    SY_RELEASE_SAFELY(_mainViewController);
    [self stopWakeUp];
    [self needResetUnitDialogueState];
    [self.speechEngine logout];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SPTimer removeAllSechedule];
    [[XZCore sharedInstance] clearData];
    [XZMainProjectBridge clearMediatorCache];
    [[XZSmartMsgManager sharedInstance] userLogout];
}

- (void)willLogout {
    [XZCore sharedInstance].baiduSpeechInfo = nil;
    _isShowMainView = NO;
    _isLogout = YES;
    [self stopWakeUp];
    [self needResetUnitDialogueState];
    [self.speechEngine logout];
    [_mainViewController hideWaveView];
    [SPTimer removeAllSechedule];
    [[XZSmartMsgManager sharedInstance] userLogout];
}

- (void)unknownCommond:(SpeechRecognizeType)type {
    [_mainViewController setXzMoodState:XZMoodStateAnalysisFailure];
    if(_unknownCount % MAX_UNKNOWN_COUNT == 1) {
        [self enterSleep:NO];
        XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:@"对不起，我还要再学习！"];
        [_mainViewController robotSpeakWithModel:model];
        [self speak:@"对不起，我还要再学习！"];
        [_smartEngine resetSmartEngine];
        //        [self enterSleep:NO];
        
        [self recognizeFirstCommond];
        _unknownCount = 0;
    } else {
        if (type == SpeechRecognizeFirstCommond) {
            if (_isContactSuccess) {
                [self robotSpeak:@"很抱歉，我没有明白，你能再重复一下吗？" speakContent:@"很抱歉，我没有明白，你能再重复一下吗？"];
            } else {
                [self robotSpeak:@"对不起，正在下载通讯录，请稍后使用小致。" speakContent:@"对不起，正在下载通讯录，请稍后使用小致。"];
            }
            
            [self recognizeFirstCommond];
            _unknownCount++;
        } else if (type == SpeechRecognizeShortText) {
            [self robotSpeak:@"很抱歉，我没有明白，你能再重复一下吗？" speakContent:@"很抱歉，我没有明白，你能再重复一下吗？"];
            [self recognizeShortText];
        } else if (type == SpeechRecognizeLongText) {
            [self robotSpeak:@"很抱歉，我没有明白，你能再重复一下吗？" speakContent:@"很抱歉，我没有明白，你能再重复一下吗？"];
            [self recognizeLongText];
        } else if (type == SpeechRecognizeMember) {
            if (_isSelectPeople) {
                [self robotSpeak:@"很抱歉，我没有明白，你能再重复一下吗？" speakContent:@"很抱歉，我没有明白，你能再重复一下吗？"];
            } else {
                if ([_smartEngine isInCol]) {
                    if ([_smartEngine isColHasMember]) {
                        [self robotSpeak:@"对不起，我没有找到，请继续选人或者命令“##下一步##”。" speakContent:@"对不起，我没有找到"];
                    } else {
                        [self robotSpeak:@"对不起，我没有找到，请重新录入。" speakContent:@"对不起，我没有找到，请重新录入。"];
                    }
                } else if ([_smartEngine isInFindMan]) {
                    [self robotSpeak:@"对不起，我没有找到，请重新说要查找谁？" speakContent:@"对不起，我没有找到"];
                    _unknownCount++;
                } else if ([_smartEngine isInCallPhone]) {
                    [self robotSpeak:@"对不起，我没有找到，请重新说要打电话给谁？" speakContent:@"对不起，我没有找到"];
                    _unknownCount++;
                } else if ([_smartEngine isInSendMessage]) {
                    [self robotSpeak:@"对不起，我没有找到，请重新说要发短信给谁？" speakContent:@"对不起，我没有找到"];
                    _unknownCount++;
                }
            }
            [self recognizeMember];
        } else if (type == SpeechRecognizeOption) {
            if ([_smartEngine isInCol]) {
                XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:@"很抱歉，我没有明白，你可以命令“##查看##”、“##发送##”或“##取消##”。"];
                [_mainViewController robotSpeakWithModel:model];
                _smartEngine.currentCellModel = model;
                [self speak:@"很抱歉，我没有明白"];
                [self needContinueRecognize];
            } else {
                XZTextModel *model = [XZTextModel modelWithMessageType:ChatCellTypeRobotMessage itemTag:0 contentInfo:@"很抱歉，我没有明白，你能再重复一下吗？"];
                [_mainViewController robotSpeakWithModel:model];
                [self speak:@"很抱歉，我没有明白，你能再重复一下吗？"];
                _unknownCount++;
            }
            SPBaseCommondNode *currentNode = [_smartEngine getCurrentNode];
            NSString *key = [NSString stringWithFormat:@"%@-%@", currentNode.commondID, currentNode.stepIndex];
            [self recognizeOption:key];
        } else if (type == SpeechRecognizeSearchColText) {
            [self robotSpeak:@"很抱歉，我没有明白，你能再重复一下吗？" speakContent:@"很抱歉，我没有明白，你能再重复一下吗？"];
            [self recognizeSearchColText];
            _unknownCount++;
        }
    }
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
    [_smartEngine setResult:result];
}

#pragma mark 打电话
/**
 打电话
 */
- (void)needCallPhone:(NSString *)number{
    _mainViewController.recognizeType =  SpeechRecognizeFirstCommond;
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
        __weak typeof(XZPreMainViewController) *weakMainViewController= _mainViewController;
        dispatch_async(dispatch_get_main_queue(), ^{
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
                [weakMainViewController presentViewController:picker animated:YES completion:nil];
            }
            [picker release];
        });
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
- (BOOL)needSendIMMsg:(CMPOfflineContactMember *)member content:(NSString *)content{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf sendIMMsg:member];
    });
    return YES;
}
- (void)sendIMMsg:(CMPOfflineContactMember *)member {
    [_smartEngine resetSmartEngine];
    _isShowMainView = NO;
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
    NSLog(@"needSearchCollWithParam:%@",[param JSONRepresentation]);
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
    NSLog(@"needSearchExpenseWithParam:%@",[param JSONRepresentation]);
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
    } fail:^(NSError *error,NSDictionary* userInfo) {
        [weakSelf handleRequestError:error];
    }];}


- (void)needOpenM3AppWithAppId:(NSString *)appId result:(void(^)(BOOL sucess))result {
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([XZOpenM3AppHelper canOpenM3AppWithAppId:appId]) {
            if (result) {
                result(YES);
            }
            if (_speechEngine.canSpeak) {
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
    });
}

- (void)needCreateObject:(XZCreateModel *)model {
    NSString *url = [XZCore fullUrlForPath:model.submitUrl];
    __weak typeof(self) weakSelf = self;
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:[model requestParam] success:^(NSString *responseStr, NSDictionary* userInfo) {
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
        _mainVCNeedAlert = NO;
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
    __weak typeof(XZPreMainViewController) *weakMainViewController= _mainViewController;
    __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
    [XZPreQATextModel modelsWithQAResult:answer block:^(NSArray *models, NSString * _Nonnull speakStr) {
        for (XZCellModel *mode in models) {
            if ([mode isKindOfClass:[XZPreQATextModel class]]) {
                XZPreQATextModel *m = (XZPreQATextModel *)mode;
                m.clickLinkBlock = ^(NSString *linkUrl) {
                    [weakSpeechEngine stopSpeak];
                    CMPBannerWebViewController *aCMPBannerViewController = [[CMPBannerWebViewController alloc] init];
                    aCMPBannerViewController.startPage = linkUrl;
                    aCMPBannerViewController.hideBannerNavBar = NO;
                    aCMPBannerViewController.statusBarStyle = UIStatusBarStyleDefault;
                    aCMPBannerViewController.hidesBottomBarWhenPushed = YES;
                    [[SPTools currentViewController] presentViewController:aCMPBannerViewController animated:YES completion:^{
                        
                    }];
                    SY_RELEASE_SAFELY(aCMPBannerViewController);
                };
                m.clickAppBlock = ^(NSString *text) {
                    //中转界面跳转
                    [weakSpeechEngine stopSpeak];
                    XZTransWebViewController *vc = [[XZTransWebViewController alloc] init];
                    vc.hideBannerNavBar = NO;
                    vc.loadUrl = @"http://xiaoz.v5.cmp/v/html/transit-page.html";
                    vc.gotoParams = [text JSONValue];
                    [[SPTools currentViewController] presentViewController:vc animated:YES completion:^{
                    }];
                    SY_RELEASE_SAFELY(vc);
                };
            }
            else if ([mode isKindOfClass:[XZPreQAFileModel class]]) {
                XZPreQAFileModel *m = (XZPreQAFileModel *)mode;
                m.clickFileBlock = ^(XZPreQAFileModel *model) {
                    [weakSpeechEngine stopSpeak];
                    [XZOpenM3AppHelper showQAFile:model];
                };
            }
        }
        [weakMainViewController robotSpeakWithModels:models];
        [weakSelf speak:speakStr];
    }];
}

- (void)needHandleIntent:(XZAppIntent *)intent {
  
}

- (void)needOpenM3AppWithAppId:(NSString *)appId  time:(NSInteger)time{
//    NSInteger time = 1;//_speechEngine.canSpeak ?4 :2;//延迟时间
    __weak typeof(self) weakSelf = self;
    __weak typeof(XZPreMainViewController) *weakMainViewController= _mainViewController;
    __weak typeof(XZSmartEngine) *weakSmartEngine = _smartEngine;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSmartEngine resetSmartEngine];
        _isShowMainView = NO;
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
    NSLog(@"searchDoc:%@",title);
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
    NSLog(@"searchBul:%@",title);
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
    [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:[model paramsDic] success:^(NSString *response,NSDictionary* userInfo) {
        [weakSelf handleSendLeaveResponse:response model:model];
    } fail:^(NSError *error,NSDictionary* userInfo) {
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
}

- (void)handleRequestError:(NSError *)error{
    _mainVCNeedAlert = NO;
    [_smartEngine resetSmartEngine];
    [self enterSleep:YES];
    
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
        dispatch_async(dispatch_get_main_queue(), ^{
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
        });
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
            XZLeaveErrorModel *model = [[XZLeaveErrorModel alloc] init];
            model.contentInfo =  errorType == 1 ? @"请你选择流程节点。":msg;
            model.templateId = templateId;
            model.sendOnload = sendOnload;
            model.formData = resultData;
            model.buttonTitle = errorType == 1? @"选择":@"查看";
            __weak typeof(self) weakself = self;
            __weak typeof(SPSpeechEngine) *weakSpeechEngine= _speechEngine;
            model.showLeaveBlock = ^(XZLeaveErrorModel *model) {
                [weakSpeechEngine stop];
                if (model.showClickTitle) {
                    [weakself humanSpeak:model.buttonTitle];
                }
                [weakself robotSpeak:@"好的，已为你打开请假单。" speakContent:@"好的，已为你打开请假单。"];
                if (weakSpeechEngine.isSpeaking) {
                    weakself.speakEndBlock = ^{
                        [weakself jumpToLeaveForm:model.templateId sendOnload:model.sendOnload formData:model.formData];
                    };
                }
                else {
                    [weakself jumpToLeaveForm:model.templateId sendOnload:model.sendOnload formData:model.formData];
                }
                [weakself needResetUnitDialogueState];
            };
            model.cancelBlock = ^(XZLeaveErrorModel *model){
                [weakSpeechEngine stop];
                if (model.showClickTitle) {
                    [weakself humanSpeak:@"取消"];
                }
                [weakself robotSpeak:@"好的" speakContent:@"好的"];
                [weakself needResetUnitDialogueState];
            };
            _smartEngine.currentCellModel = model;
            [_mainViewController robotSpeakWithModel:model];
            [_speechEngine speak:model.contentInfo];
            [self needContinueRecognize];
            [model release];
            [self needHumanSpeakNewLine];
        }
        else {
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
 /*
  {"code" : 0,
  "data" : {
  "success" : "1",
  "days" : 3,
  "end" : "2018-01-16 09:00",
  "begin" : "2018-01-11 00:00"
  },
  "message" : ""}
  */
    NSLog(@"leave time response = %@",response);
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
    _smartEngine.currentCellModel = model;
    [_mainViewController robotSpeakWithModel:model];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf handleRobotConfigInner];
    });
}

- (void)handleRobotConfigInner {
    UIView *msgview = [[XZSmartMsgManager sharedInstance] msgView];
    if (msgview && !msgview.hidden) {
        return ;
    }
    CMPSpeechRobotConfig *robotConfig = [XZCore sharedInstance].robotConfig;
    if (robotConfig.isOnShow && _isInWorkTime &&!_isShowMainView) {
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
    UIWindow *window = [SPTools keyWindow];
    [_touchWindow removeFromSuperview];
    [window addSubview:_touchWindow];
    [window bringSubviewToFront:_touchWindow];
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
}
- (void)canUseWakeup {
    _xzCanUseWakeup = YES;
    if (!_touchWindow.hidden) {
        AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
        if (permission != AVAudioSessionRecordPermissionUndetermined) {
            [self startWakeup];
        }
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
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    if (permission != AVAudioSessionRecordPermissionUndetermined) {
        [self stopOtherMusic];
        if (_showOrNot && !_isShowMainView && _enterForegroundShowIcon) {
            [[SPTimer sharedInstance] refershTimer];
        }
        [self startWakeup];
    }
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
    [[XZSmartMsgManager sharedInstance] needSearchSmartMsg:date inController:_mainViewController];
}

- (void)needShowCancelCardInHistory {
    
}


- (void)needShowCloseAlertView {
    
}


- (void)needShowOptionIntents:(NSArray *)intentArray {

}


- (void)addListenToTabbarControllerShow {
    [[XZSmartMsgManager sharedInstance] addListenToTabbarControllerShow];
}

@end
