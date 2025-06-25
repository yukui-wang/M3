//
//  SyBaseTableViewCellSelectView.m
//  M1Core
//
//  Created by wujiansheng on 15/3/9.
//
//

#import "SyBaseTableViewCellSelectView.h"
@interface SyBaseTableViewCellSelectView ()
{
    UIView *_topLineView;
    UIView *_downLineView;
}
@end
@implementation SyBaseTableViewCellSelectView
@synthesize lineLeftMargin = _lineLeftMargin;
@synthesize lineRightMargin = _lineRightMargin;
@synthesize lineHeight = _lineHeight;
- (void)dealloc
{
    SY_RELEASE_SAFELY(_topLineView);
    SY_RELEASE_SAFELY(_downLineView);
    [super dealloc];
}
- (void)setup
{
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        [self addSubview:_topLineView];
    }
    if (!_downLineView) {
        _downLineView = [[UIView alloc] init];
        [self addSubview:_downLineView];
    }
}

- (void)setupLineColor:(UIColor *)lineColor
{
    _topLineView.backgroundColor = lineColor;
    _downLineView.backgroundColor = lineColor;
}

- (void)hideSeparatorLineView:(BOOL)hide
{
    _topLineView.hidden = YES;
    _downLineView.hidden = YES;
}

- (void)customLayoutSubviews
{
    [_topLineView setFrame:CGRectMake(_lineLeftMargin, 0, self.width-_lineLeftMargin-_lineRightMargin, _lineHeight)];
    [_downLineView setFrame:CGRectMake(_lineLeftMargin, self.height-_lineHeight, self.width-_lineLeftMargin-_lineRightMargin, _lineHeight)];

}

@end
