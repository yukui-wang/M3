//
//  XZMainViewController.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZMainViewController.h"
#import "XZMainView.h"
#import "XZBaseTableViewCell.h"
#import "XZViewDelegate.h"
#import "XZPreQATextModel.h"
#import "XZQAGuideModel.h"
#import "XZQAGuideDetailModel.h"
#import "XZGuideMode.h"
#import "XZCore.h"
#import <CMPLib/CMPChatChooseMemberViewController.h>
#import <CMPLib/CMPOfflineContactMember.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "XZGuidePageView.h"
#import "XZQAGuidePageView.h"
#import "XZMainProjectBridge.h"
#import "XZInterfaceCell.h"
#import <CMPLib/NSObject+Thread.h>
#import "XZTransWebViewController.h"
@interface XZMainViewController ()<UITableViewDelegate,
    UITableViewDataSource,
    XZFrequentViewDelegate,
    XZMemberTextViewDelegate,
    XZTextEditViewDelegate,
    CMPChatChooseMemberViewControllerDelegate,
    XZMainViewDelegate,
    UIGestureRecognizerDelegate>
{
    UIImageView *_bkImgView;
    XZMainView *_xzMainView;
    BOOL _voiceOn;
    UIButton *_muteButton;
    BOOL _isFirst;
    BOOL _firstSpeakNothing;
    CGFloat _mainCellHeight;
}
@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)XZInterfaceCell *mainCell;
@property(nonatomic, strong)XZGuidePageView *guidePageView;

@end

@implementation XZMainViewController

- (void)dealloc {
//    [XZMainViewController lockRotation:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    SY_RELEASE_SAFELY(_dataArray);
//    SY_RELEASE_SAFELY(_guideInfo);
    [_guidePageView removeFromSuperview];
//    SY_RELEASE_SAFELY(_guidePageView);
//    SY_RELEASE_SAFELY(_bkImgView);
//    [super dealloc];
}

- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated {
    [super showNavBar:isShow animated:animated];
    [self.view bringSubviewToFront:_xzMainView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIColor *)statusBarColorForiOS7 {
    return [UIColor clearColor];
}

- (UIColor *)bannerNavigationBarBackgroundColor {
    return [UIColor clearColor];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [_xzMainView hideKeyboard];
    [self.mainCell hideLoadingView];
    [super dismissViewControllerAnimated:flag
                              completion:completion];
}

- (void)setRecognizeType:(SpeechRecognizeType)recognizeType {
    if (recognizeType == SpeechRecognizeLongText &&
        _recognizeType != SpeechRecognizeLongText) {
        __weak typeof(self) weakSelf = self;
        [self dispatchAsyncToMain:^{
            [weakSelf obtainCellsFormInterface];
        }];
    }
    
    if (recognizeType != SpeechRecognizeMember) {
        __weak typeof(self) weakSelf = self;
        [self dispatchAsyncToMain:^{
            [weakSelf.mainCell hideFrequentView];
        }];
    }
    
    _recognizeType = recognizeType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bannerNavigationBar hideBottomLine:YES];
    self.allowRotation =  INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
    _xzMainView = (XZMainView *)self.mainView;
    _xzMainView.tableView.delegate = self;
    _xzMainView.tableView.dataSource = self;
    [_xzMainView.bottomBar.keyboardButton addTarget:self action:@selector(keyboardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_xzMainView.bottomBar.speakButton addTarget:self action:@selector(speakButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_xzMainView.bottomBar.cancelButton addTarget:self action:@selector(cancelSpeechButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_xzMainView.bottomBar.helpButton addTarget:self action:@selector(helpButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self showBKView];
    _isFirst = YES;
    _firstSpeakNothing = YES;
    _xzMainView.delegate = self;
    
//    if (INTERFACE_IS_PHONE) {
//        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//        recognizer.delegate = self;
//        [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
//        [_xzMainView addGestureRecognizer:recognizer];
//    }
    //在这儿处理否者 weakView可能为nil
    __weak XZMainView *weakView = _xzMainView;
    __weak typeof(self) weakSelf = self;
    self.mainCell.cardViewChangeHeight = ^{
        CGPoint p = weakView.tableView.contentOffset;
        [weakView scrollTableViewBottom];
        weakView.tableView.contentOffset = p;
    };
    self.mainCell.interfaceCellClickTextBlock = ^(NSString *text) {
        //文本点击事件
        [weakSelf handleClickText:text];
    };
}

//- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipe {
//    [self backBarButtonAction:nil];
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        return NO;
//    }
//    return YES;
//}
//
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    CGPoint translate = [gestureRecognizer locationInView:_xzMainView];
//    if (translate.x < 50) {
//        return YES;
//    }
//    return NO;
//}

- (void)mainViewKeyboardDidKeyboardHideFinish {
    _mainCell.cellHeight = _mainCellHeight;
    [_xzMainView.tableView reloadData];
}



- (void)showBKView {
    if (!_bkImgView) {
        _bkImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bkImgView.image = XZ_IMAGE(@"xz_bk.png");
        [self.view addSubview:_bkImgView];
        [self.view bringSubviewToFront:_statusBarView];
        [self.view bringSubviewToFront:self.bannerNavigationBar];
        [self.view bringSubviewToFront:_xzMainView];
    }
}

- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
    _bkImgView.frame = self.view.bounds;
    CGRect f = _guidePageView.frame;
    CGRect mainFrame = [self mainFrame];
    f.size.width = mainFrame.size.width;
    f.size.height = mainFrame.size.height-_xzMainView.bottomBar.height;
    _guidePageView.frame = f;
    _mainCellHeight = mainFrame.size.height-_xzMainView.bottomBar.height;
    _mainCell.cellHeight = _mainCellHeight;
    
    [_xzMainView performSelector:@selector(scrollTableViewBottom) withObject:nil afterDelay:0.1];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (XZInterfaceCell *)mainCell {
    if (!_mainCell) {
        _mainCell = [[XZInterfaceCell alloc] initWithFrame:_xzMainView.bounds];
        _mainCellHeight = _xzMainView.tableView.height;
        _mainCell.cellHeight = _mainCellHeight;
    }
    return _mainCell;
}

- (void)needEditText {
    NSString *text = [[self mainCell] humenText];
    _mainCell.cellHeight = _mainCellHeight +40;//40 = bottomBar - textBar
    if (self.recognizeType == SpeechRecognizeMember) {
        [_xzMainView hideBottomBarView];
        [_xzMainView showMemberInputView];
        [_xzMainView.memberInpitView showText:text];
    }
    else {
        [self showTextEditView];
        [_xzMainView.textEditView showText:text];
        [_xzMainView hideBottomBarView];
    }
    [self handleStopSpeak];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.allowRotation =  INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
    //    [XZMainViewController lockRotation:INTERFACE_IS_PHONE ? YES : ![XZCore allowRotation];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_XiaozViewShow object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_xzMainView addNotifications];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerDidAppear)]) {
        [self.delegate mainViewControllerDidAppear];
    }
    if (self.guideInfo && _isFirst) {
        [self showGuidePages];
    }
    _isFirst = NO;    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_XiaozViewHide object:nil];
    [_xzMainView removeNotifications];
    
    [_xzMainView hideKeyboard];
    [_xzMainView hideTextEditView];
    [_xzMainView hideMemberInputView];
    [_xzMainView showBottomBarView];
    [_xzMainView customLayoutSubviews];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerWillDisappear)]) {
        [self.delegate mainViewControllerWillDisappear];
    }
}

- (NSArray *)guideModels:(BOOL)showAll {
    if (!self.guideInfo) {
        XZGuideMode *model = [[XZGuideMode alloc] initWithType:showAll ? GuideCellTypeHelp:GuideCellTypeGuide];
        model.moreBtnClickAction = ^{
            
        };
        return [NSArray arrayWithObject:model];
    }
    
    NSArray *array = [self.guideInfo cellModels:!showAll];
    for (id obj in array) {
        if ([obj isKindOfClass:[XZQAGuideModel class]]) {
            XZQAGuideModel *model =  (XZQAGuideModel *)obj;
            __weak typeof(self) weakSelf = self;
            model.moreBtnClickAction = ^(XZQAGuideTips *tips){
                [weakSelf dispatchAsyncToMain:^{
                    [weakSelf handleStopSpeak];
                    XZQAGuideDetailModel *detailModel = [[XZQAGuideDetailModel alloc] init];
                    detailModel.tips = tips;
                    detailModel.clickTextBlock = ^(NSString *text) {
                        [weakSelf handleClickText:text];
                    };
                    [weakSelf.dataArray addObject:detailModel];
                }];
            };
            model.clickTextBlock = ^(NSString *text) {
                [weakSelf handleStopSpeak];
                [weakSelf handleClickText:text];
            };
        }
    }
    return array;
}

- (void)setupBannerButtons {
    
    NSString *key = [NSString stringWithFormat:@"%@_%@voiceOn",[XZCore serverID],[XZCore userID]];
    NSString *value =  [[NSUserDefaults standardUserDefaults] objectForKey:key];
    _voiceOn = [NSString isNull:value] || [value isEqualToString:@"ok"] ?YES:NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerVoiceStateChange:)]) {
        [self.delegate mainViewControllerVoiceStateChange:_voiceOn];
    }
    self.backBarButtonItemHidden = YES;
    UIButton *closeButton = [UIButton buttonWithImageName:XZ_NAME(@"xz_close_1.png") frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:closeButton];
    [closeButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *image = _voiceOn ? @"xz_voiceon_1.png" : @"xz_voiceoff_1.png";
    _muteButton = [UIButton buttonWithImageName:XZ_NAME(image) frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:_muteButton];
    [_muteButton addTarget:self action:@selector(muteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backBarButtonAction:(id)sender{
    [self handleStopSpeak];
    if (self.delegate && [self.delegate mainViewControllerNeedAlertWhenClickCloseBtn]) {
        [_xzMainView hideKeyboard];
        __weak typeof(self) weakSelf = self;
        [self showCloseAlert:^{
            [weakSelf shouldDismiss];
        }];
    } else {
        [self shouldDismiss];
    }
}

- (void)showCloseAlert:(void(^)(void))complete {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"你是否确定退出小致？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (complete) {
            complete();
        }
    }];
    [ac addAction:cancel];
    [ac addAction:sure];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)speakButtonClick {
    [_xzMainView hideKeyboard];
    [_xzMainView hideTextEditView];
    [_xzMainView hideMemberInputView];
    [_xzMainView showBottomBarView];
    [_xzMainView customLayoutSubviews];
    [self handleSpeakBtnClick];
    [self hideGuidePages];
}

- (void)keyboardButtonClick {
    [_xzMainView hideBottomBarView];
    _mainCell.cellHeight = _mainCellHeight +40;//40 = bottomBar - textBar
    
    if (self.recognizeType == SpeechRecognizeMember) {
        [self showMemberView];
    }
    else {
        [self showTextEditView];
        [_xzMainView customLayoutSubviews];
    }
    [self hideGuidePages];
    [self handleStopSpeak];
}

- (void)helpButtonClick {
    [self showGuidePages];
    [self handleStopSpeak];
    [_xzMainView hideKeyboard];
}

- (void)cancelSpeechButtonClick {
    [self handleStopSpeak];
}

- (void)shouldDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerDidDismiss)]) {
        [self.delegate mainViewControllerDidDismiss];
    }
}

- (void)muteButtonAction:(id)sender{
    _voiceOn = !_voiceOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerVoiceStateChange:)]) {
        [self.delegate mainViewControllerVoiceStateChange:_voiceOn];
    }
    NSString *image = _voiceOn ? @"xz_voiceon_1.png" : @"xz_voiceoff_1.png";
    [_muteButton setImage:XZ_IMAGE(image) forState:UIControlStateNormal];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@voiceOn",[XZCore serverID],[XZCore userID]];
    NSString *value = _voiceOn ? @"ok" : @"no";
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row <self.dataArray.count) {
        XZCellModel *model = [self.dataArray objectAtIndex:row];
        model.cellWidth = tableView.width;
//        if ([model isKindOfClass:[XZWebViewModel class]]) {
//            XZWebViewModel *webModel = (XZWebViewModel *)model;
//            webModel.viewController.viewRect = NSStringFromCGRect(CGRectMake(0, 0, model.cellWidth, webModel.webviewHeight));
//            webModel.viewController.view.frame = CGRectMake(0, 10, model.cellWidth, webModel.webviewHeight);
//        }
        return model.cellHeight;
    }
    CGFloat h = _mainCell.cellHeight;
    return h;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row  > self.dataArray.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        }
        return cell;
    }
    if (row  == self.dataArray.count) {
        [self.mainCell.editButton addTarget:self action:@selector(needEditText) forControlEvents:UIControlEventTouchUpInside];
        return self.mainCell;
    }
    XZCellModel *model = [self.dataArray objectAtIndex:row];
    [model cellHeight];
    XZBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.ideltifier];
    if (!cell) {
        cell = [[NSClassFromString(model.cellClass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.ideltifier];
    }
    cell.model = model;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_xzMainView hideKeyboard];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    CGFloat f = _xzMainView.tableView.contentOffset.y -(_xzMainView.tableView.contentSize.height-_xzMainView.tableView.height*4/5);
    if (f > 0) {
        [self showGuidePages];
        [self handleStopSpeak];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)obtainCellsFormInterface {
    [self.dataArray addObjectsFromArray:[self.mainCell cellModels]];
    [self.mainCell clearData];
    [_xzMainView scrollTableViewBottom];
}

//人类说话

- (void)humenSpeakNothing {
    if (_firstSpeakNothing && !self.guideInfo) {
        [self showGuidePages];
    }
    _firstSpeakNothing = NO;
}

- (void)humenSpeakText:(NSString *)text {
    _firstSpeakNothing = NO;
    if (self.recognizeType == SpeechRecognizeLongText) {
        [self.mainCell appendHumenText:text];
    }
    else {
        [self obtainCellsFormInterface];
        [self.mainCell showHumenText:text];
    }
}

- (void)showOptionIntents:(NSArray *)array {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showOptionIntents:array];
    }];
}

- (void)showModelsInHistory:(NSArray *)models {
    __weak XZMainView *weakView = _xzMainView;
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell clearCreateCard];
        [weakSelf.dataArray addObjectsFromArray:models];
        [weakView scrollTableViewBottom];
    }];
}

//机器人说话
- (void)robotSpeakWithText:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showRobotText:text];
    }];
    
}

- (void)robotSpeakWithModels:(NSArray *)models {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell robotSpeakWithModels:models];
    }];
}


- (void)robotSpeakWithWebModel:(XZWebViewModel *)model {
    model.nav = self.navigationController;
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showWebViewWithModel:model];
    }];
}
- (void)showCreateAppCardWithAppName:(NSString *)name infoList:(NSArray *)infoList {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showCreateAppCardWithAppName:name infoList:infoList];
    }];
}

- (void)hideCreateAppCard {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell hideCreateAppCard];
    }];
}

- (void)showCreateAppCardButtons:(NSArray *)buttons {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showButtons:buttons];
    }];
}

- (void)showLoadingView {
    [super showLoadingView];
    [_xzMainView hideKeyboard];
}

- (void)showToast:(NSString*)toast {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf showToastInner:toast];
    }];
}

- (void)showToastInner:(NSString *)toast {
    [self cmp_showHUDWithText:toast inView:self.view];
}

- (void)showSpeechLoadingView {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell showLoadingView];
    }];
}
- (void)hideSpeechLoadingView {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell hideLoadingView];
    }];
}


//清空记录，并回到提示页面
- (void)clearMessage{
    
}

- (void)handleClickText:(NSString *)text {
    //文本点击事件
    if ([NSString isNull:text]) {
        return;
    }
    [_xzMainView clearInput];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerTapText:)]) {
        [self.delegate mainViewControllerTapText:text];
    }
}

//提示消息
- (void)addPromptMessage:(NSString *)string {
    XZPromptModel *model = [[XZPromptModel alloc] init];
    model.prompt = string;
    [self.dataArray addObject:model];
}

- (void)showWaveView {
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView.bottomBar showWaveView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickWave)];
        [weakView.bottomBar.waveView addGestureRecognizer:tap];
    }];
}

- (void)showWaveViewAnalysis {
    
}

- (void)hideWaveView{
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView.bottomBar hideWaveView];
    }];
}

- (void)waveVolumeChanged:(NSInteger)volume {
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView.bottomBar waveVolumeChanged:volume];
    }];
}

- (void)clickWave {
    [self handleStopSpeak];
}

- (void)recognizeMemberWithMulti:(BOOL)multi {
    self.recognizeType = SpeechRecognizeMember;
    _xzMainView.isMultiChoosemMember = multi;
    __weak typeof(self) weakSelf = self;
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        if (weakView.viewType != mainViewInputType_speech) {
            //不是语音录入，就启用键盘选人
            [weakSelf showMemberView];
        }
    }];
    //常用联系人
    [XZMainProjectBridge topTenFrequentContact:^(NSArray * result) {
        if (result.count >0) {
            [weakSelf dispatchAsyncToMain:^{
                if (weakSelf.recognizeType == SpeechRecognizeMember) {
                    [weakSelf showFrequentViewWithMembers:result multi:multi];
                }
            }];
        }
    } addressbook:!multi];
}

- (void)showKeyboard {
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView showKeyboard];
    }];
}

- (void)hideKeyboard {
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView hideKeyboard];
    }];
}

//还原界面
- (void)restoreView{
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        [weakView hideKeyboard];
    }];
    
}

//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will {
    if (will) {
        
    }
}

- (XZGuidePageView *)guidePageView {
    if (!_guidePageView) {
        if (self.guideInfo) {
            _guidePageView = [[XZQAGuidePageView alloc] initWithQAInfo:self.guideInfo];
        }
        else {
            _guidePageView = [[XZGuidePageView alloc] init];
        }
        __weak typeof(self) weakSelf = self;
        _guidePageView.shouldDismissBlock = ^{
            [weakSelf hideGuidePages];
        };
        _guidePageView.clickTextBlock = ^(NSString *text) {
            [weakSelf hideGuidePages];
            [weakSelf handleClickText:text];
        };
    }
    return _guidePageView;
}


- (void)showGuidePages {
    
    if (_guidePageView && _guidePageView.superview) {
        return;
    }
    CGRect r = CGRectMake(0, _xzMainView.tableView.height, self.view.width, 0);
    __weak XZMainView *weakView = _xzMainView;
    self.guidePageView.frame = r;
    [self.guidePageView removeFromSuperview];
    [_xzMainView addSubview:self.guidePageView];
    [_xzMainView bringSubviewToFront:_xzMainView.bottomBar];
    [self.view bringSubviewToFront:self.bannerNavigationBar];
    [self.view bringSubviewToFront:_statusBarView];
    __weak XZGuidePageView *weakGuideView = self.guidePageView;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect r = weakView.tableView.frame;
        r.origin.y = -weakView.tableView.height;
        weakView.tableView.frame = r;
        r.origin.y = 0;
        weakGuideView.frame = r;
    } completion:^(BOOL finished) {
        weakView.tableView.hidden = YES;
    }];
}

- (void)hideGuidePages {
    if (!_guidePageView || !_guidePageView.superview) {
        return;
    }
    _xzMainView.tableView.hidden = NO;
    __weak XZMainView *weakView = _xzMainView;
    __weak XZGuidePageView *weakGuideView = _guidePageView;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect r = weakView.tableView.frame;
        r.origin.y = 0;
        weakView.tableView.frame = r;
        r.origin.y = weakView.tableView.height;
        r.size.height = 0;
        weakGuideView.frame = r;
    } completion:^(BOOL finished) {
        [weakGuideView removeSubPageView];
        [weakGuideView removeFromSuperview];
        [weakView scrollTableViewBottom];
    }];
}

#pragma mark view delegate start
- (void)frequentView:(XZFrequentView *)view didFinishSelectMember:(NSArray *)members {
    [self handleSelectMember:members isMultiSelect:view.isMultiSelect skip:NO];
}

- (void)frequentView:(XZFrequentView *)view showSelectMemberView:(BOOL)isMultiSelect {
    [self showChooseMemberViewController:view.selectMembers isMultiSelect:isMultiSelect];
}

- (void)showChooseMemberViewController:(NSArray *)selectedMembers isMultiSelect:(BOOL)isMultiSelect {
    [self handleStopSpeak];
    NSMutableArray *fillBackData = [NSMutableArray array];
    for (CMPOfflineContactMember *member in  selectedMembers) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:member.orgID,@"id",member.name,@"name",@"member",@"type", nil];
        [fillBackData addObject:dic];
    }
    CMPChatChooseMemberViewController *memberVC = [[CMPChatChooseMemberViewController alloc] init];
    memberVC.minSize = 0;
    memberVC.maxSize = isMultiSelect ? 99:1;
    memberVC.delegate = self;
    memberVC.fillBackData = fillBackData;
    [self presentViewController:memberVC animated:YES completion:^{
        
    }];
}

- (void)memberTextViewDidSelectMembers:(NSArray *)members string:(NSString *)string isMultiSelect:(BOOL)isMultiSelect {
    [self handleSelectMember:members isMultiSelect:isMultiSelect skip:NO];
    NSArray *array = [NSArray arrayWithObjects:@"下一步、",@"下一步", nil];
    if ([array containsObject:string]) {
        [self handleClickText:@"下一步"];
    }
}

- (void)needShowMessage:(NSString *)string {
    [self showToast:string];
}

- (void)subSearchViewClickText:(NSString *)text {
    [self handleEditText:text];
}

- (void)textEditViewFinishInputText:(NSString *)text {
    [self handleEditText:text];
}

- (void)chatChooseMemberViewController:(CMPChatChooseMemberViewController *)controller
                       didSelectMember:(NSArray *)members{
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *dic in members) {
        CMPOfflineContactMember *member = [[CMPOfflineContactMember alloc] init];
        member.orgID = [dic objectForKey:@"id"];
        member.name = [dic objectForKey:@"name"];
        member.postName = [dic objectForKey:@"post"];
        member.mobilePhone = [dic objectForKey:@"telphone"];
        [list addObject:member];
    }
    // members change to CMPOfflineContactMember
    BOOL isMulti = controller.maxSize>1 ? YES : NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf handleSelectMember:list isMultiSelect:isMulti skip:isMulti];
    });
    [_mainCell.frequentView clearSelect];
}

#pragma mark view delegate end

- (void)handleSelectMember:(NSArray *)members isMultiSelect:(BOOL)isMultiSelect skip:(BOOL)skip  {
    if (!members || members.count == 0) {
        return;
    }
    
    NSString *memberNames = @"";
    for (CMPOfflineContactMember *member in members) {
        memberNames = [NSString stringWithFormat:@"%@%@%@",memberNames,memberNames.length > 0 ?@"、":@"",member.name];
    }
    if (memberNames.length >0) {
        [self humenSpeakText:memberNames];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerDidSelectMembers:skip:)]) {
        [self.delegate mainViewControllerDidSelectMembers:members skip:skip];
    }
}

- (void)handleEditText:(NSString *)text {
    if ([NSString isNull:text]) {
        return;
    }
    [_xzMainView clearInput];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerInputText:)]) {
        [self.delegate mainViewControllerInputText:text];
    }
}

- (void)handleSpeakBtnClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerShouldSpeak)]) {
        [self.delegate mainViewControllerShouldSpeak];
    }
}

- (void)handleStopSpeak {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerShouldStopSpeak)]) {
        [self.delegate mainViewControllerShouldStopSpeak];
    }
}

- (BOOL)isInSpeechView {
    return [_xzMainView isInSpeechView];
}

- (void)enbaleSpeakButton:(BOOL)enable {
    __weak XZMainView *weakView = _xzMainView;
    [self dispatchAsyncToMain:^{
        weakView.bottomBar.speakButton.userInteractionEnabled = enable;
    }];
}

- (void)showTextEditView {
    [_xzMainView showTextEditView];
    _xzMainView.textEditView.viewDelegate = self;
    [_xzMainView.textEditView.speakButton addTarget:self action:@selector(speakButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_xzMainView showKeyboard];
}

- (void)showMemberView{
    [_xzMainView showMemberInputView];
    [_xzMainView hideTextEditView];
    _xzMainView.memberInpitView.viewDelegate = self;
    [_xzMainView.memberInpitView.speakButton addTarget:self action:@selector(speakButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_xzMainView showKeyboard];
}

- (void)hideMemberView {
    __weak XZMainView *weakView = _xzMainView;
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf.mainCell hideFrequentView];
        if (weakView.viewType != mainViewInputType_speech) {
            [weakSelf showTextEditView];
            [weakView hideMemberInputView];
        }
        else {
            [weakView customLayoutSubviews];
        }
    }];
}

- (void)showFrequentViewWithMembers:(NSArray *)members multi:(BOOL)multi {
    [self.mainCell showFrequentViewWithMembers:members multi:multi];
    self.mainCell.frequentView.delegate = self;
}

@end
