//
//  SyRecordView.m
//  M1Core
//
//  Created by zhengxiaofeng on 13-1-9.
//
//

#import "CMPRecordView.h"
#import <QuartzCore/QuartzCore.h>
#import "CMPVisualizer.h"
#import "CMPGlobleManager.h"
#import "amrFileCodec.h"
#import "CMPFileManager.h"

@interface CMPRecordView(){
    AVAudioSession *_audioSession;
    BOOL _canShowMarqueeView;//用与取消按钮
    
    
    UIImageView     *_backgroundView;
    UIImageView     *_recodingBKView;
    
    UITextField     *_nameField;//录音名
    UIImageView     *_nameFieldBackground;
    UIButton        *_renameButton;//重命名按钮
    UIButton        *_leftButton;//录音按钮
    UIButton        *_rightButton;//播放按钮
    UIButton        *_useButton;//使用按钮
    UIButton        *_cancelButton;//取消按钮
    UIImageView     *_upLine;//分隔线
    
    UILabel         *_showRecordLabel;
    UILabel         *_timeLabel;
    CMPVisualizer    *_visualizer;//录音过程
    
    AVAudioRecorder *_recorder;//录音
    NSTimer          *_recorderTimer;
    AVAudioPlayer    *_player;
    NSTimer          *_playerTimer;
    NSString *_playPath;
    CGRect _customFrame;
    CGRect _selectedFrame;
    
    BOOL _isPalyInRecoderView;
    UIImageView *_volumeView;
    
    UIView *_middleLine;//分隔线
    UIView *_bottomLine;//分隔线
    BOOL _modifyName;
}
@property(nonatomic, assign)id<CMPRecordViewDelegate> delegate;
@property(nonatomic, retain)UITextField *nameField;
@property(nonatomic, retain)UIButton *renameButton;
@property(nonatomic, retain)UIButton *leftButton;
@property(nonatomic, retain)UIButton *rightButton;
@property(nonatomic, retain)UIButton *useButton;
@property(nonatomic, retain)UIButton *cancelButton;
@property(nonatomic, retain)CMPVisualizer *visualizer;
@property(nonatomic, assign)CMPRecordViewType type;

//button actions
- (void)renameButtonAction:(id)sender;
- (void)leftButtonAction:(id)sender;
- (void)rightButtonAction:(id)sender;
- (void)useButtonAction:(id)sender;
- (void)cancelButtonAction:(id)sender;
- (void)leftButtonActionForRecord:(id)sender;
- (void)leftButtonActionForPlay:(id)sender;
- (void)rightButtonActionForRecord:(id)sender;
- (void)rightButtonActionForPlay:(id)sender;


//record
- (void)startRecord; // 开始录音
- (void)pauseRecord; // 暂停录音
- (void)stopRecord; // 停止录音
//play
- (void)startPlay;
- (void)pausePlayer;//暂停
- (void)continuePlay;//继续
- (void)stopPlay;
//timer Action
- (void)recorderTimerAction:(id)sender;
- (void)playerTimerAction:(id)sender;

- (void)keyboardWillShown:(NSNotification*)aNotification;
- (void)keyboardWillHidden:(NSNotification*)aNotification;

- (BOOL)saveRecorderWithString:(NSString *)aPath;
- (void)setCustomName;
- (NSString *)pathForTextField;
- (void)addNotifications;

@end

@implementation CMPRecordView
@synthesize delegate = _delegate;
@synthesize nameField = _nameField;
@synthesize renameButton = _renameButton;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize useButton = _useButton;
@synthesize cancelButton = _cancelButton;
@synthesize visualizer = _visualizer;
@synthesize type = _type;

- (id)initWithDelegate:(id)aDelegate type:(CMPRecordViewType)aType {
    _type = aType;
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}

+ (BOOL)canRecord
{
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    __block BOOL record = YES;
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (available) {
            }
            else {
                NSString *boundName = [[NSBundle mainBundle]
                                       objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                NSString *alertTitle = [NSString stringWithFormat:SY_STRING(@"common_norecordalert"),boundName];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SY_STRING(@"common_norecord")
                                                                    message:alertTitle delegate:nil
                                                          cancelButtonTitle:SY_STRING(@"common_ok")
                                                          otherButtonTitles:nil];
                [alertView show];
                record = NO;
                [alertView release];
                alertView = nil;
            }
        }];
        
    }
    return record;
}

- (void)dealloc
{
    self.renameButton = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.useButton = nil;
    self.cancelButton = nil;    
    SY_RELEASE_SAFELY(_backgroundView);
    SY_RELEASE_SAFELY(_recodingBKView);
    SY_RELEASE_SAFELY(_nameField);
    SY_RELEASE_SAFELY(_nameFieldBackground);
    SY_RELEASE_SAFELY(_upLine);
    SY_RELEASE_SAFELY(_showRecordLabel);
    SY_RELEASE_SAFELY(_timeLabel);
    SY_RELEASE_SAFELY(_visualizer);
    SY_RELEASE_SAFELY(_playPath);
    SY_RELEASE_SAFELY(_audioSession);
    SY_RELEASE_SAFELY(_volumeView);
    SY_RELEASE_SAFELY(_middleLine);
    SY_RELEASE_SAFELY(_bottomLine)
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}
- (UIImage *)imageWithName:(NSString *)name {
    NSString *imageName = [NSString stringWithFormat:@"CMPRecord.bundle/%@",name];
    return [UIImage imageNamed:imageName];
}
- (void)setup{
    
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.image = [self imageWithName:@"ic_record_BK.png"];
        [self addSubview:_backgroundView];
    }
    [self addTopView];
    [self addMiddleView];
    [self addBottomView];
    if (![self hasTitle]) {
        _backgroundView.image = [self imageWithName:@"ic_record_NOTltleBK.png"];
    }
    
    UIColor *lineColor = UIColorFromRGB(0xbfbfbf);
    if (!_upLine) {
        _upLine = [[UIImageView alloc] init];
        _upLine.backgroundColor = lineColor;
        [self addSubview:_upLine];
    }
    if (!_middleLine) {
        _middleLine = [[UIView alloc] init];
        _middleLine.backgroundColor = lineColor;
        [self addSubview:_middleLine];
    }
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = lineColor;
        [self addSubview:_bottomLine];
    }
    
    [self addNotifications];
    _modifyName = NO;
}

- (BOOL)playView
{
    if (self.type == CMPRecordViewTypePlay || self.type == CMPRecordViewTypePlayNilTitle) {
        return YES;
    }
     return NO;
}

- (BOOL)recordView
{
    if (self.type == CMPRecordViewTypeRecord || self.type == CMPRecordViewTypeRecordNilTitle) {
        return YES;
    }
    return NO;
}

- (BOOL)hasTitle
{
    if (self.type == CMPRecordViewTypeRecord || self.type == CMPRecordViewTypePlay) {
        return YES;
    }
    return NO;
}


- (void)addTopView
{
    if (!_nameFieldBackground) {
        _nameFieldBackground = [[UIImageView alloc] init];
        _nameFieldBackground.hidden = YES;
        _nameFieldBackground.image = [self imageWithName:@"ic_record_titleBK.png"];
        [self addSubview:_nameFieldBackground];
    }
    
    if (!_nameField) {
        _nameField = [[UITextField alloc] init];
        _nameField.backgroundColor = [UIColor clearColor];
        _nameField.font = FONTSYS(14);
        _nameField.textColor = UIColorFromRGB(0x1e1e1e);
        _nameField.textAlignment = NSTextAlignmentCenter;
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.delegate = self;
        _nameField.selected = YES;
        _nameField.keyboardType = UIKeyboardTypeDefault;
        _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self addSubview:_nameField];
    }
    
    if (!_renameButton) {
        self.renameButton = [UIButton buttonWithImageName:@"ic_record_editTitle.png"];
        [_renameButton addTarget:self
                          action:@selector(renameButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_renameButton];
    }
}

- (void)addMiddleView
{
    if (!_leftButton) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_leftButton addTarget:self
                        action:@selector(leftButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
    }
    if (!_rightButton) {
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.userInteractionEnabled = NO;
        [_rightButton addTarget:self
                         action:@selector(rightButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_rightButton];
    }
    if (!_showRecordLabel) {
        _showRecordLabel = [[UILabel alloc] init];
        _showRecordLabel.textAlignment = NSTextAlignmentCenter;
        _showRecordLabel.textAlignment = NSTextAlignmentCenter;
        _showRecordLabel.textColor = [UIColor blackColor];
        _showRecordLabel.font = FONTSYS(11);
        _showRecordLabel.text = SY_STRING(@"common_no_record");
        _showRecordLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_showRecordLabel];
    }
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.font = FONTSYS(20);
        _timeLabel.text = @"00:00:00";
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
    }
    
    if (!_volumeView) {
        _volumeView = [[UIImageView alloc] init];
        _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
        [self addSubview:_volumeView];
    }
}

- (void)addBottomView
{
    if (!_useButton) {
        self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_useButton setTitle:SY_STRING(@"common_use") forState:UIControlStateNormal];
        [_useButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_useButton.titleLabel setFont:FONTSYS(12)];
        [_useButton addTarget:self
                       action:@selector(useButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [_useButton setBackgroundImage:[self imageWithName:@"ic_record_sure_pre.png"] forState:UIControlStateHighlighted];
        [self addSubview:_useButton];
    }
    if (!_cancelButton) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:FONTSYS(12)];
        if ([self playView]) {
            [_cancelButton setTitle:SY_STRING(@"common_close") forState:UIControlStateNormal];
        }
        else {
            [_cancelButton setBackgroundImage:[self imageWithName:@"ic_record_cancel_pre.png"] forState:UIControlStateHighlighted];
        }
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_cancelButton];
    }
    if ([self recordView]) {
        [self setCustomName];
    }
}

- (void)setupRenameButton
{
    if (!_modifyName) {
        [_renameButton setImage:[self imageWithName:@"ic_record_editTitle.png"] forState:UIControlStateNormal];
    }
    else {
        [_renameButton setImage:[self imageWithName:@"ic_record_titleOK.png"] forState:UIControlStateNormal];
    }
}

- (CGFloat)viewWidth
{
    return kCMPPhoneBackViewWidth;
}

- (CGFloat)viewHeight
{
    if (![self hasTitle]) {
        return 125;
    }
    return kCMPPhoneBackViewHeight;
}
- (void)setFrame:(CGRect)frame 
{
//    if (INTERFACE_IS_PAD) {
//        frame.size.width = kPadBackViewWidth;
//        frame.size.height = kPadBackViewHeight;
//    }
//    else {
//        frame.size.width = kPhoneBackViewWidth;
//        frame.size.height = kPhoneBackViewHeight;
//    }
    frame.size.width = [self viewWidth];
    frame.size.height = [self viewHeight];
    [super setFrame:frame];
}

- (void)customLayoutSubviews{
    
    CGFloat width = [self viewWidth];
    CGFloat height = [self viewHeight];
    self.frame = CGRectMake(0 , 0, width, height);
    [_backgroundView setFrame:self.bounds];
    CGFloat y = 0;
    if (![self hasTitle]) {
        _nameField.hidden = YES;
        _nameFieldBackground.hidden = YES;
        _renameButton.hidden = YES;
        _upLine.hidden = YES;
        [_nameField setFrame:CGRectZero];
        [_nameFieldBackground setFrame:CGRectZero];
        [_renameButton setFrame:CGRectZero];
        [_upLine setFrame:CGRectZero];
        
    }
    else {
        _nameField.font = FONTSYS(14);
        CGFloat nameHeight = [FONTSYS(14) lineHeight];
        _customFrame = CGRectMake(50, (45 - nameHeight)/2, width - 100, nameHeight);
        _selectedFrame = CGRectMake(20, (45 - nameHeight)/2, width - 20*2, nameHeight);
        [_nameField setFrame:_customFrame];
        [_nameFieldBackground setFrame:CGRectMake(15, 6, width-30, 36)];
        [_renameButton setFrame:CGRectMake(width - 45, 10.5, 24, 24)];
        [_upLine setFrame:CGRectMake(3, 43, width-6, 1)];
        
        y = 44;
    }
    CGFloat h = y;
    [_leftButton setFrame:CGRectMake(15, h+17, 49, 49)];
    [_rightButton setFrame:CGRectMake(width - 49 - 15,h+17, 49, 49)];
    h += 20;
    [_showRecordLabel setFrame:CGRectMake((width - 60)/2, h, 60, [_showRecordLabel.font lineHeight])];
    h += _showRecordLabel.height-1;
    h += 0;
    
    [_timeLabel setFrame:CGRectMake((width -100)/2, h, 100, [_timeLabel.font lineHeight])];
    h += _timeLabel.height;
    h += 0;
    
    [_volumeView setFrame:CGRectMake(width/2-37.5, h, 75, 6)];
    
    y += 75;
    [_middleLine setFrame:CGRectMake(3, y, width-6, 1)];
    
    CGFloat w = 121;
    h = 47;
    [_useButton setFrame:CGRectMake(2, y, w, h)];
    [_bottomLine setFrame:CGRectMake(w+1, y+10, 1, height-y-20)];
    [_cancelButton setFrame:CGRectMake(w+3 , y,w, h)];
    
    if ([self playView]) {
        _bottomLine.hidden = YES;
        _renameButton.hidden = YES;
        [_cancelButton setFrame:CGRectMake(0, y, width, height-y)];
    }
}

//重名名
- (void)renameButtonAction:(id)sender
{
    if (_modifyName) {
        [_nameField resignFirstResponder];
    }
    else {
        [_nameField becomeFirstResponder];
    }
    [self setupRenameButton];
}

- (void)leftButtonAction:(id)sender
{

    if ([self recordView]) {
        [self leftButtonActionForRecord:sender];
    }
    else if ([self playView]){
        [self leftButtonActionForPlay:sender];
    }

}

- (void)rightButtonAction:(id)sender
{
    if ([self recordView]) {
        [self rightButtonActionForRecord:sender];
    }
    else if ([self playView]){
        [self rightButtonActionForPlay:sender];
    }

}

- (void)leftButtonActionForRecord:(id)sender
{
    if (_nameField.text.length >0 && ![_nameField.text isWhitespaceAndNewlines]) {
        [_nameField resignFirstResponder];
        _nameFieldBackground.hidden = YES;
    }
    else {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_inputName_canNotEmpty_againInput")];
        [self renameButtonAction:nil];
    }
   
    if (_isPalyInRecoderView)
    {//录音界面播放
        if (_player) {
            if ([_player isPlaying]) {
                [self pausePlayer];
            }
            else {
                [self continuePlay];
            }
        }
    }
    else {
       // 录音界面 录音
        if (_recorder) {
            [self stopRecord];
        }
        else {
            //录音界面
            [self startRecord];
        }
    }
}
- (void)rightButtonActionForRecord:(id)sender
{
    if (!_player) {
        _isPalyInRecoderView = YES;
        [self startPlay];
        [_rightButton setImage:[self imageWithName:@"ic_record_stop.png"] forState:UIControlStateNormal];
        [_rightButton setImage:[self imageWithName:@"ic_record_stop_pre.png"] forState:UIControlStateHighlighted];
        [_leftButton setImage:[self imageWithName:@"ic_record_pause.png"] forState:UIControlStateNormal];
        [_leftButton setImage:[self imageWithName:@"ic_record_pause_pre.png"] forState:UIControlStateHighlighted];
    }
    else {
        [_rightButton setImage:[self imageWithName:@"ic_record_play.png"] forState:UIControlStateNormal];
        [_rightButton setImage:[self imageWithName:@"ic_record_play_pre.png"] forState:UIControlStateHighlighted];
        
        [_leftButton setImage:[self imageWithName:@"ic_record_record.png"] forState:UIControlStateNormal];
        [_leftButton setImage:[self imageWithName:@"ic_record_record_pre.png"] forState:UIControlStateHighlighted];
        [self stopPlay];
        _leftButton.userInteractionEnabled = YES;
        _isPalyInRecoderView = NO;
    }
}

- (void)leftButtonActionForPlay:(id)sender
{
    _rightButton.enabled = YES;
    //播放界面
    if (!_player) {
        [self startPlay];
        [_leftButton setImage:[self imageWithName:@"ic_record_pause.png"] forState:UIControlStateNormal];
        [_leftButton setImage:[self imageWithName:@"ic_record_pause_pre.png"] forState:UIControlStateHighlighted];
        
        _rightButton.userInteractionEnabled = YES;
        [_rightButton setImage:[self imageWithName:@"ic_record_stop.png"] forState:UIControlStateNormal];
        [_rightButton setImage:[self imageWithName:@"ic_record_stop_pre.png"] forState:UIControlStateHighlighted];
  }
    else  if ([_player isPlaying]) {
        [self pausePlayer];
    }
    else {
        [self continuePlay];
    }
}

- (void)rightButtonActionForPlay:(id)sender
{
    [self stopPlay];
     _rightButton.enabled = NO;
    [_leftButton setImage:[self imageWithName:@"ic_record_play.png"] forState:UIControlStateNormal];
    [_leftButton setImage:[self imageWithName:@"ic_record_play_pre.png"] forState:UIControlStateHighlighted];
    
    [_rightButton setImage:[self imageWithName:@"ic_record_stop.png"] forState:UIControlStateNormal];
    [_rightButton setImage:[self imageWithName:@"ic_record_stop_pre.png"] forState:UIControlStateHighlighted];
    _rightButton.userInteractionEnabled = NO;
}
//使用按钮
- (void)useButtonAction:(id)sender
{
    if ([_nameField.text isWhitespaceAndNewlines]) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_inputName_canNotEmpty_againInput")];
        [self renameButtonAction:nil];
        return;
    }
    [self stopRecord];
    [self stopPlay];
    NSString *path = [self pathForTextField];
    NSLog(@"recorder new path = %@",path);
    BOOL isSuccess = [self saveRecorderWithString:path];
    if (!isSuccess) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(recordView:didFinishRecordWithPath:)]) {
        // 转换caf到amr格式
        NSString *amrFilePath = [path replaceCharacter:@".caf" withString:@".amr"];
        NSData *cafData = [NSData dataWithContentsOfFile:path];
        NSData *amrData = EncodeWAVEToAMR(cafData,1,16);
        [amrData writeToFile:amrFilePath atomically:YES];
        
       //删除.caf
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        // 转换end
        [_delegate recordView:self didFinishRecordWithPath:amrFilePath];
    }
    [self dismiss];
}
//取消按钮
- (void)cancelButtonAction:(id)sender
{
    if ([self recordView]) {
        //录音界面
        _canShowMarqueeView = NO;
        [self stopRecord];
        [self stopPlay];
        [[NSFileManager defaultManager]removeItemAtPath:_playPath error:nil];
      
    }
    else if ([self playView]){
//        //播放界面
//        [_fileDownloadBiz cancel];
//        [_fileDownloadBiz release];
//        _fileDownloadBiz = nil;
       [self stopPlay];
        
    }
    if ([_delegate respondsToSelector:@selector(recordViewDidCancel:)]) {
        [_delegate recordViewDidCancel:self];
    }
    [self dismiss];
}

//////录音 start
- (void)startRecord
{
    [_leftButton setImage:[self imageWithName:@"ic_record_stop.png"] forState:UIControlStateNormal];
    [_leftButton setImage:[self imageWithName:@"ic_record_stop_pre.png"] forState:UIControlStateHighlighted];
    
    _rightButton.userInteractionEnabled = NO;
    [_rightButton setImage:[self imageWithName:@"ic_record_play_cancel.png"] forState:UIControlStateNormal];
    
    _showRecordLabel.text = SY_STRING(@"common_recording");
    
    if (!_audioSession) {
        _audioSession = [[AVAudioSession alloc] init];
        [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    if (!_recorder) {
        [_visualizer clear];
        [_visualizer setNeedsDisplay];
        _timeLabel.text = @"00:00:00";
        [_audioSession setActive:YES error:nil];
        
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [settings setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
        [settings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        [_visualizer clear];
        SY_RELEASE_SAFELY(_playPath);
        _playPath = [[self pathForTextField] retain];
        NSLog(@"record path = %@",_playPath);
        SY_RELEASE_SAFELY(_recorder);
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_playPath] settings:settings error:nil];
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
        SY_RELEASE_SAFELY(settings);
    }
    [_recorder record];
    if (!_recorderTimer) {
        _recorderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recorderTimerAction:) userInfo:nil repeats:YES];
        [_recorderTimer fire];
    }
}

- (void)pauseRecord {
    _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
}

- (void)stopRecord
{
    [_leftButton setImage:[self imageWithName:@"ic_record_record.png"] forState:UIControlStateNormal];
    [_leftButton setImage:[self imageWithName:@"ic_record_record_pre.png"] forState:UIControlStateHighlighted];
    
    _rightButton.userInteractionEnabled = YES;
    [_rightButton setImage:[self imageWithName:@"ic_record_play.png"] forState:UIControlStateNormal];
    [_rightButton setImage:[self imageWithName:@"ic_record_play_pre.png"] forState:UIControlStateHighlighted];
    _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
    
    _showRecordLabel.text = SY_STRING(@"common_record_paly");
    [_audioSession setActive:NO error:nil];
    SY_RELEASE_SAFELY(_audioSession);
    if (_recorder && _recorder.recording) {
        [_recorderTimer invalidate];
        _recorderTimer = nil;
        [_recorder stop];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        SY_RELEASE_SAFELY(_recorder);
    }
}

//////录音 end

//////播放 start

- (void)startPlay
{
    _showRecordLabel.text = SY_STRING(@"common_playing");
    _timeLabel.text = @"00:00:00";
    NSLog(@"open path = %@",_playPath);
    NSData *data;
    data = [NSData dataWithContentsOfFile:_playPath];
    if (!data || data.length == 0) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_thisDoc_isNotExist")];
        return;
        
    }
    [_visualizer clear];
    [_visualizer setNeedsDisplay];
    if ([_playPath hasSuffix:@".amr"] || [_playPath hasSuffix:@".AMR"]) {
        NSData *wavData = DecodeAMRToWAVE(data);
        _player = [[AVAudioPlayer alloc] initWithData:wavData error:nil];
    }
    else{
        _player = [[AVAudioPlayer alloc] initWithData:data error:nil];   
    }
    _player.numberOfLoops = 0;
    _player.delegate = self;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_player prepareToPlay];
    [_player play];
    if (!_playerTimer) {
        if (_player.duration >0) {
            _playerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playerTimerAction:) userInfo:nil repeats:YES];
            [_playerTimer fire];

        }
    }
}

- (void)pausePlayer
{
    [_leftButton setImage:[self imageWithName:@"ic_record_play.png"] forState:UIControlStateNormal];
    [_leftButton setImage:[self imageWithName:@"ic_record_play_pre.png"] forState:UIControlStateHighlighted];
    _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
    _showRecordLabel.text = SY_STRING(@"common_paly_stop");
    [_player pause];
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer = nil;
    }
}

- (void)continuePlay
{
    [_leftButton setImage:[self imageWithName:@"ic_record_pause.png"] forState:UIControlStateNormal];
    [_leftButton setImage:[self imageWithName:@"ic_record_pause_pre.png"] forState:UIControlStateHighlighted];
    
    _showRecordLabel.text = SY_STRING(@"common_playing");
    [_player play];
    if (!_playerTimer) {
        _playerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playerTimerAction:) userInfo:nil repeats:YES];
        [_playerTimer fire];
    }

}
- (void)stopPlay
{
    _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
    _showRecordLabel.text = SY_STRING(@"common_stop_paly");
    [_visualizer clear];
    [_visualizer setNeedsDisplay];
    if (_player) {
        [_player stop];
        [_player release];
        _player = nil;
    }
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer = nil;
    }
    
}
 - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
     if ([self playView]){
         [self rightButtonActionForPlay:nil];
     }
     else {
         [self rightButtonActionForRecord:nil];
         [_leftButton setImage:[self imageWithName:@"ic_record_record.png"] forState:UIControlStateNormal];
         [_leftButton setImage:[self imageWithName:@"ic_record_record_pre.png"] forState:UIControlStateHighlighted];
         _isPalyInRecoderView = NO;
     }
    _volumeView.image = [self imageWithName:@"ic_record_voice_0.png"];
}

//////播放 end

// 计时器——record
- (void)recorderTimerAction:(id)sender
{
    [_recorder updateMeters];
    double volume = fabs([_recorder averagePowerForChannel:0]/-160);
    [self setVolume:volume];  	double time = _recorder.currentTime;
  	_timeLabel.text = [NSString stringWithFormat:@"00:%02i:%.02i", (int)time / 60, (int)time % 60];
}
// 计时器——player
- (void)playerTimerAction:(id)sender
{
    NSLog(@"all time = %f",_player.duration);
    _player.meteringEnabled = YES;//开启仪表计数功能
    [_player updateMeters];
    double volume = fabs([_player averagePowerForChannel:0]/-160);
    [self setVolume:volume];
    double time = _player.duration - _player.currentTime;
    NSLog(@"time = %f",time);
    _timeLabel.text = [NSString stringWithFormat:@"00:%02i:%.02i", (int)time / 60, (int)time % 60];

}


- (void)setVolume:(float)volume
{
    if (volume <= 0.1) {
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_7.png"]];
    }
    else if (volume <= 0.15){
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_6.png"]];
    }
    else if (volume <= 0.2){
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_5.png"]];
    }
    else if (volume <= 0.25){
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_4.png"]];
    }
    else if (volume <= 0.3){
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_3.png"]];
    }
    else if (volume <= 0.35){
        [_volumeView setImage:[self imageWithName:@"ic_record_voice_2.png"]];
    }
    else{
        _volumeView.image = [self imageWithName:@"ic_record_voice_1.png"];
    }
}


// self custom method
- (void)setCustomName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    _nameField.text = [NSString stringWithFormat:@"%@-%@",SY_STRING(@"common_record"),stringFromDate];
}

- (NSString *)pathForTextField
{
    return [NSString stringWithFormat:@"%@/%@.caf", [CMPFileManager fileTempPath],  _nameField.text];
}

//保存
- (BOOL)saveRecorderWithString:(NSString *)aPath
{
    if (!_playPath) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_not_record")];
        return NO;
    }
    if (![aPath isEqualToString:_playPath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
            [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_nameExist_againInput")];
            [self renameButtonAction:nil];
            return NO;
        }
        else {
            [[NSFileManager defaultManager]moveItemAtPath:_playPath toPath:aPath error:nil];
            [_visualizer clear];
        }
    }
    return YES;
}

// custom method
- (void)show
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch object:[NSNumber numberWithBool:NO]];

    if ([self recordView]) {
        _canShowMarqueeView = YES;
        [_leftButton setImage:[self imageWithName:@"ic_record_record.png"] forState:UIControlStateNormal];
        [_leftButton setImage:[self imageWithName:@"ic_record_record_pre.png"] forState:UIControlStateHighlighted];
        
        
        [_rightButton setImage:[self imageWithName:@"ic_record_play_cancel.png"] forState:UIControlStateNormal];
        
    }
    else if ([self playView]) {
        [_leftButton setImage:[self imageWithName:@"ic_record_pause.png"] forState:UIControlStateNormal];
        [_leftButton setImage:[self imageWithName:@"ic_record_pause_pre.png"] forState:UIControlStateHighlighted];
        
        [_rightButton setImage:[self imageWithName:@"ic_record_stop.png"] forState:UIControlStateNormal];
        [_rightButton setImage:[self imageWithName:@"ic_record_stop_pre.png"] forState:UIControlStateHighlighted];

        _nameField.userInteractionEnabled = NO;
        _nameFieldBackground.hidden = YES;
        _useButton.hidden = YES;
    }
    [[CMPGlobleManager sharedSyGlobleManager] popModalViewWithContentView:self autoHide:NO];
}

- (void)dismiss
{
    if ([self recordView] &&_playPath &&[[NSFileManager defaultManager]fileExistsAtPath:_playPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:_playPath error:nil];
    }
    [[CMPGlobleManager sharedSyGlobleManager] dismissModalView:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_RobotToggleShowAssistiveTouchOnPageSwitch object:[NSNumber numberWithBool:YES]];

}

- (void)playWithFilePath:(NSString *)aFilePath
{
    _showRecordLabel.text = SY_STRING(@"common_no_paly");
    ///.amr  ios4.2以上不支持先放下
    SY_RELEASE_SAFELY(_playPath);
    _playPath = [aFilePath retain];
    _nameField.text = [[_playPath lastPathComponent] replaceCharacter:@".amr" withString:@""];
    _showRecordLabel.text = @"";
    [self leftButtonAction:nil];
}
#pragma mark -
#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:self];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    if (_nameField.text.length >0 && ![_nameField.text isWhitespaceAndNewlines]) {
        return YES;}
    else {
        if (_canShowMarqueeView) {
            [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_inputName_canNotEmpty_againInput")];
        }
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_nameField.text.length == 0 ||!_nameField.text ||[_nameField.text isWhitespaceAndNewlines]) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_inputName_canNotEmpty_againInput")];
        [self renameButtonAction:nil];
        return NO;
    }
    [_nameField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _nameFieldBackground.hidden = NO;
//    if (range.location > 40 ) {
//        [[SyGlobleManager sharedSyGlobleManager] pushMarqueeView:@"附件命名最多输入40个字。"];
//    }
//    return range.location >40 ? NO :YES;
    NSString *str = @"*/<>?:：｜|";
    NSRange rang = [str rangeOfString:string];
    if (rang.length > 0) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_inputCharacter_notInclude_XX")];
        return NO;
    }
    if (range.location > 40 ||(range.location == 40 && string.length > 0)) {
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_attName_theMostInput_40Words")];
        return NO;
    }
    if ( string.length > 40 -textField.text.length && string.length > 0) {
        NSMutableString *str = [NSMutableString stringWithString:textField.text];
        [str insertString:[string substringToIndex:40-textField.text.length ] atIndex:range.location];
        textField.text = str;
        [[CMPGlobleManager sharedSyGlobleManager] pushMarqueeView:SY_STRING(@"common_attName_theMostInput_40Words")];
        return NO;
    }
    return YES;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    _nameFieldBackground.hidden = NO;
    _modifyName = YES;
    [self setupRenameButton];
   
    [_nameField setFrame:_selectedFrame];
}

- (void)keyboardWillHidden:(NSNotification*)aNotification
{
    if (_nameField.text.length >0 && ![_nameField.text isWhitespaceAndNewlines]) {
        _nameFieldBackground.hidden = YES;
        _modifyName = NO;
        [self setupRenameButton];
    }
}

@end

