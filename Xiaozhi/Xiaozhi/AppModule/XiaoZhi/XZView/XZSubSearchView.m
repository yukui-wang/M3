//
//  XZSubSearchView.m
//  M3
//
//  Created by wujiansheng on 2017/11/13.
//

#import "XZSubSearchView.h"
@interface XZSubSearchView () {
    NSMutableArray *_buttonList;
}
@end;

@implementation XZSubSearchView
- (void)dealloc {
    SY_RELEASE_SAFELY(_buttonList);
    [super dealloc];
}
- (void)setup
{
    if (!_buttonList) {
        _buttonList = [[NSMutableArray alloc] init];
    }
    NSArray *titleList = [NSArray arrayWithObjects:@"查文档",@"查公告",@"查协同",@"查人员", nil];
    for (NSString *title in titleList) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        button.titleLabel.font = FONTSYS(14);
        button.layer.cornerRadius = 12;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor whiteColor];
        button.layer.borderWidth = 1;
        button.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
        [self addSubview:button];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonList addObject:button];
    }
    [self showAnimations];
}

- (void)showAnimations {
    [self layoutSubviewsWithOriginX:self.width];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self layoutSubviewsWithOriginX:0];
    [UIView commitAnimations];
}
- (void)layoutSubviewsWithOriginX:(CGFloat)orgx {
    CGFloat x = 12 +orgx;
    for (UIButton *button in _buttonList) {
        [button setFrame:CGRectMake(x, 10, 62, 30)];
        x += button.width+9;
    }
}

- (void)buttonClick:(UIButton *)sender{
    NSString *title = sender.titleLabel.text;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(subSearchView:clickText:)]) {
        [self.delegate subSearchView:self clickText:title];
    }
    if (self.viewDelegate &&[self.viewDelegate respondsToSelector:@selector(subSearchViewClickText:)]) {
        [self.viewDelegate subSearchViewClickText:title];
    }
}
@end
