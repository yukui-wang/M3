//
//  CMPOcrBaseViewController.m
//  CMPOcr
//
//  Created by 张艳 on 2021/11/24.
//

#import "CMPOcrBaseViewController.h"
#import "CustomDefine.h"

@interface CMPOcrBaseViewController ()

@end

@implementation CMPOcrBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configNavigationStyle];
}

- (void)configNavigationStyle {
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:ESFontPingFangMedium(16),
                                                 NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];


}

- (void)addNavigationBackButton {
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        UIImage *image = [UIImage imageNamed:@"navBackButton"];
        [backButton setImage:image forState:UIControlStateNormal];
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [backButton addTarget:self action:@selector(backButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
}
- (void)backButtonOnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
