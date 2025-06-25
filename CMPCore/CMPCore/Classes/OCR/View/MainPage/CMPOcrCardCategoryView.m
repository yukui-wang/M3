//
//  CMPOcrCardCategoryView.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/25.
//

#import "CMPOcrCardCategoryView.h"
#import <CMPLib/JXCategoryView.h>
#import <CMPLib/JXPagerView.h>
#import "CMPOcrCardMainListView.h"
#import <CMPLib/CMPBannerViewController.h>
#import "CMPOcrInvoiceCategoryEditViewController.h"
#import "JXPagerView+CMP.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import <CMPLib/MJRefresh.h>

#import "CMPOcrMainViewController.h"
#import "CMPOcrTipTool.h"

static const CGFloat JXheightForHeaderInSection = 50;

@interface CMPOcrCardCategoryView()<JXCategoryViewDelegate,JXPagerViewDelegate,JXCategoryTitleViewDataSource>
{
    UIButton *_editBtn;
}
@property (nonatomic, strong) JXPagerView *pagingView;
@property (nonatomic,strong) JXCategoryTitleView *categoryTitleView;
@property (nonatomic,strong) JXCategoryListContainerView *listContainerView;
@property(nonatomic,weak) UIView *headerView;
@property (nonatomic, copy) void(^refreshEndBlock)(void);

@end

@implementation CMPOcrCardCategoryView

-(instancetype)initWithHeaderView:(UIView *)headerView
{
    if (self = [super init]) {
        _headerView = headerView;
        [_pagingView refreshTableHeaderView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.pagingView.frame = self.bounds;
}

- (void)setHeaderOffset:(CGFloat)offset{
    _pagingView.pinSectionHeaderVerticalOffset = offset;
}

- (void)setMainTableBackgroundColor:(UIColor *)color{
    _pagingView.mainTableView.backgroundColor = color;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup{
    [super setup];
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    //标题tab
    _categoryTitleView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-50, JXheightForHeaderInSection)];
    _categoryTitleView.delegate = self;
    _categoryTitleView.titleColorGradientEnabled = YES;
    _categoryTitleView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    _categoryTitleView.titleSelectedColor = [UIColor cmp_specColorWithName:@"main-fc"];
    _categoryTitleView.titleColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    _categoryTitleView.titleFont = [UIFont systemFontOfSize:15 weight:(UIFontWeightRegular)];
    _categoryTitleView.titleSelectedFont = [UIFont systemFontOfSize:15 weight:(UIFontWeightMedium)];
    _categoryTitleView.averageCellSpacingEnabled = NO;
//    _categoryTitleView.titleDataSource = self;
    
    //标题tab indicator
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = [[UIColor cmp_specColorWithName:@"theme-bdc"] colorWithAlphaComponent:0.5];
    lineView.indicatorWidth = JXCategoryViewAutomaticDimension;
    lineView.indicatorWidthIncrement = 3;
    lineView.indicatorHeight = 6.f;
    lineView.indicatorCornerRadius = 3.f;
    lineView.verticalMargin = 15;
    
    _categoryTitleView.indicators = @[lineView];
    
    //tab page内容
    _pagingView = [[JXPagerView alloc] initWithDelegate:self];
    _pagingView.isListHorizontalScrollEnabled = NO;
    _pagingView.pinSectionHeaderVerticalOffset = 72;
    if (@available(iOS 15.0, *)) {
        _pagingView.mainTableView.sectionHeaderTopPadding = 0;
    }
    _pagingView.listContainerView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self addSubview:_pagingView];
    //tab page内容关联
    _categoryTitleView.listContainer = (id<JXCategoryViewListContainer>)_pagingView.listContainerView;
    self.viewController.navigationController.interactivePopGestureRecognizer.enabled = (_categoryTitleView.selectedIndex == 0);//第一个tab允许返回手势
    _pagingView.mainTableView.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    
    //首页刷新
    __weak typeof(self) weakSelf = self;
    _refreshEndBlock = ^{
        [weakSelf.pagingView.mainTableView.mj_header endRefreshing];
    };
    _pagingView.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updatePackageList];
    }];
    
    //分类编辑按钮
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _editBtn.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [_editBtn setImage:[UIImage imageNamed:@"ocr_card_control_edit"] forState:(UIControlStateNormal)];
    [_editBtn setBackgroundImage:[UIImage imageNamed:@"ocr_card_control_edit_bg"] forState:(UIControlStateNormal)];
    [_editBtn addTarget:self action:@selector(editAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_categoryTitleView addSubview:_editBtn];
    _editBtn.frame = CGRectMake(screenWidth-50,0, 50, 50);
    
    _categoryTitleView.contentEdgeInsetRight = 70;//右边
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_commonModulesSelect:) name:@"kNotificationName_ocrModulesDidSelect" object:nil];
    
    

}

- (void)editAction{
    NSLog(@"editAction");
    CMPOcrInvoiceCategoryEditViewController *vc = CMPOcrInvoiceCategoryEditViewController.new;
    vc.history = self.viewModel.isHistory;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.viewController.rdv_tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.viewController.rdv_tabBarController.providesPresentationContextTransitionStyle = YES;
    self.viewController.rdv_tabBarController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.viewController.rdv_tabBarController.definesPresentationContext = YES;
    [self.viewController.rdv_tabBarController presentViewController:vc animated:NO completion:^{
//        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }];
    
}

#pragma mark - JXPagingViewDelegate

- (UIView *)tableHeaderViewInPagerView:(JXPagerView *)pagerView {
    return self.headerView;
}

- (NSUInteger)tableHeaderViewHeightInPagerView:(JXPagerView *)pagerView {
    return self.headerView.bounds.size.height;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return JXheightForHeaderInSection;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return _categoryTitleView;
}

- (NSInteger)numberOfListsInPagerView:(JXPagerView *)pagerView {
    return _categoryTitleView.titles.count;
}

- (id<JXPagerViewListViewDelegate>)pagerView:(JXPagerView *)pagerView initListAtIndex:(NSInteger)index {
    CMPOcrCardMainListView *listView = [CMPOcrCardMainListView new];
    listView.fromPage = self.fromPage;
    listView.viewController = self.viewController;
    CMPOcrModuleItemModel *item = _viewModel.modulesArr[index];
    listView.conditionId = item.oid;
    __weak typeof(self) weakSelf = self;
    listView.DidSelectRow = ^(NSInteger row) {

    };
    listView.actBlk = ^(NSInteger act, id ext, UIViewController *controller) {
        switch (act) {
            case 1://删除成功
            {
                if (!weakSelf.viewModel) {
                    return;
                }
                [weakSelf.viewModel refreshCurrentPackageList];
            }
                break;

            default:
                break;
        }
    };
    return listView;
}

- (void)pagerView:(JXPagerView *)pagerView mainTableViewDidScroll:(UIScrollView *)scrollView{
//    if ([_headerView respondsToSelector:@selector(scrollViewDidScroll:)]) {
//        [_headerView scrollViewDidScroll:scrollView.contentOffset.y];
//    }
    CGFloat y = scrollView.contentOffset.y;
    if (_viewModel && !_viewModel.isHistory) {
        CMPBannerViewController *bannerVC = (CMPBannerViewController *)self.viewController;
        CGFloat alpha = y/290;
        UIColor *bgColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:alpha];
        [bannerVC setupStatusBarViewBackground:bgColor];
        bannerVC.bannerNavigationBar.backgroundColor = bgColor;
        
        self.viewController.title = y>200?@"首页":@"";
        
        CMPOcrMainViewController *vc = (CMPOcrMainViewController *)self.viewController;
        [vc changeBackIconToWhite:y<=200];
        
        
    }
}
#pragma mark - JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.viewController.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
    
    if (!_viewModel) {
        return;
    }
    self.viewModel.selectedModuleIndex = index;
    [self.viewModel refreshCurrentPackageList];
}


//-(CGFloat)categoryTitleView:(JXCategoryTitleView *)titleView widthForTitle:(NSString *)title
//{
//    NSString *ss = title;
//    if (title.length>7) {
//        ss = [title substringWithRange:NSMakeRange(0, 7)];
//    }
//    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
//    CGSize  size = [ss boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//    return size.width;
//}


-(void)updateCommonModules
{
    if (!_viewModel) {
        return;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (CMPOcrModuleItemModel *module in _viewModel.modulesArr) {
        [arr addObject:module.templateName];
    }

    _categoryTitleView.titles = arr;
    
    [_categoryTitleView reloadData];
    
    if (arr.count <= 0) {
        _editBtn.hidden = YES;
        [CMPOcrTipTool.new showNoMoudleMainPage:YES toView:_pagingView.listContainerView];
    }else{
        _editBtn.hidden = NO;
        [CMPOcrTipTool.new showNoMoudleMainPage:NO toView:_pagingView.listContainerView];
    }
    
}

-(void)updatePackageList
{
    if (!_viewModel) {
        return;
    }
    CMPOcrModuleItemModel *module = _viewModel.selectedModule;
    if (module) {
        CMPOcrCardMainListView *listView = (CMPOcrCardMainListView *)_pagingView.validListDict[@(_viewModel.selectedModuleIndex)];
        if (listView) {
            NSArray *data = _viewModel.packagesMap[module.oid];
            for (CMPOcrPackageModel *model in data) {
                model.isHistory = self.viewModel.isHistory;
            }
            [listView refreshData:data];
            
            if(self.refreshEndBlock){
                self.refreshEndBlock();
            }
            
            if (data.count>0) {
                listView.tableView.backgroundView = nil;
            }else{
                UIView *v = [[UIView alloc] init];
                v.backgroundColor = [UIColor clearColor];
                listView.tableView.backgroundView = v;
                if (!_viewModel.isHistory) {
                    //无报销包缺省提示
                    UIView *bgView = [UIView new];
                    [v addSubview:bgView];
                    bgView.layer.cornerRadius = 8;
                    bgView.backgroundColor = UIColor.whiteColor;
                    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(10);
                        make.left.mas_equalTo(14);
                        make.right.mas_equalTo(-14);
                        make.height.mas_equalTo(80);
                    }];
                    [self addFourSidesShadowToView:bgView withColor:UIColor.grayColor];//阴影
                    
                    UIImageView *igv = [[UIImageView alloc]init];
                    igv.backgroundColor = [UIColor cmp_specColorWithName:@"liactive-bgc"];
                    igv.image = [UIImage imageNamed:@"ocr_card_new_package"];
                    igv.contentMode = UIViewContentModeCenter;
                    [bgView addSubview:igv];
                    [igv mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(bgView.mas_centerY);
                        make.left.mas_equalTo(10);
                        make.width.height.mas_equalTo(48);
                    }];
                    igv.layer.cornerRadius = 4.f;
                    
                    UILabel *titleLabel = [[UILabel alloc]init];
                    titleLabel.text = @"新建报销包";
                    titleLabel.textColor = UIColor.blackColor;
                    titleLabel.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
                    [bgView addSubview:titleLabel];
                    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(bgView.mas_centerY);
                        make.left.mas_equalTo(igv.mas_right).offset(14);
                    }];
                    
                    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [bgView addSubview:addBtn];
                    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(bgView);
                    }];
                    [addBtn addTarget:self action:@selector(_packageAddAct:) forControlEvents:UIControlEventTouchUpInside];
                    
                }else{//历史列表缺省
                    [CMPOcrTipTool.new showNoMoudleDataView:YES toView:v];
                }
            }
        }
    }
}
//添加四边阴影效果
-(void)addFourSidesShadowToView:(UIView *)theView withColor:(UIColor*)theColor{
    //阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    //阴影偏移
    theView.layer.shadowOffset = CGSizeMake(0, 0 );
    //阴影透明度，默认0
    theView.layer.shadowOpacity = 0.1;
    //阴影半径，默认3
    theView.layer.shadowRadius = 3;
}

-(void)_commonModulesSelect:(NSNotification *)noti
{
    NSNumber *obj = noti.object;
    if (obj.integerValue == self.viewModel.selectedModuleIndex) {
        return;
    }
    [_categoryTitleView selectCellAtIndex:obj.integerValue selectedType:JXCategoryCellSelectedTypeCode];
}

-(void)_packageAddAct:(UIButton *)btn
{
    if (!_viewModel) {
        return;
    }
    CMPOcrModuleItemModel *module = _viewModel.selectedModule;
    if (module) {
        CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
        NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/createOcr.html";
        NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
        if ([NSString isNotNull:localHref]) {
            href = localHref;
        }
        href = [href urlCFEncoded];
//        href = [NSString stringWithFormat:@"%@?templateId=%@&formId=%@",href,module.templateId,module.formId];
        href = [NSString stringWithFormat:@"%@?conditionId=%@",href,module.oid];
        webCtrl.hideBannerNavBar = NO;
        webCtrl.startPage = href;
        webCtrl.viewWillClose = ^{

        };
        [self.viewController presentViewController:webCtrl animated:YES completion:^{}];
    }
}

-(void)selectModulesIndex:(NSInteger)selectIndex
{
    if (_categoryTitleView) {
        [_categoryTitleView selectItemAtIndex:selectIndex];
    }
}

@end
