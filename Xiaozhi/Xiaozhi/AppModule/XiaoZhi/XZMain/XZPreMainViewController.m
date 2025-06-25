//
//  XZMainViewController.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZPreMainViewController.h"
#import "XZPreMainView.h"
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

@interface XZPreMainViewController ()<UITableViewDelegate,
    UITableViewDataSource,
    XZViewDelegate,
    CMPChatChooseMemberViewControllerDelegate>
{
    XZPreMainView *_xzMainView;
    BOOL _voiceOn;
    UIButton *_muteButton;
}
@property(nonatomic, retain)NSMutableArray *dataArray;

@end

@implementation XZPreMainViewController

- (void)dealloc{
//    [XZMainViewController lockRotation:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SY_RELEASE_SAFELY(_dataArray);
    SY_RELEASE_SAFELY(_guideInfo);
    [super dealloc];
}

- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated
{
    [super showNavBar:isShow animated:animated];
    [self.view bringSubviewToFront:_xzMainView];
    [_xzMainView showLogoView:isShow];
}

- (UIColor *)statusBarColorForiOS7
{
    return UIColorFromRGB(0x3AADFB);
    
}
- (UIColor *)bannerNavigationBarBackgroundColor
{
    return UIColorFromRGB(0x3AADFB);
}
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [_xzMainView hideKeyboard];
    [super dismissViewControllerAnimated:flag
                              completion:completion];
}

//+ (void)lockRotation:(BOOL)lock {
//    CMPAppDelegate *aAppDelegate = (CMPAppDelegate *)[UIApplication sharedApplication].delegate;
//    aAppDelegate.onlyPortrait = lock;
//    aAppDelegate.allowRotation = !lock;
//    if (lock) {
//        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
//        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
//        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowRotation =  INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
    _xzMainView = (XZPreMainView *)self.mainView;
    [self defaultData];
    _xzMainView.tableView.delegate = self;
    _xzMainView.tableView.dataSource = self;
    [self.view bringSubviewToFront:_xzMainView];
    _xzMainView.logoView.image = XZ_IMAGE(@"xz_active.png");
    _xzMainView.delegate = self;
    
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.allowRotation =  INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
//    [XZMainViewController lockRotation:INTERFACE_IS_PHONE ? YES : ![XZCore allowRotation];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_xzMainView addNotifications];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerDidAppear)]) {
        [self.delegate mainViewControllerDidAppear];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_xzMainView removeNotifications];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerWillDisappear)]) {
        [self.delegate mainViewControllerWillDisappear];
    }
}
- (NSArray *)guideModels:(BOOL)showAll {
    
    __weak XZPreMainView *weakview = _xzMainView;
    if (!self.guideInfo) {
        XZGuideMode *model = [[[XZGuideMode alloc] initWithType:showAll ? GuideCellTypeHelp:GuideCellTypeGuide] autorelease];
        model.moreBtnClickAction = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakview scrollTableViewBottom];
            });
        };
        return [NSArray arrayWithObject:model];
    }
    
    NSArray *array = [self.guideInfo cellModels:!showAll];
    for (id obj in array) {
        if ([obj isKindOfClass:[XZQAGuideModel class]]) {
            XZQAGuideModel *model =  (XZQAGuideModel *)obj;
            __weak typeof(self) weakSelf = self;
            model.moreBtnClickAction = ^(XZQAGuideTips *tips){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf handleStopSpeak];
                    XZQAGuideDetailModel *detailModel = [[XZQAGuideDetailModel alloc] init];
                    detailModel.tips = tips;
                    detailModel.clickTextBlock = ^(NSString *text) {
                        [weakSelf handleClickText:text];
                    };
                    [weakSelf.dataArray addObject:detailModel];
                    [detailModel autorelease];
                    [weakview scrollTableViewBottom];
                });
            };
            model.clickTextBlock = ^(NSString *text) {
                [weakSelf handleStopSpeak];
                [weakSelf handleClickText:text];
            };
        }
    }
    return array;
}
- (void)defaultData {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
   
    [_dataArray addObjectsFromArray:[self guideModels:NO]];
}

- (void)setupBannerButtons {
   
    NSString *key = [NSString stringWithFormat:@"%@_%@voiceOn",[XZCore serverID],[XZCore userID]];
    NSString *value =  [[NSUserDefaults standardUserDefaults] objectForKey:key];
    _voiceOn = [NSString isNull:value] || [value isEqualToString:@"ok"] ?YES:NO;
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerVoiceStateChange:)]) {
        [self.delegate mainViewControllerVoiceStateChange:_voiceOn];
    }
    self.backBarButtonItemHidden = YES;
    UIButton *closeButton = [UIButton buttonWithImageName:XZ_NAME(@"xz_close.png") frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:closeButton];
    [closeButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
    NSString *image = _voiceOn ? @"xz_voiceon.png" : @"xz_voiceoff.png";
    _muteButton = [UIButton buttonWithImageName:XZ_NAME(image) frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:_muteButton];
    [_muteButton addTarget:self action:@selector(muteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backBarButtonAction:(id)sender{
    [self handleStopSpeak];
    if (self.delegate && [self.delegate mainViewControllerNeedAlertWhenClickCloseBtn]) {
        [_xzMainView hideKeyboard];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"你是否确定退出小致？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf shouldDismiss];
        }];
        [ac addAction:cancel];
        [ac addAction:sure];
        [self presentViewController:ac animated:YES completion:nil];
    } else {        
        [self shouldDismiss];
    }
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
    NSString *image = _voiceOn ? @"xz_voiceon.png" : @"xz_voiceoff.png";
    [_muteButton setImage:XZ_IMAGE(image) forState:UIControlStateNormal];

    NSString *key = [NSString stringWithFormat:@"%@_%@voiceOn",[XZCore serverID],[XZCore userID]];
    NSString *value = _voiceOn ? @"ok" : @"no";
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]  synchronize];

}

- (void)setXzMoodState:(XZMoodState)xzMoodState {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        _xzMoodState = xzMoodState;
        switch (xzMoodState) {
            case XZMoodStateInactive:
                weakView.logoView.image = XZ_IMAGE(@"xz_inactive.png");
                break;
            case XZMoodStateActive:
                weakView.logoView.image = XZ_IMAGE(@"xz_active.png");
                break;
            case XZMoodStateFlying:
                weakView.logoView.image = XZ_IMAGE(@"xz_fly.png");
                break;
            case XZMoodStateAnalysising:
                weakView.logoView.image = XZ_IMAGE(@"xz_working.png");
                break;
            case XZMoodStateAnalysisFailure:
                weakView.logoView.image = XZ_IMAGE(@"xz_question.png");
                break;
            case XZMoodStateError:
                weakView.logoView.image = XZ_IMAGE(@"xz_error.png");
                break;
            default:
                break;
        }
    });
}

- (void)setRecognizeType:(SpeechRecognizeType)recognizeType {
    _recognizeType = recognizeType;
}

- (void)showLoadingView
{
    [super showLoadingView];
    [_xzMainView hideKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showToast:(NSString*)toast {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showToastInner:toast];
    });
}

- (void)showToastInner:(NSString *)toast {
    [self cmp_showHUDWithText:toast inView:self.view];
}

//清空记录，并回到提示页面
- (void)clearMessage{
    
}

//机器人说话

- (void)robotSpeakWithModel:(XZCellModel *)model {
    
    __weak typeof(self) weakSelf = self;
    __weak XZPreMainView *weakView = _xzMainView;

    if ([model isKindOfClass:[XZTextModel class]]) {
        XZTextModel *textModel = (XZTextModel *)model;
        textModel.clickTextBlock = ^(NSString *text) {
            //文本点击事件
            [weakSelf handleClickText:text];
        };
    }
    [weakSelf.dataArray addObject:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView scrollTableViewBottom];
    });
}
- (void)robotSpeakWithModels:(NSArray *)models {
    __weak XZPreMainView *weakView = _xzMainView;
    [self.dataArray addObjectsFromArray:models];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView scrollTableViewBottom];
    });
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

//人类说话
- (void)humenSpeakWithModel:(XZTextModel *)model
{
    if (![self.dataArray containsObject:model] ) {
        [self.dataArray addObject:model];
    }
    else {
        model.resetCellHeight = YES;
    }
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView scrollTableViewBottom];
    });
}

//提示消息
- (void)addPromptMessage:(NSString *)string
{
    __weak XZPreMainView *weakView = _xzMainView;
    XZPromptModel *model = [[XZPromptModel alloc] init];
    model.prompt = string;
    [self.dataArray addObject:model];
    SY_RELEASE_SAFELY(model);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView scrollTableViewBottom];
    });
}

- (void)showWaveView {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView showWaveView];
    });
}
- (void)showWaveViewAnalysis {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView showWaveViewAnalysis];
    });
}
- (void)hideWaveView{
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView hideWaveView];
    });
}

- (void)showSubSearchView {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView showSearchItemsView];
    });
}
- (void)hideSubSearchView{
    //语音输入 隐藏搜索小项
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView hideSearchItemsView];
    });
}

- (void)hideMemberView
{
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView hideMemberView];
    });
}
- (void)showKeyboard {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView showKeyboard];
    });
}

- (void)hideKeyboard {
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView hideKeyboard];
    });
}

//还原界面
- (void)restoreView{
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakView hideKeyboard];
    });

}

//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will {
    if (will) {
        __weak XZPreMainView *weakView = _xzMainView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakView hideMemberView];
        });
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row <self.dataArray.count) {
        XZCellModel *model = [self.dataArray objectAtIndex:row];
        return model.cellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row  >= self.dataArray.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"] autorelease];
        }
        return cell;
    }
    XZCellModel *model = [self.dataArray objectAtIndex:row];
    [model cellHeight];
    XZBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.ideltifier];
    if (!cell) {
        cell = [[[NSClassFromString(model.cellClass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.ideltifier] autorelease];
    }
    cell.model = model;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_xzMainView hideKeyboard];
}

#pragma mark  XZViewDelegate

- (void)speakButtonClickedWithMainView:(XZPreMainView *)view {
    [self handleSpeakBtnClick];
}

- (void)keyboardButtonClickedWithMainView:(XZPreMainView *)view {
    [self handleStopSpeak];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerShouldstopWakeUp)]) {
        [self.delegate mainViewControllerShouldstopWakeUp];
    }
}

- (void)mainView:(XZPreMainView *)view finishInputText:(NSString *)text {
    [self handleEditText:text];
}

- (void)showHelpViewWithMainView:(XZPreMainView *)view {
    [self handleStopSpeak];
    [_dataArray addObjectsFromArray:[self guideModels:YES]];
    [_xzMainView scrollTableViewBottom];
}

- (void)editTextViewControllerFinishWithString:(NSString *)text {
    [self handleEditText:text];
}

- (void)textEditView:(XZTextEditView *)view finishInputText:(NSString *)text {
    [self handleEditText:text];
}

- (void)subSearchView:(XZSubSearchView *)view clickText:(NSString *)text {
    [_xzMainView hideSearchItemsView];
    [self handleEditText:text];
}

- (void)frequentView:(XZPreFrequentView *)view didFinishSelectMember:(NSArray *)members {
    [self handleSelectMember:members isMultiSelect:view.isMultiSelect];
}

- (void)frequentView:(XZPreFrequentView *)view showSelectMemberView:(BOOL)isMultiSelect {
    [self handleStopSpeak];
    NSMutableArray *fillBackData = [NSMutableArray array];
    for (CMPOfflineContactMember *member in  view.selectMembers) {
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
    SY_RELEASE_SAFELY(memberVC);
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
        SY_RELEASE_SAFELY(member);
    }
    // members change to CMPOfflineContactMember
    [self handleSelectMember:list isMultiSelect:controller.maxSize>1];
}

- (void)view:(UIView *)view needShowMessage:(NSString *)string {
    [self showToast:string];
}

- (void)memberTextView:(XZMemberTextView *)view didSelectMembers:(NSArray *)members string:(NSString *)string {
    [self handleSelectMember:members isMultiSelect:view.isMultiSelect];
   
    NSArray *array = [NSArray arrayWithObjects:@"下一步、",@"下一步", nil];
    if ([array containsObject:string]) {
        [self handleClickText:@"下一步"];
    }
}

- (void)rippleViewDidClick:(XZRippleView *)view {
    //监听过程中，停止监听
    [self handleStopSpeak];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerShouldstartWakeup)]) {
        [self.delegate mainViewControllerShouldstartWakeup];
    }
}

#pragma mark end

- (void)handleSelectMember:(NSArray *)members isMultiSelect:(BOOL)isMultiSelect {
    if (!members || members.count == 0) {
        return;
    }
    NSString *memberNames = @"";
    for (CMPOfflineContactMember *member in members) {
        memberNames = [NSString stringWithFormat:@"%@%@%@",memberNames,memberNames.length > 0 ?@"、":@"",member.name];
    }
    if (memberNames.length >0) {
        XZTextModel *mode = [[XZTextModel alloc]init];
        mode.chatCellType = ChatCellTypeUserMessage;
        mode.contentInfo = memberNames;
        [_dataArray addObject:mode];
        SY_RELEASE_SAFELY(mode);
        [_xzMainView scrollTableViewBottom];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainViewControllerDidSelectMembers:skip:)]) {
        [self.delegate mainViewControllerDidSelectMembers:members skip:NO];
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
    __weak XZPreMainView *weakView = _xzMainView;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakView.speakButton.userInteractionEnabled = enable;
    });
}

- (BOOL)keyboardIsShow {
    return [_xzMainView keyboardIsShow];
}

@end
