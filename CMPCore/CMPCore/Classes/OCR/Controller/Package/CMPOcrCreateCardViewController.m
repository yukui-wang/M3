//
//  CMPOcrCreateCardViewController.m
//  M3
//
//  Created by Shoujian Rao on 2021/11/30.
//

#import "CMPOcrCreateCardViewController.h"

@interface CMPOcrCreateCardViewController ()

@end

@implementation CMPOcrCreateCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cmp_specColorWithName:@"white-bg1"];
    
    self.title = @"创建报销包";
    
}
//自定义返回btn
- (void)setupBannerButtons{
    self.bannerNavigationBar.leftMargin = 0;
    self.backBarButtonItemHidden = YES;
    UIButton *backButton = [UIButton buttonWithImageName:@"navBackButton" frame:kBannerImageButtonFrame buttonImageAlignment:kButtonImageAlignment_Center modifyImage:NO];
    self.bannerNavigationBar.leftBarButtonItems = [NSArray arrayWithObject:backButton];
    [backButton addTarget:self action:@selector(backBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
//返回btn事件
- (void)backBarButtonAction:(id)sender{    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
