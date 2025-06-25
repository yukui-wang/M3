//
//  CMPOcrPackageDetailViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/14.
//

#import "CMPOcrPackageDetailViewController.h"
#import "CMPOcrPackageDetailHeaderView.h"
#import "CMPOcrInvoiceListViewController.h"
#import "CMPOcrPackageViewModel.h"
#import "CMPOcrTopTipView.h"
#import <CMPLib/CMPActionSheet.h>
#import "CMPOcrAddPhotoOrCameraOrFileTool.h"
#import "CMPOcrPickFileTool.h"
#import "CMPOcrUploadManageViewController.h"
#import "CMPOcrMainViewDataProvider.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrNotificationKey.h"
#import "CMPOcrInvoiceCheckViewController.h"
#import "CMPOcrReimbursementManager.h"

@interface CMPOcrPackageDetailViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) CMPOcrPackageDetailHeaderView *headerView;
@property (nonatomic, strong) CMPOcrPackageViewModel *packageViewModel;
@property (nonatomic, strong) CMPOcrPackageModel *packageModel;
@property (nonatomic, weak) UIButton *rightBtn;
@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;
@property (nonatomic, weak) CMPOcrInvoiceListViewController *listVC;
@property (nonatomic, strong) CMPOcrMainViewDataProvider *dataProvider;
//ext=@1 来自首页的页面
//ext=@2 来自我的页面
//ext=@3 来自表单唤起
@property (nonatomic, strong) NSNumber *ext;

@property (nonatomic, copy) void(^ChangeTabToMyBlock)(void);
@property (nonatomic, strong) CMPOcrReimbursementManager *reimburseManager;

@end

@implementation CMPOcrPackageDetailViewController

- (void)dealloc{
    NSLog(@"CMPOcrPackageDetailViewController - delloc");
}

-(instancetype)initWithPackageModel:(CMPOcrPackageModel *)aModel ext:(id)ext
{
    if (self = [super init]) {
        _packageModel = aModel;
        _ext = ext;
    }
    return self;
}
//我的页面进入不允许编辑
- (BOOL)canEdit{
    return self.rdv_tabBarController.selectedIndex != 2;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_ChangeTabToMyBlock){
        _ChangeTabToMyBlock();
        _ChangeTabToMyBlock = nil;
    }
}

//pop 然后切换tab
- (void)changeToMyTab:(NSNotification *)notifi{
    NSDictionary *param = notifi.object;
    BOOL saveDraft = [param[@"saveDraft"] boolValue];
    if(!saveDraft && !_ChangeTabToMyBlock){
        __weak typeof(self) weakSelf = self;
        _ChangeTabToMyBlock = ^{
            RDVTabBarController *tabVC = weakSelf.rdv_tabBarController;
            [weakSelf.navigationController popViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tabVC setSelectedIndex:2];
            });
        };
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _packageModel.name;
    [self.bannerNavigationBar hideBottomLine:YES];
    [self configView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeToMyTab:) name:kNotificationOneClickReimbursementCall object:nil];
    
    __weak typeof(self) weakSelf = self;
    //添加发票操作
    self.headerView.AddInvoiceBtnAction = ^{
        [weakSelf.pickFileTool showSheetForPickToVC:weakSelf Completion:^(NSArray<CMPOcrFileModel *> *fileArray) {
            [weakSelf pushToCheckVCWithFiles:fileArray];
        }];
    };
    //一键报销操作
    self.headerView.SubmitInvoiceBtnAction = ^{
        [weakSelf submitInvoice];
    };
}

- (void)configView{
    [self.view addSubview:self.headerView];
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo([self canEdit]?150:58);
    }];
    
    //键盘收起
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    //listVC
    CMPOcrDefaultInvoiceCategoryModel *m = CMPOcrDefaultInvoiceCategoryModel.new;
    m.packageID = _packageModel.pid;
    //此时调用页面只需要packageId和condition搜索内容
    CMPOcrInvoiceListViewController *list = [[CMPOcrInvoiceListViewController alloc] initWithCategoryModel:m ext:@(2) canEdit:[self canEdit] fromForm:[self.ext integerValue] == 3];//ext=2表示包详情页面调用
    self.listVC = list;
    
    __weak typeof(self) weakSelf = self;
    list.ScrollViewWillBeginDraggingBlock = ^{
        [weakSelf.view endEditing: YES];
    };
    UIView *listView = list.view;
    [self.view addSubview:listView];
    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(0);
        make.left.right.bottom.mas_equalTo(0);
    }];
    [self addChildViewController:list];
    [list didMoveToParentViewController:self];
    
    if ([self canEdit]) {
        //返回tip信息则提示
        __weak typeof(self) weakSelf = self;
        list.ReturnTipModelBlock = ^(CMPOcrPackageTipModel *tipModel) {
            if (tipModel.code == 1) {
                [CMPOcrTopTipView removeLastTipFromView:weakSelf.view];//先删除上一次的
                CMPOcrTopTipView *tipView = [CMPOcrTopTipView new];
                [tipView showTip:tipModel.message];
                [weakSelf.view addSubview:tipView];
                [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(0);
                    make.top.mas_equalTo(CGRectGetMaxY(weakSelf.bannerNavigationBar.frame));
                    make.height.mas_equalTo(44);
                }];
            }
            [weakSelf showRedPoint:tipModel.unDistinguishCount>0];
        };
    }
}

- (void)hideKeyBoard{
    [self.view endEditing:YES];
}

- (void)submitInvoice{
    __weak typeof(self) wSelf = self;
    
    [self.dataProvider checkPackageIfCanCommitWithParams:@{
        @"packageId":self.packageModel.pid?:@"",
    } completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
        if (!error) {
            NSString *summaryId = wSelf.packageModel.summaryId;
            if (wSelf.packageModel.status == 3) {
                summaryId = @"";
            }
            [self.reimburseManager reimbursementWithData:respData
                                                       templateId:wSelf.packageModel.templateId
                                                           formId:wSelf.packageModel.formId
                                                        packageId:wSelf.packageModel.pid
                                                        summaryId:summaryId
                                                           fromVC:wSelf
                                                      cancelBlock:nil
                                                      deleteBlock:nil ext:self.ext];
        }else{
            [wSelf cmp_showHUDError:error];
        }
    }];
}

- (void)showRedPoint:(BOOL)show{
    if (show) {
        CGFloat w = 10;
        UIView *redPoint = [UIView new];
        redPoint.backgroundColor = UIColor.redColor;
        redPoint.layer.cornerRadius = w/2.f;
        redPoint.tag = 110000;
        [self.rightBtn addSubview:redPoint];
        [redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(-w/2);
            make.right.mas_equalTo(w/2);
            make.width.height.mas_equalTo(w);
        }];
    }else{
        [self.rightBtn.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 110000) {
                [obj removeFromSuperview];
                *stop = YES;
            }
        }];
    }
}
//跳转到识别页面
- (void)pushToCheckVCWithFiles:(NSArray *)fileArr{
    if (!fileArr.count) {
        return;
    }
    
    CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:fileArr package:self.packageModel ext:@2];
    dispatch_after(0.2, dispatch_get_main_queue(), ^{
        //等手机文件页面pop返回后再跳转
        [self.navigationController pushViewController:vc animated:YES];
    });
    
}
#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //停止编辑时检测如果清空，则重新请求
    if ([searchBar.text isEqual:@""] && ![self.headerView.searchBar.lastSearchText isEqual:searchBar.text]) {
//        [self searchCategoryList:@""];
        [self.listVC searchInvoiceListByCondition:@""];
    }
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //从有数据变为空，则查询一次全部
    if ([searchBar.text isEqual:@""] && ![self.headerView.searchBar.lastSearchText isEqual:searchBar.text]) {
        [self.listVC searchInvoiceListByCondition:@""];
    }
}

//点击搜索查询
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text = searchBar.text;
    [self.listVC searchInvoiceListByCondition:text];
    [searchBar resignFirstResponder];
}

#pragma mark - custom right button
//票据识别跳转btn
- (void)setupBannerButtons{
    if ([self canEdit]) {
        self.bannerNavigationBar.rightMargin = 16;
        self.backBarButtonItemHidden = NO;
        UIButton *uploadButton = [UIButton buttonWithImageName:@"ocr_card_package_upload"];
        _rightBtn = uploadButton;
        self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:uploadButton];
        [uploadButton addTarget:self action:@selector(uploadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)uploadButtonAction:(id)sender{
    CMPOcrInvoiceCheckViewController *check = [[CMPOcrInvoiceCheckViewController alloc]initWithFileArray:nil package:_packageModel ext:nil];
    [self.navigationController pushViewController:check animated:YES];
}

#pragma mark - getter
- (CMPOcrPackageDetailHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[CMPOcrPackageDetailHeaderView alloc]initByControl:[self canEdit]];
        _headerView.backgroundColor = UIColor.whiteColor;
        _headerView.searchBar.delegate = self;
    }
    return _headerView;
}

- (CMPOcrPackageViewModel *)packageViewModel{
    if (!_packageViewModel) {
        _packageViewModel = [CMPOcrPackageViewModel new];
    }
    return _packageViewModel;
}

- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}
-(CMPOcrMainViewDataProvider *)dataProvider
{
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrMainViewDataProvider alloc] init];
    }
    return _dataProvider;
}

- (CMPOcrReimbursementManager *)reimburseManager{
    if (!_reimburseManager) {
        _reimburseManager = [CMPOcrReimbursementManager new];
    }
    return _reimburseManager;
}

@end
