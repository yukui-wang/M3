//
//  CMPOcrMyPackageListController.m
//  M3
//
//  Created by Shoujian Rao on 2022/7/23.
//

#import "CMPOcrMyPackageListController.h"
#import <CMPLib/JXCategoryView.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPBannerWebViewController.h>

#import "CMPOcrInvoiceListMyController.h"
#import "CustomCircleSearchBar.h"
#import "CMPOcrNotificationKey.h"

#import "CMPOcrPackageModel.h"
#import "CMPOcrDefaultInvoiceDataProvider.h"

@interface CMPOcrMyPackageListController ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, UISearchBarDelegate>
// 分类列表
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
// 已选择列表
@property (nonatomic, strong) NSMutableArray *selectedModels;
// 分类列表
@property (nonatomic, strong) NSMutableArray *categoryModels;
//搜索框
//@property (nonatomic, strong) UISearchBar    *searchBar;
@property (nonatomic, strong) CustomCircleSearchBar *searchBar;
//选中下标
@property (nonatomic, assign) NSInteger       selectIndex;
//list子页面
@property (nonatomic, strong) NSMutableDictionary *listVcDict;//<modelID:listvc>
//全局选中发票
@property (nonatomic, strong) NSMutableArray *allListArray;

@property (nonatomic, strong) id ext;

@property (nonatomic, strong) CMPOcrPackageModel *package;
@property (nonatomic, strong) CMPOcrDefaultInvoiceDataProvider *dataProvider;

@property (nonatomic, strong) NSMutableArray *totalArray;
@property (nonatomic, copy) NSString *condition;

@end

@implementation CMPOcrMyPackageListController


- (instancetype)initWithPackage:(CMPOcrPackageModel *)package ext:(id)ext{
    if (self = [super init]) {
        _package = package;
        _ext = ext;
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _package.name;
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"gray-bgc"];
    [self setupStatusBarViewBackground:UIColor.whiteColor];
    [self.bannerNavigationBar hideBottomLine:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEdit)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self setupSearchBar];
    [self setupCategory];//ui
    [self fetchCategoryList];//分类数据
    
    [self fetchDefaultListMy];//获取票据数据
}

- (void)endEdit{
    [self.view endEditing:YES];
}

- (void)setupSearchBar {
    CGFloat top = CGRectGetMaxY(self.bannerNavigationBar.frame);
    CGFloat searchW = kCMPOcrScreenWidth;
    CustomCircleSearchBar *search = [[CustomCircleSearchBar alloc]initWithPlaceholder:@"输入发票类型或金额" size:CGSizeMake(searchW, 44)];
    search.frame = CGRectMake(0, top, searchW, 44);
    [self.view addSubview:search];
    search.delegate = self;
    self.searchBar = search;
}

- (void)setupCategory {
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
    
    CGFloat containerHeight = self.view.height - self.categoryView.bottom;// - IKBottomSafeEdge;
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.frame = CGRectMake(0, self.categoryView.bottom, kCMPOcrScreenWidth, containerHeight);
    self.listContainerView.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.listContainerView];
    
    self.categoryView.listContainer = self.listContainerView;
}

#pragma mark - data
- (void)fetchCategoryList {
    //归纳获取到的全部数据，按分类计算个数
    [self.categoryModels removeAllObjects];
    NSMutableArray *titles = [[NSMutableArray alloc] init];

    CMPOcrDefaultInvoiceCategoryModel *model = [CMPOcrDefaultInvoiceCategoryModel new];
    model.modelID = @"1";
    model.modelName = @"全部";
    CMPOcrDefaultInvoiceCategoryModel *model1 = [CMPOcrDefaultInvoiceCategoryModel new];
    model1.modelID = @"2";
    model1.modelName = @"报销中";
    CMPOcrDefaultInvoiceCategoryModel *model2 = [CMPOcrDefaultInvoiceCategoryModel new];
    model2.modelID = @"3";
    model2.modelName = @"已报销";
    
    [self.categoryModels addObject:model];
    [self.categoryModels addObject:model1];
    [self.categoryModels addObject:model2];
    
    [titles addObject:model.modelName];
    [titles addObject:model1.modelName];
    [titles addObject:model2.modelName];
    
    self.categoryView.titles = titles;
    [self.categoryView reloadData];
}

#pragma mark - 搜索
- (void)searchCategoryList:(NSString *)keyword{
    self.searchBar.lastSearchText = keyword;
    _condition = keyword;
    [self fetchDefaultListMy];
}

#pragma mark - 获取数据
- (void)fetchDefaultListMy{
    NSString *modelId = nil;
    NSArray *statusArr = @[@2,@3];
    NSString *packageId = _package.pid;
    
    weakify(self);
    [self.dataProvider fetchInvoiceListAndTipsWithPackageId:packageId modleId:modelId condition:_condition total:nil status:statusArr success:^(NSDictionary * _Nonnull data) {
        strongify(self);
        [self.totalArray removeAllObjects];
        
        //好的发票
        NSArray *arrayOK = data[@"data"][@"invoiceList"][@"okList"];
        NSArray *totalArr = [self getInvoiceGroupListFrom:arrayOK packageId:packageId status:0];//全部
        NSArray *reimbursingArr = [self getInvoiceGroupListFrom:arrayOK packageId:packageId status:2];//报销中
        NSArray *reimbursedArr = [self getInvoiceGroupListFrom:arrayOK packageId:packageId status:3];//已报销
        
        for (CMPOcrDefaultInvoiceCategoryModel *cate in self.categoryModels) {
            if ([cate.modelName containsString:@"全部"]) {
                cate.invoiceGroupArray = totalArr;
            }else if ([cate.modelName containsString:@"报销中"]) {
                cate.invoiceGroupArray = reimbursingArr;
            }else if ([cate.modelName containsString:@"已报销"]) {
                cate.invoiceGroupArray = reimbursedArr;
            }
        }
        
        CMPOcrDefaultInvoiceCategoryModel *cate = self.categoryModels[self.selectIndex];
        CMPOcrInvoiceListMyController *list = (CMPOcrInvoiceListMyController *)[self.listVcDict objectForKey:cate.modelID];
        list.datas = cate.invoiceGroupArray;
        
        //更新UI
//        if (self.selectIndex == 0) {
            [self updateCategoryUI];
//        }
        
    } fail:^(NSError * _Nonnull error) {
        strongify(self);
        [self cmp_showHUDError:error];
    }];
}

- (NSArray *)getInvoiceGroupListFrom:(NSArray *)dictArray packageId:(NSString *)packageId status:(NSInteger)status{
    if ([dictArray isKindOfClass:[NSArray class]] && dictArray.count) {
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        
        for (NSDictionary *dic in dictArray) {
            CMPOcrInvoiceModel *model = [CMPOcrInvoiceModel yy_modelWithDictionary:dic];
            if (status == model.mainInvoice.status || status == 0) {
                model.mainInvoice.rPackageId = packageId;
                
                NSString *key = model.mainInvoice.createDate?:@"";//key
                NSMutableArray *invoiceList = [NSMutableArray arrayWithArray:[mDict objectForKey:key]];//value list
                [invoiceList addObject:model.mainInvoice];
                [invoiceList addObjectsFromArray:model.deputyInvoiceList];
                
                [mDict setObject:invoiceList forKey:key];
            }
        }
        if (mDict.allKeys.count) {
            NSMutableArray<CMPOcrInvoiceGroupListModel *> *resultArray = [NSMutableArray new];
            for (NSString *key in mDict.allKeys) {
                NSArray *valueList = [mDict objectForKey:key];
                CMPOcrInvoiceGroupListModel *model = CMPOcrInvoiceGroupListModel.new;
                model.uploadDate = key;
                model.invoiceItemArray = valueList;
                [resultArray addObject:model];
            }
            //倒序
            NSArray *sortedArr = [resultArray sortedArrayUsingComparator:^NSComparisonResult(CMPOcrInvoiceGroupListModel *obj1, CMPOcrInvoiceGroupListModel *obj2) {
                return [obj2.uploadDate compare:obj1.uploadDate];
            }];
            return sortedArr;
        }
    }
    return nil;
}

- (void)updateCategoryUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *titles = [NSMutableArray new];
        for (CMPOcrDefaultInvoiceCategoryModel *categoryModel in self.categoryModels) {
            if ([categoryModel.modelName containsString:@"全部"]) {
                if (categoryModel.invoiceCount > 0) {
                    categoryModel.modelName = [NSString stringWithFormat:@"全部(%ld)",categoryModel.invoiceCount];
                }else{
                    categoryModel.modelName = @"全部";
                }
            }else if ([categoryModel.modelName containsString:@"报销中"]) {
                if (categoryModel.invoiceCount > 0) {
                    categoryModel.modelName = [NSString stringWithFormat:@"报销中(%ld)",categoryModel.invoiceCount];
                }else{
                    categoryModel.modelName = @"报销中";
                }
            }else if ([categoryModel.modelName containsString:@"已报销"]) {
                if (categoryModel.invoiceCount > 0) {
                    categoryModel.modelName = [NSString stringWithFormat:@"已报销(%ld)",categoryModel.invoiceCount];
                }else{
                    categoryModel.modelName = @"已报销";
                }
            }
            [titles addObject:categoryModel.modelName];
        }
        self.categoryView.titles = titles;
        [self.categoryView reloadDataWithoutListContainer];
    });
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
    CMPOcrInvoiceListMyController * list = [CMPOcrInvoiceListMyController new];
    
    __weak typeof(self) weakSelf = self;
    //收起键盘
    list.ScrollViewWillBeginDraggingBlock = ^{
        [weakSelf.view endEditing:YES];
    };
    //刷新
    list.RefreshActionBlock = ^{
        [weakSelf fetchDefaultListMy];
    };
    
    [self.listVcDict setValue:list forKey:m.modelID];

    return (id<JXCategoryListContentViewDelegate>)list;
}

#pragma mark 点击切换item
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.selectIndex = index;
    [self.searchBar resignFirstResponder];
    
    CMPOcrDefaultInvoiceCategoryModel *cate = self.categoryModels[self.selectIndex];
    CMPOcrInvoiceListMyController *list = (CMPOcrInvoiceListMyController *)[self.listVcDict objectForKey:cate.modelID];
    list.datas = cate.invoiceGroupArray;
}

#pragma mark - Lazy
- (NSMutableArray *)categoryModels {
    if (!_categoryModels) {
        _categoryModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _categoryModels;
}

- (CMPOcrDefaultInvoiceDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrDefaultInvoiceDataProvider alloc] init];
    }
    return _dataProvider;
}

- (NSMutableArray *)totalArray{
    if (!_totalArray) {
        _totalArray = [NSMutableArray new];
    }
    return _totalArray;
}

- (NSMutableDictionary *)listVcDict{
    if (!_listVcDict) {
        _listVcDict = [NSMutableDictionary new];
    }
    return _listVcDict;
}

@end
