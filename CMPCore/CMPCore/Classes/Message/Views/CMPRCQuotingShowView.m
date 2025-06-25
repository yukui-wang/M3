//
//  CMPRCQuotingShowView.m
//  M3
//
//  Created by Kaku Songu on 4/21/21.
//

#import "CMPRCQuotingShowView.h"
#import <CMPLib/Masonry.h>

@interface CMPRCQuotingShowView()

@end

@implementation CMPRCQuotingShowView

-(void)setup
{
    [super setup];
    
    self.backgroundColor = [UIColor cmp_colorWithName:@"white-bg"];
    
    _funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _funcBtn.backgroundColor = [UIColor clearColor];
    [_funcBtn setImage:IMAGE(@"msg_quote_close") forState:UIControlStateNormal];
    [self addSubview:_funcBtn];
    [_funcBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-14);
        make.centerY.offset(0);
        make.size.mas_equalTo(CGSizeMake(11, 11));
    }];
    
    _showLb = [[KSLabel alloc] init];
    _showLb.font = [UIFont systemFontOfSize:12];
    _showLb.textAlignment = NSTextAlignmentLeft;
    _showLb.textColor = [UIColor cmp_colorWithName:@"desc-fc"];
    _showLb.numberOfLines = 1;
    [_showLb sizeToFit];
    [self addSubview:_showLb];
    [_showLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(13);
        make.top.offset(6);
        make.bottom.offset(-6);
        make.right.equalTo(_funcBtn.mas_left).offset(-13);
        make.height.greaterThanOrEqualTo(@20);
    }];
}

@end
