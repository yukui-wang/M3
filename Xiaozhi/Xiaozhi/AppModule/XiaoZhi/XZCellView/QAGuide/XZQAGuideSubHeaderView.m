//
//  XZQAGuideSubHeaderView.m
//  M3
//
//  Created by wujiansheng on 2018/11/16.
//

#import "XZQAGuideSubHeaderView.h"

@implementation XZQAGuideSubHeaderView

- (void)dealloc {
    self.showTipsDetailBlock = nil;
    SY_RELEASE_SAFELY(_pointView);
    SY_RELEASE_SAFELY(_titleLabel);
    SY_RELEASE_SAFELY(_tips);
    [super dealloc];
}

- (void)setup {
    if (!_pointView) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _pointView.backgroundColor = UIColorFromRGB(0xe4e4e4);
        _pointView.layer.cornerRadius = 4;
        [self addSubview:_pointView];
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FONTSYS(16);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColorFromRGB(0x33333);
        [self addSubview:_titleLabel];
    }
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setTitle:@"[更多]" forState:UIControlStateNormal];
        [_moreBtn setTitleColor:UIColorFromRGB(0x7f8eb4) forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = FONTSYS(12);
        [_moreBtn addTarget:self action:@selector(cluckMore) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreBtn];
    }
}

- (void)customLayoutSubviews {
    [_pointView setFrame:CGRectMake(0, self.height/2-4, 8, 8)];
    [_titleLabel setFrame:CGRectMake(_pointView.originX+18, 0, self.width-8-40-(_pointView.originX+18), self.height)];
    [_moreBtn setFrame:CGRectMake(self.width-8-40, 0, 40, self.height)];
}

- (void)setTips:(XZQAGuideTips *)tips {
    SY_RELEASE_SAFELY(_tips);
    _tips = [tips retain];
    _titleLabel.text = tips.tipsSetName;
}
- (void)cluckMore {
    if (self.showTipsDetailBlock) {
        self.showTipsDetailBlock(self.tips);
    }
}

@end
