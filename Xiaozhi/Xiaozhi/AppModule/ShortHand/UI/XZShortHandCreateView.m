//
//  XZShortHandCreateView.m
//  M3
//
//  Created by wujiansheng on 2019/1/7.
//

#import "XZShortHandCreateView.h"
#import "XZRecorderWave.h"
#import "XZShortHandBar.h"
#import "XZShortHandTextView.h"
@interface XZShortHandCreateView()<UITextViewDelegate> {
    XZRippleView *_rippleView;
    XZShortHandBar *_toolBar;
}

@end

@implementation XZShortHandCreateView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.titleView = nil;
    [self.contentView stopAnimation];
    self.contentView = nil;
    self.speakButton = nil;
    SY_RELEASE_SAFELY(_rippleView);
    SY_RELEASE_SAFELY(_toolBar);
    [super dealloc];
}

- (void)setup {
    if (!_titleView) {
        _titleView = [[UITextField alloc] init];
        _titleView.font = FONTSYS(18);
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"标题" attributes:[NSDictionary dictionaryWithObjectsAndKeys:FONTSYS(18),NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName, nil]];
        _titleView.attributedPlaceholder = str;
        SY_RELEASE_SAFELY(str);

        [self addSubview:_titleView];
    }
    if (!_contentView) {
        _contentView = [[XZShortHandTextView alloc] init];
        _contentView.font = FONTSYS(16);
        _contentView.delegate = self;
        [self addSubview:_contentView];
    }
    if (!self.speakButton) {
        self.speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.speakButton setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_def.png"] forState:UIControlStateNormal];
        [self.speakButton setImage:[UIImage imageNamed:@"XZbundle.bundle/xz_speakbtn_pre.png"] forState:UIControlStateSelected];
        [self addSubview:self.speakButton];
    }
    self.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)showWaveView:(id)delegate{
    self.speakButton.hidden = YES;
    if (!_rippleView) {
        _rippleView = [[XZRippleView alloc] initWithFrame:CGRectMake(self.width/2-40, self.height-20-80, 80, 80)];
        [self addSubview:_rippleView];
        _rippleView.delegate = delegate;
        _rippleView.center = self.speakButton.center;
    }
    [_rippleView show];
    [self customLayoutSubviews];
}

- (void)hideWaveView {
    self.speakButton.hidden = NO;
    _rippleView.hidden = YES;
    [_rippleView removeFromSuperview];
    SY_RELEASE_SAFELY(_rippleView);
}

- (void)customLayoutSubviews {
    [_titleView setFrame:CGRectMake(15, 0, self.width-30, 40)];
    [_contentView setFrame:CGRectMake(15, _titleView.height, self.width-30, 400-_titleView.height)];
    [self.speakButton setFrame:CGRectMake(self.width/2-30, self.height-20-80, 60, 60)];
 }

- (void)keyboardWillShow:(NSNotification *)not {
    if (!_toolBar) {
        _toolBar = [[XZShortHandBar alloc] initWithFrame:CGRectMake(0,self.height, self.width, 50)];
        [self addSubview:_toolBar];
        [_toolBar.voiceBtn addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
      
        [_toolBar.fontBtn addTarget:self action:@selector(fontBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.boldBtn addTarget:self action:@selector(boldBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.italicBtn addTarget:self action:@selector(italicBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.pointBtn addTarget:self action:@selector(pointBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.numberBtn addTarget:self action:@selector(numberBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.replaceBtn addTarget:self action:@selector(replaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [_toolBar setFrame:CGRectMake(0,self.height, self.width, 50)];
    CGRect keyboardRect = [[[not userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyboardRect.size.height == 0) {
        return;
    }
    CGFloat aCurve = [[[not userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[[not userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationDelegate:self];
    [_toolBar setFrame:CGRectMake(0,self.height-keyboardRect.size.height-50, self.width, 50)];
    [UIView commitAnimations];
    
}
- (void)keyboardWillHide:(NSNotification *)not {
    CGFloat aCurve = [[[not userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat aDuration = [[[not userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:aCurve];
    [UIView setAnimationDuration:aDuration];
    [UIView setAnimationDelegate:self];
    [_toolBar setFrame:CGRectMake(0,self.height, self.width, 50)];
    [UIView commitAnimations];
}
- (void)hideKeyboard {
    //    if ([_titleView canResignFirstResponder]) {
    //        [_titleView resignFirstResponder];
    //        _titleView.inputView = [[UIView alloc]initWithFrame:CGRectZero];
    //    }
    if ([_contentView canResignFirstResponder]) {
        [_contentView resignFirstResponder];
//        _contentView.inputView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
//        _contentView.inputAccessoryView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
//        [_contentView reloadInputViews];
//        if (IOS9_Later) {
//            UITextInputAssistantItem* item = [_contentView inputAssistantItem];
//            item.leadingBarButtonGroups = @[];
//            item.trailingBarButtonGroups = @[];
//        }
       
    }
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    _contentView.inputView = nil;
//    _contentView.inputAccessoryView = nil;

    return YES;
}

//https://www.jianshu.com/p/c26893bd0f48



- (NSRange)contentTextViewSelectRange {
    return _contentView.selectedRange;
    NSLog(@"length = %ld  select = %@",_contentView.text.length,NSStringFromRange(_contentView.selectedRange));
    NSString *str = _contentView.text;
    NSRange r = NSMakeRange(1, 0);
    NSInteger start = 0;
    [str enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {

    }];
    
}
- (void)fontBtnClick {
    NSMutableAttributedString *attString =  [[NSMutableAttributedString alloc] initWithAttributedString:_contentView.attributedText] ;
    [attString addAttribute:NSFontAttributeName value:FONTSYS(18) range:[self contentTextViewSelectRange]];
    
    _contentView.attributedText = attString;
    SY_RELEASE_SAFELY(attString);
    
}

- (void)boldBtnClick {
    NSMutableAttributedString *attString =  [[NSMutableAttributedString alloc] initWithAttributedString:_contentView.attributedText] ;
    [attString addAttribute:NSFontAttributeName value:FONTBOLDSYS(18) range:[self contentTextViewSelectRange]];
    _contentView.attributedText = attString;
    SY_RELEASE_SAFELY(attString);

}

- (void)italicBtnClick {
    //斜体
    NSMutableAttributedString *attString =  [[NSMutableAttributedString alloc] initWithAttributedString:_contentView.attributedText] ;
    [attString addAttribute:NSObliquenessAttributeName value:@1 range:[self contentTextViewSelectRange]];
    
    _contentView.attributedText = attString;
    SY_RELEASE_SAFELY(attString);

}

- (void)pointBtnClick {
    
}

- (void)numberBtnClick {
}

- (void)replaceBtnClick {
    
}


@end
