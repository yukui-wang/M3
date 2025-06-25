//
//  CMPOcrTabbarViewController.m
//  M3
//
//  Created by Kaku Songu on 12/14/21.
//

#import "CMPOcrTabbarViewController.h"
#import <CMPLib/CMPNavigationController.h>
#import <CMPLib/CMPBannerWebViewController.h>
#import "CMPOcrCreateCardViewController.h"
#import "CMPOcrMainViewController.h"
#import "CMPOcrMyViewController.h"
#import <CMPLib/CMPCachedUrlParser.h>
#import "CMPOcrNotificationKey.h"

@interface CMPOcrTabbarViewController ()<RDVTabBarControllerDelegate>

@end

@implementation CMPOcrTabbarViewController

- (void)dealloc{
    _viewModel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@-delloc",self.class);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //主页
    CMPOcrMainViewController *mainVC = [CMPOcrMainViewController new];
    CMPNavigationController *mainNavi = [[CMPNavigationController alloc]initWithRootViewController:mainVC];
    
    //占位vc
    UIViewController *voidVC = UIViewController.new;
    //我的
    CMPOcrMyViewController *myVC = [CMPOcrMyViewController new];
    CMPNavigationController *myNavi = [[CMPNavigationController alloc]initWithRootViewController:myVC];
    
    self.delegate = self;
    [self setViewControllers:@[mainNavi,voidVC,myNavi]];
            
    //首页
    UIImage *selectedimageMain = [UIImage imageNamed:@"ocr_card_main_page_selected"];
    UIImage *unselectedimageMain = [UIImage imageNamed:@"ocr_card_main_page_unselected"];
    RDVTabBarItem *mainItem = [[RDVTabBarItem alloc]init];
    mainItem.title = @"首页";
    [mainItem setFinishedSelectedImage:selectedimageMain withFinishedUnselectedImage:unselectedimageMain];
    [mainItem setSelectedTitleAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:10],
                                       NSForegroundColorAttributeName:[UIColor cmp_specColorWithName:@"theme-bdc"]
    }];
    
    //新建btn
    RDVTabBarItem *addItem = [[RDVTabBarItem alloc]initWithFrame:CGRectMake(0, 0, 80, 36)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addItem addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(addItem).offset(0);
        make.width.mas_equalTo(80);
        make.top.mas_equalTo(7);
        make.height.mas_equalTo(36);
    }];
//    btn.backgroundColor = [UIColor cmp_specColorWithName:@"theme-bdc"];
    [btn setImage:[UIImage imageNamed:@"ocr_card_add_card"] forState:(UIControlStateNormal)];
    btn.layer.cornerRadius = 18.f;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //我的
    UIImage *selectedimageMy = [UIImage imageNamed:@"ocr_card_my_page_selected"];
    UIImage *unselectedimageMy = [UIImage imageNamed:@"ocr_card_my_page_unselected"];
    RDVTabBarItem *myItem = [[RDVTabBarItem alloc]init];
    myItem.title = @"我的";
    [myItem setFinishedSelectedImage:selectedimageMy withFinishedUnselectedImage:unselectedimageMy];
    [myItem setSelectedTitleAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:10],
                                       NSForegroundColorAttributeName:[UIColor cmp_specColorWithName:@"theme-bdc"]
    }];
    
    //tabbar
    RDVTabBar *tabBar = [self tabBar];
    tabBar.translucent = YES;
    tabBar.backgroundView.backgroundColor = [UIColor whiteColor];
    [tabBar setItems:@[mainItem,addItem,myItem]];
    [tabBar hideSeperateView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveNotiAfterReimburseFromFormPlugin:) name:kNotificationOneClickReimbursementCall object:nil];
}

- (void)btnAction:(id)sender{
    CMPBannerWebViewController *webCtrl = [[CMPBannerWebViewController alloc] init];
    NSString *href = @"http://ocr.v5.cmp/v1.0.0/html/createOcr.html";
    href = [href urlCFEncoded];
    NSString *localHref = [CMPCachedUrlParser cachedPathWithUrl:[NSURL URLWithString:href]];
    if ([NSString isNotNull:localHref]) {
        href = localHref;
    }
    webCtrl.hideBannerNavBar = NO;
    webCtrl.startPage = href;
    [self presentViewController:webCtrl animated:YES completion:^{}];
}

//ks fix -- V5-38190【智能报销】iOS 进入我的票价后还显示小致入口
- (void)postNotificationForXZ{
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBar shouldSelectItemAtIndex:(NSInteger)index incompleteOperationBlock:(void (^)(void))block{
    if (index == 1) {
        return NO;
    }
    return YES;
}


-(void)onReceiveNotiAfterReimburseFromFormPlugin:(NSNotification *)noti
{
    id obj = noti.object;
    id aOb = nil;
    if (obj) {
        aOb = [obj copy];
    }
    self.viewModel.paramFromFormAfterReimburse = aOb;
    obj = nil;
}

-(CMPOcrTabbarViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[CMPOcrTabbarViewModel alloc] init];
    }
    return _viewModel;
}

@end
