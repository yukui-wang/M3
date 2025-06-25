//
//  XZMsgCellHeaderView.m
//  M3
//
//  Created by wujiansheng on 2018/9/14.
//

#import "XZMsgCellHeaderView.h"

@implementation XZMsgCellHeaderView
- (void)dealloc {
    SY_RELEASE_SAFELY(_numberLabel)
    SY_RELEASE_SAFELY(_typeLabel)

    [super dealloc];
}
- (id)initWithMsg:(XZScheduleMsgItem *)msg {
    if (self = [super init]) {
        _numberLabel.textColor = msg.color;
        _numberLabel.text = [NSString stringWithInt:msg.items.count];
        _typeLabel.text = msg.showInfo;
    }
    return self;
}

- (void)setup {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        [_numberLabel setBackgroundColor:[UIColor clearColor]];
        [_numberLabel setFont:FONTSYS(36)];
        [self addSubview:_numberLabel];
    }
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        [_typeLabel setBackgroundColor:[UIColor clearColor]];
        [_typeLabel setTextColor:UIColorFromRGB(0x666666)];
        [_typeLabel setFont:FONTSYS(14)];
        [self addSubview:_typeLabel];
    }
    self.backgroundColor = [UIColor whiteColor];
    
//    self.backgroundColor = [UIColor yellowColor];
//    _numberLabel.backgroundColor = [UIColor redColor];
//    _typeLabel.backgroundColor = [UIColor blueColor];

}

- (void)customLayoutSubviews {
    CGSize s = [_numberLabel.text sizeWithFontSize:_numberLabel.font defaultSize:CGSizeMake(1000, 50)];
    NSInteger width = s.width+1;
    [_numberLabel setFrame:CGRectMake(20, 0, width, _numberLabel.font.lineHeight)];
    NSInteger height = _typeLabel.font.lineHeight+1;
    [_typeLabel setFrame:CGRectMake(CGRectGetMaxX(_numberLabel.frame)+4, CGRectGetMaxY(_numberLabel.frame)-height-5, 100, height)];
}

+ (CGFloat)cellHeight {
    NSInteger h = FONTSYS(36).lineHeight+1;//底部+10
    return h;
}
@end
