//
//  CMPVpnEnterView.m
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/7.
//

#import "CMPVpnEnterView.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/Masonry.h>
#import "CmpVpnSetController.h"
@interface CMPVpnEnterView()
@property (nonatomic, assign) BOOL vpnStatus;
@property (nonatomic, strong) UIButton *setBtn;
//@property (nonatomic, copy) void(^vpnSetResultBlock)(NSString *vpnUrl, NSString *vpnLoginName, NSString *vpnLoginPwd);
@property (nonatomic, strong) UIViewController *fromVC;
@end
@implementation CMPVpnEnterView

- (instancetype)initWithFromViewController:(UIViewController *)fromVC{
    if (self = [super init]) {
#if defined(__arm64__)
        [self configViews];
        self.fromVC = fromVC;
#endif
    }
    return self;
}
//- (instancetype)initWithFromViewController:(UIViewController *)fromVC vpnSetResult:(void (^)(NSString *vpnUrl, NSString *vpnLoginName, NSString *vpnLoginPwd))vpnSetResultBlock{
//    if (self = [super init]) {
//        [self configViews];
//        self.vpnSetResultBlock = vpnSetResultBlock;
//        self.fromVC = fromVC;
//    }
//    return self;
//}

- (void)configViews{
    CGFloat spacing = 10;
    CGFloat labelW = 50;
    CGFloat lineW = (self.frame.size.width - labelW - 2*spacing)/2;
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = SY_STRING(@"vpn_set_toplevel");//SY_STRING(@"");
    titleLabel.frame = CGRectMake(0, 0, labelW, 18);
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(18);
    }];
    
    UIView *leftLine = [[UIView alloc]init];
    leftLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
    [self addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(titleLabel.mas_left).offset(-10);
    }];
    
    UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, lineW, 0.5)];
    rightLine.backgroundColor = [UIColor cmp_colorWithName:@"cmp-bdc"];
    [self addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.centerY.mas_equalTo(titleLabel);
        make.left.mas_equalTo(titleLabel.mas_right).offset(10);
    }];
    
    _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _setBtn.frame = CGRectMake(0, 0, 106, 30);
    [_setBtn setTitle:SY_STRING(@"vpn_set_btntitle") forState:(UIControlStateNormal)];
    _setBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_setBtn setTitleColor:[UIColor cmp_colorWithName:@"cont-fc"] forState:(UIControlStateNormal)];
//    [_setBtn setImage:[UIImage imageNamed:@"liveListShareBg"] forState:(UIControlStateNormal)];//CmpVpn.bundle/checked.png
    [_setBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    _setBtn.layer.borderWidth = 1.f;
    _setBtn.layer.borderColor = [UIColor cmp_colorWithName:@"cmp-bdc"].CGColor;
    _setBtn.layer.cornerRadius = 15.f;
    [_setBtn addTarget:self action:@selector(vpnBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self addSubview:_setBtn];
    [_setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(titleLabel);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
        make.width.mas_offset(106);
        make.height.mas_equalTo(30);
    }];
}

- (void)setVpnStatus:(BOOL)vpnOn{
    _vpnStatus = vpnOn;
    NSString *title = SY_STRING(@"vpn_set_btntitle");
    if (_vpnStatus) {
        [_setBtn setImage:[UIImage imageNamed:@"vpn_statuson"] forState:(UIControlStateNormal)];
        title = SY_STRING(@"vpn_set_btntitledone");
    }else{
        [_setBtn setImage:nil forState:(UIControlStateNormal)];
    }
    [_setBtn setTitle:title forState:(UIControlStateNormal)];
}

- (void)vpnBtnClick:(id)sender{
    if (self.fromVC) {
        CmpVpnSetController *vc = [[CmpVpnSetController alloc]initWithVpnUrl:self.vpnUrl vpnLoginName:self.vpnLoginName vpnLoginPwd:self.vpnLoginPwd spa:self.vpnSPA];
        __weak typeof(self) wSelf = self;
        vc.SubmitBlock = ^(NSString *vpnUrl, NSString *vpnLoginName, NSString *vpnLoginPwd,id ext) {
            if (![NSString isNull:vpnUrl]
                && ![NSString isNull:vpnLoginName]
                && ![NSString isNull:vpnLoginPwd]) {
                [wSelf setVpnStatus:YES];
                //vpn数据传回
//                if (wSelf.vpnSetResultBlock) {
//                    wSelf.vpnSetResultBlock(vpnUrl,vpnLoginName,vpnLoginPwd);
//                }
            }else{
                [wSelf setVpnStatus:NO];
            }
            wSelf.vpnUrl = vpnUrl;
            wSelf.vpnLoginName = vpnLoginName;
            wSelf.vpnLoginPwd = vpnLoginPwd;
            wSelf.contentChanged = [ext[@"contentChanged"] boolValue];
            wSelf.vpnSPA = ext[@"spa"];
        };
        [self.fromVC.navigationController pushViewController:vc animated:YES];
    }
}

@end
