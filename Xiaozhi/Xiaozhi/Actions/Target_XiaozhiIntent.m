//
//  Target_XiaozhiIntent.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/10/28.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "Target_XiaozhiIntent.h"
#import "XZTransWebViewController.h"
#import "XZMainController.h"
@implementation Target_XiaozhiIntent
#pragma mark 会议室申请 start

- (void)Action_setOptionValue:(NSDictionary *)params {
    UIViewController *viewController = params[@"viewController"];
    NSDictionary *subParams = params[@"params"];
    if ([viewController isKindOfClass:[XZTransWebViewController class]]) {
        XZTransWebViewController *controller = (XZTransWebViewController *)viewController;
        [controller handleOptionValue:subParams];
    }
    [self clearOptionCommands];
}

- (void)Action_nextIntent:(NSDictionary *)params {
    UIViewController *viewController = params[@"viewController"];
    NSDictionary *subParams = params[@"params"];
    if ([viewController isKindOfClass:[XZTransWebViewController class]]) {
        XZTransWebViewController *controller = (XZTransWebViewController *)viewController;
        [controller handleNextIntent:subParams];
    }
    [self clearOptionCommands];
}

- (void)Action_setOptionCommands:(NSDictionary *)params {
    XZMainController *controller = [XZMainController sharedInstance];
    controller.smartEngine.commandsDic = params[@"params"];
    controller.smartEngine.commandsBlock = params[@"block"];
    controller.smartEngine.cancelBlock = ^{
        XZMainController *controller = [XZMainController sharedInstance];
        [controller showCancelCard];
    };
}

- (void)Action_webviewChangeHeight:(NSDictionary *)params{
    UIViewController *viewController = params[@"viewController"];
    NSString *height = params[@"height"];
    if ([viewController isKindOfClass:[XZTransWebViewController class]]) {
        XZTransWebViewController *controller = (XZTransWebViewController *)viewController;
        [controller webviewChangeHeight:height];
    }
}

- (void)Action_passOperationText:(NSDictionary *)params {
    NSString *text = params[@"text"];
    XZMainController *controller = [XZMainController sharedInstance];
    [controller mainViewControllerInputText:text];
}


- (void)clearOptionCommands {
    XZMainController *controller = [XZMainController sharedInstance];
    controller.smartEngine.commandsDic = nil;
    controller.smartEngine.commandsBlock = nil;
}



#pragma mark 会议室申请 end
@end
