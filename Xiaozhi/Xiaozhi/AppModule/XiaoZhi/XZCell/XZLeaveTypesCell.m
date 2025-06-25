//
//  XZLeaveTypesCell.m
//  M3
//
//  Created by wujiansheng on 2018/1/8.
//

#import "XZLeaveTypesCell.h"
#import "XZLeaveTypesModel.h"
#import "XZModelButton.h"
@interface XZLeaveTypesCell () {
    NSMutableArray *_buttonArray;
}
@end

@implementation XZLeaveTypesCell
- (void)dealloc {
    SY_RELEASE_SAFELY(_buttonArray);
    [super dealloc];
}

- (void)setup {
    [super setup];
}
- (void)setModel:(XZLeaveTypesModel *)model {
    [super setModel:model];
    if (_buttonArray.count > 0) {
        [self resetSubview:model];
        return;
    }
    if (!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc] init];
    }
    for (NSDictionary *dic in model.showItems) {
        XZModelButton *button = [self buttonWithInfo:dic];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [_buttonArray addObject:button];
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


- (XZModelButton *)buttonWithInfo:(NSDictionary *)dic {
    XZModelButton *button = [XZModelButton buttonWithType:UIButtonTypeCustom];
    NSString *title = [dic objectForKey:@"title"];
    NSString *frame = [dic objectForKey:@"frame"];
    CGRect rect = CGRectFromString(frame);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x006ff1) forState:UIControlStateNormal];
    button.titleLabel.font = FONTSYS(16);
    [button setInfo:title];
    [button setFrame:rect];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.layer.cornerRadius = 12;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1;
    button.layer.borderColor = UIColorFromRGB(0xbedafb).CGColor;
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
