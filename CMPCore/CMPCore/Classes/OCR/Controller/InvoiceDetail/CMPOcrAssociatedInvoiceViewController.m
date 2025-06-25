//
//  CMPOcrAssociatedInvoiceViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrAssociatedInvoiceViewController.h"
#import "CMPOcrAssociatedFooterView.h"
#import "CMPOcrInvoiceSelectedAlertView.h"
#import "CMPOcrInvoiceModel.h"
#import "CMPOcrInvoiceItemCell.h"
#import "CustomDefine.h"
#import "UIView+Layer.h"
#import "CMPOcrInvoiceDetailDataProvider.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrNotificationKey.h"
#import "CMPOcrTipTool.h"
@interface CMPOcrAssociatedInvoiceViewController ()<UITableViewDelegate,UITableViewDataSource,CMPOcrInvoiceNewItemCellDelegate>

@property (nonatomic ,strong) UITableView                       *myTableView;

@property (nonatomic ,strong) CMPOcrAssociatedFooterView        *footerView;

@property (nonatomic ,strong) NSMutableArray                    *listArray;

@property (nonatomic, strong) CMPOcrInvoiceDetailDataProvider   *dataProvider;

@property (nonatomic, strong) NSMutableArray *toUpdateRelatedArray;

@end

@implementation CMPOcrAssociatedInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    self.title = @"关联发票";
    
    [self.view addSubview:self.myTableView];
    if ([self canEdit]) {
        [self configFooterView];
        self.title = @"选择发票";
    }
    [self fetchAssociatedInvoice];
}

//我的页面进入不允许编辑
- (BOOL)canEdit{
    return self.rdv_tabBarController.selectedIndex != 2;
}
#pragma mark - footerview

- (void)configFooterView {
    
    [self.view addSubview:self.footerView];
    
    weakify(self);
    //关联
    self.footerView.showBlock = ^(BOOL isShow) {
        strongify(self)
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (CMPOcrInvoiceItemModel *model in self.listArray) {
            if (model.isSelected) {
                [models addObject:model];
            }
        }
        if (models.count<=0) {
            return;
        }
        
        CMPOcrInvoiceSelectedAlertView *alert = [[CMPOcrInvoiceSelectedAlertView alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, kScreenHeight)];
        [kKeyWindow addSubview:alert];
        [alert show:models];
        [alert setDeleteCompletion:^(CMPOcrInvoiceItemModel * _Nullable item) {
            item.isSelected = NO;
            NSInteger row = [self.listArray indexOfObject:item];
            [self.listArray replaceObjectAtIndex:[self.listArray indexOfObject:item] withObject:item];
            CMPOcrInvoiceNewItemCell *cell = [self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            cell.item = item;
            [self updateSelectStatus];
        }];
    };
    //确定按钮
    self.footerView.sureBlcok = ^{
        strongify(self)
        NSMutableArray *invoiceIDMapArr = [[NSMutableArray alloc] init];
        for (CMPOcrInvoiceItemModel *model in self.listArray) {
            if (model.isSelected) {
                [invoiceIDMapArr addObject:@{
                    @"id":model.invoiceID?:@""
                }];
            }
        }
//        if (invoiceIDMapArr.count<=0) {
//            return;
//        }
//        CMPAlertView *alert = [[CMPAlertView alloc] initWithTitle:@"提示" message:@"确认要修改关联？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] callback:^(NSInteger buttonIndex) {
//            if(buttonIndex == 1){
                [self.dataProvider updateInvoiceRelationByMainId:self.mainInvoiceId toUpdateRelated:invoiceIDMapArr success:^(NSDictionary * _Nonnull data) {
                    if ([data[@"code"] integerValue] == 0) {
                        if (invoiceIDMapArr.count>0) {
                            [self cmp_showHUDWithText:@"关联成功！"];
                        }else{
                            [self cmp_showHUDWithText:@"修改关联成功！"];
                        }
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatedAssociateInvoice object:nil];
                    }else{
                        [self cmp_showHUDWithText:data[@"message"]];
                    }
                } fail:^(NSError * _Nonnull error) {
                    [self cmp_showHUDError:error];
                }];
//            }
//        }];
//        [alert show];
        
    };
}
- (void)fetchAssociatedInvoice {
    __weak typeof(self) weakSelf = self;
    [self.dataProvider fetchAssociatedInvoiceList:self.rPackageId mainInvoiceId:self.mainInvoiceId is4History:![self canEdit] success:^(NSDictionary * _Nonnull data) {
        NSArray *itemArray = data[@"data"];
        NSArray *resultArr = [NSArray yy_modelArrayWithClass:CMPOcrInvoiceItemModel.class json:itemArray];
        [weakSelf.listArray removeAllObjects];
        [weakSelf.listArray addObjectsFromArray:resultArr];

        for (CMPOcrInvoiceItemModel *item in weakSelf.listArray) {
            if (item.relationInvoiceId.length>0) {
                item.isSelected = YES;
            }
        }
        
        [weakSelf.myTableView reloadData];
        
        if (weakSelf.listArray.count > 0) {
            [CMPOcrTipTool.new showNoAssociateDataView:NO toView:weakSelf.view];
        }else{
            [CMPOcrTipTool.new showNoAssociateDataView:YES toView:weakSelf.view];
        }
        
        [weakSelf updateSelectStatus];
    } fail:^(NSError * _Nonnull error) {
        [weakSelf cmp_showHUDError:error];
    }];
}

#pragma mark - TabelViewDelegateDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceNewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMPOcrInvoiceNewItemCell" forIndexPath:indexPath];
    cell.delegate = self;
    CMPOcrInvoiceItemModel *item = self.listArray[indexPath.row];
    [cell setItem:item from:3];
    if ([self canEdit]) {
        [cell remakeConstraintForMainDeputy:item.mainDeputyTag == 1 canSelect:YES position:0 ext:2];
    }else{
        [cell remakeConstraintForMainDeputy:item.mainDeputyTag == 1 canSelect:NO position:0 ext:2];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMPOcrInvoiceItemModel *item = self.listArray[indexPath.row];
    
    //多行字段，微调
    CGFloat moreH = item.displayFields?(item.displayFields.count-1) * 17 : 0;
    if (moreH >= 17) {
        moreH -= 12;
    }
    //多行判断
    CGFloat numberLineH = [CMPOcrInvoiceNewItemCell getTitleLabelHeight:item canSelect:NO];
    if (numberLineH > 22) {
        moreH += 18;
    }
    return 78 + moreH;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCMPOcrScreenWidth, 10)];
//    headerView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
//    return headerView;
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceNewItemCell *cell = (CMPOcrInvoiceNewItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.item.mainDeputyTag == 2) {
        return nil;
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrInvoiceNewItemCell *cell = (CMPOcrInvoiceNewItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.item.mainDeputyTag == 2) {
        return nil;
    }
    return indexPath;
}

#pragma mark - CMPOcrInvoiceNewItemCellDelegate
- (void)invoiceNewItemCellSelect:(CMPOcrInvoiceNewItemCell *)cell {
    NSIndexPath *idx = [self.myTableView indexPathForCell:cell];
    CMPOcrInvoiceItemModel *item = self.listArray[idx.row];
    if (!item.isSelected) {
        item.isSelected = YES;
    }else {
        item.isSelected = NO;
    }
    cell.item = item;
    [self updateSelectStatus];
}

- (void)invoiceNewItemCellBack:(CMPOcrInvoiceNewItemCell *)cell {

}

- (void)updateSelectStatus {
    
    NSInteger count = 0;
    for (CMPOcrInvoiceItemModel *model in self.listArray) {
        if (model.isSelected == YES) {
            count++;
        }
    }
    [self.footerView refreshSelectInvoiceCount:count];
}

#pragma mark - Lazy

- (UITableView *)myTableView {
    if (!_myTableView) {
        CGFloat height = kScreenHeight-IKBottomSafeEdge-50-kNavHeight;
        if (![self canEdit]) {
            height += 50;
        }
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IKNavAreaHeight+10, kCMPOcrScreenWidth, height-10) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;

        _myTableView.tableFooterView = [[UIView alloc] init];
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.allowsMultipleSelection = YES;
        _myTableView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
        _myTableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
        _myTableView.separatorColor = [UIColor cmp_specColorWithName:@"cmp-bdc"];
        
        [_myTableView registerClass:[CMPOcrInvoiceNewItemCell class] forCellReuseIdentifier:@"CMPOcrInvoiceNewItemCell"];
        
        if (@available(iOS 15.0, *)) {
            _myTableView.sectionHeaderTopPadding = 0;
        }
    }
    return _myTableView;
}

- (CMPOcrAssociatedFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[CMPOcrAssociatedFooterView alloc] initWithFrame:CGRectMake(0, self.myTableView.bottom, kCMPOcrScreenWidth, 50+IKBottomSafeEdge)];
    }
    return _footerView;
}
- (CMPOcrInvoiceDetailDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[CMPOcrInvoiceDetailDataProvider alloc] init];
    }
    return _dataProvider;
}
- (NSMutableArray *)listArray {
    if (!_listArray) {
        _listArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listArray;
}

- (NSMutableArray *)toUpdateRelatedArray{
    if (!_toUpdateRelatedArray) {
        _toUpdateRelatedArray = [NSMutableArray new];
    }
    return _toUpdateRelatedArray;
}

@end
