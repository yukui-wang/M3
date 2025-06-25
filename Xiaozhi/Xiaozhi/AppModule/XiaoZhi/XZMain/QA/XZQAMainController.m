//
//  XZQAMainController.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/11.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAMainController.h"
#import "XZQAMainViewController.h"
#import "XZCore.h"
#import "SPTools.h"
#import "SPSpeechEngine.h"
#import "XZMainProjectBridge.h"
#import "XZM3RequestManager.h"
#import "SPAudioPlayer.h"
#import <CMPLib/CMPDevicePermissionHelper.h>
#import <CMPLib/CMPAlertView.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import "SPWakeuper.h"
#import "XZMainController.h"
#import <CMPLib/CMPCachedUrlParser.h>

@interface XZQAMainController()<SPSpeechEngineDelegate>{
    
}
@property (nonatomic, strong) XZQAMainViewController *mainViewController;

@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, strong) SPSpeechEngine *speechEngine;
@property (nonatomic, copy) NSString *requestId;

@end

static id shareInstance;

@implementation XZQAMainController
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
                [shareInstance registeNotification];
            }
        }
    }
    return shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return shareInstance;
}
- (void)initSpeechEngine {
    [[SPWakeuper sharedInstance] stopWakeup];

   if (!_speechEngine) {
       SPSpeechEngineType type = SPSpeechEngineBaidu;
       _speechEngine = [SPSpeechEngine sharedInstance:type];
       [_speechEngine setupBaseInfo:[XZCore sharedInstance].baiduSpeechInfo];
   }
    _speechEngine.delegate = self;
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
}

- (XZQAMainViewController *)mainViewController {
    if (!_mainViewController) {
        [self initSpeechEngine];
        _mainViewController = [[XZQAMainViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        _mainViewController.startRecordingBlock = ^{
            [weakSelf mainViewControllerShouldSpeak];
        };
        _mainViewController.stopRecordingBlock = ^{
            [weakSelf mainViewControllerShouldStopSpeak];
        };
        _mainViewController.inputContentBlock = ^(NSString * _Nullable content) {
            [weakSelf mainViewControllerInputText:content];
        };
        _mainViewController.voiceStateChangeBlock = ^(BOOL state) {
            [weakSelf mainViewControllerVoiceStateChange:state];
        };
        _mainViewController.shouldDismissBlock = ^{
            [weakSelf closeMainView];
        };
        _mainViewController.panGestureBackBlock = ^{
            [weakSelf clearDataForCloseMainView];
        };
        _mainViewController.commonActBlk = ^(NSInteger act, id  _Nullable obj) {
            switch (act) {
                case kXZQACommonTag_StartAsk:
                {
                    NSString *url = [XZCore fullUrlForPath:kQAAppsUrl];
                    weakSelf.requestId = [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response, NSDictionary *userInfo) {
                        [weakSelf loadWebviewWithResponse:response defaultData:nil];
                    } fail:^(NSError *error, NSDictionary *userInfo) {
                        [weakSelf handleRequestError:error];
                    }];
                    
                    NSString *keyUrl = [XZCore fullUrlForPath:kAllQaKeywordUrl];
                    [[XZM3RequestManager sharedInstance] getRequestWithUrl:keyUrl params:nil success:^(NSString *response, NSDictionary *userInfo) {
                        [weakSelf showKeywords:response];
                    } fail:^(NSError *error, NSDictionary *userInfo) {
                        [weakSelf handleRequestError:error];
                    }];
                    
                }
                    break;
                    
                case kXZQACommonTag_View30History:
                {
                    CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
                    webCtrl.hideBannerNavBar = NO;
                    NSString *urlString = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:kXiaozQAView30HistoryUrl]];
                    webCtrl.startPage = urlString;
                    [weakSelf.mainViewController.navigationController pushViewController:webCtrl animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
    return _mainViewController;
}
- (void)clearMainViewController {
    [_speechEngine stopSpeak];
    if (_mainViewController) {
        _mainViewController = nil;
    }
    if (self.requestId) {
        [[XZM3RequestManager sharedInstance] cancelWithRequestId:self.requestId];
        self.requestId = nil;
    }
}
- (void)openQAPage:(NSDictionary *)params {
    CMPBannerWebViewController *pushVC = params[@"pushVC"];
    BOOL pushView = [params[@"pushView"] boolValue];
    if (pushVC && pushView) {
        //显示主界面前关闭唤醒
        [self clearMainViewController];
        
        _speechEngine.delegate = self;
        [pushVC pushVc:self.mainViewController inVc:pushVC inDetail:YES clearDetail:YES animate:YES];
        [self mainViewControllerDidShow];
    }

    NSString *openType = params[@"openType"];
    NSDictionary *dataParams = params[@"params"];
    __weak typeof(self) weakSelf = self;
    if([openType isEqualToString:@"qaApp"]) {
        NSString *url = [XZCore fullUrlForPath:kQAAppsUrl];
        self.requestId = [[XZM3RequestManager sharedInstance] getRequestWithUrl:url params:nil success:^(NSString *response, NSDictionary *userInfo) {
            [weakSelf loadWebviewWithResponse:response defaultData:nil];
        } fail:^(NSError *error, NSDictionary *userInfo) {
            [weakSelf handleRequestError:error];
        }];
        NSString *keyUrl = [XZCore fullUrlForPath:kAllQaKeywordUrl];
        [[XZM3RequestManager sharedInstance] getRequestWithUrl:keyUrl params:nil success:^(NSString *response, NSDictionary *userInfo) {
            [weakSelf showKeywords:response];
        } fail:^(NSError *error, NSDictionary *userInfo) {
            [weakSelf handleRequestError:error];
        }];
    }
    else if ([openType isEqualToString:@"qaCategory"]) {
        NSString *qaAppName = dataParams[@"qaAppName"];
        if (![NSString isNull:qaAppName]) {
            [_mainViewController humenSpeakText:qaAppName];
        }
        NSString *qaAppId = dataParams[@"qaAppId"];
        NSString *url = [XZCore fullUrlForPath:kQACategorysUrl];
        NSDictionary *requestParams = [NSDictionary dictionaryWithObject:qaAppId forKey:@"qaAppId"];
        self.requestId = [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:requestParams success:^(NSString *response, NSDictionary *userInfo) {
            [weakSelf loadWebviewWithResponse:response defaultData:nil];
        } fail:^(NSError *error, NSDictionary *userInfo) {
            [weakSelf handleRequestError:error];
        }];
        NSString *keyUrl = [XZCore fullUrlForPath:kAllQaKeywordByAppIdUrl];
        [[XZM3RequestManager sharedInstance] postRequestWithUrl:keyUrl params:requestParams success:^(NSString *response, NSDictionary *userInfo) {
          [weakSelf showKeywords:response];
        } fail:^(NSError *error, NSDictionary *userInfo) {
            [weakSelf handleRequestError:error];
        }];
    }
    else if ([openType isEqualToString:@"qaInfo"]) {
        NSString *categoryName = dataParams[@"categoryName"];
        if (![NSString isNull:categoryName]) {
            [_mainViewController humenSpeakText:categoryName];
        }
        NSString *categoryId = dataParams[@"categoryId"];
        NSString *url = [XZCore fullUrlForPath:kQACategoryInfoUrl];
        NSDictionary *requestParams = [NSDictionary dictionaryWithObject:categoryId forKey:@"categoryId"];
        self.requestId = [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:requestParams success:^(NSString *response, NSDictionary *userInfo) {
            [weakSelf loadWebviewWithResponse:response defaultData:nil];
        } fail:^(NSError *error, NSDictionary *userInfo) {
            [weakSelf handleRequestError:error];
        }];
    }
    else if ([openType isEqualToString:@"chatResponse"]) {
        NSString *question = dataParams[@"question"];
        NSDictionary *answer = [SPTools dicValue:dataParams forKey:@"answer"];
        if (![NSString isNull:question]) {
            [_mainViewController humenSpeakText:question];
        }
        if (answer) {
            XZWebViewModel *model = [[XZWebViewModel alloc] initForQA];
            model.loadUrl = kQAAppsCardUrl;
            model.gotoParams = answer;
            [_mainViewController robotSpeakWithWebModel:model];
        }
        else {
            [self analysisResult:question];
        }
    }
}


- (UIViewController *)showIntelligentPage {
    [self clearMainViewController];
    self.mainViewController.formMsg = YES;
    XZWebViewModel *model = [[XZWebViewModel alloc] initForQA];
    model.loadUrl = kXiaozQAMsgUrl;
    model.gotoParams = nil;
    [self.mainViewController robotSpeakWithWebModel:model];
    
    return self.mainViewController;
}

- (void)showKeywords:(NSString *)response {
    NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
    NSArray *data = [SPTools arrayValue:dic forKey:@"data"];
    _mainViewController.keywordArray  = data;
}

- (void)loadWebviewWithResponse:(NSString *)response defaultData:(NSDictionary *)defaultData {
    NSDictionary *dic = [SPTools dictionaryWithJsonString:response];
    NSInteger code = [SPTools integerValue:dic forKey:@"code"];
    if (code == 292003 || code == 292002) {
        [self handleRequestError:[NSError errorWithDomain:@"" code:code userInfo:nil]];
        return;
    }
    NSDictionary *data = dic[@"data"];
    if ([SPTools dataIsNull:data]) {
        data = defaultData;
    }
    if (data) {
        NSString *intent = [SPTools stringValue:data forKey:@"intent"];
        if (intent && [intent rangeOfString:@"APP_"].location != NSNotFound) {
            if (![[XZCore sharedInstance].intentPrivilege isAvailableIntentName:intent]) {
                data = @{
                    @"renderType":@"chatResponse",
                    @"qa":@[@{@"answer":kIntentUnavailable}]
                };
            }
        }
        NSDictionary *result = [SPTools dicValue:data forKey:@"result"];//加载报表、报表指标
        NSString *loadUrl = result? [[SPTools stringValue:result forKey:@"loadUrl"] appendHtmlUrlParam:@"cardFrom" value:@"qa"] :kQAAppsCardUrl;
//        loadUrl = @"http://message.m3.cmp/v/layout/message-all.html";
        NSDictionary *loadData = result ? result[@"data"] : data;
        XZWebViewModel *model = [[XZWebViewModel alloc] initForQA];
        model.loadUrl = loadUrl;
        model.gotoParams = loadData;
        [_mainViewController robotSpeakWithWebModel:model];
    }
}
- (void)handleRequestError:(NSError *)error{
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
        [self dispatchAsyncToMain:^{
            if (![CMPCore sharedInstance].isAlertOnShowSessionInvalid) {
                [CMPCore sharedInstance].isAlertOnShowSessionInvalid = YES;
                CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"登陆失效" message:message cancelButtonTitle:@"返回登录页" otherButtonTitles:nil callback:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [XZMainProjectBridge showLoginViewControllerWithMessage:nil];//这个荡与Sp2不一样滴
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


- (void)closeMainView{
    [_mainViewController.navigationController popViewControllerAnimated:YES];
    [self clearDataForCloseMainView];
}
- (void)clearDataForCloseMainView {
    [self clearMainViewController];
}

- (void)mainViewControllerShouldSpeak {
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [CMPDevicePermissionHelper microphonePermissionTrueCompletion:^{
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
    }];
}

- (void)mainViewControllerShouldSpeakInner {
    [_mainViewController enbaleSpeakButton:NO];
    [_speechEngine recognizeShortText];
}

- (void)mainViewControllerShouldStopSpeak {
    //关闭语音识别
    [self enterSleep:YES];
    [[SPAudioPlayer sharedInstance] stopPlayAudio];
}
- (void)mainViewControllerInputText:(NSString *)text {
    //关闭语音识别
    [self mainViewControllerShouldStopSpeak];
    [self humanSpeak:text];
    [self analysisResult:text];
}

- (void)mainViewControllerVoiceStateChange:(BOOL)on {
    self.speechEngine.canSpeak = on;
    [SPAudioPlayer sharedInstance].canPlay = on;
    if (!on) {
        [self.speechEngine stopSpeak];
        [self onSpeakEnd];
    }
}

- (void)mainViewControllerDidShow {
    _speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    if (!_speechEngine.netWorkAvailable) {
        [self enterSleep:YES];
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        return;
    }
    self.speechEngine.isNeedPlayStartAudio = YES;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)enterSleep:(BOOL)isBreak {
    [_speechEngine stop];
    [self showRecord];
}

- (void)showRecord {
    [_mainViewController enbaleSpeakButton:YES];
    [_speechEngine stopRecognize];
    [_mainViewController hideWaveView];
}

- (void)humanSpeak:(NSString *)word {
    if (!word ||[word isEqualToString:@""]) {
        return;
    }
    [_mainViewController humenSpeakText:word];
}

- (void)analysisResult:(NSString *)result {
    if (![XZMainProjectBridge reachableNetwork]) {
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [self showRecord];
        return;
    }
    NSLog(@"analysisResult:%@",result);
    __weak typeof(self) weakSelf = self;
    __weak typeof(_mainViewController) weakMainViewController = _mainViewController;

   NSString *url = [XZCore fullUrlForPath:kQAChatUrl];
   NSDictionary *requestParams = [NSDictionary dictionaryWithObject:result forKey:@"content"];
   self.requestId = [[XZM3RequestManager sharedInstance] postRequestWithUrl:url params:requestParams success:^(NSString *response, NSDictionary *userInfo) {
       NSDictionary *defaultData = @{
           @"renderType":@"chatResponse",
           @"qa":@[@{@"answer":@"没有找到答案"}]
       };
       [weakSelf loadWebviewWithResponse:response defaultData:defaultData];
   } fail:^(NSError *error, NSDictionary *userInfo) {
       [weakSelf handleRequestError:error];
       [weakMainViewController hideSpeechLoadingView];
   }];
}

- (void)robotSpeak:(NSString *)word speakContent:(NSString *)content {
    if ([NSString isNull:word]) {
        return;
    }
    [_mainViewController robotSpeakWithText:word];
    [self speak:content];
}
- (void)speak:(NSString *)word {
    if (![NSString isNull:word]) {
        [_speechEngine speak:word];
    }
}

#pragma mark - SPSpeechEngineDelegate
// 识别结果返回代理
- (void)onResults:(NSArray *)resultArr type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    NSString *parameter = [resultArr firstObject];
    parameter = [self correctionSpeechInput:parameter];
    NSInteger limit = [XZCore sharedInstance].textLenghtLimit;
    if (limit > 0 && parameter.length > limit) {
        parameter = [parameter substringToIndex:limit];
    }
    [self humanSpeak:parameter];
    [self analysisResult:parameter];
    [self showRecord];
}

- (NSString *)correctionSpeechInput:(NSString *)input {
    NSString *result = input;
//    NSDictionary *spErrorCorrectionDic = [XZCore sharedInstance].spErrorCorrectionDic;
//    NSString *target = _smartEngine.targetSlot;
//    if ([NSString isNull:target]) {
//       target = @"INTENT_ERROR";
//    }
//    NSDictionary *targetDic = spErrorCorrectionDic[target];
//    if (target && input) {
//        NSString *temp = targetDic[input];
//        if (temp) {
//            result = temp;
//        }
//    }
    return result;
}

- (void)onError:(NSError *)error {
    if ([error.domain integerValue] == 31) {
//        EVRClientErrorDomainLocalNetwork = 31 本地网络联接出错
        [_mainViewController showToast:@"网络不给力，小致稍后为你服务。"];
        [self showRecord];
        return;
    }
    if (error.code == 2625535 ) {
        /*Error Domain=40 Code=2625535 "ASR: engine is busy."*/ //不处理
        [_mainViewController showToast:@"引擎忙。"];
        [self showRecord];
        return;
    }
    if (error.code == 2225219 || error.code == 1310722 ) {
        /*2225219 server speech quality problem。音频质量过低，无法识别。 相当于没有说话*/ //不处理
        /*1310722 :Error Domain=20 Code=1310722 "VAD detect: no speech." */
        [_mainViewController showToast:@"没有语音输入。"];
        [_mainViewController humenSpeakNothing];
        [self showRecord];
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
        return;
    }
}

//停止录音回调
- (void)onEndOfSpeech {
    [_mainViewController hideWaveView];
}

//开始录音回调
- (void)onBeginOfSpeech {
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

}


- (void)registeNotification {
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(canNotUseWakeup)
                                                 name:kNotificationName_AlertWillShow
                                               object:nil];
}
- (void)canNotUseWakeup {
    [_speechEngine stop];
    [_mainViewController hideKeyboard];
}

@end
