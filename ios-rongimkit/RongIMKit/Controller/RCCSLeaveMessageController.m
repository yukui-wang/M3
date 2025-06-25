//
//  RCCSLeaveMessageController.h
//  RongIMKit
//
//  Created by 张改红 on 2016/12/5.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCSLeaveMessageController.h"
#import "RCCSLeaveMessagesCell.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"

@interface RCCSLeaveMessageController ()
@property (nonatomic, strong) NSMutableDictionary *leaveMessageInfoDic;
@end

@implementation RCCSLeaveMessageController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.leaveMessageInfoDic = [NSMutableDictionary dictionary];
    self.title = @"留言";
    [self setBackAction];
    [self setupTableHeaderView];
    [self setupTableFooterView];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)setBackAction {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc]
        initWithImage:[RCKitUtility imageNamed:@"navigator_btn_back" ofBundle:@"RongCloud.bundle"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
    backText.text = NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
    [backText setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTableHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = HEXCOLOR(0xf0f0f6);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 30)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = HEXCOLOR(0x999999);
    label.text = @"请您留言，我们会尽快回复您。";
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
}

- (void)setupTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 43)];
    submitButton.center = footerView.center;
    [submitButton setTitle:@"提交留言" forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[RCKitUtility imageNamed:@"blue" ofBundle:@"RongCloud.bundle"]
                            forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[RCKitUtility imageNamed:@"blue－hover" ofBundle:@"RongCloud.bundle"]
                            forState:UIControlStateHighlighted];
    [footerView addSubview:submitButton];
    [submitButton addTarget:self action:@selector(submitSuggestAction) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = footerView;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.leaveMessageConfig.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCCSLeaveMessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leaveMessages"];
    if (!cell) {
        cell =
            [[RCCSLeaveMessagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leaveMessages"];
    }
    RCCSLeaveMessageItem *item = self.leaveMessageConfig[indexPath.row];
    [cell setDataWithModel:item indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    [cell setLeaveMessageInfomation:^(NSDictionary *info) {
        [weakSelf.leaveMessageInfoDic setValuesForKeysWithDictionary:info];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCCSLeaveMessageItem *item = self.leaveMessageConfig[indexPath.row];
    if ([item.type isEqualToString:@"textarea"]) {
        return 125;
    }
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (void)submitSuggestAction {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < self.leaveMessageConfig.count; i++) {
        RCCSLeaveMessageItem *item = self.leaveMessageConfig[i];
        NSString *infoString = self.leaveMessageInfoDic[item.name];
        for (int j = 0; j < item.message.count; j++) {
            if (j == 0 && item.required) {
                if (infoString.length == 0) {
                    //不能为空
                    [self showAlertView:item.message[j]];
                    return;
                }
            } else if (j == 1) {
                if (infoString.length > 0 && item.verification && [item.verification isEqualToString:@"phone"]) {
                    if (![RCKitUtility validateCellPhoneNumber:infoString]) {
                        //手机格式不正确
                        [self showAlertView:item.message[j]];
                        return;
                    }
                } else if (infoString.length > 0 && item.verification && [item.verification isEqualToString:@"email"]) {
                    if (![RCKitUtility validateEmail:infoString]) {
                        //邮箱格式不正确
                        [self showAlertView:item.message[j]];
                        return;
                    }
                }
            } else if (j == 2) {
                if ([item.type isEqualToString:@"textarea"]) {
                    if (infoString.length > item.max) {
                        [self showAlertView:item.message[j]];
                        return;
                    }
                }
            }
        }
        if (infoString.length > 0) {
            [dic setObject:infoString forKey:item.name];
        }
    }

    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] leaveMessageCustomerService:self.targetId
        leaveMessageDic:dic
        success:^{
            weakSelf.leaveMessageSuccess();
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        failure:^{

        }];
}

- (void)showAlertView:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
@end
