//
//  XZLeaveTypesView.m
//  Xiaozhi
//
//  Created by wujiansheng on 2019/6/11.
//  Copyright © 2019 wujiansheng. All rights reserved.
//

#import "XZLeaveTypesView.h"
#import "XZModelButton.h"
@interface XZLeaveTypesView () {
    NSMutableArray *_buttonArray;
}
@property(nonatomic, strong)XZLeaveTypesModel *model;

@end

@implementation XZLeaveTypesView


- (void)setupWithModel:(XZLeaveTypesModel *)model {
    self.model = model;
    if (_buttonArray.count > 0) {
        [self resetSubview:model];
        return;
    }
    if (!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc] init];
    }
    CGFloat x = 14;
    CGFloat y = 0;
    for (NSString *title in model.leaveTypes) {
        XZModelButton *button = [self buttonWithTitle:title x:x y:y];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [_buttonArray addObject:button];
        x = CGRectGetMaxX(button.frame)+10;
        y = button.originY;
    }
}

- (void)resetSubview:(XZLeaveTypesModel *)model {
    for (XZModelButton *button in _buttonArray) {
        NSString *info = (NSString *)button.info;
        UIColor *bkColor = model.canOperate?[UIColor whiteColor]:UIColorFromRGB(0xe4e4e4);
        UIColor *borderColor = model.canOperate?UIColorFromRGB(0xbedafb):UIColorFromRGB(0xe4e4e4);
        UIColor *titleColor = model.canOperate?UIColorFromRGB(0x006ff1):([info isEqualToString:model.selectType]?UIColorFromRGB(0x4a4a4a):UIColorFromRGB(0x9b9b9b));
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        button.layer.borderColor = borderColor.CGColor;
        [button setBackgroundColor:bkColor];
        button.userInteractionEnabled = model.canOperate;
    }
}


- (XZModelButton *)buttonWithTitle:(NSString *)title x:(CGFloat)x y:(CGFloat)y {
    XZModelButton *button = [XZModelButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    CGSize s = [button.titleLabel sizeThatFits:CGSizeMake(100, 30)];
    NSInteger width = s.width+24;
    if (x+width > self.width) {
        x = 14;
        y += 30+10;
    }
    CGRect rect = CGRectMake(x, y, width, 30);
    button.titleLabel.font = FONTSYS(14);
    [button setInfo:title];
    [button setFrame:rect];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 15;
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    return button;
}

- (void)clickButton:(XZModelButton *)sender {
    XZLeaveTypesModel *model = (XZLeaveTypesModel *)self.model;
    if (model.canOperate) {
        NSString *type = (NSString *)sender.info;
        model.selectType = type;
        model.canOperate = NO;
        if (model.clickTypeBlock) {
            model.clickTypeBlock(type);
        }
        [self resetSubview:model];
    }
}
@end
