//
//  XZQAMainViewController.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQAMainViewController.h"
#import "XZQAMainView.h"
#import "XZCore.h"
#import "XZBaseTableViewCell.h"
#import "XZQAHumanModel.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPThemeManager.h>
#import "XZTransWebViewController.h"
#import <CMPLib/CMPSplitViewController.h>
#import <CMPLib/CMPServerVersionUtils.h>

@interface XZQAMainViewController ()<UITableViewDelegate,UITableViewDataSource> {
    XZQAMainView *_qaMainView;
    BOOL _voiceOn;
    UIButton *_muteButton;
    XZQAHumanModel *_currentModel;
}
@property(nonatomic, strong)NSMutableArray *dataArray;
//@property(nonatomic, strong) UIImageView *xzIconView;;

@end

@implementation XZQAMainViewController
- (void)showNavBar:(BOOL)isShow animated:(BOOL)animated {
    [super showNavBar:isShow animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [CMPThemeManager sharedManager].automaticStatusBarStyleDefault;
}

- (UIColor *)statusBarColorForiOS7 {
    return [self bgColor];
}

- (UIColor *)bannerNavigationBarBackgroundColor {
    return [self bgColor];
}

- (UIColor *)bgColor {
    return UIColorFromRGB(0xEEEEEE);
}
- (UIColor *)bannerTitleColor {
    return [UIColor blackColor];
}

- (UIButton *)bannerButtonWithImage:(NSString *)imageName {
    return [UIButton buttonWithImageName:XZ_NAME(imageName) frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
}

- (NSString *)voiceImage {
    return _voiceOn ? @"xz_qa_on.png" : @"xz_qa_off.png";
}
- (NSString *)voiceKey {
    NSString *key = [NSString stringWithFormat:@"%@_%@qaVoiceOn",[XZCore serverID],[XZCore userID]];
    return key;
}

- (void)setupBannerButtons {
    
    self.bannerNavigationBar.leftMargin = 0;
   
    self.backBarButtonItemHidden = YES;
    UIButton *closeButton = [self bannerButtonWithImage:@"xz_qa_back.png"];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:closeButton];
    [closeButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
   if ([[XZCore sharedInstance] xiaozAvailable]) {
       NSString *key = [self voiceKey];
       NSString *value =  [[NSUserDefaults standardUserDefaults] objectForKey:key];
       _voiceOn = ![NSString isNull:value] && [value isEqualToString:@"ok"] ?YES:NO;
       _muteButton =[self bannerButtonWithImage:[self voiceImage]];
       [_muteButton addTarget:self action:@selector(muteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
       if (self.voiceStateChangeBlock) {
           self.voiceStateChangeBlock(_voiceOn);
       }
       [rightBarButtonItems addObject:_muteButton];
   }
    if (self.formMsg) {
        self.bannerNavigationBar.rightViewsMargin = 10;
        UIButton *settingButton =[self bannerButtonWithImage:@"xz_qa_setting.png"];
        [settingButton addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [rightBarButtonItems addObject:settingButton];
    }else{
        self.bannerNavigationBar.rightViewsMargin = 10;
        if ([CMPServerVersionUtils serverIsLaterV8_1]) {
            UIButton *viewHistoryBtn = [self bannerButtonWithImage:@"xz_nav_more"];
            [viewHistoryBtn addTarget:self action:@selector(_viewHistory) forControlEvents:UIControlEventTouchUpInside];
            [rightBarButtonItems addObject:viewHistoryBtn];
        }
    }
    self.bannerNavigationBar.rightBarButtonItems = rightBarButtonItems;

}
- (void)layoutSubviewsWithFrame:(CGRect)frame {
    [super layoutSubviewsWithFrame:frame];
//    if (_xzIconView) {
//        _xzIconView.frame = CGRectMake(self.view.width/2-24, self.bannerNavigationBar.originY+5, 48, 60);
//    }
}

//- (UIImageView *)xzIconView {
//     if (!_xzIconView) {
//         _xzIconView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width/2-24, self.bannerNavigationBar.originY+5, 48, 60)];
//         _xzIconView.image = XZ_IMAGE(@"xz_qa_icon.png");
//         [self.view addSubview:_xzIconView];
//     }
//    return _xzIconView;
//}

- (void)showXZIcon:(BOOL)show {
//    if (show) {
//       self.xzIconView.hidden = NO;
//        self.title = @"";
//    }
//    else {
//        self.xzIconView.hidden = YES;
        self.title = @"智能问答";
        self.bannerNavigationBar.bannerTitleView.textColor = [self bannerTitleColor];
//    }
}

- (void)setKeywordArray:(NSArray *)keywordArray {
    _keywordArray = keywordArray;
    if (_qaMainView) {
        [_qaMainView showKeyWords:_keywordArray];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bannerNavigationBar hideBottomLine:NO];
    _qaMainView = (XZQAMainView *)self.mainView;
    _qaMainView.backgroundColor = [UIColor whiteColor];
    _qaMainView.keyWordsView.backgroundColor = [self bgColor];
    _qaMainView.tableView.backgroundColor = [self bgColor];
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    __weak typeof(_qaMainView) weakMainView = _qaMainView;
    __weak typeof(self) weakSelf = self;
    NSArray *array = self.dataArray;
    if (array.count > 0) {
        for (XZCellModel *m in array) {
            if ([m isKindOfClass:[XZQAHumanModel class]] ) {
                XZQAHumanModel *model = (XZQAHumanModel *)m;
                model.editContentBlock = ^(NSString *text) {
                    [weakBar editContent:text];
                };
                model.clickSpaceBlock = ^{
                    [weakBar hideKeyboard];
                };
            }
            else  if ([m isKindOfClass:[XZWebViewModel class]] ){
                XZWebViewModel *model = (XZWebViewModel *)m;
                model.nav = self.navigationController;
                model.webviewFinishLoad = ^(CGFloat webHeight) {
                    [weakSelf scrollTableViewBottom];
                };
            }
        }
    }
    _qaMainView.tableView.delegate = self;
    _qaMainView.tableView.dataSource = self;
    _qaMainView.bottomBar.startRecordingBlock = self.startRecordingBlock;
    _qaMainView.bottomBar.stopRecordingBlock = self.stopRecordingBlock;
    _qaMainView.bottomBar.inputContentBlock = self.inputContentBlock;
    _qaMainView.bottomBar.barHeightChangeBlock = ^{
        [weakMainView customLayoutSubviews];
    };
    if ([[XZCore sharedInstance] xiaozAvailable]) {
        if (_formMsg) {
            _qaMainView.bottomBarCoverView.hidden = NO;
            __weak typeof(XZQAMainView *) wMainView = _qaMainView;
            _qaMainView.bottomBarCoverView.startAskBlock = ^{
                wMainView.bottomBarCoverView.hidden = YES;
                if (weakSelf.commonActBlk) {
                    weakSelf.commonActBlk(kXZQACommonTag_StartAsk, nil);
                }
            };
        }
//        else{
//            if (self.bannerNavigationBar) {
//                UIButton *viewHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [viewHistoryBtn setImage:XZ_IMAGE(@"xz_qa_setting.png") forState:UIControlStateNormal];
//                [viewHistoryBtn addTarget:self action:@selector(_viewHistory) forControlEvents:UIControlEventTouchUpInside];
//                [self.bannerNavigationBar insertRightBarButtonItem:viewHistoryBtn];
//            }
//        }
    }
    
    [_qaMainView showKeyWords:_keywordArray];
    [self showXZIcon:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.allowRotation =  INTERFACE_IS_PHONE ? NO : [XZCore allowRotation];
    //    [XZMainViewController lockRotation:INTERFACE_IS_PHONE ? YES : ![XZCore allowRotation];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_QAChatOn object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_XiaozViewShow object:nil];
   
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (INTERFACE_IS_PAD) {
        [self.splitViewController cmp_switchSplitScreen];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_QAChatOff object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationName_XiaozViewHide object:nil];
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)backBarButtonAction:(id)sender{
    [self handleStopSpeak];
//    if (self.delegate && [self.delegate mainViewControllerNeedAlertWhenClickCloseBtn]) {
//        [_qaMainView hideKeyboard];
//        __weak typeof(self) weakSelf = self;
//        [self showCloseAlert:^{
//            [weakSelf shouldDismiss];
//        }];
//    } else {
        [self shouldDismiss];
//    }
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


- (void)shouldDismiss {
    [self.dataArray removeAllObjects];
    if (self.shouldDismissBlock) {
        self.shouldDismissBlock();
    }
}

- (void)muteButtonAction:(id)sender{
    _voiceOn = !_voiceOn;
    if (self.voiceStateChangeBlock) {
        self.voiceStateChangeBlock(_voiceOn);
    }
    UIImage *aImg = XZ_IMAGE([self voiceImage]);
    [_muteButton setImage:aImg forState:UIControlStateNormal];
    NSString *key = [self voiceKey];
    NSString *value = _voiceOn ? @"ok" : @"no";
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}
- (void)settingButtonAction:(id)sender {
    XZTransWebViewController *vc = [[XZTransWebViewController alloc] init];
    vc.loadUrl = kXiaozQAMsgSettingUrl;
    vc.hideBannerNavBar = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.formMsg ?self.dataArray.count +1: self.dataArray.count +1+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = self.formMsg ?indexPath.row: indexPath.row-1;
    if (row >= 0 && row < self.dataArray.count) {
        XZCellModel *model = [self.dataArray objectAtIndex:row];
        model.cellWidth = tableView.width;
        return model.cellHeight;
    }
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = self.formMsg ?indexPath.row: indexPath.row-1;
    if (row >= 0 && row < self.dataArray.count) {
        XZCellModel *model = [self.dataArray objectAtIndex:row];
           model.cellWidth = self.view.width;
           [model cellHeight];
           XZBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.ideltifier];
           if (!cell) {
               cell = [[NSClassFromString(model.cellClass) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.ideltifier];
           }
           cell.model = model;
           return cell;
        
    }
   XZBaseTableViewCell *cell = (XZBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
   if (!cell) {
       cell = [[XZBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
       UIColor *color = [UIColor clearColor];
       cell.backgroundColor = color;
       [cell setBkViewColor:color];
       [cell setSelectBkViewColor:color];
   }
   return cell;
   
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_qaMainView.bottomBar hideKeyboard];
}


- (void)scrollTableViewBottom {
    if (_qaMainView) {
        [_qaMainView scrollTableViewBottom];
        [self showXZIcon:_qaMainView.tableView.contentOffset.y <= 30];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//人类说话
- (void)humenSpeakNothing {
  
}

- (void)humenSpeakText:(NSString *)text {
    _currentModel.showAnimation = NO;
    XZQAHumanModel *model = [[XZQAHumanModel alloc] init];
    model.content = text;
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    __weak typeof(self) weakSelf = self;
    model.editContentBlock = ^(NSString *text) {
        [weakBar editContent:text];
    };
    model.clickSpaceBlock = ^{
        [weakBar hideKeyboard];
    };
    _currentModel = model;
    _currentModel.showAnimation = YES;
    [self.dataArray addObject:model];
    [self dispatchSyncToMain:^{
        [weakSelf scrollTableViewBottom];
    }];
}

- (void)showOptionIntents:(NSArray *)array {
   
}

- (void)showModelsInHistory:(NSArray *)models {
    
}

//机器人说话
- (void)robotSpeakWithText:(NSString *)text {
   
}

- (void)robotSpeakWithModels:(NSArray *)models {
   
}


- (void)robotSpeakWithWebModel:(XZWebViewModel *)model {
    _currentModel.showAnimation = NO;
    _currentModel = nil;
    __weak typeof(self) weakSelf = self;
    __weak UITableView *weakTableView = _qaMainView.tableView;

    model.webviewFinishLoad = ^(CGFloat webHeight) {
        [weakSelf scrollTableViewBottom];
    };
    model.nav = self.navigationController;
    [self.dataArray addObject:model];
    [self dispatchSyncToMain:^{
        [weakTableView reloadData];
    }];
}
- (void)showCreateAppCardWithAppName:(NSString *)name infoList:(NSArray *)infoList {
  
}

- (void)hideCreateAppCard {
   
}

- (void)showCreateAppCardButtons:(NSArray *)buttons {
   
}

- (void)showLoadingView {
    [super showLoadingView];
}

- (void)showToast:(NSString*)toast {
    __weak typeof(self) weakSelf = self;
    [self dispatchAsyncToMain:^{
        [weakSelf cmp_showHUDWithText:toast inView:weakSelf.view];
    }];
}

- (void)hideSpeechLoadingView {
    if (_currentModel) {
        _currentModel.showAnimation = NO;
        _currentModel = nil;
        [_qaMainView.tableView reloadData];
    }
}

//清空记录，并回到提示页面
- (void)clearMessage{
    
}

- (void)showWaveView {
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    [self dispatchSyncToMain:^{
        [weakBar showWave];
    }];
}

- (void)showWaveViewAnalysis {
    
}

- (void)hideWaveView{
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    [self dispatchSyncToMain:^{
        [weakBar hideWave];
    }];
}

- (void)waveVolumeChanged:(NSInteger)volume {
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    [self dispatchSyncToMain:^{
        [weakBar showWaveWithVolume:volume];
    }];
}

- (void)recognizeMemberWithMulti:(BOOL)multi {
   
}

- (void)showKeyboard {
   

}

- (void)hideKeyboard {
    __weak typeof(_qaMainView.bottomBar) weakBar = _qaMainView.bottomBar;
    [self dispatchSyncToMain:^{
        [weakBar hideKeyboard];
    }];
}

//还原界面
- (void)restoreView{
   
    
}

//用于选人是否可以下一步
- (void)memberNodeWillNextStep:(BOOL)will {
    if (will) {
        
    }
}

- (void)showGuidePages {
  
}

- (void)hideGuidePages {
   
}

#pragma mark view delegate start


- (void)needShowMessage:(NSString *)string {
    [self showToast:string];
}

- (void)subSearchViewClickText:(NSString *)text {
}

- (void)textEditViewFinishInputText:(NSString *)text {
}



- (void)handleSelectMember:(NSArray *)members isMultiSelect:(BOOL)isMultiSelect skip:(BOOL)skip  {
}

- (void)handleEditText:(NSString *)text {
    
}

- (void)handleSpeakBtnClick {
   
}

- (void)handleStopSpeak {
   
}

- (BOOL)isInSpeechView {
    return NO;
}

- (void)enbaleSpeakButton:(BOOL)enable {
   
}

- (void)showTextEditView {
}

- (void)showMemberView{
}

- (void)hideMemberView {
   
}

- (void)showFrequentViewWithMembers:(NSArray *)members multi:(BOOL)multi {
}

- (void)showChooseMemberViewController:(NSArray *)selectedMembers isMultiSelect:(BOOL)isMultiSelect {
    
}

-(void)_viewHistory
{
    if (_commonActBlk) {
        _commonActBlk(kXZQACommonTag_View30History,nil);
    }
}

@end
