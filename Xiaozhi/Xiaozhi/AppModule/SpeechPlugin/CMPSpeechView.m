//
//  CMPSpeechView.m
//  M3
//
//  Created by wujiansheng on 2019/3/28.
//

#define kButtonTitleFont  FONTSYS(14)

#import "CMPSpeechView.h"
#import "SPBaiduSpeechEngine.h"
#import "XZRippleView.h"
#import "XZMainProjectBridge.h"
#import "XZCore.h"
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CMPSpeechView ()<SPSpeechEngineDelegate,XZViewDelegate> {
    UIView *_lingView;
    UIView *_mainView;
    UIButton *_closeButton;
    UIButton *_finishButton;
    UILabel *_showTextView;
    UIButton *_speechButton;
    XZRippleView *_rippleView;
}

@property(nonatomic, copy) SpeechViewEndBlock speechEndBlock;
@property(nonatomic, copy) SpeechViewCancelBlock speechCancelBlock;
@property(nonatomic, assign) CMPSpeechViewType viewType;

@end

@implementation CMPSpeechView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.speechEndBlock = nil;
    self.speechCancelBlock = nil;
}

- (id)initWithType:(NSInteger) type
          endBlock:(SpeechViewEndBlock)endBlock
       cancelBlock:(SpeechViewCancelBlock)cancelBlock {
    if (self = [super init]) {
        self.viewType = type;
        self.speechEndBlock = endBlock;
        self.speechCancelBlock = cancelBlock;
        [self initSpeechEngine];
        [self setupViews];
    }
    return self;
}

- (SPSpeechEngine *)speechEngine {
    SPSpeechEngine *speechEngine = [SPSpeechEngine sharedInstance:SPSpeechEngineBaidu];
    return speechEngine;
}

- (void)initSpeechEngine {
    self.speechEngine.delegate = self;
    self.speechEngine.netWorkAvailable = [XZMainProjectBridge reachableNetwork];
    [self.speechEngine setupBaseInfo:[XZCore sharedInstance].baiduSpeechInfo];
    self.speechEngine.delegate = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_SpeechPluginOn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didDismiss {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_SpeechPluginOff object:nil];
    self.speechEngine.delegate = nil;
    [self cancelSpeechAnimation];
}

- (void)didEnterBackground {
    [self.speechEngine stopRecognize];
}

- (void)showToast:(NSString *)msg {
    [self cmp_showHUDWithText:msg];
}

- (void)setupViews {
    if (!_lingView) {
        _lingView = [[UIView alloc] init];
        _lingView.backgroundColor = UIColorFromRGB(0xe4e4e4);
        [self addSubview:_lingView];
    }
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = _viewType == CMPSpeechViewType_Command ? [UIColor whiteColor] : UIColorFromRGB(0xf6f6f6);
        [self addSubview:_mainView];
    }
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"取消" forState:UIControlStateNormal];
        _closeButton.titleLabel.font = kButtonTitleFont;
        [_closeButton setTitleColor:UIColorFromRGB(0x38adff) forState:UIControlStateNormal];
        [_mainView addSubview:_closeButton];
        [_closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    if (_viewType != CMPSpeechViewType_Command &&!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"说完了" forState:UIControlStateNormal];
        _finishButton.titleLabel.font = kButtonTitleFont;
        [_finishButton setTitleColor:UIColorFromRGB(0x38adff) forState:UIControlStateNormal];
        [_mainView addSubview:_finishButton];
        [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_showTextView) {
        _showTextView = [[UILabel alloc] init];
        _showTextView.font = FONTSYS(14);
        _showTextView.textAlignment = NSTextAlignmentCenter;
        [_mainView addSubview:_showTextView];
    }
    if (!_speechButton) {
        _speechButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speechButton setImage:XZ_IMAGE(@"xz_speakbtn_def.png") forState:UIControlStateNormal];
        [_speechButton setImage:XZ_IMAGE(@"xz_speakbtn_pre.png") forState:UIControlStateSelected];
        [_mainView addSubview:_speechButton];
        [_speechButton addTarget:self action:@selector(speechButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    self.backgroundColor = _viewType == CMPSpeechViewType_Command ?[UIColor colorWithWhite:0.3 alpha:0.5]:[UIColor clearColor];
}

- (void)customLayoutSubviews {
    NSInteger buttonH = 20;
    [_lingView setFrame:CGRectMake(0, self.height-211, self.width, 1)];
    [_mainView setFrame:CGRectMake(0, self.height-210, self.width, 210)];
    [_closeButton setFrame:CGRectMake(20, 11, 50, buttonH)];
    CGFloat finishW = _viewType == CMPSpeechViewType_Command ?50:80;
    [_finishButton setFrame:CGRectMake(self.width-(finishW+20), 11, finishW, buttonH)];
    [_showTextView setFrame:CGRectMake(20, 53, self.width-40, _showTextView.font.lineHeight)];
    [_speechButton setFrame:CGRectMake(self.width/2-30, _mainView.height-120, 60, 60)];
}

- (void)closeButtonClick {
    if (self.speechCancelBlock) {
        self.speechCancelBlock();
    }
}

- (void)finishButtonClick {
    if (self.speechEndBlock) {
        self.speechEndBlock((_viewType == CMPSpeechViewType_Command ? _showTextView.text : @""),YES,self);
    }
}

- (void)speechButtonClick {
    _speechButton.hidden = YES;
    [self showSpeechAnimation];
    _viewType == CMPSpeechViewType_Command ? [self.speechEngine recognizeShortText] : [self.speechEngine recognizeLongText];
}

- (void)showSpeechAnimation{
    if (!_rippleView) {
        _rippleView = [[XZRippleView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_mainView addSubview:_rippleView];
        _rippleView.center = _speechButton.center;
        _rippleView.delegate = self;
    }
    [_rippleView show];
}

- (void)rippleViewDidClick:(XZRippleView *)view {
    [self.speechEngine stopRecognize];
    [self cancelSpeechAnimation];
}

- (void)cancelSpeechAnimation {
    _speechButton.hidden = NO;
    [_rippleView removeFromSuperview];
    _rippleView = nil;
    
    _showTextView.text = @"";
    _showTextView.textColor = [UIColor blackColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y < _mainView.originY-5) {
        [self closeButtonClick];
    }
}

#pragma mark SPSpeechEngineDelegate

//识别结果返回代理
- (void)onResults:(NSArray *)result type:(SpeechRecognizeType)type isLast:(BOOL)isLast {
    NSString *resultStr = [result firstObject];
    switch (_viewType) {
        case CMPSpeechViewType_Command:
            if (self.speechEndBlock) {
                self.speechEndBlock(resultStr,YES,self);
                [self cancelSpeechAnimation];
            }
            break;
        
        case CMPSpeechViewType_LongText:
//            _showTextView.text = resultStr;
//            _showTextView.textColor = [UIColor blackColor];
            if (self.speechEndBlock) {
                self.speechEndBlock(resultStr,NO,self);
            }
            break;
            
        default:
            break;
    }
}

- (void)onError:(NSError *)error {
    [self cancelSpeechAnimation];
    NSString *msg = @"";
    if ([error.domain integerValue] == 31) {
        //        EVRClientErrorDomainLocalNetwork = 31 本地网络联接出错
        msg = @"当前网络不可用";
    }
    else if (error.code == 2225219 || error.code == 1310722 ) {
        /*2225219 server speech quality problem。音频质量过低，无法识别。 相当于没有说话*/ //不处理
        /*1310722 :Error Domain=20 Code=1310722 "VAD detect: no speech." */
        msg = @"没有语音输入";
    }
    else {
        msg = error.localizedDescription;
    }
    [self showToast:msg];
}

//停止录音回调
- (void)onEndOfSpeech {
    [self cancelSpeechAnimation];
}
//开始录音回调
- (void)onBeginOfSpeech {
    [self showSpeechAnimation];
    _showTextView.text = @"正在识别...";
    _showTextView.textColor = UIColorFromRGB(0xb6b6b6);
}
//音量回调函数
- (void)onVolumeChanged:(NSInteger)volume {
    
}
//会话取消回调
- (void)onCancel {
    [self cancelSpeechAnimation];
}

- (void)onSpeakEnd {
    
}

@end
