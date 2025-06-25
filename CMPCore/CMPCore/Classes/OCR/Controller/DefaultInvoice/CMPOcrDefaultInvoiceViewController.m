//
//  CMPOcrDefaultInvoiceViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrDefaultInvoiceViewController.h"
#import "CMPOcrInvoiceListViewController.h"
#import "CMPOcrInvoiceSelectBottomView.h"
#import "CMPOcrInvoiceFolderViewController.h"
#import "CMPOcrInvoiceModel.h"
#import "CMPOcrInvoiceSelectedAlertView.h"
#import <CMPLib/JXCategoryView.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>

#import "CMPOcrTopTipView.h"
#import "CustomCircleSearchBar.h"
#import "CMPOcrInvoiceCheckViewController.h"
#import "CMPOcrFormPickViewController.h"

#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrReimbursementManager.h"
#import "CMPOcrPackageDetailViewController.h"
#import "CMPOcrNotificationKey.h"
#import "CMPOcrPickFileTool.h"
#import "CMPOcrUploadManageViewController.h"
#import "CMPOcrMainViewDataProvider.h"
#import "CMPOcrDeleteInvoiceDataProvider.h"
#import <CMPLib/CMPActionSheet.h>
#import <CMPLib/CMPAlertView.h>

@interface CMPOcrDefaultInvoiceViewController ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate,CMPOcrInvoiceSelectBottomViewDelegate,CMPOcrInvoiceListViewControllerDelegate, UISearchBarDelegate>
// 分类列表
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
// 底部已选择
@property (nonatomic, strong) CMPOcrInvoiceSelectBottomView *selectBottomView;
// network
@property (nonatomic, strong) CMPOcrMainViewDataProvider *mainDataProvider;//check和唤醒pc
@property (nonatomic, strong) CMPOcrDeleteInvoiceDataProvider *deleteDataProvider;//批量删除
// 已选择发票
@property (nonatomic, strong) NSMutableArray *selectedModels;
// 分类
@property (nonatomic, strong) NSMutableArray *categoryModels;
//搜索框
@property (nonatomic, strong) CustomCircleSearchBar *searchBar;
//选中下标
@property (nonatomic, assign) NSInteger       selectIndex;
//子页面
@property (nonatomic, strong) NSMutableDictionary *listVcDict;//<modelID:listvc>

//ai识别按钮
@property (nonatomic, weak) UIButton *aiCheckBtn;
//报销管理
@property (nonatomic, strong) CMPOcrReimbursementManager *reimburseManager;

//相册文件选取管理
@property (nonatomic, strong) CMPOcrPickFileTool *pickFileTool;

//包数据
@property (nonatomic, strong) CMPOcrPackageModel *package;
//ext=3 来自表单
@property (nonatomic, strong) id ext;

//表单发票id
@property (nonatomic, strong) NSArray *formInvoiceIdList;

@end

@implementation CMPOcrDefaultInvoiceViewController

- (instancetype)initWithPackage:(CMPOcrPackageModel *)package ext:(id)ext
{
    if (self = [super init]) {
        _package = package;
        _ext = ext;
        if ([ext integerValue] == 3) {//表单
            _formInvoiceIdList = package.invoiceIdList;
        }
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _package.name.length>0?_package.name:@"默认票夹";
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
    [self setupStatusBarViewBackground:UIColor.whiteColor];
    [self.bannerNavigationBar hideBottomLine:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEdit)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self setupSearchBar];
    [self setupCategoryUI];
    [self setupCategoryData];
    
    //报销表单处理通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeToMyTab:) name:kNotificationOneClickReimbursementCall object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_ChangeTabToMyBlock){
        _ChangeTabToMyBlock();
        _ChangeTabToMyBlock = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.categoryView) {//ks fix(不明白为什么页面消失时会刷新页面导致数据错乱，没有任何输出，暂时就重新设置下了) -- V5-36159【智能报销】报销包详情页面发票刷新不正确
        [self.categoryView selectItemAtIndex:self.categoryView.selectedIndex];
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
            [weakSelf.navigationController popViewControllerAnimated:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tabVC setSelectedIndex:2];
            });
        };
    }
}

//重新获取当前页面数据
- (void)reReqData{
    CMPOcrInvoiceListViewController * list = [self currentListVC];
    [list setSelectedModels:self.selectedModels];
    [self searchCategoryList:self.searchBar.text];
}

- (void)endEdit{
    [self.view endEditing:YES];
}

- (void)setupSearchBar {
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
    CGFloat searchW = kCMPOcrScreenWidth-40;
    CustomCircleSearchBar *search = [[CustomCircleSearchBar alloc]initWithPlaceholder:@"输入发票类型或金额" size:CGSizeMake(searchW, 44)];
    search.frame = CGRectMake(0, top, searchW, 44);
    [self.view addSubview:search];
    search.delegate = self;
    self.searchBar = search;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.backgroundColor = UIColor.whiteColor;
    [addBtn setImage:[UIImage imageNamed:@"ocr_card_package_list_add"] forState:(UIControlStateNormal)];
    [addBtn addTarget:self action:@selector(addInvoiceAction:) forControlEvents:(UIControlEventTouchUpInside)];
    addBtn.frame = CGRectMake(CGRectGetMaxX(search.frame)-13, top, 54, 44);
    [self.view addSubview:addBtn];
}

- (void)setupCategoryUI {
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    lineView.indicatorWidth = JXCategoryViewAutomaticDimension;
    lineView.indicatorHeight = 4.f;
    
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame)+44;
    self.categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, top, kCMPOcrScreenWidth, 50)];
    self.categoryView.delegate = self;
    self.categoryView.backgroundColor = UIColor.whiteColor;
    self.categoryView.titleColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleFont = [UIFont systemFontOfSize:16];
    self.categoryView.titleSelectedFont = [UIFont systemFontOfSize:16];
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.indicators = @[lineView];
    self.categoryView.averageCellSpacingEnabled = NO;
    [self.view addSubview:self.categoryView];
    
    CGFloat containerHeight = self.view.height - self.categoryView.bottom - 50 - IKBottomSafeEdge;
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.frame = CGRectMake(0, self.categoryView.bottom, kCMPOcrScreenWidth, containerHeight);
    self.listContainerView.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.listContainerView];
    
    self.categoryView.listContainer = self.listContainerView;
    
    //底部view
    self.selectBottomView = [[CMPOcrInvoiceSelectBottomView alloc] init];
    self.selectBottomView.delegate = self;
    [self.view addSubview:self.selectBottomView];
    //ext=3 为【继续添加】+【完成】
    [self.selectBottomView setExtStatus:[self.ext integerValue]];
    
    CGFloat bottomHeight = 50 + IKBottomSafeEdge;
    [self.selectBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(bottomHeight);
    }];
}
//文件上传按钮
- (void)setupBannerButtons{
    self.bannerNavigationBar.rightMargin = 4;//图标时为16
    self.backBarButtonItemHidden = NO;
//    _aiCheckBtn = [UIButton buttonWithImageName:@"ocr_card_package_upload"];
    UIButton *aiBtn = [UIButton buttonWithTitle:@"AI识别" textColor:UIColor.blackColor textSize:16.f];
    _aiCheckBtn = aiBtn;
    self.bannerNavigationBar.rightBarButtonItems = [NSArray arrayWithObject:aiBtn];
    [aiBtn addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
}
//跳转识别页面
- (void)rightBarButtonAction {
    CMPOcrInvoiceCheckViewController *check = [[CMPOcrInvoiceCheckViewController alloc]initWithFileArray:nil package:_package ext:nil];
    [self.navigationController pushViewController:check animated:YES];
}

- (void)addInvoiceAction:(id)sender{
    [self addInvoiceAction];
}

#pragma mark - data
- (void)setupCategoryData{
    CMPOcrDefaultInvoiceCategoryModel *model = [CMPOcrDefaultInvoiceCategoryModel new];
    model.modelName = @"全部";
    model.modelID = @"-1";
    [self.categoryModels addObject:model];
    self.categoryView.titles = @[@"全部"];
    [self.categoryView reloadData];
}
#pragma mark 获取listVC
- (CMPOcrInvoiceListViewController *)currentListVC{
    CMPOcrDefaultInvoiceCategoryModel *cate = self.categoryModels[self.selectIndex];
    CMPOcrInvoiceListViewController * list = (CMPOcrInvoiceListViewController *)[self.listVcDict objectForKey:cate.modelID];
    list.categoryModel.modelID = cate.modelID;
    list.categoryModel.modelName = cate.modelName;
    list.selectIndex = self.selectIndex;
    return list;
}

#pragma mark 获取数据
- (void)searchCategoryList:(NSString *)keyword{
    self.searchBar.lastSearchText = keyword;
    
    CMPOcrInvoiceListViewController * list = [self currentListVC];
    [list searchInvoiceListByCondition:keyword];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //停止编辑时检测如果清空，则重新请求
    if ([searchBar.text isEqual:@""] && ![self.searchBar.lastSearchText isEqual:searchBar.text]) {
        [self searchCategoryList:@""];
    }
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //从有数据变为空，则查询一次全部
    if ([searchBar.text isEqual:@""] && ![self.searchBar.lastSearchText isEqual:searchBar.text]) {
        [self searchCategoryList:@""];
    }
}

//点击搜索查询
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text = searchBar.text;
    [self searchCategoryList:text];
    [searchBar resignFirstResponder];
}

#pragma mark - JXCategoryListContentViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    self.selectIndex = index;
    
    CMPOcrDefaultInvoiceCategoryModel *m = [self.categoryModels objectAtIndex:index];
    m.packageID = _package.pid;
    //ext=1默认票夹页面跳转
    CMPOcrInvoiceListViewController * list = [[CMPOcrInvoiceListViewController alloc] initWithCategoryModel:m ext:@1 canEdit:YES fromForm:[self.ext integerValue] == 3];
    list.delegate = self;
    
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
    //收起键盘
    list.ScrollViewWillBeginDraggingBlock = ^{
        [weakSelf.view endEditing:YES];
    };
    
    list.formInvoiceIdList = _formInvoiceIdList;
    
    [list setSelectedModels:self.selectedModels];

    [self.listVcDict setValue:list forKey:m.modelID];
    
    return (id<JXCategoryListContentViewDelegate>)list;
}
#pragma mark 点击切换item
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
    self.selectIndex = index;
    
    [self.searchBar resignFirstResponder];
    [self searchCategoryList:self.searchBar.text];
    
    CMPOcrInvoiceListViewController * list = [self currentListVC];
    [list setSelectedModels:self.selectedModels];//更新选中状态
    
}

#pragma mark - CMPOcrInvoiceListViewController Delegate
// 选中
- (void)invoiceListViewController:(CMPOcrInvoiceListViewController *)listVC selectedItem:(NSArray *)models {
    NSMutableArray *invoiceIdArr = [NSMutableArray new];
    [self.selectedModels enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [invoiceIdArr addObject:obj.invoiceID];
    }];
    for (CMPOcrInvoiceItemModel *item in models) {
        if (![invoiceIdArr containsObject:item.invoiceID]) {
            [self.selectedModels addObject:item];
        }
    }
    [self updateBottomSelectStatus];
}

//取消选中
- (void)invoiceListViewController:(CMPOcrInvoiceListViewController *)listVC deselectedItem:(NSArray *)models {
    NSMutableArray *remove = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *item in models) {
        for (CMPOcrInvoiceItemModel *select in self.selectedModels) {
            if ([select.invoiceID isEqual:item.invoiceID]) {
                [remove addObject:select];
            }
        }
    }
    [self.selectedModels removeObjectsInArray:remove];
    [self updateBottomSelectStatus];
}

- (void)updateBottomSelectStatus {
    double money = 0.0;
    for (CMPOcrInvoiceItemModel *item in self.selectedModels) {
        money += item.total.doubleValue;
    }
    [self.selectBottomView setInvoiceNumber:self.selectedModels.count money:money];
    
//    CMPOcrInvoiceListViewController * list = [self currentListVC];
//    [list setSelectedModels:self.selectedModels];
}

//更新分类数据
- (void)updateCategoryWithDict:(NSArray *)modelDictArr{
    CMPOcrDefaultInvoiceCategoryModel *currentCate = self.categoryModels[self.selectIndex];
    NSInteger lastSelectIndex = self.selectIndex;
    
    NSMutableArray *tmp = [NSMutableArray new];
    NSMutableArray *titles = [NSMutableArray new];
    if ([modelDictArr isKindOfClass:NSArray.class]) {
        for (NSDictionary *dict in modelDictArr) {
            if ([dict isKindOfClass:NSDictionary.class]) {
                CMPOcrDefaultInvoiceCategoryModel *cate = [CMPOcrDefaultInvoiceCategoryModel yy_modelWithDictionary:dict];
                [tmp addObject:cate];
                [titles addObject:cate.modelName];
            }
        }
    }
    
    CMPOcrDefaultInvoiceCategoryModel *model = [CMPOcrDefaultInvoiceCategoryModel new];
    model.modelName = @"全部";
    model.modelID = @"-1";
    [tmp insertObject:model atIndex:0];
    [titles insertObject:@"全部" atIndex:0];
        
    self.categoryModels = tmp;
    self.categoryView.titles = titles;
    
    [self.categoryView reloadDataWithoutListContainer];
    
    
    self.selectIndex = 0;
    for (int i=0; i<tmp.count; i++) {
        CMPOcrDefaultInvoiceCategoryModel *cate = tmp[i];
        if ([cate.modelID isEqualToString:currentCate.modelID]) {
            self.selectIndex = i;//如果有变化
            break;
        }
    }
    if (lastSelectIndex != self.selectIndex) {
        [self.categoryView reloadData];
//        [self.categoryView selectItemAtIndex:self.selectIndex];
    }
    
}

#pragma mark - CMPOcrInvoiceSelectBottomViewDelegate

//更多
- (void)invoiceSelectBottomViewMore {
    __weak typeof(self) weakSelf = self;
    CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:@[@"唤醒PC",@"移动到",@"批量删除"] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {//pc唤醒
            [weakSelf wakeUpPC];
        }else if (buttonIndex == 2){//移动到
            [weakSelf moveToPackage];
        }else if (buttonIndex == 3){//删除
            [weakSelf deleteInvoiceList];
        }
    }];
    [actionSheet show];
}
//继续添加发票
- (void)addInvoiceAction{
    __weak typeof(self) weakSelf = self;
    [self.pickFileTool showSheetForPickToVC:weakSelf Completion:^(NSArray<CMPOcrFileModel *> *fileArray) {
        CMPOcrPackageModel *package = [CMPOcrPackageModel new];
        package.pid = weakSelf.package.pid;
        package.name = weakSelf.package.name;
        CMPOcrUploadManageViewController *vc = [[CMPOcrUploadManageViewController alloc]initWithFileArray:fileArray package:package ext:@2];
        dispatch_after(0.2, dispatch_get_main_queue(), ^{
            //等手机文件页面pop返回后再跳转
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
}

//唤醒PC
- (void)wakeUpPC{
    if (self.selectedModels.count<=0) {
        [self cmp_showHUDWithText:@"请选择发票"];
        return;
    }
    if (![CMPCore sharedInstance].isUcOnline) {
        [self cmp_showHUDWithText:@"唤醒失败，PC端致信未登录！"];
        return;
    }
    NSMutableArray *invoiceIdArr = [NSMutableArray new];
    [self.selectedModels enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.invoiceID) {
            [invoiceIdArr addObject:@(obj.invoiceID.longLongValue)];
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    void(^blk)(CMPOcrModuleItemModel *) = ^(CMPOcrModuleItemModel *module){
        
        [self.mainDataProvider checkPackageIfCanCommitWithInvoiceIds:invoiceIdArr templateId:module.templateId formId:module.formId completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull extInfo) {
            if (!error) {
                
                [weakSelf.reimburseManager ks_reimbursementWithData:respData templateId:module.templateId formId:module.formId packageId:nil summaryId:nil fromVC:weakSelf cancelBlock:nil actBlock:^(NSArray *invoiceIds, NSError *err, id ext, NSInteger from) {
                    if (from == 1 && !err && invoiceIds && [invoiceIds isKindOfClass:NSArray.class]) {
                        [weakSelf.mainDataProvider checkWakeUpIfCanCommitWithInvoiceIdList:invoiceIds completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                            if (!error) {
                                NSString *sourceId = ext[@"data"];
                                //唤起pc
                                [weakSelf.mainDataProvider wakeupPC:@{
                                    @"templateId":module.templateId?:@"",
                                    @"formId":module.formId?:@"",
                                    @"sourceId":sourceId?:@"",
                                } completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                                    if (error) {
                                        [weakSelf cmp_showHUDError:error];
                                    }else{
                                        NSString *msg = ext[@"message"];
                                        [weakSelf cmp_showHUDWithText:msg.length?msg:@"唤醒成功，请前往PC端查看～"];
                                    }
                                }];
                            }else{
                                [weakSelf cmp_showHUDError:error];
                            }
                        }];
                    }
                } ext:weakSelf.ext];

            }else{
                [weakSelf cmp_showHUDError:error];
            }
        }];
    };
    
    if ([self.ext integerValue] == 3) {//来自表单
        CMPOcrModuleItemModel *module = [CMPOcrModuleItemModel new];
        module.formId = self.formData[@"formId"];
        module.templateId = self.formData[@"templateId"];
        blk(module);
    }else{
        if (self.package.type == 1) {//默认票夹
            CMPOcrFormPickViewController *pickVC = [[CMPOcrFormPickViewController alloc] initWithCompletion:^(CMPOcrModuleItemModel *module) {
                blk(module);
            }];
            [pickVC showTargetVC:self];
        }else{
            CMPOcrModuleItemModel *module = [CMPOcrModuleItemModel new];
            module.formId = self.package.formId;
            module.templateId = self.package.templateId;
            blk(module);
        }
    }
}
//移动到->包
- (void)moveToPackage{
    if (self.selectedModels.count<=0) {
        [self cmp_showHUDWithText:@"请选择发票"];
        return;
    }
    NSMutableArray *invoiceIdArray = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *model in self.selectedModels) {
        if (model.invoiceID) {
            [invoiceIdArray addObject:model.invoiceID];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    CMPOcrInvoiceFolderViewController *alert = [[CMPOcrInvoiceFolderViewController alloc] initWithInvoiceArr:invoiceIdArray selectdPackageId:_package.pid completion:^(NSArray *invoiceIdArr){
        
        CMPOcrInvoiceListViewController * list = [weakSelf currentListVC];
        if (invoiceIdArray.count == [list getTotalCountOfItem]) {
            [weakSelf reReqData];
        }else{
            [list reloadInvoiceListWithRemoved:weakSelf.selectedModels];
        }
        [weakSelf.selectedModels removeAllObjects];
        [weakSelf updateBottomSelectStatus];
        
    }];
    [alert showTargetVC:self];
}
//批量删除发票
- (void)deleteInvoiceList{
    if (self.selectedModels.count<=0) {
        [self cmp_showHUDWithText:@"请选择发票"];
        return;
    }
    NSMutableArray *invoiceIdArray = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *model in self.selectedModels) {
        if (model.invoiceID) {
            [invoiceIdArray addObject:model.invoiceID];
        }
    }
    NSString *tipStr = [NSString stringWithFormat:@"删除后不可恢复，确定删除所选（%ld张）票据？",self.selectedModels.count];
    CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:nil message:tipStr cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        if(buttonIndex == 1){
            weakify(self);
            [self.deleteDataProvider deleteInvoiceListByArr:invoiceIdArray completion:^(NSError *error) {
                strongify(self);
                if (error) {
                    [self cmp_showHUDError:error];
                }else{
                    [self cmp_showHUDWithText:@"删除成功"];
                    CMPOcrInvoiceListViewController * list = [self currentListVC];
                    if (invoiceIdArray.count == [list getTotalCountOfItem]) {
                        [self reReqData];
                    }else{
                        [list reloadInvoiceListWithRemoved:self.selectedModels];
                    }
                    [self.selectedModels removeAllObjects];
                    [self updateBottomSelectStatus];
                }
            }];
        }
    }];
    [alert show];
}

//显示已选发票
- (void)invoiceSelectBottomViewShowInfo {
    [self showSelectAlert:self.selectedModels];
}

#pragma mark - 一键报销
- (void)invoiceSelectBottomViewReimburse{
    if (self.selectedModels.count <= 0) {
        [self cmp_showHUDWithText:@"请选择发票"];
        return;
    }
    NSMutableArray *invoiceIdArray = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *model in self.selectedModels) {
        if (model.invoiceID) {
            [invoiceIdArray addObject:@(model.invoiceID.longLongValue)];
        }
    }
    
    //发起一键报销
    if ([self.ext integerValue] == 3) {//来自表单
        CMPOcrModuleItemModel *module = [CMPOcrModuleItemModel new];
        module.formId = self.formData[@"formId"];
        module.templateId = self.formData[@"templateId"];
        [self reimburseActionWithInvoiceArr:invoiceIdArray module:module];
    }else{
        if (self.package.type == 1) {//默认票夹
            __weak typeof(self) weakSelf = self;
            CMPOcrFormPickViewController *pickVC = [[CMPOcrFormPickViewController alloc]initWithCompletion:^(CMPOcrModuleItemModel *module) {
                [weakSelf reimburseActionWithInvoiceArr:invoiceIdArray module:module];
            }];
            [pickVC showTargetVC:self];
        }else{
            CMPOcrModuleItemModel *module = [CMPOcrModuleItemModel new];
            module.formId = self.package.formId;
            module.templateId = self.package.templateId;
            [self reimburseActionWithInvoiceArr:invoiceIdArray module:module];
        }
    }
    
}

//一键报销check
- (void)reimburseActionWithInvoiceArr:(NSArray *)invoiceIdArray module:(CMPOcrModuleItemModel *)module{
    __weak typeof(self) weakSelf = self;
    [self.mainDataProvider checkPackageIfCanCommitWithInvoiceIds:invoiceIdArray templateId:module.templateId formId:module.formId completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull extInfo) {
        if (!error) {
            [weakSelf.reimburseManager reimbursementWithData:respData templateId:module.templateId formId:module.formId packageId:nil summaryId:nil fromVC:weakSelf cancelBlock:nil deleteBlock:nil ext:weakSelf.ext];
        }else{
            [weakSelf cmp_showHUDError:error];
        }
    }];
}
//显示选中发票
- (void)showSelectAlert:(NSArray *)models {
    if (models.count<=0) {
        return;
    }
    CMPOcrInvoiceSelectedAlertView *alert = [[CMPOcrInvoiceSelectedAlertView alloc] initWithFrame:CGRectMake(0, 0, kScreenBounds.size.width, kScreenHeight)];
    [kKeyWindow addSubview:alert];
    [alert show:models];
    __weak typeof(self) weakSelf = self;
    [alert setDeleteCompletion:^(CMPOcrInvoiceItemModel * _Nullable item) {
        NSMutableArray *removes = [NSMutableArray new];
        [removes addObject:item];
        [weakSelf.selectedModels removeObjectsInArray:removes];
        CMPOcrInvoiceListViewController * list = [weakSelf currentListVC];
        [list setSelectedModels:weakSelf.selectedModels];
        [weakSelf updateBottomSelectStatus];
    }];
}
//显示红点
- (void)showRedPoint:(BOOL)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        //先删除
        [self.aiCheckBtn.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == 110000) {
                [obj removeFromSuperview];
                *stop = YES;
            }
        }];
        if (show) {
            CGFloat w = 10;
            UIView *redPoint = [UIView new];
            redPoint.backgroundColor = UIColor.redColor;
            redPoint.layer.cornerRadius = w/2.f;
            redPoint.tag = 110000;
            [self.aiCheckBtn addSubview:redPoint];
            [redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(w/2);
                make.right.mas_equalTo(-w/2);
                make.width.height.mas_equalTo(w);
            }];
        }
    });
}

#pragma mark - Lazy
- (NSMutableArray *)selectedModels {
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedModels;
}

- (NSMutableArray *)categoryModels {
    if (!_categoryModels) {
        _categoryModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _categoryModels;
}

- (CMPOcrReimbursementManager *)reimburseManager{
    if (!_reimburseManager) {
        _reimburseManager = [CMPOcrReimbursementManager new];
    }
    return _reimburseManager;
}
- (CMPOcrPickFileTool *)pickFileTool{
    if (!_pickFileTool) {
        _pickFileTool = [CMPOcrPickFileTool new];
    }
    return _pickFileTool;
}

- (CMPOcrMainViewDataProvider *)mainDataProvider{
    if (!_mainDataProvider) {
        _mainDataProvider = [CMPOcrMainViewDataProvider new];
    }
    return _mainDataProvider;
}
- (NSMutableDictionary *)listVcDict{
    if (!_listVcDict) {
        _listVcDict = [NSMutableDictionary new];
    }
    return _listVcDict;
}

- (CMPOcrDeleteInvoiceDataProvider *)deleteDataProvider{
    if (!_deleteDataProvider) {
        _deleteDataProvider = [CMPOcrDeleteInvoiceDataProvider new];
    }
    return _deleteDataProvider;
}
@end
