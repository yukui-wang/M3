//
//  CMPAuthCodeInputView.m
//  M3
//
//  Created by SeeyonMobileM3MacMini2 on 2023/9/19.
//

#import "CMPAuthCodeInputView.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/Masonry.h>
#import <CMPLib/CMPConstant.h>
#import <CMPLib/MSWeakTimer.h>

@implementation AuthCodeTextField

-(instancetype)init{
    if(self = [super init]){
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = RGB_COLOR(236, 237, 246);
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.textColor = [UIColor blackColor];
       // iOS12.0 系统之后，可以自动获取短信中的验证码
        if(@available(iOS 12.0,*)){
            self.textContentType = UITextContentTypeOneTimeCode;
        }
    }
    return self;
}
// 把这个代理方法传递出去
-(void)deleteBackward{
    if(self.text.length == 1){
        self.text = @"";
        return;
    }
    if(self.text.length == 0){
        if([self.auth_delegate respondsToSelector:@selector(authCodeTextFieldDeleteBackward:)]){
            [self.auth_delegate authCodeTextFieldDeleteBackward:self];
        }
    }
    [super deleteBackward];
}

@end


///////////////////
CGFloat spMargin_left = 20, spMargin_right = 20, codeView_width = 40, codeView_height = 44;
NSUInteger codeView_count = 6;

@interface CMPAuthCodeInputView () <UITextFieldDelegate,AuthCodeDeleteDelegate>
{
    BOOL _autoFetch;
}
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) UIView *backGround;
@property (nonatomic,strong) NSMutableArray *tfArr;
@property (nonatomic,strong) NSString *codeStr;
@property (nonatomic,strong) UIButton *fetchBtn;
/* 定时器，用于获取验证码 */
@property (strong, nonatomic) MSWeakTimer *timer;
/* 倒计时 */
@property (assign, nonatomic) int count;

@end

@implementation CMPAuthCodeInputView

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
    _timer = nil;
}

-(instancetype)initWithFrame:(CGRect)frame andPhone:(NSString *)phone autoFetch:(BOOL)autoFetch{
    if(self = [super initWithFrame:frame])
    {
        _phone = phone;
        _autoFetch = autoFetch;
        [self createSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillShow:)
                                                         name:UIKeyboardWillShowNotification
                                                       object:nil];
    }
    return self;
}



-(void)createSubviews
{
    _backGround = [[UIView alloc]init];
    _backGround.backgroundColor = [UIColor clearColor];
    [self addSubview:_backGround];
    _backGround.layer.cornerRadius = 10;
    _backGround.layer.masksToBounds = YES;
    
    [_backGround mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(0);
        make.right.offset(0);
        make.height.mas_equalTo(400);
//        make.bottom.mas_equalTo(-400);
    }];
   
    UIView *_tempView;
//    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [closeBtn setImage:[UIImage imageNamed:@"alert_close"] forState:UIControlStateNormal];
//    [closeBtn addTarget:self action:@selector(closeAuthCodeInputView) forControlEvents:UIControlEventTouchUpInside];
//    [_backGround addSubview:closeBtn];
//    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.top.mas_equalTo(10);
//        make.width.height.mas_equalTo(40);
//    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = SY_STRING(@"login_mutilauth_pleaseinputsms");
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont boldSystemFontOfSize:20];
    [_backGround addSubview:titleLab];
    [titleLab sizeToFit];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spMargin_left);
        make.right.mas_equalTo(-spMargin_right);
        make.top.mas_equalTo(32);
    }];
    
    _tempView = titleLab;
    
    NSString *phoneStr = @"";
    if(_phone.length > 7){
        phoneStr = [_phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    
    UILabel *textLab = [[UILabel alloc]init];
    textLab.text = [NSString stringWithFormat:@"%@%@",SY_STRING(@"login_mutilauth_smshassendto"),phoneStr];
    textLab.textColor = RGB_COLOR(153, 153, 153);
    textLab.font = [UIFont systemFontOfSize:16];
    textLab.numberOfLines = 0;
    [_backGround addSubview:textLab];
//    CGSize textLabSize = [textLab sizeThatFits:CGSizeMake(CMP_SCREEN_WIDTH-65, CGFLOAT_MAX)];
    [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spMargin_left);
        make.top.equalTo(titleLab.mas_bottom).offset(15);
        make.right.mas_equalTo(-spMargin_right);
//        make.height.mas_equalTo(textLabSize.height);
    }];
    
    _tempView = textLab;
    
    self.tfArr = [NSMutableArray array];
    // 六个输入框
    NSInteger count = codeView_count;
    CGFloat width = codeView_width;
    CGFloat height = codeView_height;
    for (int i = 1 ; i < count+1; i ++) {
        AuthCodeTextField *textF = [[AuthCodeTextField alloc]init];
        textF.tag = 10+i;
        textF.auth_delegate = self;
        textF.delegate = self;
        [_backGround addSubview:textF];
        [self.tfArr addObject:textF];
        if(i == 1 && _autoFetch){
            [textF becomeFirstResponder];
        }
        [textF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(textLab.mas_bottom).offset(25);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
        }];
    }
    
    _tempView = [self.tfArr firstObject];
    
    _fetchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fetchBtn addTarget:self action:@selector(_fetchSmsAction) forControlEvents:UIControlEventTouchUpInside];
    _fetchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _fetchBtn.backgroundColor = UIColor.clearColor;
    [_fetchBtn sizeToFit];
    [_backGround addSubview:_fetchBtn];
    [_fetchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(spMargin_left);
        make.top.mas_equalTo(_tempView.mas_bottom).offset(16);
    }];
    [self switchFetchBtnState:1];
    
    _tempView = _fetchBtn;
    
     // 确认按钮
//    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
//    [sureBtn addTarget:self action:@selector(checkAuthcode) forControlEvents:UIControlEventTouchUpInside];
//    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    sureBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//    sureBtn.backgroundColor = RGB_COLOR(96, 138, 190);
//    [_backGround addSubview:sureBtn];
//    sureBtn.layer.cornerRadius = 45/2;
//    sureBtn.layer.masksToBounds = YES;
//    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(75/2);
//        make.right.mas_equalTo(-75/2);
//        make.height.mas_equalTo(45);
//        make.bottom.mas_equalTo(-32);
//    }];
    
    if (_autoFetch) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self _fetchSmsAction];
        });
    }
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_backGround) {
        CGFloat w = _backGround.frame.size.width;
        if (codeView_count > 1) {
            CGFloat sp = (w - spMargin_left - spMargin_right - codeView_width*codeView_count)*1.00/(codeView_count-1);
            for (int i = 1 ; i < codeView_count+1; i ++) {
                AuthCodeTextField *textF = [_backGround viewWithTag:10+i];
                if (textF) {
                    [textF mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.left.offset(spMargin_left+(i-1)*(codeView_width+sp));
                    }];
                }
            }
        }
    }
}

#pragma mark  UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
// 获取短信中提取的验证码，自动输入到输入框中
    if(string.length > 1){
        self.codeStr = @"";
        for (int i = 0 ; i < self.tfArr.count; i++) {
            AuthCodeTextField *tf = self.tfArr[i];
            tf.text = [string substringWithRange:NSMakeRange(i, 1)];
            self.codeStr = [self.codeStr stringByAppendingString:tf.text];
        }
        [textField resignFirstResponder];
        if (_autoFetch) {
            [self checkAuthcode];
        }
        return NO;
    }
    NSInteger nextTag = textField.tag + 1;
    UITextField *nextTextField = [self viewWithTag:nextTag];
    if(string.length > 0){
        textField.text = string;
        if (nextTextField) {
            [nextTextField becomeFirstResponder];
        }
        else
        {
            self.codeStr = @"";
            for (AuthCodeTextField *tf in self.tfArr) {
                self.codeStr = [self.codeStr stringByAppendingString:tf.text];
            }
            [textField resignFirstResponder];
            if (_autoFetch) {
                [self checkAuthcode];
            }
        }
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)_fetchSmsAction
{
    if (_fetchSmsAction) {
        _fetchSmsAction();
    }
}
// 调用接口验证验证码正确性
-(void)checkAuthcode
{
    if(self.codeStr.length < codeView_count){
      //验证码不足六位
        if (_smsCodeChangeAction) {
            _smsCodeChangeAction(_codeStr,NO);
        }
        return;
    }
    if (_smsCodeChangeAction) {
        _smsCodeChangeAction(_codeStr,YES);
    }
}

-(void)closeAuthCodeInputView{
//    [self removeFromSuperview];
}

/*
 state 1:重新获取+倒计时,不可点击   2:重新获取验证码 无倒计时，可点击。 default：获取验证码，可点击
 */
-(void)switchFetchBtnState:(NSInteger)state
{
    switch (state) {
        case 1:
        {
            [_fetchBtn setTitle:SY_STRING(@"login_mutilauth_refetch") forState:UIControlStateNormal];
            [_fetchBtn setTitleColor:UIColorFromRGB(0x92A4B5) forState:UIControlStateNormal];
            _fetchBtn.enabled = NO;
        }
            break;
        case 2:
        {
            [_fetchBtn setTitle:SY_STRING(@"login_mutilauth_refetchsms") forState:UIControlStateNormal];
            [_fetchBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
            _fetchBtn.enabled = YES;
        }
            break;
            
        default:
        {
            [_fetchBtn setTitle:SY_STRING(@"login_mutilauth_refetchsms") forState:UIControlStateNormal];
            [_fetchBtn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
            _fetchBtn.enabled = YES;
        }
            break;
    }
}


- (void)fireCountdonwTimer:(NSInteger)count {
    self.count = count>=0 ? count : 0;
    [self switchFetchBtnState:1];
    [_timer invalidate];
    _timer = nil;
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countdown) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self.timer fire];
}

- (void)countdown {
    if (self.count <= 0) {
        [self switchFetchBtnState:2];
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    NSInteger second = self.count;
    NSString *leftTime = [NSString stringWithFormat:@"%@ (%ld%@)",SY_STRING(@"login_mutilauth_refetch"),(long)second,SY_STRING(@"login_mutilauth_seconds")];
    [_fetchBtn setTitle:leftTime forState:UIControlStateDisabled];
    self.count--;
}

-(void)clearCodes
{
    self.codeStr = @"";
    for (int i = 0 ; i < self.tfArr.count; i++) {
        AuthCodeTextField *tf = self.tfArr[i];
        tf.text = @"";
        if (i == 0) {
            [tf becomeFirstResponder];
        }
    }
}

#pragma mark  AuthCodeDeleteDelegate 删除输入的值
-(void)authCodeTextFieldDeleteBackward:(AuthCodeTextField *)textField
{   self.codeStr = @"";
    NSInteger lastTag = textField.tag - 1;
    AuthCodeTextField *lastTextField = [self viewWithTag:lastTag];
    [lastTextField becomeFirstResponder];
}

#pragma mark  NSNotificationCenter
-(void)keyboardWillShow:(NSNotification *)notify
{
//    NSDictionary *userInfo = [notify userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    //height 就是键盘的高度
//    int height = keyboardRect.size.height;
//    [_backGround mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.height.mas_equalTo(320);
//        make.bottom.mas_equalTo(-height+10);
//    }];
}

@end

