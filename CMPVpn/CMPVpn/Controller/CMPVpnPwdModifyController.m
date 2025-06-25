//
//  CMPVpnPwdModifyController.m
//  CMPVpn
//
//  Created by SeeyonMobileM3MacMini2 on 2023/10/18.
//

#import "CMPVpnPwdModifyController.h"
#import <CMPLib/Masonry.h>
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/UIViewController+KSSafeArea.h>
#import <CMPLib/CMPThemeManager.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPVpnCommonTextField.h"
#import "CMPVpnManager.h"
#if defined(__arm64__) && defined(USE_SANGFOR_VPN)
#import <SangforSDK/SFUemSDK.h>
#endif

@interface CMPVpnPwdModifyController ()<UITextFieldDelegate>
{
    UILabel *_ruleLab;
    UIButton *_confirmBtn;
    NSString *_newPwd;
}
@property (nonatomic, strong) CMPVpnCommonTextField *vpnLoginPwdTF;
@property (nonatomic, strong) CMPVpnCommonTextField *vpnLoginPwdRepeatTF;

@end

@implementation CMPVpnPwdModifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cmp_colorWithName:@"p-bg"];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[[UIImage imageNamed:@"login_view_back_btn_icon"] cmp_imageWithTintColor:[UIColor cmp_colorWithName:@"cont-fc"]] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#92a4b5"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn sizeToFit];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15+10);
        make.top.offset(39+20);
    }];
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBtn setTitle:SY_STRING(@"common_save") forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    _confirmBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bdc"];
    [_confirmBtn setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
    _confirmBtn.layer.cornerRadius = 19.f;
    [_confirmBtn addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-25-20);
        make.height.equalTo(38);
        make.left.offset(35);
        make.right.offset(-35);
    }];
    
    UIView *contentV = [[UIView alloc] init];
    contentV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelBtn.mas_bottom).offset(31);
//        make.bottom.equalTo(confirmBtn.mas_top).offset(-20);
        make.left.offset(35);
        make.right.offset(-35);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = SY_STRING(@"vpn_setpwd");
//    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont boldSystemFontOfSize:20];
    [contentV addSubview:titleLab];
    [titleLab sizeToFit];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(0);
    }];
    
    
    _vpnLoginPwdTF = [CMPVpnCommonTextField new];
    _vpnLoginPwdTF.textField.placeholder = SY_STRING(@"vpn_inputnewpwd");
    _vpnLoginPwdTF.textField.secureTextEntry = YES;
    [contentV addSubview:_vpnLoginPwdTF];
    [_vpnLoginPwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLab.mas_bottom).offset(20);
        make.left.right.offset(0);
        make.height.mas_equalTo(44);
    }];
    
    _ruleLab = [[UILabel alloc] init];
//    if ([CMPVpnManager sharedInstance].resetPwdRuleJson) {
//        _ruleLab.text = [[@"*" stringByAppendingString:[CMPVpnManager sharedInstance].resetPwdRuleJson] replaceCharacter:@"\n" withString:@"\n*"];
//    }
    _ruleLab.text = [self _fixRuleJson];
    _ruleLab.numberOfLines = 0;
    _ruleLab.textColor = UIColorFromRGB(0x92A4B5);
    _ruleLab.font = [UIFont systemFontOfSize:14];
    [contentV addSubview:_ruleLab];
    [_ruleLab sizeToFit];
    [_ruleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(_vpnLoginPwdTF.mas_bottom).offset(5);
    }];
    
    _vpnLoginPwdRepeatTF = [CMPVpnCommonTextField new];
    _vpnLoginPwdRepeatTF.textField.placeholder = SY_STRING(@"vpn_inputnewpwdagain");
    _vpnLoginPwdRepeatTF.textField.secureTextEntry = YES;
    [contentV addSubview:_vpnLoginPwdRepeatTF];
    [_vpnLoginPwdRepeatTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_ruleLab.mas_bottom).offset(5);
        make.left.right.offset(0);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(contentV.mas_bottom);
    }];
    
    
    _vpnLoginPwdRepeatTF.textField.delegate = self;
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
    
    
    UIView *rightActionView2 = [[UIView alloc] init];
    rightActionView2.backgroundColor = [UIColor clearColor];
    rightActionView2.tag = 38;
    [_vpnLoginPwdRepeatTF addSubview:rightActionView2];
    [rightActionView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.offset(0);
    }];
    
    UIButton *_rightEyeBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightEyeBtn2.backgroundColor = UIColor.clearColor;
    [_rightEyeBtn2 setImage:[UIImage imageNamed:@"login_tf_check_pwd_icon"] forState:UIControlStateNormal];
    [_rightEyeBtn2 setImage:[UIImage imageNamed:@"login_tf_uncheck_pwd_icon"] forState:UIControlStateSelected];
    _rightEyeBtn2.selected = NO;
    [_rightEyeBtn2 addTarget:self action:@selector(eyeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightActionView2 addSubview:_rightEyeBtn2];
    [_rightEyeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.offset(5);
    }];
    [_vpnLoginPwdRepeatTF.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-40);
    }];
    rightActionView2.hidden = YES;
    
    
    [self enableConfirmBtn:NO];
    [_vpnLoginPwdTF.textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [_vpnLoginPwdRepeatTF.textField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    
    UIScreenEdgePanGestureRecognizer *reg = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnClicked)];
    reg.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:reg];
}

-(NSString *)_fixRuleJson
{
    NSString *s = [CMPVpnManager sharedInstance].resetPwdRuleJson;
    if (!s || !s.length) return @"";
    
    NSArray *arr = [s componentsSeparatedByString:@"\n"];
    if (!arr || arr.count == 0) return @"";
    __block NSString *temp = @"";
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        temp = [temp stringByAppendingString:[[[NSString stringWithFormat:@"%ld.",idx+1] stringByAppendingString:obj] stringByAppendingFormat:@"%@",(idx==arr.count-1 ? @"":@"\n")]];
    }];
    return temp;
}

-(void)enableConfirmBtn:(BOOL)enable
{
    if (!_confirmBtn) return;
    [_confirmBtn setEnabled:enable];
    if (enable) {
        [_confirmBtn setBackgroundColor:[UIColor cmp_colorWithName:@"theme-bgc"]];
        [_confirmBtn setTitleColor:[UIColor cmp_colorWithName:@"reverse-fc"] forState:UIControlStateNormal];
    } else {
        [_confirmBtn setBackgroundColor:[[UIColor cmp_colorWithName:@"theme-bgc"] colorWithAlphaComponent:0.3]];
        [_confirmBtn setTitleColor:[[UIColor cmp_colorWithName:@"reverse-fc"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    }
}


-(void)cancelBtnClicked
{
    BOOL conti = YES;
    if (_cancelBlk) {
        conti = _cancelBlk(nil,nil);
        if (!conti) return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationName_vpnpwdcancel" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)confirmBtnAction:(UIButton *)btn
{
    NSString *s = _vpnLoginPwdTF.textField.text;
    if (!s.length) {
        [self cmp_showHUDWithText:@"请输入重置密码"];
        return;
    }
    NSString *s2 = _vpnLoginPwdRepeatTF.textField.text;
    if (!s2.length) {
        [self cmp_showHUDWithText:@"请输入重置密码"];
        return;
    }
    if (![s isEqualToString:s2]) {
        [self cmp_showHUDWithText:SY_STRING(@"vpn_inputnewpwd_notsame")];
        return;
    }
#if defined(__arm64__) && defined(USE_SANGFOR_VPN)
    CMPServerVpnModel *vpnModel = [CMPVpnManager sharedInstance].vpnConfig;
    [[SFUemSDK sharedInstance] doSecondaryAuth:SFAuthTypeRenewPassword data:@{kAuthKeyRenewOldPassword:vpnModel.vpnLoginPwd,kAuthKeyRenewNewPassword:s}];
#endif
    _newPwd = s;
}

#if defined(__arm64__) && defined(USE_SANGFOR_VPN)
- (BOOL)onAuthFailed:(BaseMessage *)msg
{
    _newPwd = @"";
    if (msg && msg.errStr && [msg isKindOfClass:SFResetPswMessage.class]) {
        if (msg.errCode == 75500001) {
            msg.errStr = SY_STRING(@"vpn_renewpwd_overtime");
        }
        [self cmp_showHUDWithText:msg.errStr];
        return NO;
    }
    return YES;
}

- (BOOL)onAuthSuccess:(BaseMessage *)msg
{
    [[CMPVpnManager sharedInstance] updatePwd:_newPwd];
    if ([CMPVpnManager sharedInstance].loginProcessBlock) {
        NSDictionary *msgDic = @{@"serverInfo":@"vpn修改密码成功",@"authType":@(SFAuthTypeRenewPassword),@"status":@(200)};
        NSLog(@"vpn loginProcessBlock");
        [CMPVpnManager sharedInstance].loginProcessBlock(msgDic,@(NO));
    }
    [self cmp_showHUDWithText:SY_STRING(@"vpn_renewpwd_success") completionBlock:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    return NO;
}
#endif

- (void)eyeBtnClicked:(UIButton *)btn {
    CMPFuncLog;
    CMPVpnCommonTextField *f = btn.superview.superview;
    f.textField.secureTextEntry = btn.selected;
    btn.selected = !btn.selected;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


-(void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    NSLog(@"%@",textField.text);
    
    UIView *rightActView = [textField.superview viewWithTag:38];
    if (rightActView) {
        rightActView.hidden = !(textField.text.length>0);
    }
    
    if (_vpnLoginPwdTF.textField.text.length && _vpnLoginPwdRepeatTF.textField.text.length) {
        [self enableConfirmBtn:YES];
    } else {
        [self enableConfirmBtn:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *rightActView = [textField.superview viewWithTag:38];
    if (rightActView) {
        rightActView.hidden = !(textField.text.length>0);
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *rightActView = [textField.superview viewWithTag:38];
    if (rightActView) {
        rightActView.hidden = YES;
    }
}

@end
