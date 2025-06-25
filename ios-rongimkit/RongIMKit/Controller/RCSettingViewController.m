//
//  RCSettingViewController.m
//  RongIMKit
//
//  Created by Liv on 15/4/20.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCSettingViewController.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"

@interface RCSettingViewController ()

@end

@implementation RCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //默认隐藏顶部视图
    self.headerHidden = YES;

    //设置switch状态
    [self setSwitchState];

    self.navigationController.navigationBar.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    self.navigationItem.title = NSLocalizedStringFromTable(@"Setting", @"RongCloudKit", nil); //@"设置";
    UIView *backBtn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 87, 23)];
    UIImageView *backImage = [[UIImageView alloc] initWithImage:IMAGE_BY_NAMED(@"navigator_btn_back")];
    backImage.frame = CGRectMake(-6, 3, 10, 17);
    [backBtn addSubview:backImage];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 85, 23)];
    backText.text = NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
    [backBtn addSubview:backText];
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backBarButtonItemClicked:)];
    [backBtn addGestureRecognizer:tap];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSwitchState {
    
    //设置新消息通知状态
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:self.conversationType
                                                            targetId:self.targetId
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                    BOOL enableNotification = NO;
                                                                    if (nStatus == NOTIFY) {
                                                                        enableNotification = YES;
                                                                    }
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        weakSelf.switch_newMessageNotify = enableNotification;
                                                                    });
                                                                    
                                                                }
                                                                error:^(RCErrorCode status){
                                                                    
                                                                }];
    
    //设置置顶聊天状态
    RCConversation *conversation =
    [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];
    self.switch_isTop = conversation.isTop;
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickNewMessageNotificationSwitch:(id)sender {
    UISwitch *swch = sender;
    __weak RCSettingViewController *weakSelf = self;
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:self.conversationType
        targetId:self.targetId
        isBlocked:!swch.on
        success:^(RCConversationNotificationStatus nStatus) {
            BOOL enableNotification = NO;
            if (nStatus == NOTIFY) {
                enableNotification = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.switch_newMessageNotify = enableNotification;
            });

        }
        error:^(RCErrorCode status){

        }];
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickClearMessageHistory:(id)sender {

    _clearMsgHistoryAlertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedStringFromTable(@"IsDeleteHistoryMsg", @"RongCloudKit", nil)
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    [_clearMsgHistoryAlertController
        addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                                           style:UIAlertActionStyleCancel
                                         handler:nil]];
    [_clearMsgHistoryAlertController
        addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                           style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction *_Nonnull action) {
                                             [self clearHistoryMessage];
                                         }]];
    if ([RCKitUtility currentDeviceIsIPad]) {
        UIPopoverPresentationController *popPresenter = [_clearMsgHistoryAlertController popoverPresentationController];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        popPresenter.sourceView = window;
        popPresenter.sourceRect = CGRectMake(window.frame.size.width / 2, window.frame.size.height / 2, 0, 0);
        popPresenter.permittedArrowDirections = 0;
    }
    [self presentViewController:_clearMsgHistoryAlertController animated:YES completion:nil];
}
- (void)clearHistoryMessage {
    BOOL isClear = [[RCIMClient sharedRCIMClient] clearMessages:self.conversationType targetId:self.targetId];

    //清除消息之后回调操作，例如reload 会话列表
    if (self.clearHistoryCompletion) {
        self.clearHistoryCompletion(isClear);
    }
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickIsTopSwitch:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:swch.on];
}

// override
- (void)settingTableViewHeader:(RCConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users {
}

// override
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath {
}

@end
