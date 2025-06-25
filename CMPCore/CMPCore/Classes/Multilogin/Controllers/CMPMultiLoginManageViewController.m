//
//  CMPMultiLoginManageViewController.m
//  M3
//
//  Created by 程昆 on 2019/9/10.
//

#import "CMPMultiLoginManageViewController.h"
#import "CMPMultiLoginManageView.h"
#import "CMPOnlineDevModel.h"
#import <CMPLib/CMPActionSheet.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPMessageManager.h"
#import "CMPPushConfigResponse.h"
#import <CMPLib/CMPSplitViewController.h>
#import "CMPSetPushConfigProvider.h"
#import "CMPTabBarViewController.h"

typedef NS_ENUM(NSInteger, CMPLogoutType) {
    CMPLogoutTypePc   = 1,
    CMPLogoutTypeUc  = 4,
    CMPLogoutTypeWeChat  = 8,
    CMPLogoutTypePhone  = 2,
    CMPLogoutTypePad  = 2048,
};

@interface CMPMultiLoginManageViewController ()

@property (nonatomic,weak)CMPMultiLoginManageView *multiLoginManageView;
@property (nonatomic,strong)CMPOnlineDevModel *onlineDev;
@property (nonatomic,weak)UIViewController *presentViewController;

@property (nonatomic,strong)CMPSetPushConfigProvider *setPushConfigProvider;
@property (nonatomic,weak) CMPActionSheet *actionSheet;

@end

@implementation CMPMultiLoginManageViewController

- (instancetype)initWithOnlineDevModel:(CMPOnlineDevModel *)model presentViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.onlineDev = model;
        self.presentViewController = viewController;
        self.setPushConfigProvider = [[CMPSetPushConfigProvider alloc] init];
    }
   return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.multiLoginManageView = (CMPMultiLoginManageView *)self.mainView;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onlineDevDidChange:) name:kNotificationName_OnlineDevDidChange object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willReloadTabBarClearViewNotificationAction:) name:CMPWillReloadTabBarClearViewNotification object:nil];
    
    [self.multiLoginManageView updateDataWithModel:self.onlineDev];
    
    __weak typeof(self) weakSelf = self;
    self.multiLoginManageView.closeButtonAction = ^{
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    };
    
    self.multiLoginManageView.muteButtonAction = ^{
        [weakSelf muteOrCancel];
    };
    
    self.multiLoginManageView.fileAssistantButtonAction = ^{
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            CMPMessageObject *fileAssistantObjc = [[CMPMessageManager sharedManager] messageWithAppID:[CMPCore sharedInstance].userID];
           [[CMPMessageManager sharedManager] showChatView:fileAssistantObjc viewController:weakSelf.presentViewController];
        }];
    };
    
    self.multiLoginManageView.exitOtherDeviceButtonAction = ^{
        [weakSelf exitOtherDevice];
    };
}

- (void)onlineDevDidChange:(NSNotification *)notification {
    CMPOnlineDevModel *model = notification.userInfo[@"onlineDev"];
    self.onlineDev = model;
    [self.multiLoginManageView updateDataWithModel:model];
}

- (void)willReloadTabBarClearViewNotificationAction:(NSNotification *)notification {
    [self.actionSheet dissmiss];
}

- (void)exitOtherDevice {
    if (!self.onlineDev.isMultiOnline) {
        return;
    }
    
//    if (self.onlineDev.phoneOnline ||self.onlineDev.padOnline) {//全部采用新逻辑
        NSMutableArray *sheetTitles = [NSMutableArray array];
        if (self.onlineDev.pcOnline) {
            CMPActionSheetViewItem *item = [[CMPActionSheetViewItem alloc] init];
            [item setTitle:[SY_STRING(@"mu_login_exit") stringByAppendingString:SY_STRING(@"mu_login_type_web")]];
            [item setKey:CMPLogoutTypePc];
            [sheetTitles addObject:item];
        }
        
        if (self.onlineDev.ucOnline) {
            CMPActionSheetViewItem *item = [[CMPActionSheetViewItem alloc] init];
            [item setTitle:[SY_STRING(@"mu_login_exit") stringByAppendingString:SY_STRING(@"mu_login_type_pc")]];
            [item setKey:CMPLogoutTypeUc];
            [sheetTitles addObject:item];
        }
        
        if (self.onlineDev.phoneOnline) {
            CMPActionSheetViewItem *item = [[CMPActionSheetViewItem alloc] init];
            [item setTitle:[SY_STRING(@"mu_login_exit") stringByAppendingString:SY_STRING(@"mu_login_type_phone")]];
            [item setKey:CMPLogoutTypePhone];
            [sheetTitles addObject:item];
        }
        
        if (self.onlineDev.padOnline) {
            CMPActionSheetViewItem *item = [[CMPActionSheetViewItem alloc] init];
            [item setTitle:[SY_STRING(@"mu_login_exit") stringByAppendingString:SY_STRING(@"mu_login_type_pad")]];
            [item setKey:CMPLogoutTypePad];
            [sheetTitles addObject:item];
        }
    
        if (self.onlineDev.weChatOnline) {
            CMPActionSheetViewItem *item = [[CMPActionSheetViewItem alloc] init];
            [item setTitle:[SY_STRING(@"mu_login_exit") stringByAppendingString:SY_STRING(@"mu_login_type_wechat")]];
            [item setKey:CMPLogoutTypeWeChat];
            [sheetTitles addObject:item];
        }
        
        __weak typeof(self) weakSelf = self;
        CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:nil sheetItems:sheetTitles cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(CMPActionSheetViewItem *actionItem, id ext) {
            if (![actionItem isCancelItem]) {
                [weakSelf logoutDeviceType:actionItem.key isDismiss:!(sheetTitles.count>1)];
            }
        }];
        [actionSheet show];
        self.actionSheet = actionSheet;
        
        return;
//    }
    
    
//    NSMutableArray *sheetTitles = [NSMutableArray array];
//    if (self.onlineDev.pcOnline) {
//        [sheetTitles addObject:SY_STRING(@"mu_login_exit_web")];
//    }
//
//    if (self.onlineDev.ucOnline) {
//        [sheetTitles addObject:SY_STRING(@"mu_login_exit_zhixin")];
//    }
//
//    if (self.onlineDev.weChatOnline) {
//        [sheetTitles addObject:SY_STRING(@"mu_login_exit_weChat")];
//    }
//
//    __weak typeof(self) weakSelf = self;
//    CMPActionSheet *actionSheet = [CMPActionSheet actionSheetWithTitle:nil sheetTitles:[sheetTitles copy] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
//        if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevPC) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypePc isDismiss:YES];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevUC) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeUc isDismiss:YES];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevWeChat) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeWeChat isDismiss:YES];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevPCAndUC) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypePc isDismiss:NO];
//            } else if (buttonIndex == 2) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeUc isDismiss:NO];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevPCAndWeChat) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypePc isDismiss:NO];
//            } else if (buttonIndex == 2) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeWeChat isDismiss:NO];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevUCAndWeChat) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeUc isDismiss:NO];
//            } else if (buttonIndex == 2) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeWeChat isDismiss:NO];
//            }
//        } else if (weakSelf.onlineDev.onlineDevState == CMPOnlineDevPCAndUCAndWeChat) {
//            if (buttonIndex == 1) {
//                [weakSelf logoutDeviceType:CMPLogoutTypePc isDismiss:NO];
//            } else if (buttonIndex == 2) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeUc isDismiss:NO];
//            } else if (buttonIndex == 3) {
//                [weakSelf logoutDeviceType:CMPLogoutTypeWeChat isDismiss:NO];
//            }
//        }
//    }];
//    [actionSheet show];
//    self.actionSheet = actionSheet;
}

- (void)muteOrCancel {
    CMPCore *core = [CMPCore sharedInstance];
    CMPActionSheet *actionSheet;
    if (core.multiLoginReceivesMessageState) {
       actionSheet  = [CMPActionSheet actionSheetWithTitle:SY_STRING(@"mutil_login_mute_hint") sheetTitles:@[SY_STRING(@"mutil_login_stop_notification")] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
           if (buttonIndex == 1) {
               core.multiLoginReceivesMessageState = NO;
               [self.multiLoginManageView setMuteButtonSelectedStatus:NO];
               [self updateMuteSetting];
           }
        }];
    } else {
        actionSheet = [CMPActionSheet actionSheetWithTitle:SY_STRING(@"mutil_login_unmute_hint") sheetTitles:@[SY_STRING(@"mutil_login_recovery_notification")] cancleBtnTitle:SY_STRING(@"common_cancel") sheetStyle:CMPActionSheetDefault callback:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                core.multiLoginReceivesMessageState = YES;
                [self.multiLoginManageView setMuteButtonSelectedStatus:YES];
                [self updateMuteSetting];
            }
        }];
        actionSheet.subtitleColor = [UIColor redColor];
    }
    [actionSheet show];
    self.actionSheet = actionSheet;
}

- (void)logoutDeviceType:(NSInteger)type isDismiss:(BOOL)isDismiss {
    [self cmp_showProgressHUDInView:self.view];
    [[CMPMessageManager sharedManager] logoutDeviceType:type completion:^(NSError *error) {
        [self cmp_hideProgressHUD];
        [self cmp_showSuccessHUDWithText:SY_STRING(@"muj_login_exit_success") completionBlock:^{
            if (isDismiss) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [[CMPMessageManager sharedManager] refreshMessage];
    }];
}

- (void)updateMuteSetting {
    CMPCore *core = [CMPCore sharedInstance];
    CMPPushConfigResponse *aResponse = [CMPPushConfigResponse yy_modelWithJSON:core.pushConfig];
    aResponse.mute = core.multiLoginReceivesMessageState ? @"0" : @"1";
    core.pushConfig = [aResponse yy_modelToJSONString];
    [self.setPushConfigProvider setPushConfigMuteSetting:aResponse.mute];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_AcceptInformationChange object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_OnlineDevDidChange object:self userInfo:@{@"onlineDev" : self.onlineDev}];
}

- (void)pushInDetailWithViewController:(UIViewController *)vc in:(UIViewController *)parentVc {
    if (CMP_IPAD_MODE &&
        [parentVc cmp_canPushInDetail]) {
        [parentVc cmp_clearDetailViewController];
        [parentVc cmp_showDetailViewController:vc];
    } else {
        [parentVc.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - CMPScreenshotControlProtocol

- (NSString *)currentPageScreenshotControlTitle {
    return SY_STRING(@"screeenshot_page_title_multi_login");
}


@end
