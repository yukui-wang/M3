//
//  XZShortHandCreateViewController.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandCreateViewController.h"
#import "XZShortHandCreateView.h"
#import "CMPDataRequest.h"
#import "CMPDataProvider.h"
#import "XZShortHandParam.h"
#import "SPSpeechEngine.h"
#import "CMPSpeechRobotManager.h"
#import "CMPCommonManager.h"
#import "CMPGlobleManager.h"
#import "XZViewDelegate.h"
#import "SPTools.h"
#import "XZCore.h"
@interface XZShortHandCreateViewController ()<CMPDataProviderDelegate,SPSpeechEngineDelegate,XZViewDelegate> {
    XZShortHandCreateView *_createView;
    CMPDataRequest *_saveRequest;
    UIButton *_finishBtn;
}
@property (nonatomic, retain) SPSpeechEngine *speechEngine;

@end

@implementation XZShortHandCreateViewController

- (void)dealloc {
    self.createSucessBlock = nil;
    self.speechEngine = nil;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_saveRequest)
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"语音速记"];
    self.backBarButtonItemHidden = NO;
    _createView = (XZShortHandCreateView *)self.mainView;
    [self initSpeechEngine];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentChange) name:UITextViewTextDidChangeNotification object:nil];
    [_createView.speakButton addTarget:self action:@selector(speakButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    [self speakButtonAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
//    [_createView.contentView  becomeFirstResponder];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_createView hideKeyboard];
//
//    });
}


- (void)backBarButtonAction:(id)sender {
    [self stopSpeech];
    [super backBarButtonAction:sender];
}

- (void)setupBannerButtons {
    _finishBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 42, 45) title:@"完成"];
    [_finishBtn addTarget:self action:@selector(finishShortHand) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:[NSArray arrayWithObjects:_finishBtn, nil]];
    [self finishBtnAvaible];
}

- (void)contentChange {
    [self finishBtnAvaible];
}

- (void)finishShortHand {
    //防止重复点击
    _finishBtn.userInteractionEnabled = NO;
    [self stopSpeech];
    [self requestSave];
}

- (void)speakButtonAction {
    [_speechEngine recognizeLongText];
 }

- (void)finishBtnAvaible {
    BOOL avaiable = _createView.contentView.text.length > 0;
    [_finishBtn setTitleColor:avaiable? UIColorFromRGB(0x3AADFB): [UIColor grayColor] forState:UIControlStateNormal];
    _finishBtn.userInteractionEnabled = avaiable;
}

- (void)requestSave {
    
    NSString *title = _createView.titleView.text;
    NSString *content = _createView.contentView.text;
    if ([NSString isNull:title]) {
        if (content.length <= 15) {
            title = content;
        }
        else {
            title = [content substringToIndex:15];
        }
    }
    NSString *url = kShorthandUrl_Create;
    [[CMPDataProvider sharedInstance] cancelRequestsWithDelegate:self];
    SY_RELEASE_SAFELY(_saveRequest);
    _saveRequest = [[CMPDataRequest alloc] init];
    _saveRequest.requestUrl = url;
    _saveRequest.delegate = self;
    _saveRequest.requestMethod = @"POST";
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict setObject:title forKey:@"title"];
    [mDict setObject:content forKey:@"content"];
    _saveRequest.requestParam = [mDict JSONRepresentation];
    _saveRequest.requestType = kDataRequestType_Url;
    [[CMPDataProvider sharedInstance] addRequest:_saveRequest];
}

- (void)initSpeechEngine {
    self.speechEngine = [SPSpeechEngine sharedInstance:SPSpeechEngineBaidu];
    _speechEngine.delegate = self;
    _speechEngine.netWorkAvailable = [CMPCommonManager reachableNetwork];
    [_speechEngine setupBaseInfo:[XZCore sharedInstance].baiduSpeechInfo];
}

- (void)stopSpeech {
    [_speechEngine stop];

}
- (void)providerDidStartLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest {
    //防止重复点击
    _finishBtn.userInteractionEnabled = YES;
}

- (void)providerDidFinishLoad:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest response:(CMPDataResponse *)aResponse {
    [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"保存成功"];
    if (self.createSucessBlock) {
        self.createSucessBlock();
        self.createSucessBlock = nil;
    }
    [self backBarButtonAction:nil];
}

- (void)provider:(CMPDataProvider *)aProvider request:(CMPDataRequest *)aRequest didFailLoadWithError:(NSError *)error {
    [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:@"保存失败"];
}

#pragma mark  SPSpeechEngineDelegate <NSObject>

//识别结果返回代理
- (void)onResults:(NSArray *)result type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    __weak UITextView *weakTextView = _createView.contentView;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = weakTextView.text;
        weakTextView.text = [NSString stringWithFormat:@"%@%@",str,[result firstObject]];
        [weakSelf finishBtnAvaible];

    });
}
- (void)onError:(NSError *)error {
    [_createView hideWaveView];
}
//停止录音回调
- (void)onEndOfSpeech {
    
}
//开始录音回调
- (void)onBeginOfSpeech {
    [_createView showWaveView:self];
}
//音量回调函数
- (void)onVolumeChanged:(int)volume{
    
}
//会话取消回调
- (void)onCancel{
    [_createView hideWaveView];
}
//机器说话结束
- (void)onSpeckEnd{
    [_createView hideWaveView];
}

- (void)rippleViewDidClick:(XZRippleView *)view {
    [self stopSpeech];
}

@end
