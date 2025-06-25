//
//  CMPPhoneTabBarViewController.m
//  M3
//
//  Created by CRMO on 2019/5/23.
//

#import "CMPPhoneTabBarViewController.h"
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/UIView+CMPView.h>
#import "CMPCore_XiaozhiBridge.h"

@interface CMPPhoneTabBarViewController ()

@end

@implementation CMPPhoneTabBarViewController

- (void)viewDidLoad {
    self.orientation = RDVTabBarHorizontal;
    [super viewDidLoad];
}

#pragma mark-
#pragma mark 继承

- (void)onlyOneTabBarItem {
    [self setTabBarAlwaysHidden:YES];
}

- (UIViewController *)itemViewControllerWithRoot:(UIViewController *)rootVc appID:(NSString *)appID {
    return [[CMPNavigationController alloc] initWithRootViewController:rootVc];
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

@end
