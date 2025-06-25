//
//  XZBottomView.m
//  M3
//
//  Created by wujiansheng on 2017/11/3.
//

#import "XZBottomView.h"
#import "SPTools.h"

@implementation XZBottomView
- (void)dealloc
{
    self.keyboardButton = nil;
    self.helpButton = nil;
    [super dealloc];
}

- (void)setup
{
    if (!_line) {
        _line = [[UIView alloc] init];
        [self addSubview:_line];
        _line.backgroundColor = UIColorFromRGB(0xeeeeee);
    }
    if (!self.keyboardButton) {
        self.keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.keyboardButton setImage:XZ_IMAGE(@"xz_keyboard_p.png") forState:UIControlStateNormal];
        [self addSubview:self.keyboardButton];
    }
    if (!self.helpButton) {
        self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.helpButton setImage:XZ_IMAGE(@"xz_help.png") forState:UIControlStateNormal];
        [self addSubview:self.helpButton];
    }
    self.backgroundColor = [UIColor whiteColor];
}

- (void)customLayoutSubviews
{
    [_line setFrame:CGRectMake(0, 0, self.width, 0.5)];
    UIEdgeInsets  edgeInsets = [SPTools xzSafeAreaInsets];
    [_keyboardButton setFrame:CGRectMake(17+edgeInsets.left, self.height-33-10, 33, 33)];
    [_helpButton setFrame:CGRectMake(self.width-17-33-edgeInsets.right, _keyboardButton.originY, 33, 33)];
}


@end
