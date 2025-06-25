//
//  CMPOcrMainViewController.m
//  M3
//
//  Created by Kaku Songu on 11/23/21.
//
#import <CMPLib/CMPFileManagementRecord.h>
#import "CMPOcrMainViewController.h"
#import "CMPOcrMainView.h"
#import "CMPOcrMainViewModel.h"
#import "CMPOcrPackageDetailViewController.h"
#import "CMPOcrNotificationKey.h"
#import "CMPOcrUploadManageViewController.h"
#import <CMPLib/NSObject+CMPHUDView.h>

#import "CMPOcrDefaultInvoiceViewController.h"

@interface CMPOcrMainViewController ()

@property (nonatomic,strong) CMPOcrMainViewModel *viewModel;
@property (nonatomic, copy) void(^ChangeTabToMyBlock)(void);

@property (nonatomic, weak) UIButton *navBackButton;

@end

@implementation CMPOcrMainViewController
- (void)dealloc
{
    NSLog(@"%@-dealloc",self.class);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self _refreshCurrentModules];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_ChangeTabToMyBlock){
        _ChangeTabToMyBlock();
        _ChangeTabToMyBlock = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bgc"];//white-bg1,gray-bgc
    
    //statusbar
    [self setupStatusBarViewBackground:UIColor.clearColor];
    //navibar
    [self.bannerNavigationBar hideBottomLine:YES];

    //mainView
    CMPOcrMainView *mainView = (CMPOcrMainView *)self.mainView;
    mainView.viewModel = self.viewModel;
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).offset(0);
    }];
    
    __weak typeof(self) wSelf = self;
    __weak typeof(CMPOcrMainView *) wMainView = mainView;
    self.viewModel.commonModulesCompletionBlk = ^(NSArray<CMPOcrModuleItemModel *> * _Nonnull modules, NSError * _Nonnull error) {
        if (!error) {
            [wMainView.cardCategoryView updateCommonModules];
            [wSelf.viewModel setSelectedModuleIndex:wSelf.viewModel.selectedModuleIndex];
            [wSelf.viewModel refreshCurrentPackageList];
        }else{
            [wSelf cmp_showHUDError:error];
        }
        
    };
    
    self.viewModel.packagesCompletionBlk = ^(NSArray<CMPOcrPackageModel *> * _Nonnull packages, NSError * _Nonnull error) {
        if (!error) {
            [wMainView.cardCategoryView updatePackageList];
        }else{
            [wSelf cmp_showHUDError:error];
        }
    };
    
    [self.viewModel refreshCommonModules];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_commonModulesUpdate) name:@"kNotificationName_ocrModulesUpdateSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_packageDidUpdate:) name:kNotificationUpdateBagCall object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_packageDidUpdate:) name:kNotificationOneReimbursementRemovedInvoice object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushToPackageDetail:) name:kNotificationCreateBagCall object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeToMyTab:) name:kNotificationOneClickReimbursementCall object:nil];
}

-(void)_packageDidUpdate:(NSNotification *)noti
{
    [self _refreshCurrentModules];
}

-(void)_commonModulesUpdate
{
    [self.viewModel refreshCommonModules];
}

-(void)_refreshCurrentModules
{
    if (_mainView) {
        [self.viewModel refreshCurrentPackageList];
    }
}

//navigationBar
- (UIColor *)bannerNavigationBarBackgroundColor{
    return UIColor.clearColor;
}
//自定义返回btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = YES;
    UIButton *backButton = [UIButton buttonWithImageName:@"nav_back_white" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.navBackButton = backButton;
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:backButton];
    [backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeBackIconToWhite:(BOOL)white{
    if (white) {
        [self.navBackButton setImage:[UIImage imageNamed:@"nav_back_white"] forState:(UIControlStateNormal)];
    }else{
        [self.navBackButton setImage:[UIImage imageNamed:@"navBackButton"] forState:(UIControlStateNormal)];
    }
}

//返回btn事件
- (void)backBarButtonAction:(id)sender{
    if (self.rdv_tabBarController.navigationController) {
        [self.rdv_tabBarController.navigationController popViewControllerAnimated:YES];
    }else{
        [self.rdv_tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(CMPOcrMainViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOcrMainViewModel alloc] init];
        _viewModel.statusArr = @[@0];
    }
    return _viewModel;
}

//pop and 切换tab到我的
- (void)changeToMyTab:(NSNotification *)notifi{
    NSDictionary *param = notifi.object;
    BOOL saveDraft = [param[@"saveDraft"] boolValue];
    if(!saveDraft && !_ChangeTabToMyBlock){
        __weak typeof(self) weakSelf = self;
        _ChangeTabToMyBlock = ^{
            [weakSelf.rdv_tabBarController setSelectedIndex:2];
        };
    }
}

- (void)pushToPackageDetail:(NSNotification *)notifi{
    if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        //刷新页面数据
        id obj = notifi.object;
        CMPOcrPackageModel *packageModel = [CMPOcrPackageModel yy_modelWithJSON:obj];
        if (packageModel) {
            //跳转
//            CMPOcrPackageDetailViewController *vc = [[CMPOcrPackageDetailViewController alloc] initWithPackageModel:packageModel ext:@1];
//            [self.navigationController pushViewController:vc animated:YES];
            CMPOcrDefaultInvoiceViewController *vc = [[CMPOcrDefaultInvoiceViewController alloc]initWithPackage:packageModel ext:@1];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
