//
//  XZQAGuideSubFooterView.m
//  M3
//
//  Created by wujiansheng on 2018/11/19.
//

#import "XZQAGuideSubFooterView.h"

@implementation XZQAGuideSubFooterView

- (void)dealloc {
    SY_RELEASE_SAFELY(_lineView);
    [super dealloc];
}
- (void)setup {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xe4e4e4);
        [self addSubview:_lineView];
    }
    self.backgroundColor = [UIColor clearColor];
}

- (void)customLayoutSubviews {
    [_lineView setFrame:CGRectMake(0, self.height/2, self.width, 0.5)];
}
@end
