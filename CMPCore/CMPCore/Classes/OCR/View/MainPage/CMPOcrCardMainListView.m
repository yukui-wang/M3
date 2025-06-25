//
//  CMPOcrCardMainListView.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/26.
//

#import "CMPOcrCardMainListView.h"
#import "CMPOcrMainListCell.h"
#import "CMPOcrPackageModel.h"
#import <CMPLib/CMPBannerWebViewController.h>
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrMainViewDataProvider.h"
#import <CMPLib/CMPAlertView.h>
#import "CMPOcrPackageDetailViewController.h"
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPOcrNotificationKey.h"
#import "CMPOcrReimbursementManager.h"

#import "CMPOcrDefaultInvoiceViewController.h"
#import "CMPOcrMyPackageListController.h"

static NSString *kCMPOcrMainListCell = @"CMPOcrMainListCell";

@interface CMPOcrCardMainListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray <CMPOcrPackageModel *> *dataSource;
@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);
@property (nonatomic,strong) CMPOcrMainViewDataProvider *dataProvider;
@property (nonatomic, strong) CMPOcrReimbursementManager *reimburseManager;

@end

@implementation CMPOcrCardMainListView

- (void)setup{
    
    self.tableView = [[CMPCustomLeftSwipeTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:CMPOcrMainListCell.class forCellReuseIdentifier:kCMPOcrMainListCell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];

    _dataSource = [[NSMutableArray alloc] init];
}

- (BOOL)canEdit{
    return self.viewController.rdv_tabBarController.selectedIndex != 2;
}
#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMPOcrMainListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCMPOcrMainListCell forIndexPath:indexPath];
    cell.fromPage = self.fromPage;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColor.clearColor;
    if (indexPath.row < _dataSource.count) {
        CMPOcrPackageModel *model = _dataSource[indexPath.row];
        [cell setItem:model];
        __weak typeof(self) wSelf = self;
        cell.actBlk = ^(NSInteger act, id  _Nonnull ext) {
            switch (act) {
                case 1://一键报销
                {
                    CMPOcrPackageModel *aObj = ext;
                    [wSelf.dataProvider checkPackageIfCanCommitWithParams:@{
                        @"packageId":aObj.pid?:@""} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                        if (!error) {
                            [self.reimburseManager reimbursementWithData:respData templateId:aObj.templateId formId:aObj.formId packageId:aObj.pid summaryId:aObj.summaryId fromVC:wSelf.viewController cancelBlock:nil deleteBlock:nil ext:nil];
                        }else{
                            [wSelf cmp_showHUDError:error];
                        }
                    }];
                }
                    break;
                case 2://唤醒PC
                {
                    if (![CMPCore sharedInstance].isUcOnline) {
                        [self cmp_showHUDWithText:@"唤醒失败，PC端致信未登录！"];
                        return;
                    }
                    CMPOcrPackageModel *aObj = ext;
                    [wSelf.dataProvider checkPackageIfCanCommitWithParams:@{
                        @"packageId":aObj.pid?:@""} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                        if (!error) {
                            
                            [wSelf.reimburseManager ks_reimbursementWithData:respData templateId:aObj.templateId formId:aObj.formId packageId:aObj.pid summaryId:aObj.summaryId fromVC:wSelf.viewController cancelBlock:nil actBlock:^(NSArray *invoiceIds, NSError *err, id ext, NSInteger from) {
                                if (from == 1 && !err && invoiceIds && [invoiceIds isKindOfClass:NSArray.class]) {
                                    [wSelf.dataProvider checkWakeUpIfCanCommitWithInvoiceIdList:invoiceIds completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                                        if (!error) {
                                            NSString *sourceId = ext[@"data"];
                                            //唤起pc
                                            [wSelf.dataProvider wakeupPC:@{
                                                @"templateId":aObj.templateId?:@"",
                                                @"formId":aObj.formId?:@"",
                                                @"sourceId":sourceId?:@"",
                                            } completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
                                                if (error) {
                                                    [wSelf cmp_showHUDError:error];
                                                }else{
                                                    NSString *msg = ext[@"message"];
                                                    [wSelf cmp_showHUDWithText:msg.length?msg:@"唤醒成功，请前往PC端查看～"];
                                                }
                                            }];
                                        }else{
                                            [wSelf cmp_showHUDError:error];
                                        }
                                    }];
                                }
                            } ext:nil];
                            
                        }else{
                            [wSelf cmp_showHUDError:error];
                        }
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;// UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_DidSelectRow) {
        _DidSelectRow(indexPath.row);
    }
    if (indexPath.row < _dataSource.count) {
        CMPOcrPackageModel *model = _dataSource[indexPath.row];
//        CMPOcrPackageDetailViewController *vc = [[CMPOcrPackageDetailViewController alloc] initWithPackageModel:model ext:@(1)];;
//        [self.viewController.navigationController pushViewController:vc animated:YES];
        if (self.fromPage == 0) {
            CMPOcrDefaultInvoiceViewController *vc = [[CMPOcrDefaultInvoiceViewController alloc] initWithPackage:model ext:@(1)];
            [self.viewController.navigationController pushViewController:vc animated:YES];
        }else if (self.fromPage == 1){
            CMPOcrMyPackageListController *vc = [[CMPOcrMyPackageListController alloc] initWithPackage:model ext:@(2)];;
            [self.viewController.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self canEdit]) {
        return NO;
    }
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
API_AVAILABLE(ios(11.0)){
    
    if (indexPath.row < _dataSource.count) {
        __weak typeof(self) wSelf = self;
        CMPOcrPackageModel *model = _dataSource[indexPath.row];
        UIContextualAction *act_del = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [wSelf _cellDeleteActionWithModelWithModel:model];
        }];
        UIContextualAction *act_edit = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [wSelf _cellEditActionWithModelWithModel:model];
        }];
        
        act_del.image = IMAGE(@"ocr_card_main_del");
        act_edit.image = IMAGE(@"ocr_card_main_edit");
        
        act_del.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
        act_edit.backgroundColor = [UIColor cmp_specColorWithName:@"p-bg"];
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[act_del,act_edit]];
        config.performsFirstActionWithFullSwipe = NO;
        return config;
    };
    return nil;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wSelf = self;
    CMPOcrPackageModel *model = _dataSource[indexPath.row];
//这里的title需要设置为空格
   UITableViewRowAction *delBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       [wSelf _cellDeleteActionWithModelWithModel:model];
    //做一些处理
    }];

    UITableViewRowAction *topBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)  {
        [wSelf _cellEditActionWithModelWithModel:model];
    //做一些处理

    }];
    return @[delBtn, topBtn];
}
#pragma mark - private
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollCallback != nil) {
        self.scrollCallback(scrollView);
    }
    if (self.listScrollCallback != nil) {
        self.listScrollCallback(scrollView);
    }
}

#pragma mark - JXPagingViewListViewDelegate

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

- (UIView *)listView {
    return self;
}

-(void)refreshData:(NSArray *)data
{
    if (!data || ![data isKindOfClass:NSArray.class]) {
        return;
    }
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:data];
    [self.tableView reloadData];
}

-(void)_cellDeleteActionWithModelWithModel:(CMPOcrPackageModel *)model{
    __weak typeof(self) wSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"报销包及发票删除后无法恢复，是否确认删除" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [wSelf cmp_showProgressHUD];
        [wSelf.dataProvider deletePackageWithParams:@{@"pid":model.pid?:@""} completion:^(id  _Nonnull respData, NSError * _Nonnull error, id  _Nonnull ext) {
            [wSelf cmp_hideProgressHUD];
            if (!error) {
                if (wSelf.actBlk) {
                    wSelf.actBlk(1, nil, wSelf.viewController);
                }
            }else{
                [wSelf.viewController showAlertMessage:error.domain];
            }
        }];
    }]];
    [wSelf.viewController presentViewController:alert animated:YES completion:nil];
}

-(void)_cellEditActionWithModelWithModel:(CMPOcrPackageModel *)model{
    CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
    NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/createOcr.html";
    href = [href stringByAppendingFormat:@"?templateId=%@&formId=%@&id=%@&name=%@&conditionId=%@",model.templateId,model.formId,model.pid,model.name,_conditionId];
    href = [href urlCFEncoded];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
    webCtrl.hideBannerNavBar = NO;
    webCtrl.startPage = href;
    [self.viewController presentViewController:webCtrl animated:YES completion:^{}];
}
#pragma mark - cell左滑自定义





#pragma mark - lazy
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
