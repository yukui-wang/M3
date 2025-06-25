//
//  CMPMessageAlertManager.m
//  M3
//
//  Created by CRMO on 2017/12/23.
//

#import "CMPMessageAlertTool.h"
#import <CMPLib/UIViewController+CMPViewController.h>
#import "AppDelegate.h"

@interface CMPMessageAlertTool()

@property (strong, nonatomic) JCAlertController *alertController;

@end

@implementation CMPMessageAlertTool

- (void)showAlertWithContent:(NSString *)content buttonType:(CMPMessageAlertButtonType)type {
    [self dispatchAsyncToMain:^{
        if (_alertController) {
            [_alertController dismissViewControllerAnimated:NO completion:nil];
        }
        _alertController = nil;
        UIImage *icon = [UIImage imageNamed:@"msg_alert_icon"];
        _alertController = [JCAlertController alertWithTitle:SY_STRING(@"msg_push") icon:icon message:content];
        __weak JCAlertController *weakAlert = _alertController;
        [_alertController addButtonWithTitle:SY_STRING(@"common_isee") type:JCButtonTypeNormal clicked:^{
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [[AppDelegate shareAppDelegate].tabBarViewController presentViewController:_alertController animated:YES completion:nil];
    }];
}

@end
