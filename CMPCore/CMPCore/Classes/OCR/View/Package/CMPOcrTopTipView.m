//
//  CMPOcrTopTipView.m
//  M3
//
//  Created by Shoujian Rao on 2021/12/21.
//

#import "CMPOcrTopTipView.h"

@interface CMPOcrTopTipView()


@end

@implementation CMPOcrTopTipView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColorFromRGB(0xFFC4C4) colorWithAlphaComponent:1];
        self.tag = 100201;
    }
    return self;
}

- (void)showTip:(NSString *)tip{
    UILabel *tipLabel = UILabel.new;
    tipLabel.text = tip;
    tipLabel.numberOfLines = 2;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor cmp_specColorWithName:@"hl-bgc3"];
    tipLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(44);
        make.right.mas_equalTo(-44);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithImageName:@"familyApplyClose"];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(44);
    }];
    [closeBtn addTarget:self action:@selector(closeTipView) forControlEvents:(UIControlEventTouchUpInside)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self closeTipView];
    });

}

+ (void)removeLastTipFromView:(UIView *)fromView{
    [fromView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 100201) {
            [obj removeFromSuperview];
            *stop = YES;
        }
    }];
}

- (void)closeTipView{
    [self removeFromSuperview];
}

@end
