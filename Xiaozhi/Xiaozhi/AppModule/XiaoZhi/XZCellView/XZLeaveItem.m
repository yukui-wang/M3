//
//  XZLeaveTextItem.m
//  M3
//
//  Created by wujiansheng on 2018/1/2.
//

#import "XZLeaveItem.h"

@interface XZLeaveItem () {
    UILabel *_targetLable;
    UILabel *_valueLable;
}
@end


@implementation XZLeaveItem

- (void)setup {
    if (!_targetLable) {
        _targetLable = [[UILabel alloc] init];
        _targetLable.font = FONTSYS(16);
        _targetLable.textColor = UIColorFromRGB(0x4a4a4a);
        [self addSubview:_targetLable];
    }
    if (!_valueLable) {
        _valueLable = [[UILabel alloc] init];
        _valueLable.font = FONTSYS(16);
        _valueLable.textColor = [UIColor blackColor];
        _valueLable.numberOfLines = 0;
        [self addSubview:_valueLable];
    }
}

- (void)customLayoutSubviews {
    NSInteger height = _targetLable.font.lineHeight+1;
    [_targetLable setFrame:CGRectMake(24, 0, 96, height)];
    [_valueLable setFrame:CGRectMake(120, 0, self.width-125,self.height)];
}

- (void)showTarget:(NSString *)target value:(id)value valueLineBreakMode:(NSLineBreakMode)mode {
    _targetLable.text = target;
    if ([value isKindOfClass:[NSString class]]) {
        _valueLable.text = value;
        _valueLable.lineBreakMode = mode;
    }
    else {
        _valueLable.attributedText = value;
    }
}

@end
