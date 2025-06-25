//
//  CMPSMSGraphVerView.m
//  M3
//
//  Created by zy on 2022/3/1.
//

#import "CMPSMSGraphVerView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/NSObject+CMPHUDView.h>
#import "CMPNewPhoneCodeLoginProvider.h"
#import <CMPLib/CMPCommonTool.h>
#import <CMPLib/UIImageView+WebCache.h>
#import "AppDelegate.h"

@interface CMPSMSGraphVerView ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) CMPNewPhoneCodeLoginProvider *provider;

@end

@implementation CMPSMSGraphVerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    
    CGFloat containerWidth = CMP_SCREEN_WIDTH - 60;
    CGFloat containerHeight = 195;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(30, 0, containerWidth, containerHeight)];
    containerView.backgroundColor = [UIColor cmp_colorWithName:@"alert-bg"];
    containerView.userInteractionEnabled = YES;
    containerView.cmp_centerY = CMP_SCREEN_HEIGHT/2 - 100;
    containerView.layer.cornerRadius = 6;
    containerView.clipsToBounds = YES;
    [self addSubview:containerView];
    
    
    NSString *tips = SY_STRING(@"login_sms_graph_ver_tips");
    UIFont *font = FONTBOLDSYS(16);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, containerWidth, 22)];
    titleLabel.font = font;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = tips;
    [containerView addSubview:titleLabel];


    CGFloat textFieldHeight = 44.0f;
    
    UIView *textFieldContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 56, containerWidth - 40, textFieldHeight)];
    textFieldContainer.userInteractionEnabled = YES;
    textFieldContainer.backgroundColor = [UIColor cmp_colorWithName:@"input-bg"];
    textFieldContainer.layer.cornerRadius = 6;
    textFieldContainer.clipsToBounds = YES;
    [containerView addSubview:textFieldContainer];
    
    UIImageView *graphImageView = [[UIImageView alloc] initWithFrame:CGRectMake(textFieldContainer.width - 70, 2, 68, 40)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(graphImageAciton)];
    [graphImageView addGestureRecognizer:tap];
    [graphImageView setUserInteractionEnabled:YES];
    self.codeImageView = graphImageView;
    
    UITextField *_textField = [UITextField.alloc initWithFrame:CGRectMake(0, 0, textFieldContainer.width - 70, textFieldHeight)];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 10.f, textFieldHeight)];
    _textField.font = [UIFont boldSystemFontOfSize:16.f];
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.delegate = self;
    _textField.keyboardType = UIKeyboardTypeASCIICapable;
    [textFieldContainer addSubview:_textField];
    [textFieldContainer addSubview:graphImageView];

    self.textField = _textField;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, textFieldContainer.cmp_bottom + 2, containerWidth - 40, 17)];
    tipsLabel.font = [UIFont systemFontOfSize:12];
    tipsLabel.textColor = [UIColor colorWithHexString:@"#FF4141"];
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.text = SY_STRING(@"login_sms_graph_ver_input_error");
    [containerView addSubview:tipsLabel];
    tipsLabel.hidden = YES;
    self.tipsLabel = tipsLabel;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:SY_STRING(@"common_cancel") forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cnacelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    cancelButton.frame = CGRectMake(0, 140, 155, 54);
    [containerView addSubview:cancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:SY_STRING(@"common_ok") forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor cmp_colorWithName:@"theme-fc"] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    confirmButton.frame = CGRectMake(156, 140, 155, 54);
    [containerView addSubview:confirmButton];
    
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 140, containerWidth, 0.5)];
    horizontalLine.backgroundColor = [UIColor colorWithHexString:@"#E4E4E4"];
    [containerView addSubview:horizontalLine];
    
    UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(155, containerHeight - 19 - 16, 1, 16)];
    verticalLine.backgroundColor = [UIColor colorWithHexString:@"#E4E4E4"];
    [containerView addSubview:verticalLine];
    
    self.alpha = 0;
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.height.equalTo(195);
        make.left.offset(30);
        make.right.offset(-30);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14);
        make.height.equalTo(20);
        make.centerX.offset(0);
    }];
    [textFieldContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(56);
        make.height.equalTo(44);
        make.left.offset(20);
        make.right.offset(-20);
    }];
    [graphImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(2);
        make.height.equalTo(40);
        make.width.equalTo(68);
        make.right.offset(-1);
    }];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.right.equalTo(graphImageView.mas_left).offset(-1);
    }];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textFieldContainer.mas_bottom).offset(2);
        make.height.equalTo(17);
        make.left.offset(20);
        make.right.offset(-20);
    }];
    
    [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(140);
        make.height.equalTo(0.5);
        make.left.right.offset(0);
    }];
    [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-19);
        make.height.equalTo(16);
        make.width.equalTo(1);
        make.centerX.offset(0);
    }];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(horizontalLine.mas_bottom).offset(0);
        make.left.bottom.offset(0);
        make.right.equalTo(verticalLine.mas_left);
    }];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(horizontalLine.mas_bottom).offset(0);
        make.right.bottom.offset(0);
        make.left.equalTo(verticalLine.mas_right);
    }];
    
    [self showViewWithAnimate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if (textField.text.length >= 4) {
        return NO;
    }
    return YES;
}

- (void)showViewWithAnimate {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        [self.textField becomeFirstResponder];
    }];
}

- (void)cnacelButtonAction {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.cancelBtnClicked) {
            self.cancelBtnClicked();
        }
        [self removeFromSuperview];
    }];
}

- (void)graphImageAciton {
    [self downloadCodeImage];
}

- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
    [self downloadCodeImage];
}

- (void)downloadCodeImage {
    __weak typeof(self) wSelf = self;
    [self.codeImageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (wSelf.verifyCodeImgDownloadCallback) {
            wSelf.verifyCodeImgDownloadCallback(image, error);
        }
    }];
}

- (void)confirmButtonAction {
    if ([NSString isNull:self.textField.text]) {
        //[self cmp_showHUDWithText:SY_STRING(@"login_verification_code_can_not_be_null")];
        self.tipsLabel.hidden = NO;
        self.tipsLabel.text = SY_STRING(@"login_verification_code_null_tips");
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.provider phoneCodeLoginWithGetPhoneCode:self.phoneNumber verifyCode:self.textField.text extParams:nil success:^(NSString * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        NSDictionary *dict = [CMPCommonTool dictionaryWithJsonString:response];
        NSNumber *code = dict[@"code"];
        if (code.intValue == 0) {
            [weakSelf confirmCallback];
            return;
        }
        weakSelf.tipsLabel.hidden = NO;
        self.tipsLabel.text = SY_STRING(@"login_sms_graph_ver_input_error");
        NSString *msg = [NSString stringWithFormat:@"%@",dict[@"message"]];
        if (code.intValue == 8) {
            msg = @"您的账号需要双因子认证，请使用账号密码方式登录";
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:cancel];
            
            UIViewController *vc = [AppDelegate shareAppDelegate].window.rootViewController;
            [vc presentViewController:ac animated:YES completion:^{
                [weakSelf cnacelButtonAction];
            }];
        }else{
            self.tipsLabel.text = msg;
        }
    } fail:^(NSError * _Nonnull response, NSDictionary * _Nonnull userInfo) {
        if (response && response.code == -1011) {
            NSString *msg = response.domain ? : @"您的账号需要双因子认证，请使用账号密码方式登录";
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:SY_STRING(@"common_ok") style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:cancel];
            
            UIViewController *vc = [AppDelegate shareAppDelegate].window.rootViewController;
            [vc presentViewController:ac animated:YES completion:^{
                [weakSelf cnacelButtonAction];
            }];
            return;
        }
        weakSelf.tipsLabel.hidden = NO;
        self.tipsLabel.text = SY_STRING(@"login_sms_graph_ver_input_error");
    }];
}

- (void)confirmCallback {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.confirmBtnClicked) {
            self.confirmBtnClicked(self.textField.text);
        }
        [self removeFromSuperview];
    }];
}

- (CMPNewPhoneCodeLoginProvider *)provider {
    if (!_provider) {
        _provider = [[CMPNewPhoneCodeLoginProvider alloc] init];
    }
    return _provider;
}

@end
