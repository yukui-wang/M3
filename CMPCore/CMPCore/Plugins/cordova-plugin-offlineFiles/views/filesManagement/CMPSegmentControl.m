//
//  CMPSegmentControl.m
//  M3
//
//  Created by MacBook on 2019/10/11.
//

#import "CMPSegmentControl.h"
#import <CMPLib/UIColor+Hex.h>
#import <CMPLib/CMPThemeManager.h>
@interface CMPSegmentedControl()

/* 选中的按钮 */
@property (weak, nonatomic) UIButton *selectedBtn;

/* 点击方法的target */
@property (weak, nonatomic) id clickTarget;
/* 点击方法的sel */
@property (assign, nonatomic) SEL clickSelector;
@end

@implementation CMPSegmentedControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)segmentedWithFrame:(CGRect)frame titles:(NSArray<NSString *>*)titles {
    return [[CMPSegmentedControl alloc] initWithFrame:frame titles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles {
    if (self = [self initWithFrame:frame]) {
        NSInteger count = titles.count;
        CGFloat width = self.frame.size.width/count;
        CGFloat height = self.frame.size.height;
        CGFloat x = 0;
        CGFloat y = 0;
        for (NSInteger i = 0; i < count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            x = i*width;
            btn.frame = CGRectMake(x, y, width, height);
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor cmp_colorWithName:@"theme-bgc"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [btn setBackgroundColor: [UIColor whiteColor]];
            btn.tag = i;
            btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (0 == i) {
                btn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
                btn.selected = YES;
                self.selectedBtn = btn;
            }
            [self addSubview:btn];
        }
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height/2.f;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor cmp_colorWithName:@"theme-bgc"].CGColor;
    }
    return self;
}


- (void)btnClicked:(UIButton *)sender {
    if (_selectedBtn.tag == sender.tag) return;
    
    _selectedBtn.selected = NO;
    _selectedBtn.backgroundColor = [UIColor whiteColor];
    _selectedBtn = sender;
    _selectedBtn.backgroundColor = [UIColor cmp_colorWithName:@"theme-bgc"];
    _selectedBtn.selected = YES;
    if (_clickTarget) {
        [_clickTarget performSelector:_clickSelector withObject:sender];
    }
}

- (void)addValueChangedEventWithTarget:(id)target action:(SEL)action {
    _clickTarget = target;
    _clickSelector = action;
}

- (void)selectIndex:(NSInteger)index {
    if (index > self.subviews.count) return;
    
    UIButton *btn = self.subviews[index];
    [self btnClicked:btn];
}

- (void)disableBtnWithIndex:(int)index disable:(BOOL)disable {
    NSInteger count = self.subviews.count;
    if (index >= count) return;
    
    UIButton *btn = self.subviews[index];
    btn.enabled = !disable;
}

@end
