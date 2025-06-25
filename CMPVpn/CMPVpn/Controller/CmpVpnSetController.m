//
//  CmpVpnSetController.m
//  CMPVpn
//
//  Created by Shoujian Rao on 2022/4/8.
//

#import "CmpVpnSetController.h"
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/Masonry.h>
#import "CMPVpnCommonTextField.h"
#import <CMPLib/CMPCommonWebViewController.h>
#import <CMPLib/NSObject+CMPHUDView.h>

@interface CmpVpnSetController ()<UITextFieldDelegate>

@property (nonatomic, strong) CMPVpnCommonTextField *vpnAddressTF;
@property (nonatomic, strong) CMPVpnCommonTextField *vpnLoginNameTF;
@property (nonatomic, strong) CMPVpnCommonTextField *vpnLoginPwdTF;
@property (nonatomic, strong) CMPVpnCommonTextField *vpnSPATF;

@property (nonatomic, copy) NSString *vpnUrl;
@property (nonatomic, copy) NSString *vpnLoginName;
@property (nonatomic, copy) NSString *vpnLoginPwd;
@property (nonatomic, copy) NSString *vpnSPA;

@property (nonatomic, assign) BOOL contentChanged;

@end

@implementation CmpVpnSetController

- (instancetype)initWithVpnUrl:(NSString *)vpnUrl vpnLoginName:(NSString *)vpnLoginName vpnLoginPwd:(NSString *)vpnLoginPwd spa:(NSString *)spa{
    if (self = [super init]) {
        self.vpnUrl = vpnUrl;
        self.vpnLoginName = vpnLoginName;
        self.vpnLoginPwd = vpnLoginPwd;
        self.vpnSPA = spa;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    [self setupView];
    if (![NSString isNull:self.vpnUrl]) {
        self.vpnAddressTF.textField.text = self.vpnUrl;
    }
    if (![NSString isNull:self.vpnLoginName]) {
        self.vpnLoginNameTF.textField.text = self.vpnLoginName;
    }
    if (![NSString isNull:self.vpnLoginPwd]) {
        self.vpnLoginPwdTF.textField.text = self.vpnLoginPwd;
    }
    if (![NSString isNull:self.vpnSPA]) {
        self.vpnSPATF.textField.text = self.vpnSPA;
    }
//    self.vpnAddressTF.textField.text = @"https://ztna.safeapp.com.cn:60201";
//    self.vpnLoginNameTF.textField.text = @"zy";
//    self.vpnLoginPwdTF.textField.text = @"zhiyuan@123";
    
    [self registerContentChangedAction];
}

- (void)setupView{
    CGFloat naviHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat marginLeft = 35.f;
    //返回
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"login_view_back_btn_icon"] forState:(UIControlStateNormal)];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.5);
        make.top.mas_equalTo(naviHeight + 19);
        make.width.height.mas_equalTo(30);
    }];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //title
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = SY_STRING(@"vpn_set_btntitle");
    titleLabel.font = [UIFont systemFontOfSize:20 weight:(UIFontWeightSemibold)];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(35);
        make.top.mas_equalTo(naviHeight + 70);
    }];
    
    //vpnAddress
    _vpnAddressTF = [CMPVpnCommonTextField new];
    _vpnAddressTF.textField.placeholder = SY_STRING(@"vpn_set_enteraddress");
    [self.view addSubview:_vpnAddressTF];
    [_vpnAddressTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(30);
    }];
    //verify label
    UILabel *verifyLabel = UILabel.new;
    verifyLabel.text = SY_STRING(@"vpn_set_pwdverify");
    verifyLabel.font = [UIFont systemFontOfSize:12];
    verifyLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
    [self.view addSubview:verifyLabel];
    [verifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.vpnAddressTF.mas_bottom).offset(10);
        make.left.mas_equalTo(marginLeft);
    }];
    
    //vpn login name
    _vpnLoginNameTF = [CMPVpnCommonTextField new];
    _vpnLoginNameTF.textField.placeholder = SY_STRING(@"vpn_set_entername");
    [self.view addSubview:_vpnLoginNameTF];
    [_vpnLoginNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(verifyLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.height.mas_equalTo(44);
    }];
    //vpn pwd
    _vpnLoginPwdTF = [CMPVpnCommonTextField new];
    _vpnLoginPwdTF.textField.placeholder = SY_STRING(@"vpn_set_enterpwd");
    _vpnLoginPwdTF.textField.secureTextEntry = YES;
    [self.view addSubview:_vpnLoginPwdTF];
    [_vpnLoginPwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.vpnLoginNameTF.mas_bottom).offset(10);
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.height.mas_equalTo(44);
    }];
    
    _vpnAddressTF.textField.delegate = self;
    _vpnLoginNameTF.textField.delegate = self;
    _vpnLoginPwdTF.textField.delegate = self;
    UIView *rightActionView = [[UIView alloc] init];
    rightActionView.backgroundColor = [UIColor clearColor];
    rightActionView.tag = 38;
    [_vpnLoginPwdTF addSubview:rightActionView];
    [rightActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.offset(0);
    }];
    
    UIButton *_rightEyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightEyeBtn.backgroundColor = UIColor.clearColor;
    [_rightEyeBtn setImage:[UIImage imageNamed:@"login_tf_check_pwd_icon"] forState:UIControlStateNormal];
    [_rightEyeBtn setImage:[UIImage imageNamed:@"login_tf_uncheck_pwd_icon"] forState:UIControlStateSelected];
    _rightEyeBtn.selected = NO;
    [_rightEyeBtn addTarget:self action:@selector(eyeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightActionView addSubview:_rightEyeBtn];
    [_rightEyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.offset(5);
    }];
    
    [_vpnLoginPwdTF.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-40);
    }];
    rightActionView.hidden = YES;
    
    UILabel *spaTitleLabel = UILabel.new;
    spaTitleLabel.text = SY_STRING(@"vpn_set_spaverify");
    spaTitleLabel.font = [UIFont systemFontOfSize:12];
    spaTitleLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
    [self.view addSubview:spaTitleLabel];
    [spaTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_vpnLoginPwdTF.mas_bottom).offset(10);
        make.left.mas_equalTo(marginLeft);
    }];
    
    _vpnSPATF = [CMPVpnCommonTextField new];
    _vpnSPATF.textField.placeholder = SY_STRING(@"vpn_set_spaentercode");
    [self.view addSubview:_vpnSPATF];
    [_vpnSPATF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(spaTitleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.height.mas_equalTo(44);
    }];
    
    //desc label
    UILabel *descLabel = UILabel.new;
    descLabel.text = SY_STRING(@"vpn_set_description");
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont systemFontOfSize:12];
    descLabel.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
    [self.view addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.top.mas_equalTo(_vpnSPATF.mas_bottom).offset(12);
    }];
    
    //privacy
    UIView *_policyView = [[UIView alloc] init];
    [self.view addSubview:_policyView];
    [_policyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(marginLeft);
        make.top.mas_equalTo(descLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *descLabel2 = UILabel.new;
    descLabel2.text = SY_STRING(@"vpn_set_agreedes");
    descLabel2.numberOfLines = 1;
    descLabel2.font = [UIFont systemFontOfSize:12];
    descLabel2.textColor = [UIColor cmp_colorWithName:@"sup-fc2"];
    [descLabel2 sizeToFit];
    [_policyView addSubview:descLabel2];
    [descLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.offset(0);
    }];
    
    UIButton *privacyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [privacyBtn setTitle:SY_STRING(@"vpn_set_privacy") forState:(UIControlStateNormal)];
    [privacyBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bdc"] forState:(UIControlStateNormal)];
    privacyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [privacyBtn sizeToFit];
    [_policyView addSubview:privacyBtn];
    [privacyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(descLabel2.mas_right);
        make.centerY.offset(0);
        make.top.mas_equalTo(descLabel.mas_bottom).offset(6);
        make.right.offset(0);
    }];
    [privacyBtn addTarget:self action:@selector(privacyBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //submit btn
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setTitle:SY_STRING(@"vpn_set_submit") forState:(UIControlStateNormal)];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    submitBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bdc"];
    submitBtn.layer.cornerRadius = 20.f;
    [self.view addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(marginLeft);
        make.right.mas_equalTo(-marginLeft);
        make.top.mas_equalTo(privacyBtn.mas_bottom).offset(30);
        make.height.mas_equalTo(40);
    }];
    [submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    _vpnSPATF.textField.delegate = self;
}


- (void)eyeBtnClicked:(UIButton *)btn {
    CMPFuncLog;
    _vpnLoginPwdTF.textField.secureTextEntry = btn.selected;
    btn.selected = !btn.selected;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)privacyBtnClick:(id)sender{
//    NSLog(@"privacyBtnClick");
//    NSString *url = @"https://bbs.sangfor.com.cn/atrustdeveloper/%E6%B7%B1%E4%BF%A1%E6%9C%8D%E9%9B%B6%E4%BF%A1%E4%BB%BBSDK%E9%9A%90%E7%A7%81%E5%8D%8F%E8%AE%AE.html";
    NSString *url = @"https://bbs.sangfor.com.cn/atrustdeveloper/appsdk/common/zero_trust_protocol.html";
    CMPCommonWebViewController *ctrl = [[CMPCommonWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)submitBtnClick:(id)sender{
    NSLog(@"submitBtnClick");
    
    self.vpnUrl = self.vpnAddressTF.textField.text;
    self.vpnLoginName = self.vpnLoginNameTF.textField.text;
    self.vpnLoginPwd = self.vpnLoginPwdTF.textField.text;
    self.vpnSPA = self.vpnSPATF.textField.text;
    //TODO 验证url、登录名、密码格式
    BOOL con1 = self.vpnUrl.length && self.vpnLoginName.length && self.vpnLoginPwd.length;
    BOOL con2 = !self.vpnUrl.length && !self.vpnLoginName.length && !self.vpnLoginPwd.length;
    
    if (con1 || con2) {
//        if (con1) {
//            NSURL *url = [NSURL URLWithString:self.vpnUrl];
//            if (!url || ![[UIApplication sharedApplication] canOpenURL:url]) {
//                [self cmp_showHUDWithText:@"请输入正确的VPN地址"];
//                return;
//            }
//        }
        if (self.SubmitBlock) {
            self.SubmitBlock(self.vpnUrl, self.vpnLoginName, self.vpnLoginPwd,@{@"contentChanged":@(_contentChanged),@"spa":_vpnSPA?:@""});
        }
//        [self cmp_showHUDWithText:@"设置成功"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    //tip
    [self cmp_showHUDWithText:SY_STRING(@"vpn_set_blanktip")];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


-(BOOL)registerContentChangedAction
{
    [_vpnAddressTF.textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [_vpnLoginNameTF.textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [_vpnLoginPwdTF.textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    return YES;
}

-(void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSLog(@"%@",textField.text);
    _contentChanged = YES;
    
    UIView *rightActView = [_vpnLoginPwdTF viewWithTag:38];
    if (rightActView) {
        if ([textField isEqual:_vpnLoginPwdTF.textField] && textField.isFirstResponder) {
            rightActView.hidden = !(textField.text.length>0);
        }else{
            rightActView.hidden = YES;
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *rightActView = [_vpnLoginPwdTF viewWithTag:38];
    if (rightActView) {
        if ([textField isEqual:_vpnLoginPwdTF.textField]) {
            rightActView.hidden = !(textField.text.length>0);
        }else{
            rightActView.hidden = YES;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *rightActView = [_vpnLoginPwdTF viewWithTag:38];
    if (rightActView) {
        rightActView.hidden = YES;
    }
}

@end
