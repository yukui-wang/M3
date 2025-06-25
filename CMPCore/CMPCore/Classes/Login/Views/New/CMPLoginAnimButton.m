//
//  CMPLoginAnimButton.m
//  M3
//
//  Created by MacBook on 2020/1/6.
//

#import "CMPLoginAnimButton.h"
#import <CMPLib/MSWeakTimer.h>

@interface CMPLoginAnimButton()
{
    MSWeakTimer *_weakTimer;
    NSInteger _textIndex;
    NSInteger _count;
    NSString *_animString;
    UIFont *_titleFont;
}

@end

@implementation CMPLoginAnimButton

- (void)startAnimation {
    [self validateTimer];
}

- (void)stopAnimation {
    [self invalidateTimer];
}

#pragma mark - timer相关

- (void)validateTimer {
    _textIndex = 0;
    _count = 3;
    if (!_animString) {
        _animString = [[self titleForState:UIControlStateDisabled] stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    
    _titleFont = self.titleLabel.font;
    if (_animString.length) {
        _weakTimer = [MSWeakTimer scheduledTimerWithTimeInterval:0.45f target:self selector:@selector(textJumpAnim) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [_weakTimer fire];
    }
}

- (void)invalidateTimer {
    [_weakTimer invalidate];
    _weakTimer = nil;
}

- (void)textJumpAnim {
    NSInteger index = _textIndex % _count + 1;
    NSInteger index1 = _count - index;
    
    NSString *title = _animString;
    for (NSInteger i = 0; i < index; i++) {
        if (0 == i) {
            title = [title stringByAppendingString:@" "];
        }
        title = [title stringByAppendingString:@"."];
    }
    
    for (NSInteger i = 0; i < index1; i++) {
        title = [title stringByAppendingString:@" "];
    }
    
    [self setTitle:title forState:UIControlStateDisabled];
    
    _textIndex++;
    
}



@end
