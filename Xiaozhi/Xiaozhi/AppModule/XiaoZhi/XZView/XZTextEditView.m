//
//  XZTextEditView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZTextEditView.h"
#import "XZCore.h"
#import "SPTools.h"

@interface XZTextEditView ()<UITextViewDelegate> {
    CGFloat _edgeTop;
    UIView *_line;
}
@end
@implementation XZTextEditView

- (void)dealloc {
    self.speakButton = nil;
    self.textView = nil;
    self.placeholderLabel = nil;
}

- (void)setup {
    if (!_line) {
        _line = [[UIView alloc] init];
        [self addSubview:_line];
        _line.backgroundColor = UIColorFromRGB(0xeeeeee);
    }
    _edgeTop = (kDefaultTextEditHeight -20-FONTSYS(16).lineHeight)/2;
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = FONTSYS(16);
        _textView.textContainerInset = UIEdgeInsetsMake(_edgeTop,10, _edgeTop, 10);
        _textView.layer.cornerRadius = 4;
        _textView.backgroundColor = UIColorFromRGB(0xf5f5f5);
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.delegate = self;
        _textView.textColor = [UIColor blackColor];
        [self addSubview:_textView];
    }
    
    if (!_placeholderLabel) {
        _placeholderLabel= [[UILabel alloc] init];
        _placeholderLabel.text = @"在这里输入想说的话...";
        _placeholderLabel.font = FONTSYS(16);
        _placeholderLabel.textColor = UIColorFromRGB(0xcecece);
        _placeholderLabel.numberOfLines = 0;
        [_placeholderLabel sizeToFit];
        [self addSubview:_placeholderLabel];
    }
    if (!self.speakButton) {
        self.speakButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.speakButton setImage:XZ_IMAGE(@"xz_speakbtn_s.png") forState:UIControlStateNormal];
        [self addSubview:self.speakButton];
    }
    self.backgroundColor = [UIColor whiteColor];
}

- (void)customLayoutSubviews
{
    [_line setFrame:CGRectMake(0, 0, self.width, 0.5)];
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    CGFloat x = 15+edgeInsets.left;
    [_speakButton setFrame:CGRectMake(x, self.height/2-16.5, 33, 33)];
    x += _speakButton.width+10;
    [_textView setFrame:CGRectMake(x, 10, self.width-x-20-edgeInsets.left, self.height-20)];
    [_placeholderLabel setFrame:CGRectMake(x+15, _textView.originY, 200, _textView.height)];
}

- (void)clickSend{
    NSString *result = [_textView.text deleteBothSidesWhitespaces];
    if (!result || result.length == 0) {
        _textView.text = @"";
        [self textViewDidChange:_textView];
        return;
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(textEditView:finishInputText:)]) {
        [self.delegate textEditView:self finishInputText:result];
    }
    if (self.viewDelegate &&[self.viewDelegate respondsToSelector:@selector(textEditViewFinishInputText:)]) {
        [self.viewDelegate textEditViewFinishInputText:result];
    }
    _textView.text = nil;
    [self textViewDidChange:_textView];
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
        NSString *string = [NSString stringWithFormat:@"对不起，你录入的标题已超出%ld字", (long)textLimit];
        if (_delegate && [_delegate respondsToSelector:@selector(view:needShowMessage:)]) {
            [_delegate view:self needShowMessage:string];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _placeholderLabel.hidden = textView.text.length > 0;
    CGSize s = [textView sizeThatFits:CGSizeMake(textView.width, MAXFLOAT)];
    CGFloat max = FONTSYS(16).lineHeight*4+_edgeTop*2;
    s.height = s.height > max ? max : s.height;
    CGRect f = textView.frame;
    if (f.size.height != s.height) {
        //textview change frame
        CGFloat maxY = CGRectGetMaxY(f);
        textView.frame = CGRectMake(f.origin.x, maxY-s.height, f.size.width, s.height);
        textView.textContainerInset = UIEdgeInsetsMake(_edgeTop,10, _edgeTop, 10);
        [textView scrollRangeToVisible: NSMakeRange(textView.text.length-1, 1)];
        //self chang frame
        f = self.frame;
        maxY = CGRectGetMaxY(f);
        s.height += 20;//20 is textview margin
        self.frame = CGRectMake(f.origin.x, maxY-s.height, f.size.width, s.height);
        UIView *supperView = [self superview];
        if ([supperView isKindOfClass:[CMPBaseView class]]) {
            [(CMPBaseView *)supperView customLayoutSubviews];
        }
    }
}

- (void)showText:(NSString *)text {
    _textView.text = text;
    [self textViewDidChange:_textView];
}

- (void)showKeyboard {
    [_textView becomeFirstResponder];
}

- (void)hideKeyboard {
    [_textView resignFirstResponder];
}

- (void)clearInput {
    _textView.text = @"";
    [self textViewDidChange:_textView];
}

@end
