//
//  CMPprivacyProtocolWebViewController.m
//  M3
//
//  Created by 程昆 on 2019/8/13.
//

#import "CMPPrivacyProtocolWebViewController.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPThemeManager.h>
#import "CMPCommonManager.h"
#import <CMPLib/CMPConstant.h>
#import "CMPCustomManager.h"
#import <CoreTelephony/CTCellularData.h>

@interface CMPPrivacyProtocolWebViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation CMPPrivacyProtocolWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self->_statusBarView removeFromSuperview];
    
    self.webView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.text = SY_STRING(@"login_policy_detail");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.layer.cornerRadius = 14;
    titleLabel.layer.masksToBounds = YES;
    [self.view addSubview:titleLabel];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.hidden = YES;
    [_backBtn setTitle:@"" forState:(UIControlStateNormal)];
    [_backBtn setImage:[UIImage imageNamed:@"login_view_back_btn_icon"] forState:(UIControlStateNormal)];
    [_backBtn setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
    [titleLabel addSubview:_backBtn];
    titleLabel.userInteractionEnabled = YES;
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
    }];
    
    UIView *shieldRectView = [[UIView alloc] init];
    shieldRectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:shieldRectView];
    
    UIView *buttomBackView = [[UIView alloc] init];
    buttomBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:buttomBackView];
    
    UIButton *notAgreeButton = [[UIButton alloc] init];
    [notAgreeButton setBackgroundColor:[UIColor whiteColor]];
    [notAgreeButton setTitle:SY_STRING(@"login_policy_not_agree") forState:UIControlStateNormal];
    [notAgreeButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    notAgreeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    notAgreeButton.layer.cornerRadius = 20;
    notAgreeButton.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
    notAgreeButton.layer.borderWidth = 1.0f;
    [notAgreeButton addTarget:self action:@selector(notAgreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttomBackView addSubview:notAgreeButton];
    
    UIButton *agreeButton = [[UIButton alloc] init];
    [agreeButton setBackgroundColor:[CMPThemeManager sharedManager].themeColor];
    [agreeButton setTitle:SY_STRING(@"login_policy_pop_agree") forState:UIControlStateNormal];
    [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    agreeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    agreeButton.layer.cornerRadius = 20;
    [agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttomBackView addSubview:agreeButton];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(62);
        make.top.equalTo(self.view.mas_top).offset(140);
    }];
    
    [shieldRectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(titleLabel);
        make.height.equalTo(14);
    }];
    
    [buttomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self.view);
        make.height.equalTo(80);
    }];
    
    [notAgreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(buttomBackView).offset(20);
        make.bottom.equalTo(buttomBackView).offset(-20);
        make.trailing.equalTo(agreeButton.mas_leading).offset(-20);
        make.width.equalTo(agreeButton);
    }];
    
    [agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buttomBackView).offset(20);
        make.trailing.equalTo(buttomBackView).offset(-20);
        make.bottom.equalTo(buttomBackView).offset(-20);
        make.leading.equalTo(notAgreeButton.mas_trailing).offset(20);
        make.width.equalTo(notAgreeButton);
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(buttomBackView.mas_top);
        make.top.equalTo(titleLabel.mas_bottom);
    }];
    
    _indicator = [[UIActivityIndicatorView alloc]init];
    [self.webView addSubview:_indicator];
    [_indicator startAnimating];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.webView);
    }];
    
    //代理方式
    WKWebView *wv = (WKWebView *)self.webView;
    wv.navigationDelegate = self;
    
    //监听方式
//    [wv addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    
    [self _checkNetwork];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    _backBtn.hidden = ![webView canGoBack];
}

- (void)backAction:(id)sender{
    WKWebView *wv = (WKWebView *)self.webView;
    if ([wv canGoBack]) {
        [wv goBack];
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"URL"]) {
//        NSString *url = ((WKWebView *)self.webView).URL.absoluteString;
//        if ([url containsString:@"/policy_"]) {
//
//        }
//    }
//}

- (void)reLayoutSubViews {
    
}

- (void)notAgreeButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.notAgreeButtonActionBlock) {
            self.notAgreeButtonActionBlock();
        }
    }];
}

- (void)agreeButtonAction:(UIButton *)sender {
    if (self.agreeButtonActionBlock) {
        self.agreeButtonActionBlock();
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (BOOL)popUpPrivacyProtocolPageWithPresentedController:(UIViewController *)presentedController
                                     beforePopPageBlock:(void (^)(void))beforePopPageBlock
                                 agreeButtonActionBlock:(void (^)(void))agreeButtonActionBlock
                              notAgreeButtonActionBlock:(void (^)(void))notAgreeButtonActionBlock {
#if CUSTOM
    if (![CMPCustomManager sharedInstance].cusModel.hasPrivacy) {
        if (agreeButtonActionBlock) {
            agreeButtonActionBlock();
        }
        return NO;
    }
#endif
    CMPCore *core = [CMPCore sharedInstance];
    if(core.isByPopUpPrivacyProtocolPage && !core.currentUser.extraDataModel.isAlreadyShowPrivacyAgreement) {
        if (beforePopPageBlock) {
            beforePopPageBlock();
        }
        CMPPrivacyProtocolWebViewController *viewController = [[self alloc] init];
        viewController.agreeButtonActionBlock = agreeButtonActionBlock;
        viewController.notAgreeButtonActionBlock = notAgreeButtonActionBlock;
        viewController.startPage = [CMPCommonManager privacyAgreementUrl];
        viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [presentedController presentViewController:viewController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (BOOL)singlePopUpPrivacyProtocolPageWithPresentedController:(UIViewController *)presentedController
                                     beforePopPageBlock:(void (^)(void))beforePopPageBlock
                                 agreeButtonActionBlock:(void (^)(void))agreeButtonActionBlock
                              notAgreeButtonActionBlock:(void (^)(void))notAgreeButtonActionBlock {
#if CUSTOM
    if (![CMPCustomManager sharedInstance].cusModel.hasPrivacy) {
        if (agreeButtonActionBlock) {
            agreeButtonActionBlock();
        }
        return NO;
    }
#endif
    if(![self isAlreadySinglePopUpPrivacyProtocolPage]) {
        if (beforePopPageBlock) {
            beforePopPageBlock();
        }
        CMPPrivacyProtocolWebViewController *viewController = [[self alloc] init];
        viewController.agreeButtonActionBlock = agreeButtonActionBlock;
        viewController.notAgreeButtonActionBlock = notAgreeButtonActionBlock;
        viewController.startPage = [CMPCommonManager privacyAgreementUrl];
        viewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [presentedController presentViewController:viewController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (BOOL)isAlreadySinglePopUpPrivacyProtocolPage {
    BOOL singlePopUpPrivacyProtocolPageValue = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultName_SinglePopUpPrivacyProtocolPageFlag];
    if (singlePopUpPrivacyProtocolPageValue) {
        return YES;
    }
    return NO;
}

+ (void)setupSinglePopUpPrivacyProtocolPageFlag {
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultName_SinglePopUpPrivacyProtocolPageFlag];
}


/*
 获取网络权限状态
 */
- (void)_checkNetwork {
    __weak typeof(self) wSelf = self;
    //2.根据权限执行相应的交互
    CTCellularData *cellularData = [[CTCellularData alloc] init];
      
    /*
     此函数会在网络权限改变时再次调用
     */
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        switch (state) {
            case kCTCellularDataRestricted:
                  
                NSLog(@"Restricted");
                //2.1权限关闭的情况下 再次请求网络数据会弹出设置网络提示
               
                break;
            case kCTCellularDataNotRestricted:
                  
                NSLog(@"NotRestricted");
                //2.2已经开启网络权限 监听网络状态
                [wSelf refresh];
                
                break;
            case kCTCellularDataRestrictedStateUnknown:
                  
                NSLog(@"Unknown");
                [wSelf refresh];
               
                break;
                  
            default:
                [wSelf refresh];
                break;
        }
    };
}

-(void)refresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSURL *appURL = [self appUrl];
        if (appURL) {
            NSURLRequest* appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
            [self.webViewEngine loadRequest:appReq];
        }
        [self.indicator stopAnimating];
    });
    
}

@end
