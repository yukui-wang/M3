//
//  CMPOcrInvoiceListViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrInvoiceListViewController.h"
#import "CMPOcrInvoiceItemCell.h"
#import "CMPOcrInvoiceModel.h"
#import "CMPOcrInvoiceSelectedAlertView.h"
#import "CMPOcrInvoiceFolderViewController.h"
#import "CMPOcrInvoiceDetailViewController.h"
#import <CMPLib/Masonry.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import "CMPOcrDefaultInvoiceDataProvider.h"
#import "CMPOcrTipTool.h"
#import "UIView+Layer.h"
#import <CMPLib/MJRefresh.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrNotificationKey.h"
#import "CMPOcrPackageModel.h"

#import "CMPCustomLeftSwipeTableView.h"
@interface CMPOcrInvoiceListViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, CMPOcrInvoiceNewItemCellDelegate>

@property (nonatomic, strong) CMPCustomLeftSwipeTableView *chatTableView;

@property (nonatomic, assign) NSInteger selectCount;

@property (nonatomic, strong) NSMutableArray<CMPOcrInvoiceGroupListModel *> *datas;

@property (nonatomic, strong) NSArray *selectItems;

@property (nonatomic, strong) CMPOcrDefaultInvoiceDataProvider *dataProvider;

@property (nonatomic, strong) NSString  *totalString;

@property (nonatomic, strong) id ext;//ext=1默认票夹,ext=2包详情
@property (nonatomic, assign) BOOL canEdit;

@property (nonatomic, assign) BOOL isFromForm;

@property (nonatomic, strong) dispatch_source_t sourceTimer;

@property (nonatomic, strong) UIButton *selectAllBtn;

@end

@implementation CMPOcrInvoiceListViewController

-(instancetype)initWithCategoryModel:(CMPOcrDefaultInvoiceCategoryModel *)categoryModel ext:(id)ext canEdit:(BOOL)canEdit fromForm:(BOOL)isFromForm{
    if (self = [super init]) {
        _categoryModel = categoryModel;
        _ext = ext;//ext=1默认票夹,ext=2包详情,ext=4我的
        _canEdit = canEdit;
        _isFromForm = isFromForm;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchDefaultList:nil];//ks fix --- V5-36166【智能报销】发票卡片上展示的验真状态与发票详情页展示的验真状态不一致
    [self startIntervalFetch];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    dispatch_source_cancel(_sourceTimer);
}
- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bannerNavigationBar.hidden = YES;
    [self setupStatusBarViewBackground:UIColor.clearColor];
    [self setupViews];
    
    self.chatTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchDefaultList:nil];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchDefaultList:) name:kNotificationOneReimbursementRemovedInvoice object:nil];
}

- (void)setupViews {
    [self.view addSubview:self.chatTableView];
    CGFloat bottomHeight = 0;
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-bottomHeight);
    }];
    
    UIView *coverView = UIView.new;
    coverView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    [self.view addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(10);
    }];
    
    //全选按钮
    if ([_ext integerValue] == 1) {
        _selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.view addSubview:_selectAllBtn];
        [_selectAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(9.5);
            make.top.mas_equalTo(5);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(36);
        }];
        _selectAllBtn.hidden = YES;
        [_selectAllBtn setTitle:@"全选" forState:(UIControlStateNormal)];
        _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_selectAllBtn setTitleColor:[UIColor cmp_specColorWithName:@"theme-bdc"] forState:(UIControlStateNormal)];
        [_selectAllBtn setImage:[UIImage imageNamed:@"ocr_card_batch_manage_uncheck"] forState:(UIControlStateNormal)];
        [_selectAllBtn setImage:[UIImage imageNamed:@"ocr_card_batch_manage_checked"] forState:(UIControlStateSelected)];
        [_selectAllBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        
        [_selectAllBtn addTarget:self action:@selector(selectAllBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    
}

- (void)setFormInvoiceIdList:(NSArray *)formInvoiceIdList{
    _formInvoiceIdList = formInvoiceIdList;
}
#pragma mark - 全选
- (void)selectAllBtnClick:(UIButton *)btn{
    NSMutableArray *invoiceArr = [NSMutableArray new];//所有发票
    [self.datas enumerateObjectsUsingBlock:^(CMPOcrInvoiceGroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [invoiceArr addObjectsFromArray:obj.invoiceItemArray];
    }];
    
    btn.selected = !btn.selected;
    
    BOOL select = btn.selected;
    if (invoiceArr.count > 0) {
        for (CMPOcrInvoiceItemModel *item in invoiceArr) {
            if (select) {
                item.isSelected = YES;
            }else {
                item.isSelected = NO;
            }
        }
        if (select) {
            if ([_delegate respondsToSelector:@selector(invoiceListViewController:selectedItem:)]) {
                [_delegate invoiceListViewController:self selectedItem:invoiceArr];
            }
            self.selectItems = invoiceArr;
        }else{
            if ([_delegate respondsToSelector:@selector(invoiceListViewController:deselectedItem:)]) {
                [_delegate invoiceListViewController:self deselectedItem:invoiceArr];
            }
            self.selectItems = @[];
        }
    }
    [self.chatTableView reloadData];
}
#pragma mark - timer
- (void)startIntervalFetch{
    //全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSTimeInterval delayTime = 0.0f;//延迟时间
    if (self.selectIndex > 0) {
        delayTime = 5.f;
    }
    NSTimeInterval timeInterval = 5.0f;//间隔时间
    //设置开始时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    //设置计时器
    dispatch_source_set_timer(_sourceTimer,startDelayTime,timeInterval*NSEC_PER_SEC,0.1*NSEC_PER_SEC);
    //执行事件
    dispatch_source_set_event_handler(_sourceTimer,^{
        //销毁定时器
        //dispatch_source_cancel(_myTimer);
        [self fetchDefaultList:nil];
    });
    dispatch_resume(_sourceTimer);//启动计时器
}

- (void)fetchDefaultList:(NSNotification *)notifi{
    if (notifi.object) {
        NSArray *deleteIdArr = notifi.object;
        NSMutableArray *removeRows = [NSMutableArray new];
        for (CMPOcrInvoiceItemModel *item in self.selectItems) {
            if ([deleteIdArr containsObject:item.invoiceID]) {
                [removeRows addObject:item];
            }
        }
        if ([self.delegate respondsToSelector:@selector(invoiceListViewController:deselectedItem:)]) {
            [self.delegate invoiceListViewController:self deselectedItem:removeRows];
        }
    }
    
    // 如果当前是全部分类，modelID传空
    NSString *modelId = _categoryModel.modelID;
    BOOL isSelectAll = NO;
    if (_isFromForm) {//表单页面才需要
        isSelectAll = YES;
    }
    if ([_categoryModel.modelName isEqualToString:@"全部"]) {
        modelId = nil;
    }
    NSString *packageId = _categoryModel.packageID;
    
    NSArray *statusArr = @[@0];
    
    weakify(self);
    [self.dataProvider fetchInvoiceListAndTipsWithPackageId:packageId modleId:modelId condition:_condition total:nil status:statusArr success:^(NSDictionary * _Nonnull data) {
        strongify(self);
        [self.datas removeAllObjects];        
        
        //提示信息(重复票、红点)
        CMPOcrPackageTipModel *tipModel = [CMPOcrPackageTipModel yy_modelWithDictionary:data[@"data"][@"tips"]];
        if (tipModel && self.ReturnTipModelBlock) {
            self.ReturnTipModelBlock(tipModel);
        }
        //polling轮询 - 0：不需要轮询了，已经没有识别任务了；1：需要继续轮询
        NSInteger polling = [data[@"data"][@"polling"] integerValue];
        if (polling == 0) {
            dispatch_source_cancel(self.sourceTimer);
        }
        
        //更新分类数据
        NSArray *modelList = data[@"data"][@"invoiceList"][@"modelList"];
        if ([self.delegate respondsToSelector:@selector(updateCategoryWithDict:)]) {
            [self.delegate updateCategoryWithDict:modelList];
        }
        
        NSMutableArray *totalInvoiceList = [NSMutableArray new];
        //信息不全的发票
        NSArray *arrayBad = data[@"data"][@"invoiceList"][@"badList"];
        if ([arrayBad isKindOfClass:[NSArray class]] && arrayBad.count) {
            NSMutableDictionary *mDict = [NSMutableDictionary new];
            for (NSDictionary *dic in arrayBad) {
                CMPOcrInvoiceModel *model = [CMPOcrInvoiceModel yy_modelWithDictionary:dic];
                model.mainInvoice.rPackageId = packageId;
                
                NSString *key = model.mainInvoice.createDate?:@"";//key
                NSMutableArray *invoiceList = [NSMutableArray arrayWithArray:[mDict objectForKey:key]];//value list
                [invoiceList addObject:model.mainInvoice];
                [invoiceList addObjectsFromArray:model.deputyInvoiceList];
                
                NSMutableArray *hideArr = [NSMutableArray new];
                for (CMPOcrInvoiceItemModel *item in invoiceList) {
                    //来自表单的数据，隐藏
                    if ([self.formInvoiceIdList containsObject:item.invoiceID]) {
                        [hideArr addObject:item];
                    }
                }
                
                [invoiceList removeObjectsInArray:hideArr];
                
                if (invoiceList.count) {
                    [totalInvoiceList addObjectsFromArray:invoiceList];
                    [mDict setObject:invoiceList forKey:key];
                }
            }
            
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
            
            [self.datas addObjectsFromArray:sortedArr];
        }
        //好的发票
        NSArray *arrayOK = data[@"data"][@"invoiceList"][@"okList"];
        if ([arrayOK isKindOfClass:[NSArray class]] && arrayOK.count) {
            NSMutableDictionary *mDict = [NSMutableDictionary new];
            for (NSDictionary *dic in arrayOK) {
                CMPOcrInvoiceModel *model = [CMPOcrInvoiceModel yy_modelWithDictionary:dic];
                model.mainInvoice.rPackageId = packageId;
                
                NSString *key = model.mainInvoice.createDate?:@"";//key
                NSMutableArray *invoiceList = [NSMutableArray arrayWithArray:[mDict objectForKey:key]];//value list
                
                [invoiceList addObject:model.mainInvoice];
                [invoiceList addObjectsFromArray:model.deputyInvoiceList];
                
                NSMutableArray *hideArr = [NSMutableArray new];
                for (CMPOcrInvoiceItemModel *item in invoiceList) {
                    //来自表单的数据，隐藏
                    if ([self.formInvoiceIdList containsObject:item.invoiceID]) {
                        [hideArr addObject:item];
                    }
                }
                
                [invoiceList removeObjectsInArray:hideArr];
                
                if (invoiceList.count) {
                    
                    [totalInvoiceList addObjectsFromArray:invoiceList];
                    [mDict setObject:invoiceList forKey:key];
                }
                
            }
            
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
            
            [self.datas addObjectsFromArray:sortedArr];
        }
        
        [self.chatTableView reloadData];
        
        [self updateTableViewSelectStatus];
        
        [self.chatTableView.mj_header endRefreshing];

        [CMPOcrTipTool.new showNoDataView:self.datas.count<=0 toView:self.view];
        
    } fail:^(NSError * _Nonnull error) {
        strongify(self);
        [self cmp_showHUDError:error];
        [self.chatTableView.mj_header endRefreshing];
        [CMPOcrTipTool.new showNoDataView:self.datas.count<=0 toView:self.view];
    }];
}

#pragma mark 搜索
- (void)searchInvoiceListByCondition:(NSString *)condition{
    self.condition = condition;
    [self fetchDefaultList:nil];
}

- (NSArray *)getInvoiceIdsByArr:(NSArray<CMPOcrInvoiceItemModel *> *)itemArr{
    NSMutableArray *tmp = [NSMutableArray new];
    [itemArr enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tmp addObject:obj.invoiceID];
    }];
    return tmp;
}

#pragma mark 切换刷新选中状态
- (void)setSelectedModels:(NSArray *)models {
    self.selectItems = models;
    [self updateTableViewSelectStatus];
}

- (void)updateTableViewSelectStatus {
    //选中状态
    NSMutableArray *selectInvoiceIds = [NSMutableArray new];
    [self.selectItems enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.invoiceID) {
            [selectInvoiceIds addObject:obj.invoiceID];
        }
    }];
    NSInteger selectCount = 0;
    NSInteger totalCount = 0;
    
    for (CMPOcrInvoiceGroupListModel *group in self.datas) {
        for (CMPOcrInvoiceItemModel *item in group.invoiceItemArray) {
            item.isSelected = NO;//如果selectItems为空，则全部取消选择
            if ([selectInvoiceIds containsObject:item.invoiceID]) {
                item.isSelected = YES;
                selectCount++;
            }
            totalCount++;
        }
    }

    [self.chatTableView reloadData];
    //全选按钮选中按钮的状态
    self.selectAllBtn.selected = totalCount == selectCount;
    self.selectAllBtn.hidden = totalCount == 0;
    
}

// 删除
- (void)deleteIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceGroupListModel *group = [self.datas objectAtIndex:indexPath.section];
    NSMutableArray *invoiceArray = [NSMutableArray arrayWithArray:group.invoiceItemArray];
    CMPOcrInvoiceItemModel *currentInvoiceItem = [invoiceArray objectAtIndex:indexPath.row];
    
    //删除提示
    NSString *tipStr = @"删除后不可恢复，确定删除该票据？";
    for (CMPOcrInvoiceItemModel *invoiceItem in invoiceArray) {
        if ([currentInvoiceItem.invoiceID isEqual:invoiceItem.relationInvoiceId]) {
            //存在副发票，提示副发票会一起删除
            tipStr = @"包内发票将一并删除哦，请确定是否删除？";
            break;
        }
    }
    CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"" message:tipStr cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] callback:^(NSInteger buttonIndex) {
        if(buttonIndex == 1){
            weakify(self);
            [self.dataProvider deleteInvoiceWithInvoiceID:currentInvoiceItem.invoiceID success:^(NSDictionary * _Nonnull data) {
                strongify(self);
                [self cmp_showHUDWithText:@"删除成功"];
                //删除主发票后 把相关关联发票也删掉,但不需要去请求数据，只需删本列表数据
                NSMutableArray *removeRows = [NSMutableArray new];
                [removeRows addObject:currentInvoiceItem];
                for (CMPOcrInvoiceItemModel *item in invoiceArray) {
                    if ([item.relationInvoiceId isEqual:currentInvoiceItem.invoiceID]) {
                        [removeRows addObject:item];
                    }
                }
                
                if ([self.delegate respondsToSelector:@selector(invoiceListViewController:deselectedItem:)]) {
                    [self.delegate invoiceListViewController:self deselectedItem:removeRows];
                }
                                
                [invoiceArray removeObjectsInArray:removeRows];
                group.invoiceItemArray = invoiceArray;
                if (invoiceArray.count <= 0) {
                    [self.datas removeObject:group];
                }
                
                if (self.datas.count == 0) {
                    [self fetchDefaultList:nil];//没有数据则刷新
                }else{
                    [self.chatTableView reloadData];
                    [CMPOcrTipTool.new showNoDataView:self.datas.count<=0 toView:self.view];
                    self.selectAllBtn.hidden = self.datas.count<=0;
                }
                
            } fail:^(NSError * _Nonnull error) {
                strongify(self);
                [self cmp_showHUDError:error];
            }];
        }
    }];
    [alert show];
    
}

// 修改分类
- (void)editIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceGroupListModel *group = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = [group.invoiceItemArray objectAtIndex:indexPath.row];
    
    if (item.invoiceID.length <= 0) {
        return;
    }
    NSMutableArray *invoiceIdArr = [NSMutableArray new];
    [invoiceIdArr addObject:item.invoiceID];
    
    [group.invoiceItemArray enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.relationInvoiceId isEqual:item.invoiceID]) {
            [invoiceIdArr addObject:obj.invoiceID];
        }
    }];
    
    NSString *pid = [self.ext integerValue] == 2 ? self.categoryModel.packageID:item.rPackageId;
    __weak typeof(self) weakSelf = self;
    CMPOcrInvoiceFolderViewController *alert = [[CMPOcrInvoiceFolderViewController alloc] initWithInvoiceArr:invoiceIdArr selectdPackageId:pid completion:^(NSArray *invoices){
        [weakSelf fetchDefaultList:nil];
    }];
    [alert showTargetVC:self];
}

- (void)invoiceNewItemCellSelect:(CMPOcrInvoiceNewItemCell *)cell {
    if (cell.item.mainDeputyTag == 2) {// 副发票不能选中
        return;
    }
    NSIndexPath *idx = [self.chatTableView indexPathForCell:cell];
    CMPOcrInvoiceGroupListModel *group = [self.datas objectAtIndex:idx.section];
    CMPOcrInvoiceItemModel *item = [group.invoiceItemArray objectAtIndex:idx.row];
    if (!item.isSelected) {
        
        NSMutableArray *selectInvoiceIds = [NSMutableArray new];
        [self.selectItems enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.invoiceID) {
                [selectInvoiceIds addObject:obj.invoiceID];
            }
        }];
        
        if (![selectInvoiceIds containsObject:item.invoiceID]) {
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.selectItems];
            [tmpArr addObject:item];
            self.selectItems = tmpArr;
        }
        
        item.isSelected = YES;
        if ([_delegate respondsToSelector:@selector(invoiceListViewController:selectedItem:)]) {
            NSMutableArray *arr = [NSMutableArray new];
            [arr addObject:item];
            [arr addObjectsFromArray:[self findAssociatedItemsFrom:group.invoiceItemArray byInvoiceId:item.invoiceID]];
            [_delegate invoiceListViewController:self selectedItem:arr];
        }
    }else {
        
        NSMutableArray *selectInvoiceIds = [NSMutableArray new];
        [self.selectItems enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.invoiceID) {
                [selectInvoiceIds addObject:obj.invoiceID];
            }
        }];
        if ([selectInvoiceIds containsObject:item.invoiceID]) {
            __block CMPOcrInvoiceItemModel *removeItem;
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.selectItems];
            [self.selectItems enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.invoiceID isEqual:item.invoiceID]) {
                    removeItem = obj;
                    *stop = YES;
                }
            }];
            [tmpArr removeObject:removeItem];
            self.selectItems = tmpArr;
        }
        
        item.isSelected = NO;
        if ([_delegate respondsToSelector:@selector(invoiceListViewController:deselectedItem:)]) {
            NSMutableArray *arr = [NSMutableArray new];
            [arr addObject:item];
            [arr addObjectsFromArray:[self findAssociatedItemsFrom:group.invoiceItemArray byInvoiceId:item.invoiceID]];
            [_delegate invoiceListViewController:self deselectedItem:arr];
        }
    }
    cell.item = item;
    
    [self updateTableViewSelectStatus];
}

//查找主发票的关联发票
- (NSArray *)findAssociatedItemsFrom:(NSArray *)itemArray byInvoiceId:(NSString *)invoiceId{
    NSMutableArray *arr = [NSMutableArray new];
    for (CMPOcrInvoiceItemModel *item in itemArray) {
        if ([item.relationInvoiceId isEqual:invoiceId]) {
            [arr addObject:item];
        }
    }
    return arr;
}

//删除已经移动了的本地数据发票，并刷新table
- (void)reloadInvoiceListWithRemoved:(NSArray *)array{
    NSMutableArray *removeInvoiceIds = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(CMPOcrInvoiceItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.invoiceID) {
            [removeInvoiceIds addObject:obj.invoiceID];
        }
    }];
    
    NSMutableArray *removeGroup = [NSMutableArray new];
    for(CMPOcrInvoiceGroupListModel *group in self.datas){
        NSMutableArray *removeArr = [NSMutableArray new];
        NSMutableArray *originArr = [NSMutableArray arrayWithArray:group.invoiceItemArray];
        for (CMPOcrInvoiceItemModel *item in originArr) {
            if ([removeInvoiceIds containsObject:item.invoiceID]) {
                [removeArr addObject:item];
            }
        }
        [originArr removeObjectsInArray:removeArr];
        if (originArr.count==0) {
            //发票删完后，group信息一起删
            [removeGroup addObject:group];
        }
        group.invoiceItemArray = originArr;
    }
    [self.datas removeObjectsInArray:removeGroup];
    
    if (self.datas.count == 0) {
        [self fetchDefaultList:nil];
    }else{
        [CMPOcrTipTool.new showNoDataView:self.datas.count<=0 toView:self.view];
        [self updateTableViewSelectStatus];
    }
    
}

#pragma mark - 发票点击事件
- (void)invoiceNewItemCellBack:(CMPOcrInvoiceNewItemCell *)cell {
    NSMutableArray *all = [NSMutableArray new];
    [self.datas enumerateObjectsUsingBlock:^(CMPOcrInvoiceGroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [all addObjectsFromArray:obj.invoiceItemArray];
    }];
    NSInteger index = [all indexOfObject:cell.item];

    CMPOcrInvoiceDetailViewController *detailVC = [[CMPOcrInvoiceDetailViewController alloc] init];
    detailVC.hideBannerNavBar = NO;
    detailVC.selectIdx = index;//选择的第几个
    detailVC.packageId = self.categoryModel.packageID;
    detailVC.invoiceArr = all;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableViewDelegate DataSource
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    weakify(self);
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        strongify(self);
        [self deleteIndexPath:indexPath];
    }];
    deleteRowAction.image = [UIImage imageNamed:@"ocr_card_main_del"];
    deleteRowAction.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];

    UIContextualAction *shareRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        strongify(self);
        [self editIndexPath:indexPath];
    }];
    shareRowAction.image = [UIImage imageNamed:@"ocr_card_move"];
    shareRowAction.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];

    NSMutableArray *actionArr = [NSMutableArray new];
    if ([self.ext integerValue] == 1) {//默认票夹
        [actionArr addObject:deleteRowAction];
        [actionArr addObject:shareRowAction];//ks fix -- 设计修改都添加移动操作
    }else if([self.ext integerValue] == 2){ //包详情
        [actionArr addObject:deleteRowAction];
        [actionArr addObject:shareRowAction];
    }
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:actionArr];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_canEdit) {
        return NO;
    }
    CMPOcrInvoiceGroupListModel *group = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = group.invoiceItemArray[indexPath.row];

    return item.mainDeputyTag != 2;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;// | UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceNewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMPOcrInvoiceNewItemCell" forIndexPath:indexPath];
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = groupModel.invoiceItemArray[indexPath.row];
    cell.delegate = self;
    [cell setItem:item from:[self.ext integerValue]];
    NSInteger position = [self position:indexPath];
    BOOL isMainDeputy = item.mainDeputyTag != 2;
    if (indexPath.row == 0) {
        isMainDeputy = NO;
    }
    [cell remakeConstraintForMainDeputy:isMainDeputy canSelect:[self.ext integerValue] != 2 position:position ext:0];
    
    if (!_canEdit) {
        [cell hideStatus];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = groupModel.invoiceItemArray[indexPath.row];
    NSInteger position = [self position:indexPath];
    
    CGFloat moreH = item.displayFields?(item.displayFields.count-1) * 17 : 0;
    //如果超过17，微调-12
    if (moreH >= 17) {
        moreH -= 12;
    }
    
    //多行判断
    CGFloat numberLineH = [CMPOcrInvoiceNewItemCell getTitleLabelHeight:item canSelect:[_ext integerValue] == 1];
    if (numberLineH > 22) {
        moreH += 18;
    }
    
    if (item.mainDeputyTag == 1) {//1：主发票；
        return 88 + moreH;
    }else if (item.mainDeputyTag == 2){//副发票
        if (position >= 3) {//最后一个或者只有一个
            return 88 + moreH;
        }
        return 78 + moreH;
    }
    
    if (indexPath.row == 0) {//section第一个顶部10的高度
        moreH -= 10;
    }
    
    return 88 + moreH;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:section];
    return groupModel.invoiceItemArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    UILabel *_messageContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 200, 20)];
    _messageContentLabel.font = [UIFont systemFontOfSize:12];
    _messageContentLabel.textAlignment = NSTextAlignmentRight;

    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:section];
    _messageContentLabel.text = groupModel.uploadDate;
    _messageContentLabel.textColor = [UIColor cmp_specColorWithName:@"desc-fc"];
    [header addSubview:_messageContentLabel];
    
    [_messageContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(header.mas_centerY);
    }];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return UIView.new;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_ScrollViewWillBeginDraggingBlock) {
        _ScrollViewWillBeginDraggingBlock();
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger position = [self position:indexPath];
    CMPOcrInvoiceNewItemCell *itemCell = (CMPOcrInvoiceNewItemCell *)cell;
    itemCell.backView.layer.mask = nil;
    
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = groupModel.invoiceItemArray[indexPath.row];
    
    if (position > 0) {
        BOOL showSelect = [self.ext integerValue] != 2;
        CGFloat margin = showSelect?45+14+3:14+14+3;

        CGFloat moreH = item.displayFields?(item.displayFields.count-1) * 17 : 0;
        //如果超过17，微调-12
        if (moreH >= 17) {
            moreH -= 12;
        }
        //多行判断
        CGFloat numberLineH = [CMPOcrInvoiceNewItemCell getTitleLabelHeight:item canSelect:[_ext integerValue] == 1];
        if (numberLineH > 22) {
            moreH += 18;
        }
        
        CGFloat height = moreH + 78;//圆角高度
        
        if (position == 1) {//第一个
            [itemCell.backView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight radii:CGSizeMake(6, 6) rect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - margin, height)];
        }else if (position == 3){//最后一个
            [itemCell.backView addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radii:CGSizeMake(6, 6) rect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - margin, height)];
        }else if (position == 4){//只有一个
            [itemCell.backView addRoundedCorners:UIRectCornerAllCorners radii:CGSizeMake(6, 6) rect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - margin, height)];
        }
    }
    
    //设置是否可选择
//    [itemCell setCellEnable:YES];
    
}
//判断副发票位置
//return 1首、2中间、3尾部、4仅有一个
- (NSInteger)position:(NSIndexPath *)indexPath{
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = groupModel.invoiceItemArray[indexPath.row];
    if (item.mainDeputyTag == 2) {
        //group只有一个副发票
        if ([item isEqual:groupModel.invoiceItemArray.lastObject]) {
            if (groupModel.invoiceItemArray.count == 2) {
                return 4;
            }
        }
        
        //下一个
        CMPOcrInvoiceItemModel *nextItem;
        if (groupModel.invoiceItemArray.count > indexPath.row+1) {
            nextItem = groupModel.invoiceItemArray[indexPath.row+1];
        }
        //上一个
        CMPOcrInvoiceItemModel *lastItem;
        if (indexPath.row-1 >= 0) {
            lastItem = groupModel.invoiceItemArray[indexPath.row-1];
        }
        
        
        if (lastItem.mainDeputyTag != 2 && nextItem.mainDeputyTag != 2) {
            return 4; //仅一个
        }
        if (lastItem.mainDeputyTag != 2 && nextItem.mainDeputyTag == 2) {
            return 1; //第一个
        }
        if (nextItem.mainDeputyTag != 2 && lastItem.mainDeputyTag == 2) {
            return 3; //最后一个
        }
        return 2;//中间
    }
    return 0;//没有位置
}

#pragma mark - getter
- (CMPCustomLeftSwipeTableView *)chatTableView {
    if (!_chatTableView) {
        _chatTableView = [[CMPCustomLeftSwipeTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _chatTableView.dataSource = self;
        _chatTableView.delegate = self;
        _chatTableView.tableFooterView = UIView.new;
        _chatTableView.allowsMultipleSelection = YES;
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_chatTableView registerClass:[CMPOcrInvoiceNewItemCell class] forCellReuseIdentifier:@"CMPOcrInvoiceNewItemCell"];
        _chatTableView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
//        if (@available(iOS 11.0, *)) {
//            _chatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
        _chatTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
        if (@available(iOS 15.0, *)) {
            _chatTableView.sectionHeaderTopPadding = 0;
        }
    }
    return _chatTableView;
}

- (UIView *)listView {
    return self.view;
}

- (NSMutableArray<CMPOcrInvoiceGroupListModel *> *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}

- (CMPOcrDefaultInvoiceDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrDefaultInvoiceDataProvider alloc] init];
    }
    return _dataProvider;
}

- (NSInteger)getTotalCountOfItem{
    __block NSInteger count = 0;
    [self.datas enumerateObjectsUsingBlock:^(CMPOcrInvoiceGroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count += obj.invoiceItemArray.count;
    }];
    return count;
}

@end
