//
//  CMPOcrInvoiceListMyController.m
//  M3
//
//  Created by Shoujian Rao on 2022/7/25.
//

#import "CMPOcrInvoiceListMyController.h"
#import "CMPOcrInvoiceItemCell.h"
#import "CMPOcrInvoiceModel.h"
#import "CMPOcrInvoiceSelectedAlertView.h"
#import "CMPOcrInvoiceFolderViewController.h"
#import "CMPOcrInvoiceDetailViewController.h"
#import <CMPLib/Masonry.h>
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import "CMPOcrTipTool.h"
#import "UIView+Layer.h"
#import <CMPLib/MJRefresh.h>
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrNotificationKey.h"
#import "CMPOcrPackageModel.h"

#import "CMPCustomLeftSwipeTableView.h"
@interface CMPOcrInvoiceListMyController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,CMPOcrInvoiceNewItemCellDelegate>

@property (nonatomic, strong) CMPCustomLeftSwipeTableView *chatTableView;
@property (nonatomic, assign) BOOL canEdit;

@end

@implementation CMPOcrInvoiceListMyController

- (void)dealloc{
    NSLog(@"%@-dealloc",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _canEdit = NO;
    self.bannerNavigationBar.hidden = YES;
    [self setupStatusBarViewBackground:UIColor.clearColor];
    [self setupViews];
    
    self.chatTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (self.RefreshActionBlock) {
            self.RefreshActionBlock();
        }
    }];
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
}

- (void)setDatas:(NSMutableArray<CMPOcrInvoiceGroupListModel *> *)datas{
    _datas = datas;
    
    [self.chatTableView reloadData];
    
    [self.chatTableView.mj_header endRefreshing];
    //占位图
    [CMPOcrTipTool.new showNoDataView:self.datas.count<=0 toView:self.view];
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
    detailVC.packageId = self.packageId;
    detailVC.invoiceArr = all;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceNewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMPOcrInvoiceNewItemCell" forIndexPath:indexPath];
    CMPOcrInvoiceGroupListModel *groupModel = [self.datas objectAtIndex:indexPath.section];
    CMPOcrInvoiceItemModel *item = groupModel.invoiceItemArray[indexPath.row];
    cell.delegate = self;
    [cell setItem:item from:4];//4为我的页面进入
    NSInteger position = [self position:indexPath];
    BOOL isMainDeputy = item.mainDeputyTag != 2;
    if (indexPath.row == 0) {
        isMainDeputy = NO;
    }
    [cell remakeConstraintForMainDeputy:isMainDeputy canSelect:NO position:position ext:0];
    
//    if (!_canEdit) {
//        [cell hideStatus];
//    }
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
    CGFloat numberLineH = [CMPOcrInvoiceNewItemCell getTitleLabelHeight:item canSelect:NO];
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
        BOOL showSelect = NO;
        CGFloat margin = showSelect?45+14+3:14+14+3;

        CGFloat moreH = item.displayFields?(item.displayFields.count-1) * 17 : 0;
        //如果超过17，微调-12
        if (moreH >= 17) {
            moreH -= 12;
        }
        //多行判断
        CGFloat numberLineH = [CMPOcrInvoiceNewItemCell getTitleLabelHeight:item canSelect:NO];
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

@end
