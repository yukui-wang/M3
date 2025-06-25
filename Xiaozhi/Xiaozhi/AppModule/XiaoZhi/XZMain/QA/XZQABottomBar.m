//
//  XZQABottomBar.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/12/9.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZQABottomBar.h"
#import "XZCore.h"
#import "XZSpeechWave.h"

@interface XZQABottomBar ()<UITextViewDelegate> {
    UILabel *_placeholderLabel;
    CGFloat _textEdgeTop;
    CGFloat _viewHeight;

}
@property(nonatomic, strong)UIButton *keyboardBtn;
@property(nonatomic, strong)UIButton *speechBtn;
@property(nonatomic, strong)UITextView *textView;
@property(nonatomic, strong)UIButton *beginSpeechBtn;
@property(nonatomic, strong)XZSpeechWave *speechWave;

@end

@implementation XZQABottomBar

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    if ([[XZCore sharedInstance] xiaozAvailable]) {
        [self speechBtn];
    }
    else {
        [self keyboardBtn];
    }
   [self textView];
}

- (UIButton *)keyboardBtn {
    if (!_keyboardBtn) {
        _keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_keyboardBtn setImage:XZ_IMAGE(@"xz_qa_keyboard.png") forState:UIControlStateNormal];
        [self addSubview:_keyboardBtn];
        [_keyboardBtn addTarget:self action:@selector(keyboardBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardBtn;
}
- (UIButton *)speechBtn {
   if (!_speechBtn) {
       _speechBtn = [UIButton buttonWithType:UIButtonTypeCustom];
       [_speechBtn setImage:XZ_IMAGE(@"xz_qa_speech.png") forState:UIControlStateNormal];
       [self addSubview:_speechBtn];
       [_speechBtn addTarget:self action:@selector(speechBtnClick) forControlEvents:UIControlEventTouchUpInside];
   }
    return _keyboardBtn;
}
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = FONTSYS(16);
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.delegate = self;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        [self addSubview:_textView];
        if (!_placeholderLabel) {
            _placeholderLabel= [[UILabel alloc] init];
            _placeholderLabel.text = @"请输入问题...";
            _placeholderLabel.font = FONTSYS(16);
            _placeholderLabel.textColor = UIColorFromRGB(0x92A4B5);
            _placeholderLabel.numberOfLines = 0;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            [_placeholderLabel sizeToFit];
            [self addSubview:_placeholderLabel];
        }
        _textEdgeTop = (kQABottomBarHeight- _textView.font.lineHeight)/2;
    }
    return _textView;
}

- (UIButton *)beginSpeechBtn {
    if (!_beginSpeechBtn) {
        _beginSpeechBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beginSpeechBtn setTitle:@"点击说话" forState:UIControlStateNormal];
        [_beginSpeechBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        _beginSpeechBtn.titleLabel.font = FONTSYS(16);
        [self addSubview:_beginSpeechBtn];
        [_beginSpeechBtn addTarget:self action:@selector(beginSpeechBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginSpeechBtn;
}

- (XZSpeechWave *)speechWave {
    if (!_speechWave) {
        _speechWave = [[XZSpeechWave alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:_speechWave];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickWave)];
        [_speechWave addGestureRecognizer:tap];
    }
    return _speechWave;
}

- (CGFloat)viewHeight {
    return MAX(kQABottomBarHeight, _viewHeight);
}

- (void)customLayoutSubviews {
    if (_keyboardBtn) {
        [_keyboardBtn setFrame:CGRectMake(14, self.height/2-15, 30, 30)];
    }
    if (_speechBtn) {
        [_speechBtn setFrame:CGRectMake(14, self.height/2-15, 30, 30)];
    }
    if (_textView) {
        [_textView setFrame:CGRectMake(52, _textEdgeTop, self.width-60, self.height-_textEdgeTop*2)];
        [_placeholderLabel setFrame:CGRectMake(_textView.originX+4, _textView.originY-2, _textView.width, 24)];
    }
    if (_beginSpeechBtn) {
        [_beginSpeechBtn setFrame:CGRectMake(52, 16, self.width-104, 24)];
    }
    if (_speechWave && !_speechWave.hidden) {
        [_speechWave setFrame:CGRectMake(0, 0, self.width, self.height)];
    }
}

- (void)keyboardBtnClick {
     if ([[XZCore sharedInstance] xiaozAvailable]) {
         _textView.text = @"";
         _speechBtn.hidden = NO;
         _placeholderLabel.hidden = NO;
         _textView.hidden = NO;
         _beginSpeechBtn.hidden = YES;
         _keyboardBtn.hidden = YES;
         [self customLayoutSubviews];
     }
     else {
         [_textView becomeFirstResponder];
     }
}

- (void)speechBtnClick {
    _viewHeight = 0;
    if (self.barHeightChangeBlock) {
        self.barHeightChangeBlock();
    }
    self.beginSpeechBtn.hidden = NO;
    self.keyboardBtn.hidden = NO;
    
    [self hideKeyboard];
    
    _speechBtn.hidden = YES;
    _placeholderLabel.hidden = YES;
    _textView.hidden = YES;

    [self customLayoutSubviews];
}

- (void)beginSpeechBtnClick {
    if (self.startRecordingBlock) {
        self.startRecordingBlock();
    }
    [self showWave];
}


- (void)clickWave {
    [self hideWave];
    if (self.stopRecordingBlock) {
        self.stopRecordingBlock();
    }
}
- (void)showWave {
    _keyboardBtn.hidden = YES;
    _speechBtn.hidden = YES;
    _beginSpeechBtn.hidden = YES;
    _placeholderLabel.hidden = YES;
    _textView.hidden = YES;
    CGRect f = self.frame;
    f.origin.y = (f.origin.y + f.size.height -kQABottomBarHeight);
    f.size.height = kQABottomBarHeight;
    self.frame = f;
    [self.speechWave show];
}
- (void)showWaveWithVolume:(NSInteger)volume {
    [_speechWave showWaveWithVolume:volume];
}
- (void)hideWave {
    if (!_speechWave) {
        return;
    }
    _beginSpeechBtn.hidden = NO;
    _keyboardBtn.hidden = NO;
    [_speechWave stop];
    [_speechWave removeFromSuperview];
    _speechWave = nil;
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /*屏蔽表情 start*/
    NSString *primaryLanguage = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if (!primaryLanguage || [primaryLanguage isEqualToString:@"emoji"]) {
        return NO;
    }
    if ([text containsEmoji]) {
        return NO;
    }
    /*屏蔽表情 end*/

    if ([text isEqualToString:@"\n"]) {
        [self clickSend];
        return NO;
    }
    if (text.length == 0) {
        return YES;
    }
    NSInteger length = _textView.text.length-range.length+text.length ;
    NSInteger textLimit = [XZCore sharedInstance].textLenghtLimit;
    if (textLimit > 0 &&length >textLimit) {
        NSInteger max = textLimit- (_textView.text.length-range.length);
        if (text.length >= max) {
            NSString *subString = [text substringToIndex:max];
            _textView.text = [_textView.text stringByReplacingCharactersInRange:range withString:subString];
            [self textViewDidChange:_textView];
        }
//        NSString *string = [NSString stringWithFormat:@"对不起，你录入的标题已超出%ld字", (long)textLimit];
//        if (_delegate && [_delegate respondsToSelector:@selector(view:needShowMessage:)]) {
//            [_delegate view:self needShowMessage:string];
//        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _placeholderLabel.hidden = textView.text.length > 0;
    CGSize s = [textView sizeThatFits:CGSizeMake(textView.width, MAXFLOAT)];
    CGFloat max = textView.font.lineHeight*4;
    CGFloat height = MIN(max, s.height)+_textEdgeTop*2;
    if (height != _viewHeight) {
        _viewHeight = height;
        if (self.barHeightChangeBlock) {
            self.barHeightChangeBlock();
        }
    }
}

- (void)clickSend{
    _viewHeight = 0;
    NSString *result = [_textView.text deleteBothSidesWhitespaces];
    if (!result || result.length == 0) {
        _textView.text = @"";
        [self textViewDidChange:_textView];
        return;
    }
    if (self.inputContentBlock) {
        self.inputContentBlock(result);
    }
    _textView.text = nil;
    [self textViewDidChange:_textView];
}

- (void)editContent:(NSString *)content {
    [self hideWave];
    [self keyboardBtnClick];
    self.textView.text = content;
    [self textViewDidChange:self.textView];
    [self.textView becomeFirstResponder];
}
- (void)hideKeyboard {
    [self.textView resignFirstResponder];
}
@end
