//
//  XZShortHandTextView.m
//  M3
//
//  Created by wujiansheng on 2019/1/12.
//

//参考 https://www.jianshu.com/p/c26893bd0f48

#import "XZShortHandTextView.h"
#import <CMPLib/CMPConstant.h>

@interface XZShortHandTextView ()  {
    UIView *_cursorView;
    BOOL _animated;
}
@end

@implementation XZShortHandTextView

- (void)dealloc {
    [self stopAnimation];
    SY_RELEASE_SAFELY(_cursorView);
    [super dealloc];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    CGRect f = _cursorView.frame;
    f.size.height = font.lineHeight;
    _cursorView.frame = f;
}
- (BOOL)becomeFirstResponder {
    [self stopAnimation];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [self showCursorView];
    return [super resignFirstResponder];
}
- (void)showCursorView  {
    if (!_cursorView) {
        _cursorView = [[UIView alloc] init];
        _cursorView.backgroundColor = UIColorFromRGB(0x366CEE);
        [self addSubview:_cursorView];
    }
    NSRange characterRange = NSMakeRange(self.text.length, 0);
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    CGRect r =  [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
    [_cursorView setFrame:CGRectMake(CGRectGetMaxX(r), r.origin.y+self.textContainerInset.top, 2, self.font.lineHeight)];
    [self beginAnimation];
}

- (void)beginAnimation {
    if (_animated) {
        return;
    }
    _cursorView.hidden = NO;
    _animated = YES;
    [self animation];
}
- (void)stopAnimation {
    _animated = NO;
    _cursorView.hidden = YES;
}


- (void)animation {
    if (!_cursorView) {
        _animated = NO;
    }
    __weak typeof(self) weakSelf = self;
    if (_animated ) {
        [UIView animateWithDuration:0.5 animations:^{
            if (_animated) {
                _cursorView.alpha = 0;
            }
            NSLog(@"[XZShortHandTextView] animation 1");
        } completion:^(BOOL finished) {
            if (_animated) {
                [UIView animateWithDuration:0.5 animations:^{
                    if (_animated) {
                        _cursorView.alpha = 1;
                    }
                } completion:^(BOOL finished) {
                    if (_animated) {
                        [weakSelf animation];
                    }
                    NSLog(@"[XZShortHandTextView] animation 2");
                }];
            }
        }];
    }
}


@end
