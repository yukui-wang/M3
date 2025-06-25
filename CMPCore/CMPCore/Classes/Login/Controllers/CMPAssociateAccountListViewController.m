//
//  CMPAssociateAccountListViewController.m
//  M3
//
//  Created by CRMO on 2018/6/11.
//

#import "CMPAssociateAccountListViewController.h"
#import "CMPAssociateAccountListView.h"
#import "CMPAssociateAccountListCell.h"
#import <CMPLib/UIColor+Hex.h>
#import "CMPAssociateAccountEditViewController.h"
#import "CMPAssociateAccountEditController.h"
#import <CMPLib/CMPLoginDBProvider.h>
#import <CMPLib/GTMUtil.h>
#import <CMPLib/CMPGlobleManager.h>
#include <CMPLib/CMPSplitViewController.h>

@interface CMPAssociateAccountListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CMPAssociateAccountListView *listView;
/** 关联账号列表 **/
@property (strong, nonatomic) NSArray *accountList;
/** 是否可以编辑、添加 **/
@property (assign, nonatomic) BOOL canEdit;

@end

@implementation CMPAssociateAccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listView = (CMPAssociateAccountListView *)self.mainView;
    _listView.tableView.delegate = self;
    _listView.tableView.dataSource = self;
    [self setTitle:SY_STRING(@"ass_title")];
    _canEdit = [[CMPCore sharedInstance].currentServer isMainAssAccount];
    if (_canEdit) {
        [self addRightButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    CMPLoginDBProvider *dbProvider = [CMPCore sharedInstance].loginDBProvider;
    NSString *serverUniqueID = [CMPCore sharedInstance].serverID;
    NSString *currentUserID = [CMPCore sharedInstance].userID;
    _accountList = [dbProvider assAcountListWithServerID:serverUniqueID userID:currentUserID];
    [self.listView showNothingView:_accountList.count == 0];
    [self.listView.tableView reloadData];
}

- (void)addRightButton {
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightMedium],
                                   NSForegroundColorAttributeName : [UIColor cmp_colorWithName:@"theme-fc"]};
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:SY_STRING(@"ass_add")
                                                                      attributes:attributeDic];
    [addButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    [addButton setFrame:kBannerImageButtonFrame];
    [addButton addTarget:self action:@selector(tapAddButton) forControlEvents:UIControlEventTouchUpInside];
    [self.bannerNavigationBar setRightBarButtonItems:@[addButton]];
}

- (UIViewController *)editViewController:(CMPAssociateAccountModel *)assAccount {
   UIViewController *vc = nil;
    if (CMPCore.sharedInstance.serverIsLaterV8_0) {
        vc = [[CMPAssociateAccountEditController alloc] initWithAssAccount:assAccount];
    }
    else {
        vc = [[CMPAssociateAccountEditViewController alloc] initWithAssAccount:assAccount];
    }
    return vc;
}

- (void)tapAddButton {
    UIViewController *vc = [self editViewController:nil];
    if (CMP_IPAD_MODE && [self cmp_inMasterStack]) {
        [self.navigationController.topViewController cmp_pushPageInMasterView:vc navigation:self.navigationController];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark-
#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_accountList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 136;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CMPAssociateAccountListCellIdentifier";
    CMPAssociateAccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CMPAssociateAccountListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger row = indexPath.row;
    if (row < _accountList.count) {
        CMPAssociateAccountModel *assAcount = _accountList[row];
        cell.shortName = assAcount.loginAccount.extend1;
        cell.fullUrl = assAcount.server.fullUrl;
        cell.username = [GTMUtil decrypt:assAcount.loginAccount.loginName];
        cell.note = assAcount.server.note;
        cell.showEdit = _canEdit;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_canEdit) {
        [self showToastWithText:SY_STRING(@"ass_edit_err")];
        return;
    }
   NSInteger row = indexPath.row;
    if (row < _accountList.count) {
        CMPAssociateAccountModel *assAcount = _accountList[row];
        UIViewController *vc = [self editViewController:assAcount];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
